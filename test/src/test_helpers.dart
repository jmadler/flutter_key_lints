import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

/// Verifies the basic metadata of a lint rule
void verifyRuleMetadata({
  required DartLintRule rule,
  required String name,
  required String problemMessageSubstring,
  required String correctionMessageSubstring,
}) {
  expect(rule.code.name, equals(name));
  expect(rule.code.problemMessage, contains(problemMessageSubstring));
  expect(rule.code.correctionMessage, contains(correctionMessageSubstring));
}

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
    home: Scaffold(
      body: Column(
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
    ),
  );
}

/// Simple reporter for use in testing
class SimpleReporter {
  final List<String> errors = [];
  
  void reportIssue(String message) {
    errors.add(message);
  }
  
  void clear() {
    errors.clear();
  }
} 