import 'package:ubademy/src/models/course.dart';
import 'package:ubademy/src/models/review.dart';
import 'package:ubademy/src/services/auth.dart';
import 'package:ubademy/src/services/server.dart';
import 'package:ubademy/src/services/user.dart';
import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:provider/provider.dart';
import 'package:ubademy/src/widgets/review_card.dart';

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
  int? _filter;

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
      filter: _filter,
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
    return Padding(
      padding: const EdgeInsets.only(top: 24.0),
      child: Column(
        children: [
          SizedBox(
            height: 32,
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              scrollDirection: Axis.horizontal,
              shrinkWrap: true,
              children: [
                InkWell(
                  customBorder: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  onTap: () {
                    setState(() {
                      _filter = null;
                    });
                    if (!mounted) return;
                    _pagingController.refresh();
                  },
                  child: Container(
                    constraints: const BoxConstraints(minWidth: 64),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.black38,
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      color: _filter == null ? Colors.blue[100] : null,
                    ),
                    child: Text('All',
                        style: Theme.of(context).textTheme.subtitle1),
                  ),
                ),
                const SizedBox(width: 16.0),
                InkWell(
                  customBorder: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  onTap: () {
                    setState(() {
                      _filter = 5;
                    });
                    if (!mounted) return;
                    _pagingController.refresh();
                  },
                  child: Container(
                    constraints: const BoxConstraints(minWidth: 64),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.black38,
                        width: 1,
                      ),
                      color: _filter == 5 ? Colors.blue[100] : null,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Text('5', style: Theme.of(context).textTheme.subtitle1),
                        const Icon(Icons.star_rounded,
                            size: 16, color: Colors.black87),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 16.0),
                InkWell(
                  customBorder: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  onTap: () {
                    setState(() {
                      _filter = 4;
                    });
                    if (!mounted) return;
                    _pagingController.refresh();
                  },
                  child: Container(
                    constraints: const BoxConstraints(minWidth: 64),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.black38,
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      color: _filter == 4 ? Colors.blue[100] : null,
                    ),
                    child: Row(
                      children: [
                        Text('4', style: Theme.of(context).textTheme.subtitle1),
                        const Icon(Icons.star_rounded,
                            size: 16, color: Colors.black87),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 16.0),
                InkWell(
                  customBorder: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  onTap: () {
                    setState(() {
                      _filter = 3;
                    });
                    if (!mounted) return;
                    _pagingController.refresh();
                  },
                  child: Container(
                    constraints: const BoxConstraints(minWidth: 64),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.black38,
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      color: _filter == 3 ? Colors.blue[100] : null,
                    ),
                    child: Row(
                      children: [
                        Text('3', style: Theme.of(context).textTheme.subtitle1),
                        const Icon(Icons.star_rounded,
                            size: 16, color: Colors.black87),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 16.0),
                InkWell(
                  customBorder: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  onTap: () {
                    setState(() {
                      _filter = 2;
                    });
                    if (!mounted) return;
                    _pagingController.refresh();
                  },
                  child: Container(
                    constraints: const BoxConstraints(minWidth: 64),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.black38,
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      color: _filter == 2 ? Colors.blue[100] : null,
                    ),
                    child: Row(
                      children: [
                        Text('2', style: Theme.of(context).textTheme.subtitle1),
                        const Icon(Icons.star_rounded,
                            size: 16, color: Colors.black87),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 16.0),
                InkWell(
                  customBorder: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  onTap: () {
                    setState(() {
                      _filter = 1;
                    });
                    if (!mounted) return;
                    _pagingController.refresh();
                  },
                  child: Container(
                    constraints: const BoxConstraints(minWidth: 64),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.black38,
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      color: _filter == 1 ? Colors.blue[100] : null,
                    ),
                    child: Row(
                      children: [
                        Text('1', style: Theme.of(context).textTheme.subtitle1),
                        const Icon(Icons.star_rounded,
                            size: 16, color: Colors.black87),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16.0),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => Future.sync(
                () => _pagingController.refresh(),
              ),
              child: PagedListView<int, Review>(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                pagingController: _pagingController,
                builderDelegate: PagedChildBuilderDelegate<Review>(
                  itemBuilder: (context, item, index) =>
                      ReviewCard(review: item),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
