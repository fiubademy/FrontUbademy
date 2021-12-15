import 'package:flutter/material.dart';

class CourseContentPage extends StatefulWidget {
  const CourseContentPage({Key? key}) : super(key: key);

  @override
  _CourseContentPageState createState() => _CourseContentPageState();
}

class _CourseContentPageState extends State<CourseContentPage> {
  final PageController pageController = PageController();

  @override
  Widget build(BuildContext context) {
    return PageView(
        controller: pageController,
        children: [Container(height: 200, width: 200, color: Colors.red)]);
  }
}
