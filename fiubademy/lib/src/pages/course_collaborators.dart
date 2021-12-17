import 'package:fiubademy/src/pages/profile.dart';
import 'package:fiubademy/src/services/user.dart';
import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:provider/provider.dart';

import 'package:fiubademy/src/services/auth.dart';
import 'package:fiubademy/src/services/server.dart';

class CourseCollaboratorsPage extends StatefulWidget {
  final String _courseID;

  const CourseCollaboratorsPage({Key? key, required String courseID})
      : _courseID = courseID,
        super(key: key);

  @override
  _CourseCollaboratorsPageState createState() =>
      _CourseCollaboratorsPageState();
}

class _CourseCollaboratorsPageState extends State<CourseCollaboratorsPage> {
  bool _isLoadingAdd = false;
  bool _isLoadingRemove = false;
  final _newCollaboratorController = TextEditingController();
  final _addCollaboratorFormKey = GlobalKey<FormState>();
  final PagingController<int, User> _pagingController =
      PagingController(firstPageKey: 0);

  @override
  void initState() {
    _pagingController.addPageRequestListener((pageKey) {
      _fetchPage(pageKey);
    });
    super.initState();
  }

  void _fetchPage(int pageKey) async {
    try {
      Auth auth = Provider.of<Auth>(context, listen: false);
      final newItems =
          await Server.getCourseCollaborators(auth, widget._courseID);

      if (newItems['error'] != null) {
        throw Exception('Failed to load collaborators');
      }

      List<String> collaboratorsIDs = List<String>.from(newItems['content']);

      // TODO Can be optimized to make all server calls at once and then wait for them
      List<User> collaborators = [];
      for (final collaboratorID in collaboratorsIDs) {
        final collaboratorData = await Server.getUser(auth, collaboratorID);
        if (collaboratorData == null) {
          throw Exception('Failed to load collaborator');
        }
        User user = User();
        user.updateData(collaboratorData);
        collaborators.add(user);
      }

      // If not mounted, using page controller throws Error.
      if (!mounted) return;

      _pagingController.appendLastPage(collaborators);
    } on Exception catch (error) {
      String errorMessage = error.toString();
      // Show snackbar only if planned error
      if (errorMessage.startsWith('Exception: ')) {
        // Keep only part past 'Exception: '. Yes, it's ugly.
        final snackBar =
            SnackBar(content: Text(error.toString().substring(11)));
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
      if (!mounted) return;
      _pagingController.error = error;
    }
  }

  void _addCollaborator() async {
    setState(() {
      _isLoadingAdd = true;
    });
    FocusScope.of(context).unfocus();
    if (_addCollaboratorFormKey.currentState!.validate()) {
      Auth auth = Provider.of<Auth>(context, listen: false);
      String? result = await Server.addCollaborator(
          auth, _newCollaboratorController.text, widget._courseID);
      if (result == null) {
        _pagingController.refresh();
      } else {
        final snackBar = SnackBar(content: Text(result));
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    }
    setState(() {
      _isLoadingAdd = false;
    });
  }

  void _removeCollaborator(String collaboratorID) async {
    setState(() {
      _isLoadingRemove = true;
    });

    Auth auth = Provider.of<Auth>(context, listen: false);
    String? result =
        await Server.removeCollaborator(auth, collaboratorID, widget._courseID);
    if (result == null) {
      _pagingController.refresh();
    } else {
      final snackBar = SnackBar(content: Text(result));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }

    setState(() {
      _isLoadingRemove = false;
    });
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty || !Server.isValidEmail(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Collaborators')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16.0, 24.0, 16.0, 16.0),
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Text('Add Collaborator',
                    style: Theme.of(context).textTheme.headline6),
              ),
              const SizedBox(height: 16.0),
              Form(
                key: _addCollaboratorFormKey,
                child: TextFormField(
                  validator: (value) => _validateEmail(value),
                  controller: _newCollaboratorController,
                  decoration: const InputDecoration(
                    hintText: 'example@email.com',
                    labelText: 'Email',
                    filled: true,
                  ),
                ),
              ),
              const SizedBox(height: 16.0),
              Align(
                alignment: Alignment.centerRight,
                child: _isLoadingAdd
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                        onPressed: () => _addCollaborator(),
                        child: const Text('ADD'),
                      ),
              ),
              const Divider(),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () => Future.sync(
                    () => _pagingController.refresh(),
                  ),
                  child: PagedListView(
                    pagingController: _pagingController,
                    builderDelegate: PagedChildBuilderDelegate<User>(
                      itemBuilder: (context, item, index) => Card(
                        child: ListTile(
                          title: Text(item.username),
                          subtitle: Text(item.email),
                          trailing: _isLoadingRemove
                              ? const CircularProgressIndicator()
                              : IconButton(
                                  onPressed: () =>
                                      _removeCollaborator(item.userID!),
                                  icon: const Icon(Icons.close_rounded),
                                ),
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        ProfilePage(user: item)));
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _newCollaboratorController.dispose();
    _pagingController.dispose();
    super.dispose();
  }
}
