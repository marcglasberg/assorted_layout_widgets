import 'package:assorted_layout_widgets/assorted_layout_widgets.dart';
import 'package:flutter/material.dart';

void main() => runApp(const MaterialApp(home: Demo(), debugShowCheckedModeBanner: false));

class Demo extends StatefulWidget {
  const Demo({super.key});

  @override
  State<Demo> createState() => _DemoState();
}

class _DemoState extends State<Demo> with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  bool _shrink = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        title: const Text('KeepTallest Example'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Tab A'),
            Tab(text: 'Tab B'),
            Tab(text: 'Tab C'),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- KeepTallest wraps the tab content ---
            KeepTallest(
              shrink: _shrink,
              duration: const Duration(milliseconds: 600),
              shrinkDelay: const Duration(milliseconds: 300),
              child: AnimatedBuilder(
                animation: _tabController,
                builder: (context, _) => _buildTabContent(_tabController.index),
              ),
            ),

            const Divider(height: 32),

            // Content below — this should stay in place.
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Column(
                children: [
                  Icon(Icons.arrow_upward, color: Colors.grey),
                  SizedBox(height: 8),
                  Text(
                    'Other content\n'
                    'Should stay in place when switching from a taller tab content to a shorter one',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        color: Colors.grey.shade200,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'The Main Content above is wrapped in KeepTallest.'
                  '\n'
                  'Switch tabs and notice that the "Other content" '
                  'never jumps up (unless you turn on the "Shrink back" switch).'
                  '\n'
                  'If you open another route and then go back, '
                  'you can also see that the tallest height is reset.',
                  style: TextStyle(fontSize: 14),
                  textAlign: TextAlign.center,
                ),
                const Divider(),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Text('Shrink back'),
                    const SizedBox(width: 4),
                    Switch(value: _shrink, onChanged: (v) => setState(() => _shrink = v)),
                    const Spacer(),
                    FilledButton.icon(
                      icon: const Icon(Icons.open_in_new),
                      label: const Text('Open a route'),
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (ctx) => Scaffold(
                            appBar: AppBar(title: const Text('Another page')),
                            body: Center(
                              child: FilledButton(
                                onPressed: () => Navigator.of(ctx).pop(),
                                child: const Text('Go back to see the snap-back'),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabContent(int index) {
    switch (index) {
      case 0:
        return Container(
          alignment: Alignment.topCenter,
          child: _contentCard(
            color: const Color(0xFF1e3a5f),
            label: 'Main Content A',
            height: 80,
          ),
        );
      case 1:
        return Align(
          alignment: Alignment.topCenter,
          child: _contentCard(
            color: const Color(0xFF3a1e5f),
            label: 'Main Content B (taller)',
            height: 200,
          ),
        );
      case 2:
        return Center(
          child: _contentCard(
            color: const Color(0xFF1e5f3a),
            label: 'Main Content C (tallest)',
            height: 320,
          ),
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _contentCard({
    required Color color,
    required String label,
    required double height,
  }) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white24),
      ),
      alignment: Alignment.center,
      child: Text(
        '$label\n(${height.toInt()} px)',
        textAlign: TextAlign.center,
        style: const TextStyle(color: Colors.white70, fontSize: 14),
      ),
    );
  }
}
