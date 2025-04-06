import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Widget builder that creates a list view with or without keys
Widget buildListView({required bool useKeys}) {
  final items = ['Item 1', 'Item 2', 'Item 3'];
  
  return MaterialApp(
    home: Scaffold(
      body: ListView.builder(
        itemCount: items.length,
        itemBuilder: (context, index) {
          return ListTile(
            key: useKeys ? ValueKey(items[index]) : null,
            title: Text(items[index]),
          );
        },
      ),
    ),
  );
}

/// Widget builder that creates a conditional widget with or without a key
Widget buildConditionalWidget({required bool useKey, required bool condition}) {
  return MaterialApp(
    home: Scaffold(
      body: Column(
        children: [
          if (condition)
            Container(
              key: useKey ? const ValueKey('conditional-widget') : null,
              color: Colors.blue,
              child: const Text('Conditional Widget'),
            ),
        ],
      ),
    ),
  );
}

/// Widget builder that creates animation widgets with or without keys
Widget buildAnimationWidgets({required bool useKeys}) {
  return MaterialApp(
    home: Column(
      children: [
        AnimatedContainer(
          key: useKeys ? const ValueKey('animated-container') : null,
          duration: const Duration(milliseconds: 300),
          width: 100,
          height: 100,
          color: Colors.red,
        ),
        AnimatedOpacity(
          key: useKeys ? const ValueKey('animated-opacity') : null,
          duration: const Duration(milliseconds: 300),
          opacity: 0.5,
          child: Container(),
        ),
        SizedBox(
          height: 100,
          child: Stack(
            children: [
              AnimatedPositioned(
                key: useKeys ? const ValueKey('animated-positioned') : null,
                duration: const Duration(milliseconds: 300),
                left: 0,
                child: Container(width: 50, height: 50, color: Colors.blue),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

void main() {
  group('Widget configurations', () {
    testWidgets('ListView with and without keys', (WidgetTester tester) async {
      // Test ListView with keys
      await tester.pumpWidget(buildListView(useKeys: true));
      
      // Get the ListTiles and verify they have keys
      final listTilesWithKeys = tester.widgetList<ListTile>(find.byType(ListTile));
      for (final tile in listTilesWithKeys) {
        expect(tile.key, isNotNull);
      }
      
      // Test ListView without keys
      await tester.pumpWidget(buildListView(useKeys: false));
      
      // Get the ListTiles and verify they don't have keys
      final listTilesWithoutKeys = tester.widgetList<ListTile>(find.byType(ListTile));
      for (final tile in listTilesWithoutKeys) {
        expect(tile.key, isNull);
      }
    });
    
    testWidgets('Conditional widgets with and without keys', (WidgetTester tester) async {
      // Test conditional widget with key, condition true
      await tester.pumpWidget(buildConditionalWidget(useKey: true, condition: true));
      
      // Verify the widget exists and has a key
      final containerWithKey = tester.widget<Container>(find.byType(Container));
      expect(containerWithKey.key, isNotNull);
      expect(find.text('Conditional Widget'), findsOneWidget);
      
      // Test conditional widget without key, condition true
      await tester.pumpWidget(buildConditionalWidget(useKey: false, condition: true));
      
      // Verify the widget exists but doesn't have a key
      final containerWithoutKey = tester.widget<Container>(find.byType(Container));
      expect(containerWithoutKey.key, isNull);
      
      // Test conditional widget with key, condition false
      await tester.pumpWidget(buildConditionalWidget(useKey: true, condition: false));
      
      // Verify the widget doesn't exist
      expect(find.text('Conditional Widget'), findsNothing);
    });
    
    testWidgets('Animation widgets with and without keys', (WidgetTester tester) async {
      // Test animation widgets with keys
      await tester.pumpWidget(buildAnimationWidgets(useKeys: true));
      
      // Verify that AnimatedContainer has a key
      final animatedContainerWithKey = tester.widget<AnimatedContainer>(
        find.byType(AnimatedContainer)
      );
      expect(animatedContainerWithKey.key, isNotNull);
      
      // Verify that AnimatedOpacity has a key
      final animatedOpacityWithKey = tester.widget<AnimatedOpacity>(
        find.byType(AnimatedOpacity)
      );
      expect(animatedOpacityWithKey.key, isNotNull);
      
      // Verify that AnimatedPositioned has a key
      final animatedPositionedWithKey = tester.widget<AnimatedPositioned>(
        find.byType(AnimatedPositioned)
      );
      expect(animatedPositionedWithKey.key, isNotNull);
      
      // Test animation widgets without keys
      await tester.pumpWidget(buildAnimationWidgets(useKeys: false));
      
      // Verify that AnimatedContainer doesn't have a key
      final animatedContainerWithoutKey = tester.widget<AnimatedContainer>(
        find.byType(AnimatedContainer)
      );
      expect(animatedContainerWithoutKey.key, isNull);
      
      // Verify that AnimatedOpacity doesn't have a key
      final animatedOpacityWithoutKey = tester.widget<AnimatedOpacity>(
        find.byType(AnimatedOpacity)
      );
      expect(animatedOpacityWithoutKey.key, isNull);
      
      // Verify that AnimatedPositioned doesn't have a key
      final animatedPositionedWithoutKey = tester.widget<AnimatedPositioned>(
        find.byType(AnimatedPositioned)
      );
      expect(animatedPositionedWithoutKey.key, isNull);
    });
    
    testWidgets('Different key types in widgets', (WidgetTester tester) async {
      // Build a widget with different key types
      await tester.pumpWidget(MaterialApp(
        home: Column(
          children: [
            // ValueKey
            Container(
              key: const ValueKey('value-key'),
              height: 50,
              color: Colors.red,
            ),
            // UniqueKey
            Builder(builder: (context) {
              final uniqueKey = UniqueKey();
              return Container(
                key: uniqueKey,
                height: 50,
                color: Colors.green,
              );
            }),
            // GlobalKey
            Builder(builder: (context) {
              final globalKey = GlobalKey();
              return Container(
                key: globalKey,
                height: 50,
                color: Colors.blue,
              );
            }),
            // ObjectKey
            Container(
              key: ObjectKey(Object()),
              height: 50,
              color: Colors.yellow,
            ),
          ],
        ),
      ));
      
      // Find all containers
      final containers = tester.widgetList<Container>(find.byType(Container));
      
      // Verify we have 4 containers
      expect(containers.length, equals(4));
      
      // Verify each container has a key of the expected type
      expect(containers.elementAt(0).key, isA<ValueKey<String>>());
      expect(containers.elementAt(1).key, isA<UniqueKey>());
      expect(containers.elementAt(2).key, isA<GlobalKey>());
      expect(containers.elementAt(3).key, isA<ObjectKey>());
    });
    
    testWidgets('Exempt widgets without keys', (WidgetTester tester) async {
      // Build a widget with exempt widgets that don't need keys
      await tester.pumpWidget(MaterialApp(
        home: Column(
          children: [
            // SizedBox - exempt
            const SizedBox(
              key: ValueKey('sizedbox-for-test'), // Adding a key just for testing
              height: 10,
              child: SizedBox.shrink(),
            ),
            
            // Divider - exempt
            const Divider(
              key: ValueKey('divider-for-test'), // Adding a key just for testing
            ),
            
            // Padding - exempt
            const Padding(
              key: ValueKey('padding-for-test'), // Adding a key just for testing
              padding: EdgeInsets.all(8.0),
              child: Text('Padded text'),
            ),
            
            // Container - not exempt, should have key in real code
            Container(
              key: const ValueKey('container'),
              color: Colors.blue,
              child: const Text('This container should have a key'),
            ),
          ],
        ),
      ));
      
      // Verify exempt widgets (in real code they don't need keys, but we added keys for testing purposes)
      expect(find.byKey(const ValueKey('sizedbox-for-test')), findsOneWidget);
      expect(find.byKey(const ValueKey('divider-for-test')), findsOneWidget);
      expect(find.byKey(const ValueKey('padding-for-test')), findsOneWidget);
      
      // Verify the non-exempt widget has a key
      expect(find.byKey(const ValueKey('container')), findsOneWidget);
      
      // The point here is to demonstrate that in real Flutter code:
      // - Layout widgets like SizedBox, Divider, Padding don't typically need keys
      // - Widgets like Container that manage state or are in dynamic lists should have keys
    });
  });
} 