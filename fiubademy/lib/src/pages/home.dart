import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:fiubademy/src/pages/message_list.dart';
import 'package:fiubademy/src/pages/my_favourites.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

import 'package:fiubademy/src/models/course.dart';

import 'package:fiubademy/src/services/user.dart';
import 'package:fiubademy/src/services/auth.dart';
import 'package:fiubademy/src/services/google_auth.dart';
import 'package:fiubademy/src/services/location.dart';
import 'package:fiubademy/src/services/server.dart';

import 'package:fiubademy/src/pages/profile.dart';
import 'package:fiubademy/src/pages/my_inscriptions.dart';
import 'package:fiubademy/src/pages/my_courses.dart';
import 'package:fiubademy/src/pages/my_collaborations.dart';

import 'package:fiubademy/src/widgets/course_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final ScaffoldMessengerState _scaffoldMessenger;
  late final NavigatorState _navigator;

  @override
  void initState() {
    super.initState();
    FirebaseMessaging.instance.getToken().then((token) {
      if (token == null) return;
      print(token);
      Auth auth = Provider.of<Auth>(context, listen: false);
      print(auth.userID);
      Server.updateFCMToken(auth, token);
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage event) {
      _scaffoldMessenger.showMaterialBanner(
        MaterialBanner(
          content: Text(event.notification!.body!),
          actions: [
            TextButton(
              onPressed: () {
                _scaffoldMessenger.hideCurrentMaterialBanner();
              },
              child: const Text('DISMISS'),
            ),
            TextButton(
              onPressed: () {
                _scaffoldMessenger.hideCurrentMaterialBanner();
                _navigator.popUntil((route) => route.isFirst);
                _navigator.push(
                  MaterialPageRoute(
                    builder: (context) => const MessageListPage(),
                  ),
                );
              },
              child: const Text('GO'),
            ),
          ],
        ),
      );
    });
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      _navigator.popUntil((route) => route.isFirst);
      _navigator.push(
        MaterialPageRoute(
          builder: (context) => const MessageListPage(),
        ),
      );
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _scaffoldMessenger = ScaffoldMessenger.of(context);
    _navigator = Navigator.of(context);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: updateUserLocation(Provider.of<Auth>(context, listen: false),
            Provider.of<User>(context, listen: false)),
        builder: (context, AsyncSnapshot<void> snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              return const Center(
                child: CircularProgressIndicator(),
              );
            default:
              if (snapshot.hasError) {
                return _requestLocation(context);
              }
              return const CourseSearchListView();
          }
        });
  }

  Widget _requestLocation(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ubademy'),
      ),
      body: SafeArea(
        child: Container(
          constraints: const BoxConstraints.expand(),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                Icons.location_off_outlined,
                size: 170,
                color: Theme.of(context).colorScheme.secondaryVariant,
              ),
              const SizedBox(height: 16.0),
              Text(
                'Whoops! It looks like your location isn\'t enabled.',
                style: Theme.of(context).textTheme.headline6,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16.0),
              Text('Please enable Ubademy to access your location to continue',
                  style: Theme.of(context).textTheme.subtitle1,
                  textAlign: TextAlign.center),
              const SizedBox(height: 32.0),
              ElevatedButton(
                onPressed: () async {
                  setState(() {});
                },
                child: const Text('Enable Location'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Widget _buildDrawer(BuildContext context) {
  return Drawer(
    child: Column(
      children: [
        Expanded(
          child: ListView(
            children: [
              UserAccountsDrawerHeader(
                  accountName: Text(Provider.of<User>(context).username),
                  accountEmail: Text(Provider.of<User>(context).email)),
              ListTile(
                leading: const Icon(Icons.account_circle),
                title: const Text('My Profile'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) {
                      return ProfilePage(
                        user: Provider.of<User>(context),
                        isSelf: true,
                      );
                    }),
                  );
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.cases_rounded),
                title: const Text('My Inscriptions'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) {
                      return const MyInscriptionsPage();
                    }),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.school),
                title: const Text('My Courses'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) {
                      return const MyCoursesPage();
                    }),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.supervisor_account),
                title: const Text('My Collaborations'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) {
                      return const MyCollaborationsPage();
                    }),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.favorite),
                title: const Text('My Favourites'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) {
                      return const MyFavouritesPage();
                    }),
                  );
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.message),
                title: const Text('Messages'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MessageListPage(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        const Divider(),
        ListTile(
          onTap: () {
            Provider.of<Auth>(context, listen: false).deleteAuth();
            googleSignIn
                .isSignedIn()
                .then((value) => {if (value) googleSignIn.disconnect()});
          },
          leading: Icon(Icons.logout, color: Colors.red[700]),
          title: Text(
            'Log Out',
            style: TextStyle(
              color: Colors.red[700],
            ),
          ),
        ),
      ],
    ),
  );
}

class CourseSearchListView extends StatefulWidget {
  const CourseSearchListView({Key? key}) : super(key: key);

  @override
  _CourseSearchListViewState createState() => _CourseSearchListViewState();
}

class _CourseSearchListViewState extends State<CourseSearchListView> {
  final int _pageSize = 5;
  final PagingController<int, Course> _pagingController =
      PagingController(firstPageKey: 0);
  final List<String> _categories = Course.categories();
  final List<String> _subscriptions = Course.subscriptionNames();
  String _titleFilter = "";
  String _categoryFilter = 'All Categories';
  String _subscriptionFilter = 'All Subscriptions';

  @override
  void initState() {
    _pagingController.addPageRequestListener((pageKey) {
      _fetchPage(pageKey);
    });
    _categories.insert(0, 'All Categories');
    _subscriptions.insert(0, 'All Subscriptions');

    super.initState();
  }

  Future<void> _fetchPage(int pageKey) async {
    try {
      final newItems = await onLoad(pageKey);

      final isLastPage = newItems.length < _pageSize;
      if (isLastPage) {
        if (!mounted) return;
        _pagingController.appendLastPage(newItems);
      } else {
        final nextPageKey = pageKey + newItems.length;
        if (!mounted) return;
        _pagingController.appendPage(newItems, nextPageKey);
      }
    } on Exception catch (error) {
      String errorMessage = error.toString();
      // Show snackbar only if planned error
      if (errorMessage.startsWith('Exception: ')) {
        // Keep only part past 'Exception: '. Yes, it's ugly.
        final snackBar =
            SnackBar(content: Text(error.toString().substring(11)));
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
      if (!mounted) return;
      _pagingController.error = error;
    }
  }

  Future<List<Course>> onLoad(index) async {
    Auth auth = Provider.of<Auth>(context, listen: false);
    int page = (index ~/ 5) + 1;
    final result = await Server.getCourses(
      auth,
      page,
      title: _titleFilter.isEmpty ? null : _titleFilter,
      category: _categoryFilter == 'All Categories' ? null : _categoryFilter,
      subLevel: Course.subscriptionLevelFromName(_subscriptionFilter),
    );
    if (result['error'] != null) {
      throw Exception(result['error']);
    }

    List<Map<String, dynamic>> coursesData =
        List<Map<String, dynamic>>.from(result['content']);
    Map<String, String> idsToNameMapping = {};
    for (var courseData in coursesData) {
      String ownerID = courseData['ownerId'];
      if (!idsToNameMapping.containsKey(ownerID)) {
        final userQuery = await Server.getUser(auth, ownerID);
        if (userQuery == null) {
          throw Exception(result['Failed to fetch user data']);
        }
        idsToNameMapping[ownerID] = userQuery['username'];
      }
      courseData['ownerName'] = idsToNameMapping[ownerID];

      // Order is by speed and then probability
      if (ownerID == auth.userID) {
        courseData['role'] = CourseRole.owner;
      } else if (await Server.isEnrolled(auth, courseData['id'])) {
        courseData['role'] = CourseRole.student;
      } else if (await Server.isCollaborator(auth, courseData['id'])) {
        courseData['role'] = CourseRole.collaborator;
      } else {
        courseData['role'] = CourseRole.notStudent;
      }

      if (await Server.isFavourite(auth, courseData['id'])) {
        courseData['isFavourite'] = true;
      } else {
        courseData['isFavourite'] = false;
      }
    }

    List<Course> courses = List.generate(
        coursesData.length, (index) => Course.fromMap(coursesData[index]));
    return Future<List<Course>>.value(courses);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SearchAppBar(
        onSubmitted: (value) {
          setState(() {
            _titleFilter = value;
          });
          if (!mounted) return;
          _pagingController.refresh();
        },
      ),
      drawer: _buildDrawer(context),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16.0, 24.0, 16.0, 16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    alignment: Alignment.center,
                    isDense: true,
                    value: _categoryFilter,
                    onChanged: (String? newValue) {
                      setState(() {
                        _categoryFilter = newValue ?? 'All Categories';
                      });
                      if (!mounted) return;
                      _pagingController.refresh();
                    },
                    items: _categories.map(
                      (String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Center(
                            child: Text(value),
                          ),
                        );
                      },
                    ).toList(),
                  ),
                ),
                DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    alignment: Alignment.center,
                    isDense: true,
                    value: _subscriptionFilter,
                    onChanged: (String? newValue) {
                      setState(() {
                        _subscriptionFilter = newValue ?? 'All Subscriptions';
                      });
                      if (!mounted) return;
                      _pagingController.refresh();
                    },
                    items: _subscriptions.map(
                      (String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Center(
                            child: Text(value),
                          ),
                        );
                      },
                    ).toList(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () => Future.sync(
                  () => _pagingController.refresh(),
                ),
                child: PagedListView<int, Course>(
                  pagingController: _pagingController,
                  builderDelegate: PagedChildBuilderDelegate<Course>(
                    itemBuilder: (context, item, index) =>
                        CourseCard(course: item),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }
}

class SearchAppBar extends StatefulWidget implements PreferredSizeWidget {
  final void Function(String)? onSubmitted;

  const SearchAppBar({Key? key, this.onSubmitted}) : super(key: key);

  @override
  _SearchAppBarState createState() => _SearchAppBarState();

  @override
  Size get preferredSize => Size.fromHeight(AppBar().preferredSize.height);
}

class _SearchAppBarState extends State<SearchAppBar> {
  bool _isSearching = false;
  final _textController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AppBar(
        title: _isSearching
            ? TextField(
                controller: _textController,
                maxLines: 1,
                autofocus: false,
                textInputAction: TextInputAction.search,
                cursorColor: Theme.of(context).colorScheme.onSecondary,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSecondary,
                  overflow: TextOverflow.ellipsis,
                ),
                onSubmitted: (value) {
                  widget.onSubmitted?.call(value);
                  if (value.isEmpty) {
                    setState(() {
                      _isSearching = false;
                    });
                  }
                },
                decoration: InputDecoration(
                  isDense: true,
                  hintText: 'Search a course...',
                  hintStyle: TextStyle(
                    color: Theme.of(context).colorScheme.onSecondary,
                    fontStyle: FontStyle.italic,
                  ),
                  border: InputBorder.none,
                ),
              )
            : const Text('Ubademy'),
        actions: [
          _isSearching
              ? IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () {
                    setState(() {
                      _textController.clear();
                      _isSearching = false;
                      widget.onSubmitted?.call(_textController.text);
                    });
                  },
                )
              : IconButton(
                  icon: const Icon(Icons.search_rounded),
                  onPressed: () {
                    setState(() {
                      _isSearching = !_isSearching;
                    });
                  },
                ),
        ]);
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }
}
