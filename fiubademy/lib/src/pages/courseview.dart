import 'package:fiubademy/src/pages/profile.dart';
import 'package:fiubademy/src/pages/review_course.dart';
import 'package:fiubademy/src/pages/review_list.dart';
import 'package:fiubademy/src/services/location.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:fiubademy/src/services/auth.dart';
import 'package:fiubademy/src/services/server.dart';
import 'package:fiubademy/src/services/user.dart';

import 'package:fiubademy/src/widgets/course_rating.dart';
import 'package:fiubademy/src/widgets/course_tags.dart';
import 'package:fiubademy/src/models/course.dart';

class FavouriteIcon extends StatefulWidget {
  final bool isFavourite;
  final void Function()? onToggle;
  final String courseID;

  const FavouriteIcon(
      {Key? key,
      required this.isFavourite,
      this.onToggle,
      required this.courseID})
      : super(key: key);

  @override
  _FavouriteIconState createState() => _FavouriteIconState();
}

class _FavouriteIconState extends State<FavouriteIcon> {
  bool isLoading = false;
  bool isFavourite = false;

  @override
  void initState() {
    super.initState();
    isFavourite = widget.isFavourite;
  }

  void _toggleFavourite() async {
    if (isLoading) {
      return;
    }
    setState(() {
      isLoading = true;
      isFavourite = !isFavourite;
    });
    Auth auth = Provider.of<Auth>(context, listen: false);
    String? result = isFavourite
        ? await Server.addFavourite(auth, widget.courseID)
        : await Server.removeFavourite(auth, widget.courseID);
    if (result != null) {
      final snackBar = SnackBar(content: Text(result));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      setState(() {
        isFavourite = !isFavourite;
      });
    }
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
        onPressed: () => _toggleFavourite(),
        icon: isFavourite
            ? const Icon(Icons.favorite, color: Colors.red)
            : const Icon(Icons.favorite_outline));
  }
}

class CourseViewPage extends StatelessWidget {
  final Course _course;

  const CourseViewPage({
    Key? key,
    required Course course,
  })  : _course = course,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ubademy'), actions: [
        FavouriteIcon(
            isFavourite: _course.isFavourite, courseID: _course.courseID)
      ]),
      body: _buildCourse(context),
    );
  }

  Widget _buildCourse(BuildContext context) {
    return Scrollbar(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16.0, 24.0, 16.0, 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTitle(context),
              const SizedBox(height: 8.0),
              _buildSubtitle(context),
              const SizedBox(height: 4.0),
              const Divider(),
              const SizedBox(height: 8.0),
              ..._buildDescription(context),
              const SizedBox(height: 8.0),
              const Divider(),
              const SizedBox(height: 8.0),
              ..._buildDetails(context),
              const SizedBox(height: 8.0),
              const Divider(),
              const SizedBox(height: 8.0),
              ..._buildRatings(context),
              if (_course.role == CourseRole.notStudent ||
                  _course.role == CourseRole.student) ...[
                const SizedBox(height: 8.0),
                const Divider(),
                CourseToggleEnrollButton(course: _course),
              ]
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTitle(BuildContext context) {
    return Text(
      _course.title,
      style: Theme.of(context).textTheme.headline5,
    );
  }

  Widget _buildSubtitle(BuildContext context) {
    return Row(
      children: [
        Icon(
          Icons.school,
          color: Theme.of(context).colorScheme.secondaryVariant,
        ),
        const SizedBox(width: 8.0),
        InkWell(
          onTap: () async {
            Auth auth = Provider.of<Auth>(context, listen: false);
            Map<String, dynamic>? userData =
                await Server.getUser(auth, _course.ownerID);
            if (userData == null) return;
            User user = User();
            user.updateData(userData);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProfilePage(
                  user: user,
                  isSelf: user.userID == auth.userID,
                ),
              ),
            );
          },
          child: Text('by ${_course.ownerName}',
              style: Theme.of(context).textTheme.subtitle2),
        ),
        const Spacer(),
        Text(
          _course.minSubscriptionName,
          style: Theme.of(context).textTheme.subtitle2,
        ),
        const SizedBox(width: 8.0),
        Icon(
          Icons.monetization_on_rounded,
          color: Colors.green[700],
        ),
      ],
    );
  }

  List<Widget> _buildDescription(BuildContext context) {
    return [
      Text('About this course', style: Theme.of(context).textTheme.headline6),
      const SizedBox(
        height: 16.0,
      ),
      Text(_course.description),
    ];
  }

  List<Widget> _buildDetails(BuildContext context) {
    return [
      Text('Details', style: Theme.of(context).textTheme.headline6),
      const SizedBox(
        height: 16.0,
      ),
      IntrinsicHeight(
          child: Row(
        children: [
          const Icon(Icons.category, color: Colors.grey),
          const VerticalDivider(),
          const SizedBox(width: 8.0),
          Text(_course.category, style: Theme.of(context).textTheme.subtitle1),
        ],
      )),
      const SizedBox(
        height: 16.0,
      ),
      IntrinsicHeight(
          child: Row(
        children: [
          const Icon(Icons.calendar_today, color: Colors.grey),
          const VerticalDivider(),
          const SizedBox(width: 8.0),
          Text(
              'Created ${_course.creationDay} ${_course.creationMonthName} ${_course.creationYear}',
              style: Theme.of(context).textTheme.subtitle1),
        ],
      )),
      const SizedBox(
        height: 16.0,
      ),
      IntrinsicHeight(
        child: Row(
          children: [
            const Icon(Icons.location_on, color: Colors.grey),
            const VerticalDivider(),
            const SizedBox(width: 8.0),
            FutureBuilder(
              future: getLocationName(_course.latitude, _course.longitude),
              builder: (BuildContext context, AsyncSnapshot<String?> snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.waiting:
                    return Text('Fetching location',
                        style: Theme.of(context).textTheme.subtitle1);
                  default:
                    if (snapshot.hasError) {
                      return Text('Failed to fetch location',
                          style: Theme.of(context).textTheme.subtitle1);
                    }
                    if (snapshot.data == null) {
                      return Text('Failed to fetch location',
                          style: Theme.of(context).textTheme.subtitle1);
                    }
                    return Text(snapshot.data!,
                        style: Theme.of(context).textTheme.subtitle1);
                }
              },
            ),
          ],
        ),
      ),
      const SizedBox(
        height: 16.0,
      ),
      IntrinsicHeight(
        child: Row(
          children: [
            const Icon(Icons.tag_rounded, color: Colors.grey),
            const VerticalDivider(),
            // Expanded is necessary otherwise throws error
            _course.tags.isEmpty
                ? Row(
                    children: [
                      const SizedBox(width: 8.0),
                      Text(
                        'No tags',
                        style: Theme.of(context).textTheme.subtitle1,
                      ),
                    ],
                  )
                : Expanded(
                    child: CourseTags(
                      tags: _course.tags,
                    ),
                  ),
          ],
        ),
      ),
    ];
  }

  Future<Map<String, dynamic>> _getStudentMark(context) async {
    final _scaffoldMessenger = ScaffoldMessenger.of(context);
    Auth auth = Provider.of<Auth>(context, listen: false);
    Map<String, dynamic> result =
        await Server.getCourseMark(auth, _course.courseID);

    if (result['error'] != null) {
      if (result['error'] != 'No exams in the course') {
        final snackBar = SnackBar(content: Text(result['error']));
        _scaffoldMessenger.showSnackBar(snackBar);
      }
      throw Exception(result['error']);
    } else {
      return result['content'];
    }
  }

  List<Widget> _buildRatings(BuildContext context) {
    return [
      Text('Reviews and Ratings', style: Theme.of(context).textTheme.headline6),
      const SizedBox(height: 16.0),
      CourseRating(avg: _course.ratingAvg, count: _course.ratingCount),
      const SizedBox(height: 8.0),
      FutureBuilder(
        future: _getStudentMark(context),
        builder: (context, AsyncSnapshot<Map<String, dynamic>> snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              return const Center(child: CircularProgressIndicator());
            default:
              bool isEnabled = true;

              if (snapshot.hasError) {
                isEnabled = false;
              }

              if (!snapshot.hasData) {
                isEnabled = false;
              } else if (snapshot.data!['status'] != 'Finished') {
                isEnabled = false;
              }

              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: _course.role != CourseRole.student
                          ? null
                          : () {
                              if (isEnabled) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        ReviewCoursePage(course: _course),
                                  ),
                                );
                              } else {
                                const snackBar = SnackBar(
                                    content: Text(
                                        'You need to finish the course to write a review'));
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(snackBar);
                              }
                            },
                      child: const Text('Write a review'),
                    ),
                  ),
                  Expanded(
                    child: TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  ReviewListPage(course: _course),
                            ),
                          );
                        },
                        child: const Text('See all reviews')),
                  )
                ],
              );
          }
        },
      ),
    ];
  }
}

class CourseToggleEnrollButton extends StatefulWidget {
  final Course _course;

  const CourseToggleEnrollButton({Key? key, required Course course})
      : _course = course,
        super(key: key);

  @override
  _CourseToggleEnrollButtonState createState() =>
      _CourseToggleEnrollButtonState();
}

class _CourseToggleEnrollButtonState extends State<CourseToggleEnrollButton> {
  late bool _isEnrolled;
  bool _isLoading = false;

  @override
  void initState() {
    _isEnrolled = widget._course.role == CourseRole.student;
    super.initState();
  }

  void _enrollToCourse() async {
    setState(() {
      _isLoading = true;
    });
    Auth auth = Provider.of<Auth>(context, listen: false);
    String? result = await Server.enrollToCourse(auth, widget._course.courseID);

    if (!mounted) return;

    if (result != null) {
      final snackBar = SnackBar(content: Text(result));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } else {
      setState(() {
        _isEnrolled = true;
        widget._course.role = CourseRole.student;
      });
    }

    setState(() {
      _isLoading = false;
    });
  }

  void _unsubscribeFromCourse() async {
    setState(() {
      _isLoading = true;
    });
    Auth auth = Provider.of<Auth>(context, listen: false);
    String? result =
        await Server.unsubscribeFromCourse(auth, widget._course.courseID);

    if (!mounted) return;

    if (result != null) {
      final snackBar = SnackBar(content: Text(result));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } else {
      setState(() {
        _isEnrolled = false;
        widget._course.role = CourseRole.notStudent;
      });
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: _isLoading
          ? const CircularProgressIndicator()
          : (_isEnrolled
              ? ElevatedButton(
                  onPressed: () {
                    showDialog<String>(
                      context: context,
                      builder: (context) => AlertDialog(
                          title: const Text('Unsubscribe from Course'),
                          content: Text(
                              'Are you sure you want to leave ${widget._course.title}?'),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: const Text('CANCEL'),
                            ),
                            TextButton(
                              onPressed: () {
                                _unsubscribeFromCourse();
                                Navigator.pop(context);
                              },
                              child: const Text('UNSUBSCRIBE'),
                            ),
                          ]),
                    );
                  },
                  style: ElevatedButton.styleFrom(primary: Colors.red[700]),
                  child: const Text('UNSUBSCRIBE FROM COURSE'),
                )
              : ElevatedButton(
                  onPressed: () {
                    showDialog<String>(
                      context: context,
                      builder: (context) => AlertDialog(
                          title: const Text('Enroll to Course'),
                          content: Text(
                              'Are you sure you want to enroll to ${widget._course.title}?'),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: const Text('CANCEL'),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                _enrollToCourse();
                                Navigator.pop(context);
                              },
                              child: const Text('ENROLL'),
                            ),
                          ]),
                    );
                  },
                  child: const Text('ENROLL TO COURSE'),
                )),
    );
  }
}
