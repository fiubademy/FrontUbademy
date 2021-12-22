import 'package:flutter/material.dart';

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
