import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';

import 'package:fiubademy/src/widgets/course_card.dart';

class MyCoursesPage extends StatelessWidget {
  const MyCoursesPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('My Courses'),
        ),
        body: Scrollbar(
          child: ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: 10,
              itemBuilder: (context, index) =>
                  Container() // TODO FIX CourseCard(),
              ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {},
          label: const Text('CREATE'),
          icon: const Icon(Icons.add),
        ));
  }
}
