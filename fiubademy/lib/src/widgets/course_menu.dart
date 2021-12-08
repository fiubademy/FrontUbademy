import 'package:fiubademy/src/pages/courseview.dart';
import 'package:flutter/material.dart';
import 'package:fiubademy/src/models/course.dart';

enum CourseMenu {
  creator,
  collaborator,
  student,
}

class CourseCreatorMenu extends StatelessWidget {
  final Course _course;

  const CourseCreatorMenu({Key? key, required Course course})
      : _course = course,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton(
      itemBuilder: (context) => [
        const PopupMenuItem(
          child: Text('View'),
        ),
        const PopupMenuItem(
          child: Text('Edit'),
        ),
        const PopupMenuItem(
          child: Text('Exams'),
        ),
        const PopupMenuItem(
          child: Text('Collaborators'),
        ),
        const PopupMenuItem(
          child: Text('Metrics'),
        ),
        const PopupMenuItem(
          child: Text('Forum'),
        ),
      ],
    );
  }
}

class CourseStudentMenu extends StatelessWidget {
  final Course _course;

  const CourseStudentMenu({Key? key, required Course course})
      : _course = course,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton(
      itemBuilder: (context) => [
        const PopupMenuItem(
          child: Text('View'),
        ),
        const PopupMenuItem(
          child: Text('Exams'),
        ),
        const PopupMenuItem(
          child: Text('Forum'),
        ),
      ],
    );
  }
}

class CourseCollaboratorMenu extends StatelessWidget {
  final Course _course;

  const CourseCollaboratorMenu({Key? key, required Course course})
      : _course = course,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton(
      itemBuilder: (context) => [
        const PopupMenuItem(
          child: Text('View'),
        ),
        const PopupMenuItem(
          child: Text('Exams'),
        ),
        const PopupMenuItem(
          child: Text('Forum'),
        ),
      ],
    );
  }
}

class CourseNotStudentMenu extends StatelessWidget {
  final Course _course;

  const CourseNotStudentMenu({Key? key, required Course course})
      : _course = course,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton(
      itemBuilder: (context) => [
        PopupMenuItem(
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => CourseViewPage(course: _course, isFavorite: false));
          },
          child: const Text('View'),
        ),
      ],
    );
  }
}
