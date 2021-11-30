import 'package:flutter/material.dart';

import 'package:fiubademy/src/models/course.dart';
import 'package:fiubademy/src/widgets/course_card.dart';

class CourseListView extends StatefulWidget {
  Function? onLoad;

  CourseListView({Key? key, this.onLoad}) : super(key: key);

  @override
  _CourseListViewState createState() => _CourseListViewState();
}

class _CourseListViewState extends State<CourseListView> {
  List<Course> _courses = [];

  @override
  Widget build(BuildContext context) {
    return ListView.builder(itemBuilder: (context, index) {
      if (index >= _courses.length) {
        List<Course>? newCourses;
        if (widget.onLoad != null) newCourses = widget.onLoad!();
        if (newCourses != null) _courses.addAll(newCourses);
      }
      return CourseCard(course: _courses[index]);
    });
  }
}
