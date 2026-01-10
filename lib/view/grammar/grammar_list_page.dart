import 'package:beelingual_app/view/grammar/grammar_page.dart';
import 'package:beelingual_app/controller/grammarController.dart';
import 'package:beelingual_app/model/grammar.dart';
import 'package:flutter/material.dart';

class PageGrammarList extends StatefulWidget {
  const PageGrammarList({super.key});

  @override
  State<PageGrammarList> createState() => _PageGrammarListState();
}

class _PageGrammarListState extends State<PageGrammarList> {
  final TextEditingController _searchController = TextEditingController();
  List<Category> _allCategories = [];
  List<Category> _filteredCategories = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadCategories();
    _searchController.addListener(_onSearchChanged);
  }

  void _loadCategories() async {
    try {
      List<Category> categories = await fetchAllCategory();
      setState(() {
        _allCategories = categories;
        _filteredCategories = List.from(_allCategories);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredCategories = List.from(_allCategories);
      } else {
        _filteredCategories = _allCategories
            .where((cat) => cat.name.toLowerCase().contains(query))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Color> colors = [
      const Color(0xFFFF6B6B),
      const Color(0xFF4ECDC4),
      const Color(0xFF95E1D3),
      const Color(0xFFF38181),
      const Color(0xFFAA96DA),
      const Color(0xFFFCBF49),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Grammar",
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFFFFF176),
      ),
      body: _isLoading
          ? const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFBC02D)),
        ),
      )
          : _error != null
          ? Center(
        child: Text(
          "Error: $_error",
          style: const TextStyle(fontSize: 16, color: Colors.red),
        ),
      )
          : Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Searching Category Grammar',
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
          ),
          Expanded(
            child: _filteredCategories.isEmpty
                ? Center(
              child: Text(
                "Không tìm thấy category nào",
                style: TextStyle(
                    fontSize: 16, color: Colors.grey[600]),
              ),
            )
                : ListView.builder(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 20),
              itemCount: _filteredCategories.length,
              itemBuilder: (context, index) {
                final item = _filteredCategories[index];
                final color = colors[index % colors.length];

                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: color.withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PageGrammar(
                              title: item.name,
                              categoryId: item.id,
                            ),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.white,
                              color.withOpacity(0.1),
                            ],
                          ),
                          borderRadius:
                          BorderRadius.circular(20),
                          border: Border.all(
                            color: color.withOpacity(0.3),
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    color,
                                    color.withOpacity(0.7),
                                  ],
                                ),
                                borderRadius:
                                BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: color.withOpacity(0.4),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Text(
                                  item.icon.isNotEmpty
                                      ? item.icon
                                      : item.name[0]
                                      .toUpperCase(),
                                  style: const TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                item.name,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2D3436),
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: color.withOpacity(0.1),
                                borderRadius:
                                BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.arrow_forward_ios,
                                size: 20,
                                color: color,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          SizedBox(height: 20,)
        ],
      ),
    );
  }
}
