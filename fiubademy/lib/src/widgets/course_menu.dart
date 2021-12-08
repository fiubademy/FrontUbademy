import 'package:flutter/material.dart';

enum CourseMenu {
  creator,
  collaborator,
  student,
}

class CourseCreatorMenu extends StatelessWidget {
  const CourseCreatorMenu({Key? key}) : super(key: key);

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
  const CourseStudentMenu({Key? key}) : super(key: key);

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
  const CourseCollaboratorMenu({Key? key}) : super(key: key);

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
