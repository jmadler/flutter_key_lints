import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

/// A rule that analyzes the potential performance impact of missing widget keys
class PerformanceImpactRule extends DartLintRule {
  /// Creates a new instance of [PerformanceImpactRule]
  const PerformanceImpactRule()
      : super(
          code: const LintCode(
            name: 'performance_impact',
            problemMessage: 'Widget rebuilds could impact performance',
            correctionMessage:
                'Adding a key could reduce unnecessary rebuilds and improve performance',
          ),
        );

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    // Track the depth of the widget tree to determine complexity
    int treeDepth = 0;
    Map<String, int> widgetCounts = {};

    // Check for widgets with conditional rebuilds (common performance issue)
    context.registry.addIfStatement((node) {
      _analyzeIfStatement(node, reporter);
    });

    // Check for deep widget hierarchies (can exacerbate missing key issues)
    context.registry.addInstanceCreationExpression((node) {
      final type = node.constructorName.type.type;
      if (type == null) return;

      final String typeName = type.toString();
      if (_isWidget(typeName)) {
        widgetCounts[typeName] = (widgetCounts[typeName] ?? 0) + 1;
        treeDepth++; // This is simplified - in reality we'd need to track actual tree depth

        // Check for potential performance issues
        _analyzePotentialIssue(node, reporter, treeDepth, widgetCounts);

        treeDepth--; // Exit the level after processing
      }
    });
  }

  /// Analyze if statements for conditional widgets without keys
  void _analyzeIfStatement(IfStatement node, ErrorReporter reporter) {
    AstNode? conditionalWidget;

    // Look for conditional widgets in then and else branches
    if (node.thenStatement is Block) {
      conditionalWidget = _findWidgetInBlock(node.thenStatement as Block);
    } else if (node.thenStatement is ExpressionStatement) {
      conditionalWidget = _findWidgetInExpression(
          (node.thenStatement as ExpressionStatement).expression);
    }

    // If we found a conditional widget, check if it has a key and is a high impact widget
    if (conditionalWidget != null &&
        conditionalWidget is InstanceCreationExpression) {
      final type = conditionalWidget.constructorName.type.type?.toString() ?? '';
      
      // Check if this widget or its parent has a key
      if (!_hasEffectiveKey(conditionalWidget) && _isHighImpactWidget(type)) {
        // This is a conditional widget without key - high performance impact
        final customMessage =
            'Conditional widget lacking key: ${_getImpactMessage("high")}';

        reporter.atNode(
          conditionalWidget,
          LintCode(
            name: 'performance_impact',
            problemMessage: customMessage,
            correctionMessage:
                'Add a key to this widget to prevent unnecessary rebuilds',
          ),
        );
      }
    }
  }

  /// Find widgets in blocks of code
  InstanceCreationExpression? _findWidgetInBlock(Block block) {
    for (final statement in block.statements) {
      if (statement is ReturnStatement && statement.expression != null) {
        final widget = _findWidgetInExpression(statement.expression!);
        if (widget != null) return widget;
      } else if (statement is ExpressionStatement) {
        final widget = _findWidgetInExpression(statement.expression);
        if (widget != null) return widget;
      }
    }
    return null;
  }

  /// Find widgets in expressions
  InstanceCreationExpression? _findWidgetInExpression(Expression expression) {
    if (expression is InstanceCreationExpression) {
      final type = expression.constructorName.type.type;
      if (type != null && _isWidget(type.toString())) {
        return expression;
      }
    }
    return null;
  }

  /// Analyze potential performance issues in widgets
  void _analyzePotentialIssue(InstanceCreationExpression node,
      ErrorReporter reporter, int depth, Map<String, int> widgetCounts) {
    final type = node.constructorName.type.type;
    if (type == null) return;

    final String typeName = type.toString();

    // Skip checking if widget already has an effective key
    if (_hasEffectiveKey(node)) {
      return;
    }

    // Check for performance risk patterns
    String impactLevel = "low";
    String advice = "";

    // Assess impact level based on various factors
    if (_isListWidget(typeName)) {
      impactLevel = "critical";
      advice =
          "Missing keys in list items cause complete rebuilds and can lose state";
    } else if (_isComplexWidget(typeName)) {
      impactLevel = "high";
      advice =
          "Complex widgets benefit significantly from keys for rebuild optimization";
    } else if (depth > 8) {
      impactLevel = "medium";
      advice =
          "Deep widget tree depth increases the cost of unnecessary rebuilds";
    } else if (widgetCounts[typeName] != null && widgetCounts[typeName]! > 5) {
      impactLevel = "medium";
      advice =
          "Multiple instances of the same widget type should use keys for identification";
    }

    // Only report high impact issues
    if (impactLevel == "critical" || impactLevel == "high") {
      reporter.atNode(
        node,
        LintCode(
          name: 'performance_impact',
          problemMessage:
              'Performance impact (${impactLevel.toUpperCase()}): ${_getImpactMessage(impactLevel)}',
          correctionMessage: advice,
        ),
      );
    }
  }

  /// Get a detailed message based on impact level
  String _getImpactMessage(String level) {
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

  /// Check if a widget is list-related (high impact for keys)
  bool _isListWidget(String typeName) {
    return typeName == 'ListView' ||
        typeName == 'GridView' ||
        typeName == 'ListTile' ||
        typeName.startsWith('ListView.') ||
        typeName.startsWith('GridView.');
  }

  /// Check if a widget is considered complex (would benefit from keys)
  bool _isComplexWidget(String typeName) {
    return typeName.contains('Form') ||
        typeName.startsWith('Sliver') ||
        typeName == 'Table' ||
        typeName == 'AnimatedSwitcher' ||
        typeName == 'AnimatedList';
  }

  /// Check if a widget is likely to have high performance impact without keys
  bool _isHighImpactWidget(String typeName) {
    return _isListWidget(typeName) ||
        typeName.startsWith('Animated') ||
        typeName == 'ExpansionTile' ||
        typeName == 'Dismissible' ||
        typeName == 'Draggable' ||
        typeName == 'DragTarget';
  }

  /// More precise check if a type is a widget
  bool _isWidget(String typeName) {
    // Common Flutter widgets that should be checked
    final widgetTypes = [
      'ListView', 'GridView', 'Table', 'Column', 'Row',
      'Stack', 'Wrap', 'Container', 'Card', 'Scaffold',
      'AnimatedContainer', 'AnimatedSwitcher', 'ExpansionTile',
      'Draggable', 'Dismissible', 'ReorderableListView',
    ];
    
    // Check if it's a known widget type or clearly a custom widget
    return typeName.endsWith('Widget') ||
        widgetTypes.any((widget) => 
            typeName == widget || 
            typeName.startsWith('$widget.'));
  }

  /// Check if a node has an effective key (either direct or via parent)
  bool _hasEffectiveKey(InstanceCreationExpression node) {
    // Check direct key parameter
    if (_hasKeyParameter(node)) {
      return true;
    }

    // Additionally check if this widget is wrapped inside a parent with a key
    final parent = node.parent;
    if (parent is NamedExpression) {
      final grandParent = parent.parent;
      if (grandParent is ArgumentList) {
        final greatGrandParent = grandParent.parent;
        if (greatGrandParent is InstanceCreationExpression) {
          return _hasKeyParameter(greatGrandParent);
        }
      }
    }

    return false;
  }

  /// Check if a node has a key parameter
  bool _hasKeyParameter(InstanceCreationExpression node) {
    for (final argument in node.argumentList.arguments) {
      if (argument is NamedExpression) {
        final name = argument.name.label.name;
        if (name == 'key') {
          // Check if key value is not null
          final value = argument.expression;
          if (value is! NullLiteral) {
            return true;
          }
        }
      }
    }
    return false;
  }
}
