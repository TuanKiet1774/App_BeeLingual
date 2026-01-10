import 'package:flutter/material.dart';

import '../../controller/grammarController.dart';
import '../../controller/streakController.dart';
import '../../model/grammar.dart';
import 'grammer_exe_page.dart';

class PageGrammar extends StatefulWidget {
  final String title;
  final String categoryId;

  const PageGrammar({
    super.key,
    required this.title,
    required this.categoryId,
  });

  @override
  State<PageGrammar> createState() => _PageGrammarState();
}

class _PageGrammarState extends State<PageGrammar> {
  List<Grammar> _allGrammar = [];
  List<Grammar> _filteredGrammar = [];
  bool _isLoading = true;
  String? _error;

  final TextEditingController _searchController = TextEditingController();

  final List<List<Color>> cardGradients = [
    [Color(0xFFFFD194), Color(0xFFFF8A65)],
    [Color(0xFFB6F492), Color(0xFF338B93)],
    [Color(0xFFD4BFFF), Color(0xFF9B6DFF)],
    [Color(0xFFA1FFCE), Color(0xFF3EB489)],
  ];

  @override
  void initState() {
    super.initState();
    _loadGrammar();
    _searchController.addListener(_onSearchChanged);
  }

  void _loadGrammar() async {
    try {
      final data = await fetchAllGrammarByCategory(widget.categoryId);
      if (!mounted) return;
      if (data.isNotEmpty) {
        StreakService().updateStreak(context);
      }

      setState(() {
        _allGrammar = data;
        _filteredGrammar = List.from(_allGrammar);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredGrammar = List.from(_allGrammar);
      } else {
        _filteredGrammar = _allGrammar
            .where((g) => g.title.toLowerCase().contains(query))
            .toList();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFDE7),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFFFFE474),
        title: Text(
          widget.title,
          style: const TextStyle(
            fontWeight: FontWeight.w900,
            color: Color(0xFF5D4037),
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(child: Text('Error: $_error'))
          : Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Searching Grammar...',
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
                    borderRadius: BorderRadius.circular(10)),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
          ),
          Expanded(
            child: _filteredGrammar.isEmpty
                ? const Center(
              child: Text('Không tìm thấy grammar nào'),
            )
                : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: _filteredGrammar.length,
              itemBuilder: (context, index) {
                final grammar = _filteredGrammar[index];
                final gradient =
                cardGradients[index % cardGradients.length];
                return _grammarCard(grammar, index, gradient);
              },
            ),
          ),
          SizedBox(height: 20,)
        ],
      ),
    );
  }

  Widget _grammarCard(Grammar grammar, int index, List<Color> gradient) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PageGrammarDetail(grammar: grammar),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 18),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(colors: gradient),
          boxShadow: [
            BoxShadow(
              blurRadius: 16,
              color: Colors.black.withOpacity(0.15),
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(16),
              ),
              alignment: Alignment.center,
              child: Text(
                '${index + 1}',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF5D4037),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    grammar.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Level: ${grammar.level}',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: Colors.white),
          ],
        ),
      ),
    );
  }
}

class PageGrammarDetail extends StatelessWidget {
  final Grammar grammar;
  const PageGrammarDetail({super.key, required this.grammar});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFDE7),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFE474),
        elevation: 0,
        title: Text(
          grammar.title,
          style: const TextStyle(
            fontWeight: FontWeight.w900,
            color: Color(0xFF5D4037),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _section('Cấu trúc', grammar.structure, Icons.account_tree),
            _section('Cách dùng', grammar.content, Icons.menu_book),
            _section('Ví dụ', grammar.example, Icons.lightbulb_outline),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.edit_note, size: 26),
                label: const Text(
                  'Luyện tập ngay',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFA000),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  elevation: 6,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PageExercisesGrmList(
                        grammarId: grammar.id,
                        grammarTitle: grammar.title,
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _section(String title, String content, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            blurRadius: 12,
            color: Colors.black.withOpacity(0.08),
            offset: const Offset(0, 6),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: const Color(0xFFFFA000)),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: const TextStyle(fontSize: 16, height: 1.6),
          ),
        ],
      ),
    );
  }
}
