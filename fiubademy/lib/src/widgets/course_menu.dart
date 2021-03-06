import 'package:ubademy/src/pages/course_collaborators.dart';
import 'package:ubademy/src/pages/course_content.dart';
import 'package:ubademy/src/pages/course_edition.dart';
import 'package:ubademy/src/pages/course_students.dart';
import 'package:ubademy/src/pages/courseview.dart';
import 'package:ubademy/src/pages/exam_list.dart';
import 'package:flutter/material.dart';
import 'package:ubademy/src/models/course.dart';

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
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (content) => CourseContentPage(course: _course)));
            break;
          case 1:
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CourseEditionPage(course: _course),
              ),
            );
            break;
          case 2:
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ExamListPage(course: _course),
              ),
            );
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
            break;
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
    return PopupMenuButton<int>(
      onSelected: (value) {
        switch (value) {
          case 0:
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (content) => CourseContentPage(course: _course)));
            break;
          case 1:
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ExamListPage(course: _course),
              ),
            );
            break;
          case 2:
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
          child: Text('Exams'),
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
    return PopupMenuButton<int>(
      onSelected: (value) {
        switch (value) {
          case 0:
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (content) => CourseContentPage(course: _course)));
            break;
          case 1:
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ExamListPage(course: _course),
              ),
            );
            break;
          case 2:
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
          child: Text('Exams'),
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
                  builder: (context) => CourseViewPage(course: _course)));
        }
      },
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 0,
          child: Text('View'),
        ),
      ],
    );
  }
}
