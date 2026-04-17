import 'package:assorted_layout_widgets/assorted_layout_widgets.dart';
import 'package:flutter/material.dart';

void main() => runApp(const MaterialApp(home: Demo(), debugShowCheckedModeBanner: false));

class Demo extends StatefulWidget {
  const Demo({super.key});

  @override
  State<Demo> createState() => _DemoState();
}

class _DemoState extends State<Demo> {
  bool _showBanner = true;
  bool _showBadge = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        title: const Text('AnimatedBetween.showHide Example'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 16),

            // --- Banner that slides/grows in and out ---
            // Uses overflow mode: the banner stays at its natural
            // (parent-bounded) width while the box opens/closes
            // vertically. fit mode would wrap the child in a
            // FittedBox, which provides unbounded width and breaks
            // the Row + Expanded inside.
            AnimatedBetween.showHide(
              show: _showBanner,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.amber.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.amber.shade700),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.amber.shade900),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Heads up — this banner animates in and out with '
                        'AnimatedBetween.showHide. The surrounding layout '
                        'shifts smoothly as the box grows or shrinks to '
                        'zero size.',
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            FilledButton.icon(
              icon: Icon(_showBanner ? Icons.visibility_off : Icons.visibility),
              label: Text(_showBanner ? 'Hide banner' : 'Show banner'),
              onPressed: () => setState(() => _showBanner = !_showBanner),
            ),

            const Divider(height: 48),

            // --- Small badge inline with text ---
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Notifications',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                const SizedBox(width: 8),
                AnimatedBetween.showHide(
                  show: _showBadge,
                  alignment: Alignment.centerLeft,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.red.shade600,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: const Text(
                      '3 new',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            FilledButton.icon(
              icon: Icon(_showBadge ? Icons.remove : Icons.add),
              label: Text(_showBadge ? 'Clear badge' : 'Show badge'),
              onPressed: () => setState(() => _showBadge = !_showBadge),
            ),

            const Spacer(),

            const Text(
              'AnimatedBetween.showHide animates a single widget in and out. '
              'When show is true the child grows in; when false the box '
              'shrinks to zero size. The grow/shrink timing follows the same '
              'rules as AnimatedBetween.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Colors.black54),
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
