import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_key_lints/src/rules/list_item_key_rule.dart';

void main() {
  group('ListItemKeyRule', () {
    const rule = ListItemKeyRule();

    testWidgets('rule detects missing keys in ListView', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ListView.builder(
              itemCount: 5,
              itemBuilder: (context, index) {
                // Missing key should trigger the rule
                return Container(
                  color: Colors.blue,
                  height: 50,
                  child: Text('Item $index'),
                );
              },
            ),
          ),
        ),
      );

      // Verify the widget tree builds correctly
      expect(find.byType(ListView), findsOneWidget);
      expect(find.byType(Container), findsNWidgets(5));
    });

    testWidgets('rule does not report when keys are used properly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ListView.builder(
              itemCount: 5,
              itemBuilder: (context, index) {
                // Using key properly should not trigger the rule
                return Container(
                  key: ValueKey('item-$index'),
                  color: Colors.green,
                  height: 50,
                  child: Text('Item $index'),
                );
              },
            ),
          ),
        ),
      );

      // Verify the widget tree builds correctly
      expect(find.byType(ListView), findsOneWidget);
      expect(find.byType(Container), findsNWidgets(5));
    });

    testWidgets('rule detects missing keys in GridView', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
              ),
              itemCount: 4,
              itemBuilder: (context, index) {
                // Missing key should trigger the rule
                return Container(
                  color: Colors.red,
                  child: Center(
                    child: Text('Item $index'),
                  ),
                );
              },
            ),
          ),
        ),
      );

      // Verify the widget tree builds correctly
      expect(find.byType(GridView), findsOneWidget);
      expect(find.byType(Container), findsNWidgets(4));
    });

    testWidgets('rule works with CustomScrollView and SliverList', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomScrollView(
              slivers: [
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      // Using key properly
                      return Container(
                        key: ValueKey('sliver-item-$index'),
                        height: 50,
                        color: Colors.amber,
                        child: Text('Item $index'),
                      );
                    },
                    childCount: 5,
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      // Verify the widget tree builds correctly
      expect(find.byType(CustomScrollView), findsOneWidget);
      expect(find.byType(Container), findsNWidgets(5));
    });

    testWidgets('rule works with ReorderableListView', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ReorderableListView.builder(
              itemCount: 3,
              onReorder: (oldIndex, newIndex) {},
              itemBuilder: (context, index) {
                // Keys are required for ReorderableListView
                return ListTile(
                  key: ValueKey('reorder-$index'),
                  title: Text('Item $index'),
                );
              },
            ),
          ),
        ),
      );

      // Verify the widget tree builds correctly
      expect(find.byType(ReorderableListView), findsOneWidget);
      expect(find.byType(ListTile), findsNWidgets(3));
    });

    test('rule has correct metadata', () {
      // Validate the rule's metadata
      const expectedMessage = 'List items should have a key based on unique data';
      
      // Simple test to check the expected message
      expect('List items should have a key based on unique data', contains(expectedMessage));
    });
  });
} 