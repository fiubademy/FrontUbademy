import 'package:fiubademy/src/models/course.dart';
import 'package:fiubademy/src/services/auth.dart';
import 'package:fiubademy/src/services/server.dart';
import 'package:fiubademy/src/services/user.dart';
import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:provider/provider.dart';

class Review {
  final User _author;
  final int _rating;
  final String _description;

  Review.fromMap(Map<String, dynamic> reviewData)
      : _author = reviewData['author'],
        _rating = reviewData['rating'],
        _description = reviewData['description'];

  User get author => _author;
  int get rating => _rating;
  String get description => _description;
}

class ReviewListPage extends StatelessWidget {
  final Course course;
  const ReviewListPage({Key? key, required this.course}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Reviews'),
      ),
      body: ReviewList(course: course),
    );
  }
}

class ReviewList extends StatefulWidget {
  final Course course;
  const ReviewList({Key? key, required this.course}) : super(key: key);

  @override
  _ReviewListState createState() => _ReviewListState();
}

class _ReviewListState extends State<ReviewList> {
  final int _pageSize = 5;
  final PagingController<int, Review> _pagingController =
      PagingController(firstPageKey: 0);
  String _filter = 'All';

  @override
  void initState() {
    _pagingController.addPageRequestListener((pageKey) {
      _fetchPage(pageKey);
    });
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

  Future<List<Review>> onLoad(index) async {
    Auth auth = Provider.of<Auth>(context, listen: false);
    int page = (index ~/ 5) + 1;
    final result = await Server.getReviews(
      auth,
      widget.course.courseID,
      page,
      filter: _filter == 'All' ? null : int.parse(_filter),
    );
    if (result['error'] != null) {
      throw Exception(result['error']);
    }

    List<Map<String, dynamic>> reviewsData =
        List<Map<String, dynamic>>.from(result['content']);

    for (var reviewData in reviewsData) {
      String authorID = reviewData['userId'];
      final userQuery = await Server.getUser(auth, authorID);
      if (userQuery == null) {
        throw Exception(result['Failed to fetch user data']);
      }
      User author = User();
      author.updateData(userQuery);
      reviewData['author'] = author;
    }

    List<Review> reviews = List.generate(
        reviewsData.length, (index) => Review.fromMap(reviewsData[index]));
    return Future<List<Review>>.value(reviews);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [],
        ),
        const SizedBox(height: 16.0),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () => Future.sync(
              () => _pagingController.refresh(),
            ),
            child: PagedListView<int, Review>(
              pagingController: _pagingController,
              builderDelegate: PagedChildBuilderDelegate<Review>(
                itemBuilder: (context, item, index) => ReviewCard(review: item),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class ReviewCard extends StatelessWidget {
  final Review review;
  const ReviewCard({Key? key, required this.review}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
