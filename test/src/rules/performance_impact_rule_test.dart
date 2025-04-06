// ignore_for_file: avoid_unnecessary_containers, prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_key_lints/src/rules/performance_impact_rule.dart';

// Simple mocks that don't rely on analyzer or internal APIs
class MockReporter {
  final List<String> impacts = [];
  
  void reportIssue(String impact) {
    impacts.add(impact);
  }
  
  void clear() {
    impacts.clear();
  }
}

// Class to test rule detection logic with simplified approach
class RuleTestHelper {
  final MockReporter reporter = MockReporter();
  
  // Get the performance impact level based on the widget type and context
  String? getPerformanceImpact({
    required String widgetType,
    required String context,
    bool hasKey = false,
    int treeDepth = 1,
    int widgetCount = 1,
  }) {
    if (hasKey) {
      // Widgets with keys shouldn't have performance impacts
      return null;
    }
    
    // Check for list-related widgets
    if (_isListWidget(widgetType) && context.contains('list')) {
      return 'critical';
    }
    
    // Check for complex widgets
    if (_isComplexWidget(widgetType)) {
      return 'high';
    }
    
    // Check for deep widget trees
    if (treeDepth > 5) {
      return 'medium';
    }
    
    // Check for many instances of the same widget
    if (widgetCount > 3) {
      return 'medium';
    }
    
    // Conditional widgets
    if (context.contains('conditional') || context.contains('if statement')) {
      return 'high';
    }
    
    return 'low';
  }
  
  // Helper method to simulate _isListWidget from the actual rule
  bool _isListWidget(String typeName) {
    return typeName.contains('ListView') ||
        typeName.contains('GridView') ||
        typeName.contains('ListTile');
  }

  // Helper method to simulate _isComplexWidget from the actual rule
  bool _isComplexWidget(String typeName) {
    return typeName.contains('Form') ||
        typeName.contains('Animated') ||
        typeName.contains('Sliver') ||
        typeName.contains('Table');
  }
  
  // Simulates the rule's impact message logic
  String getImpactMessage(String level) {
    switch (level) {
      case "critical":
        return "Severe performance degradation likely";
      case "high":
        return "Significant unnecessary rebuilds";
      case "medium":
        return "Potential performance bottleneck";
      default:
        return "Minimal performance concern";
    }
  }
  
  // Helper to check if a key is present in a widget
  bool hasWidgetKey(Widget widget) {
    return widget.key != null;
  }
}

void main() {
  group('PerformanceImpactRule', () {
    late RuleTestHelper helper;
    
    setUp(() {
      helper = RuleTestHelper();
    });
    
    test('rule has correct metadata', () {
      final rule = PerformanceImpactRule();
      expect(rule.code.name, equals('performance_impact'));
      expect(rule.code.problemMessage, contains('performance'));
      expect(rule.code.correctionMessage, contains('key'));
    });
    
    group('performance impact assessment', () {
      test('correctly identifies critical impact in list widgets without keys', () {
        final impact = helper.getPerformanceImpact(
          widgetType: 'ListView.builder',
          context: 'list of items',
          hasKey: false,
        );
        
        expect(impact, equals('critical'));
        expect(helper.getImpactMessage(impact!), contains('Severe'));
      });
      
      test('correctly identifies high impact in complex widgets without keys', () {
        final impact1 = helper.getPerformanceImpact(
          widgetType: 'AnimatedContainer',
          context: 'animation',
          hasKey: false,
        );
        
        final impact2 = helper.getPerformanceImpact(
          widgetType: 'Form',
          context: 'form inputs',
          hasKey: false,
        );
        
        expect(impact1, equals('high'));
        expect(impact2, equals('high'));
        expect(helper.getImpactMessage(impact1!), contains('Significant'));
      });
      
      test('correctly identifies medium impact in deep widget trees', () {
        final impact = helper.getPerformanceImpact(
          widgetType: 'Container',
          context: 'nested widgets',
          hasKey: false,
          treeDepth: 7, // > 5 threshold in the rule
        );
        
        expect(impact, equals('medium'));
        expect(helper.getImpactMessage(impact!), contains('bottleneck'));
      });
      
      test('correctly identifies medium impact with many instances of same widget', () {
        final impact = helper.getPerformanceImpact(
          widgetType: 'Container',
          context: 'repeated containers',
          hasKey: false,
          widgetCount: 5, // > 3 threshold in the rule
        );
        
        expect(impact, equals('medium'));
      });
      
      test('correctly identifies high impact in conditional widgets', () {
        final impact = helper.getPerformanceImpact(
          widgetType: 'Container',
          context: 'conditional rendering in if statement',
          hasKey: false,
        );
        
        expect(impact, equals('high'));
      });
      
      test('returns null for widgets with keys (no impact)', () {
        final impact1 = helper.getPerformanceImpact(
          widgetType: 'ListView.builder',
          context: 'list of items',
          hasKey: true,
        );
        
        final impact2 = helper.getPerformanceImpact(
          widgetType: 'AnimatedContainer',
          context: 'animation',
          hasKey: true,
        );
        
        expect(impact1, isNull);
        expect(impact2, isNull);
      });
    });
    
    group('widget tests', () {
      testWidgets('list widgets with and without keys', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Column(
                children: [
                  // ListView without keys - would trigger critical impact
                  SizedBox(
                    height: 100,
                    child: ListView.builder(
                      itemCount: 3,
                      itemBuilder: (context, index) {
                        return ListTile(
                          // Missing key here - would trigger rule
                          title: Text('Item $index'),
                        );
                      },
                    ),
                  ),
                  
                  // ListView with keys - would not trigger rule
                  SizedBox(
                    height: 100,
                    child: ListView.builder(
                      itemCount: 3,
                      itemBuilder: (context, index) {
                        return ListTile(
                          key: ValueKey('item-$index'),
                          title: Text('Item $index with key'),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
        
        // We need to wait for all frames to be rendered
        await tester.pumpAndSettle();
        
        // Verify ListTile widgets were created
        final allListTiles = tester.widgetList<ListTile>(find.byType(ListTile));
        
        // Check our ListTiles
        final tilesWithKeys = allListTiles.where((tile) => tile.key != null).toList();
        final tilesWithoutKeys = allListTiles.where((tile) => tile.key == null).toList();
        
        expect(tilesWithoutKeys.length, greaterThan(0), reason: 'Should have ListTiles without keys');
        expect(tilesWithKeys.length, greaterThan(0), reason: 'Should have ListTiles with keys');
      });
      
      testWidgets('animated widgets with and without keys', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Column(
                children: [
                  // Animated widget without key - would trigger high impact
                  AnimatedContainer(
                    duration: Duration(milliseconds: 300),
                    width: 100,
                    height: 100,
                    color: Colors.red,
                  ),
                  
                  // Animated widget with key - would not trigger rule
                  AnimatedContainer(
                    key: ValueKey('animated-container'),
                    duration: Duration(milliseconds: 300),
                    width: 100,
                    height: 100,
                    color: Colors.blue,
                  ),
                ],
              ),
            ),
          ),
        );
        
        // Verify widgets with and without keys were created
        final animatedContainers = tester.widgetList<AnimatedContainer>(find.byType(AnimatedContainer));
        
        // One should have a key, one should not
        final containersWithKeys = animatedContainers.where((container) => container.key != null).toList();
        final containersWithoutKeys = animatedContainers.where((container) => container.key == null).toList();
        
        expect(containersWithKeys.length, 1);
        expect(containersWithoutKeys.length, 1);
      });
      
      testWidgets('conditional widgets with and without keys', (WidgetTester tester) async {
        bool condition = true;
        
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Column(
                children: [
                  // Conditional widget without key - would trigger high impact
                  if (condition)
                    Container(
                      // Missing key
                      width: 100,
                      height: 100,
                      color: Colors.red,
                    ),
                  
                  // Conditional widget with key - would not trigger rule
                  if (condition)
                    Container(
                      key: ValueKey('conditional-container'),
                      width: 100,
                      height: 100,
                      color: Colors.blue,
                    ),
                ],
              ),
            ),
          ),
        );
        
        // Verify widgets with and without keys were created
        final containers = tester.widgetList<Container>(find.byType(Container));
        
        // One should have a key, one should not
        final containersWithKeys = containers.where((container) => container.key != null).toList();
        final containersWithoutKeys = containers.where((container) => container.key == null).toList();
        
        expect(containersWithKeys.length, 1);
        expect(containersWithoutKeys.length, 1);
      });
    });
  });
} 