import 'package:beelingual_app/view/vocabulary/vocab_level_page.dart';
import 'package:beelingual_app/component/progressProvider.dart';
import 'package:beelingual_app/connect_api/api_connect.dart';
import 'package:beelingual_app/model/topic.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AppColors {
  static const Color background = Color(0xFFFFFDE7);
  static const Color cardBackground = Color(0xFFFFF9C4);
  static const Color cardSelected = Color(0xFFFCE79A);
  static const Color iconActive = Color(0xFFEBC934);
  static const Color textDark = Color(0xFF5D4037);
  static const Color textLight = Color(0xFFA68B7B);
  static const Color progressBarFill = Color(0xFF5D4037);
}

class LearningTopicsScreen extends StatefulWidget {
  const LearningTopicsScreen({super.key});

  @override
  State<LearningTopicsScreen> createState() => _LearningTopicsScreenState();
}

class _LearningTopicsScreenState extends State<LearningTopicsScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  List<Topic> _topics = [];
  List<Topic> _filteredTopics = [];
  int _currentPage = 1;
  int _totalTopics = 0;

  bool _isLoading = false;
  bool _hasMore = true;
  bool _isFetchingMore = false;

  @override
  void initState() {
    super.initState();

    Future.microtask(() async {
      await Provider.of<ProgressProvider>(context, listen: false)
          .fetchProgress(context);
      await _loadInitialTopics();
    });

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
            .where((topic) => topic.title.toLowerCase().contains(query))
            .toList();
      }
    });
  }

  void _onScroll() {
    if (!_scrollController.hasClients || !_hasMore) return;

    final threshold = _scrollController.position.maxScrollExtent - 200;

    if (_scrollController.position.pixels >= threshold) {
      _loadMoreTopics();
    }
  }

  Future<void> _loadInitialTopics() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _currentPage = 1;
      _topics.clear();
      _filteredTopics.clear();
      _hasMore = true;
    });

    try {
      final result = await fetchTopicsPaginated(
        page: 1,
        limit: 6,
        context: context,
      );

      final List<Topic> fetched = List<Topic>.from(result['data']);

      if (!mounted) return;

      setState(() {
        _topics = fetched;
        _filteredTopics = List.from(fetched);
        _totalTopics = result['total'] ?? 0;
        _hasMore = _topics.length < _totalTopics;
        _currentPage = 2;
      });
    } catch (e) {
      debugPrint("Load initial error: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _loadMoreTopics() async {
    if (_isFetchingMore || !_hasMore || _isLoading) return;

    _isFetchingMore = true;

    try {
      final result = await fetchTopicsPaginated(
        page: _currentPage,
        limit: 2,
        context: context,
      );

      final List<Topic> newTopics = List<Topic>.from(result['data']);

      if (!mounted) return;

      setState(() {
        _topics.addAll(
          newTopics.where((t) => !_topics.any((e) => e.id == t.id)),
        );

        // cập nhật filtered theo search
        final query = _searchController.text.toLowerCase();
        if (query.isEmpty) {
          _filteredTopics = List.from(_topics);
        } else {
          _filteredTopics = _topics
              .where((topic) => topic.title.toLowerCase().contains(query))
              .toList();
        }

        _hasMore = _topics.length < _totalTopics;
        _currentPage++;
      });
    } catch (e) {
      debugPrint("Load more error: $e");
    } finally {
      _isFetchingMore = false;
    }
  }

  Future<void> _refreshData() async {
    _isFetchingMore = false;
    _currentPage = 1;
    _hasMore = true;

    await Provider.of<ProgressProvider>(context, listen: false)
        .fetchProgress(context);
    await _loadInitialTopics();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Vocabulary Topic',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFFFFE474),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refreshData,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: _buildHeader(),
              ),
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _filteredTopics.isEmpty
                    ? const Center(child: Text("Don't have data"))
                    : ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                  itemCount:
                  _filteredTopics.length + (_hasMore ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == _filteredTopics.length) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Center(
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: TopicCard(topic: _filteredTopics[index]),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
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
              borderRadius: BorderRadius.circular(10),
            ),
            filled: true,
            fillColor: Colors.white,
          ),
        ),
      ],
    );
  }
}

class TopicCard extends StatelessWidget {
  final Topic topic;

  const TopicCard({super.key, required this.topic});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => LevelPage(
                  topicId: topic.id,
                  topicName: topic.title,
                  topic: topic,
                ),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: topic.imageUrl.isNotEmpty
                      ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      topic.imageUrl,
                      fit: BoxFit.cover,
                      height: 100,
                    ),
                  )
                      : const Icon(Icons.image, size: 50),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        topic.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${topic.learnedWords}/${topic.totalWords} words',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textLight,
                        ),
                      ),
                      const SizedBox(height: 6),
                      LinearProgressIndicator(
                        value: topic.progress / 100,
                        backgroundColor: Colors.amber,
                        valueColor: AlwaysStoppedAnimation(
                          topic.progress >= 100
                              ? Colors.green
                              : AppColors.progressBarFill,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${topic.progress}%',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
