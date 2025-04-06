import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'src/test_helpers.dart';

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
      final containerWithKey = tester.widgetList<Container>(find.byType(Container)).where((w) => w.child is Text).first;
      expect(containerWithKey.key, isNotNull);
      expect(find.text('Conditional Widget'), findsOneWidget);
      
      // Test conditional widget without key, condition true
      await tester.pumpWidget(buildConditionalWidget(useKey: false, condition: true));
      
      // Verify the widget exists but doesn't have a key
      final containerWithoutKey = tester.widgetList<Container>(find.byType(Container)).where((w) => w.child is Text).first;
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
      final containers = tester.widgetList<Container>(find.byType(Container)).toList();
      
      // Verify we have 4 containers
      expect(containers.length, equals(4));
      
      // Verify each container has a key of the expected type
      expect(containers[0].key, isA<ValueKey<String>>());
      expect(containers[1].key, isA<UniqueKey>());
      expect(containers[2].key, isA<GlobalKey>());
      expect(containers[3].key, isA<ObjectKey>());
    });
    
    testWidgets('Exempt widgets without keys', (WidgetTester tester) async {
      // Build a widget with exempt widgets that don't need keys
      await tester.pumpWidget(MaterialApp(
        home: Column(
          children: [
            // SizedBox - exempt
            const SizedBox(height: 10),
            
            // Divider - exempt
            const Divider(),
            
            // Padding - exempt
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text('Padded text'),
            ),
            
            // Container - not exempt, should have key
            Container(
              key: const ValueKey('container'),
              color: Colors.blue,
              child: const Text('This container should have a key'),
            ),
          ],
        ),
      ));
      
      // Verify exempt widgets don't have keys (and don't need them)
      final sizedBoxes = tester.widgetList<SizedBox>(find.byType(SizedBox)).toList();
      expect(sizedBoxes.any((widget) => widget.height == 10 && widget.key == null), isTrue);
      
      final dividers = tester.widgetList<Divider>(find.byType(Divider)).toList();
      expect(dividers.any((widget) => widget.key == null), isTrue);
      
      final paddings = tester.widgetList<Padding>(find.byType(Padding)).toList();
      expect(paddings.any((widget) => widget.key == null && widget.child is Text), isTrue);
      
      // Find the container with our specific key
      final container = tester.widget<Container>(find.byKey(const ValueKey('container')));
      expect(container.key, isNotNull);
    });
  });
} 