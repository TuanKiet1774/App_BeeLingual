import 'package:beelingual_app/view/exercises/exercises_list_page.dart';
import 'package:beelingual_app/controller/topicController.dart';
import 'package:flutter/material.dart';

import '../../model/exe_topic.dart';

class PageTopicExercisesList extends StatefulWidget {
  const PageTopicExercisesList({super.key});

  @override
  State<PageTopicExercisesList> createState() => _PageTopicExercisesListState();
}

class _PageTopicExercisesListState extends State<PageTopicExercisesList> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  final List<Topic> _topics = [];
  List<Topic> _filteredTopics = [];
  bool _isLoading = false;
  bool _hasMore = true;
  int _page = 1;
  final int _pageSize = 10;

  @override
  void initState() {
    super.initState();
    _loadMoreTopics();
    _scrollController.addListener(_onScroll);
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredTopics = List.from(_topics);
      } else {
        _filteredTopics = _topics
            .where((topic) => topic.name.toLowerCase().contains(query))
            .toList();
      }
    });
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200 &&
        !_isLoading &&
        _hasMore) {
      _loadMoreTopics();
    }
  }

  Future<void> _loadMoreTopics() async {
    setState(() => _isLoading = true);

    List<Topic> newTopics = await fetchTopicPage(_page, _pageSize);

    setState(() {
      _page++;
      _topics.addAll(newTopics);

      // Cập nhật danh sách filtered theo search
      final query = _searchController.text.toLowerCase();
      if (query.isEmpty) {
        _filteredTopics = List.from(_topics);
      } else {
        _filteredTopics = _topics
            .where((topic) => topic.name.toLowerCase().contains(query))
            .toList();
      }

      _isLoading = false;
      if (newTopics.length < _pageSize) _hasMore = false;
    });
  }

  Future<List<Topic>> fetchTopicPage(int page, int pageSize) async {
    List<Topic> allTopics = (await fetchAllTopic()).cast<Topic>();
    int start = (page - 1) * pageSize;
    int end = start + pageSize;
    if (start >= allTopics.length) return [];
    if (end > allTopics.length) end = allTopics.length;
    return allTopics.sublist(start, end);
  }

  Color _getLevelColor(String level) {
    switch (level.toLowerCase()) {
      case 'beginner':
      case 'easy':
        return const Color(0xFF66BB6A);
      case 'intermediate':
      case 'medium':
        return const Color(0xFFFFB74D);
      case 'advanced':
      case 'hard':
        return const Color(0xFFEF5350);
      default:
        return const Color(0xFF42A5F5);
    }
  }

  IconData _getLevelIcon(String level) {
    switch (level.toLowerCase()) {
      case 'beginner':
      case 'easy':
        return Icons.star_outline;
      case 'intermediate':
      case 'medium':
        return Icons.star_half;
      case 'advanced':
      case 'hard':
        return Icons.star;
      default:
        return Icons.emoji_events_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text(
          'Exercises Topic',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        elevation: 0,
        backgroundColor: const Color(0xFFFFF176),
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Searching Topics...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    _onSearchChanged();
                  },
                )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
          ),

          // Danh sách topic
          Expanded(
            child: _filteredTopics.isEmpty && _isLoading
                ? const Center(
              child: CircularProgressIndicator(
                valueColor:
                AlwaysStoppedAnimation<Color>(Color(0xFFFFF176)),
              ),
            )
                : _filteredTopics.isEmpty
                ? const Center(child: Text('Không có chủ đề nào'))
                : ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 50),
              itemCount: _filteredTopics.length + (_hasMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index >= _filteredTopics.length) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                            Color(0xFFFFF176)),
                      ),
                    ),
                  );
                }

                final item = _filteredTopics[index];
                final levelColor = _getLevelColor(item.level);
                final levelIcon = _getLevelIcon(item.level);

                return Hero(
                  tag: 'topic_${item.name}_$index',
                  child: Material(
                    color: Colors.transparent,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 15,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(20),
                        onTap: () {
                          Navigator.push(
                            context,
                            PageRouteBuilder(
                              pageBuilder: (context, animation,
                                  secondaryAnimation) =>
                                  PageExercisesList(
                                    topicId: item.id,
                                    name: item.name,
                                  ),
                              transitionsBuilder: (context, animation,
                                  secondaryAnimation, child) {
                                const begin = Offset(1.0, 0.0);
                                const end = Offset.zero;
                                const curve = Curves.easeInOutCubic;
                                var tween = Tween(begin: begin, end: end)
                                    .chain(CurveTween(curve: curve));
                                var offsetAnimation = animation.drive(tween);

                                return SlideTransition(
                                  position: offsetAnimation,
                                  child: FadeTransition(
                                    opacity: animation,
                                    child: child,
                                  ),
                                );
                              },
                              transitionDuration:
                              const Duration(milliseconds: 400),
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(14.0),
                          child: Row(
                            children: [
                              Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(16),
                                    child: Image.network(
                                      item.imageUrl,
                                      width: 100,
                                      height: 100,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                        return Container(
                                          width: 100,
                                          height: 100,
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                              colors: [
                                                levelColor.withOpacity(0.6),
                                                levelColor,
                                              ],
                                            ),
                                            borderRadius:
                                            BorderRadius.circular(16),
                                          ),
                                          child: const Icon(
                                            Icons.book,
                                            color: Colors.white,
                                            size: 40,
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  Positioned(
                                    top: 6,
                                    left: 6,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.black.withOpacity(0.6),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            levelIcon,
                                            color: levelColor,
                                            size: 14,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.name,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                        height: 1.3,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: levelColor.withOpacity(0.15),
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                          color: levelColor.withOpacity(0.3),
                                          width: 1,
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            levelIcon,
                                            color: levelColor,
                                            size: 16,
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            item.level,
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                              color: levelColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color:
                                  const Color(0xFFFFF176).withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(
                                  Icons.arrow_forward_ios,
                                  size: 18,
                                  color: Color(0xFFFFD54F),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
