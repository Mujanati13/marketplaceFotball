import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HelpScreen extends ConsumerStatefulWidget {
  const HelpScreen({super.key});

  @override
  ConsumerState<HelpScreen> createState() => _HelpScreenState();
}

class _HelpScreenState extends ConsumerState<HelpScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  final List<_FAQItem> _faqItems = [
    _FAQItem(
      question: 'How do I create a listing?',
      answer:
          'To create a listing, go to the Browse Opportunities page and tap the "+" button in the top-right corner. Fill in your details and publish your listing.',
      category: 'Listings',
    ),
    _FAQItem(
      question: 'How do I contact other users?',
      answer:
          'You can contact other users by submitting a request on their listing. Once they accept, you can start a conversation.',
      category: 'Communication',
    ),
    _FAQItem(
      question: 'How do I edit my profile?',
      answer:
          'Go to your Profile page and tap the edit icon in the top-right corner. You can update your personal information, bio, and other details.',
      category: 'Profile',
    ),
    _FAQItem(
      question: 'What types of opportunities are available?',
      answer:
          'We offer opportunities for players looking for teams, teams looking for players, coaching positions, and trial opportunities.',
      category: 'Opportunities',
    ),
    _FAQItem(
      question: 'How do I schedule a meeting?',
      answer:
          'After connecting with someone through a request, you can schedule meetings through the chat interface or meetings page.',
      category: 'Meetings',
    ),
    _FAQItem(
      question: 'Is the app free to use?',
      answer:
          'Yes, the basic features of Football Marketplace are free to use. Premium features may be available in future updates.',
      category: 'Account',
    ),
    _FAQItem(
      question: 'How do I report inappropriate content?',
      answer:
          'You can report inappropriate content by contacting our support team. We take all reports seriously and will investigate promptly.',
      category: 'Safety',
    ),
    _FAQItem(
      question: 'Can I delete my account?',
      answer:
          'Yes, you can delete your account from the Settings page. Please note that this action cannot be undone.',
      category: 'Account',
    ),
  ];

  List<_FAQItem> get _filteredItems {
    if (_searchQuery.isEmpty) {
      return _faqItems;
    }
    return _faqItems
        .where(
          (item) =>
              item.question.toLowerCase().contains(
                _searchQuery.toLowerCase(),
              ) ||
              item.answer.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              item.category.toLowerCase().contains(_searchQuery.toLowerCase()),
        )
        .toList();
  }

  Map<String, List<_FAQItem>> get _groupedItems {
    final filtered = _filteredItems;
    final grouped = <String, List<_FAQItem>>{};

    for (final item in filtered) {
      if (!grouped.containsKey(item.category)) {
        grouped[item.category] = [];
      }
      grouped[item.category]!.add(item);
    }

    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Help & FAQ'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Search Section
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search for help...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),

          // FAQ Content
          Expanded(
            child: _filteredItems.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No results found',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Try different keywords or browse categories below',
                          style: TextStyle(color: Colors.grey[500]),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                : ListView(
                    children: [
                      if (_searchQuery.isEmpty) ...[
                        // Quick Help Section
                        Container(
                          margin: const EdgeInsets.all(16),
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Theme.of(
                              context,
                            ).colorScheme.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Quick Help',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                              const SizedBox(height: 12),
                              _QuickHelpItem(
                                icon: Icons.add_circle,
                                title: 'Create your first listing',
                                description:
                                    'Get started by creating a listing to showcase your skills or find opportunities.',
                              ),
                              const SizedBox(height: 8),
                              _QuickHelpItem(
                                icon: Icons.person,
                                title: 'Complete your profile',
                                description:
                                    'Add your details, skills, and experience to attract the right opportunities.',
                              ),
                              const SizedBox(height: 8),
                              _QuickHelpItem(
                                icon: Icons.search,
                                title: 'Browse opportunities',
                                description:
                                    'Explore available opportunities and connect with other users.',
                              ),
                            ],
                          ),
                        ),
                      ],

                      // FAQ Categories
                      ..._groupedItems.entries
                          .map(
                            (entry) => _FAQCategory(
                              category: entry.key,
                              items: entry.value,
                            ),
                          )
                          .toList(),

                      // Contact Support Section
                      Container(
                        margin: const EdgeInsets.all(16),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Still need help?',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'If you can\'t find the answer you\'re looking for, our support team is here to help.',
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.of(context).pushNamed('/support');
                                },
                                icon: const Icon(Icons.support_agent),
                                label: const Text('Contact Support'),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class _FAQCategory extends StatelessWidget {
  final String category;
  final List<_FAQItem> items;

  const _FAQCategory({required this.category, required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
          child: Text(
            category,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
        ...items.map((item) => _FAQTile(item: item)).toList(),
      ],
    );
  }
}

class _FAQTile extends StatefulWidget {
  final _FAQItem item;

  const _FAQTile({required this.item});

  @override
  State<_FAQTile> createState() => _FAQTileState();
}

class _FAQTileState extends State<_FAQTile> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ExpansionTile(
        title: Text(
          widget.item.question,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        trailing: Icon(_isExpanded ? Icons.expand_less : Icons.expand_more),
        onExpansionChanged: (expanded) {
          setState(() {
            _isExpanded = expanded;
          });
        },
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Text(
              widget.item.answer,
              style: TextStyle(color: Colors.grey[600], height: 1.5),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickHelpItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _QuickHelpItem({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: Theme.of(context).colorScheme.primary, size: 24),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              Text(
                description,
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _FAQItem {
  final String question;
  final String answer;
  final String category;

  _FAQItem({
    required this.question,
    required this.answer,
    required this.category,
  });
}
