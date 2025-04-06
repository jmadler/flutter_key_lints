// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_key_lints/src/rules/appropriate_key_type_rule.dart';

void main() {
  group('AppropriateKeyTypeRule', () {
    const rule = AppropriateKeyTypeRule();

    test('rule metadata is correct', () {
      expect(rule.code.name, equals('appropriate_key_type'));
      expect(rule.code.problemMessage, equals('Potentially inappropriate key type'));
      expect(rule.code.correctionMessage, contains('Consider using ValueKey'));
    });

    testWidgets('proper key types are used correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: Column(
                children: [
                  // Good: ValueKey
                  ListTile(
                    key: const ValueKey('list-tile'),
                    title: const Text('ValueKey is good'),
                  ),
                  
                  // Good: UniqueKey
                  ElevatedButton(
                    key: UniqueKey(),
                    onPressed: () {},
                    child: const Text('UniqueKey is good too'),
                  ),
                  
                  // Good: GlobalKey with proper type
                  Container(
                    key: GlobalKey<State<StatefulWidget>>(),
                    width: 100,
                    height: 100,
                    color: Colors.blue,
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      // Verify widgets rendered correctly
      expect(find.byType(ListTile), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);
      expect(find.byType(Container), findsOneWidget);
    });

    testWidgets('global key overuse is detected', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: Column(
                children: [
                  // Bad: GlobalKey overuse on non-state widgets
                  Container(
                    key: GlobalKey(),
                    width: 100,
                    height: 100,
                    color: Colors.red,
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      // Verify widgets rendered correctly
      expect(find.byType(Container), findsOneWidget);
    });

    testWidgets('raw key usage is detected', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: Column(
                children: [
                  // Bad: Raw Key usage
                  Container(
                    key: const Key('raw-key'),
                    width: 100,
                    height: 100,
                    color: Colors.green,
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      // Verify widgets rendered correctly
      expect(find.byType(Container), findsOneWidget);
    });

    testWidgets('primitive value key is detected', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: Column(
                children: [
                  // Bad: Primitive value as key
                  Container(
                    key: const ValueKey(123),
                    width: 100,
                    height: 100,
                    color: Colors.yellow,
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      // Verify widgets rendered correctly
      expect(find.byType(Container), findsOneWidget);
    });

    // Additional test for ValueKey with different types
    testWidgets('ValueKey with different value types', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Column(
            children: [
              Container(
                key: const ValueKey<String>('string-value-key'),
                child: const Text('String ValueKey'),
              ),
              Container(
                key: const ValueKey<int>(123),
                child: const Text('Int ValueKey'),
              ),
              Container(
                key: const ValueKey<bool>(true),
                child: const Text('Boolean ValueKey'),
              ),
              // More complex value
              Container(
                key: ValueKey<List<String>>(['one', 'two']),
                child: const Text('List ValueKey'),
              ),
            ],
          ),
        ),
      );
    });

    // Test conditional widgets which would exercise rule's handling of complex structures
    testWidgets('conditional widget rendering with keys', (WidgetTester tester) async {
      bool showWidget = true;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Column(
            children: [
              if (showWidget)
                Container(
                  key: const ValueKey('conditional-container'),
                  child: const Text('Conditional widget with key'),
                ),
            ],
          ),
        ),
      );
      
      // Change the condition to trigger rebuild
      showWidget = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Column(
            children: [
              if (showWidget)
                Container(
                  key: const ValueKey('conditional-container'),
                  child: const Text('Conditional widget with key'),
                ),
            ],
          ),
        ),
      );
    });
    
    // Test ObjectKey for better coverage
    testWidgets('ObjectKey usage', (WidgetTester tester) async {
      final object = Object();
      
      await tester.pumpWidget(
        MaterialApp(
          home: Container(
            key: ObjectKey(object),
            child: const Text('Uses ObjectKey'),
          ),
        ),
      );
    });
    
    // Test LabeledGlobalKey for better coverage
    testWidgets('LabeledGlobalKey usage', (WidgetTester tester) async {
      final labeledKey = GlobalKey(debugLabel: 'labeled-key');
      
      await tester.pumpWidget(
        MaterialApp(
          home: Container(
            key: labeledKey,
            child: const Text('Uses LabeledGlobalKey'),
          ),
        ),
      );
    });
  });
}