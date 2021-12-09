import 'package:fiubademy/src/pages/course_collaborators.dart';
import 'package:fiubademy/src/pages/course_edition.dart';
import 'package:fiubademy/src/pages/course_students.dart';
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
    return PopupMenuButton<int>(
      onSelected: (int value) {
        switch (value) {
          case 0:
          case 1:
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MultimediaPicker(),
              ),
            );
            break;
          case 2:
            break;
          case 3:
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CourseCollaboratorsPage(
                  courseID: _course.courseID,
                ),
              ),
            );
            break;
          case 4:
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CourseStudentsPage(
                  courseID: _course.courseID,
                ),
              ),
            );
            break;
          case 5:
          case 6:
            break;
        }
      },
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 0,
          child: Text('View'),
        ),
        const PopupMenuItem(
          value: 1,
          child: Text('Edit'),
        ),
        const PopupMenuItem(
          value: 2,
          child: Text('Exams'),
        ),
        const PopupMenuItem(
          value: 3,
          child: Text('Collaborators'),
        ),
        const PopupMenuItem(
          value: 4,
          child: Text('Students'),
        ),
        const PopupMenuItem(
          value: 5,
          child: Text('Metrics'),
        ),
        const PopupMenuItem(
          value: 6,
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
    return PopupMenuButton<int>(
      onSelected: (value) {
        if (value == 0) {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      CourseViewPage(course: _course, isFavorite: false)));
        }
      },
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 0,
          child: const Text('View'),
        ),
      ],
    );
  }
}
