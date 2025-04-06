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
      if (_isWidgetType(typeName)) {
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

    // If we found a conditional widget, check if it has a key
    if (conditionalWidget != null &&
        conditionalWidget is InstanceCreationExpression) {
      if (!_hasKeyParameter(conditionalWidget)) {
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
      if (type != null && _isWidgetType(type.toString())) {
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

    // Check for performance risk patterns
    String impactLevel = "low";
    String advice = "";

    // Assess impact level based on various factors
    if (_isListWidget(typeName) && !_hasKeyParameter(node)) {
      impactLevel = "critical";
      advice =
          "Missing keys in list items cause complete rebuilds and can lose state";
    } else if (_isComplexWidget(typeName) && !_hasKeyParameter(node)) {
      impactLevel = "high";
      advice =
          "Complex widgets benefit significantly from keys for rebuild optimization";
    } else if (depth > 5 && !_hasKeyParameter(node)) {
      impactLevel = "medium";
      advice =
          "Deep widget tree depth increases the cost of unnecessary rebuilds";
    } else if (widgetCounts[typeName] != null && widgetCounts[typeName]! > 3) {
      impactLevel = "medium";
      advice =
          "Multiple instances of the same widget type should use keys for identification";
    }

    // Only report non-low impact issues
    if (impactLevel != "low") {
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
    return typeName.contains('ListView') ||
        typeName.contains('GridView') ||
        typeName.contains('ListTile');
  }

  /// Check if a widget is considered complex (would benefit from keys)
  bool _isComplexWidget(String typeName) {
    return typeName.contains('Form') ||
        typeName.contains('Animated') ||
        typeName.contains('Sliver') ||
        typeName.contains('Table');
  }

  /// Check if a type is likely a widget
  bool _isWidgetType(String typeName) {
    return typeName.contains('Widget') ||
        typeName.endsWith('View') ||
        typeName.endsWith('Bar') ||
        typeName.endsWith('Button');
  }

  /// Check if a node has a key parameter
  bool _hasKeyParameter(InstanceCreationExpression node) {
    for (final argument in node.argumentList.arguments) {
      if (argument is NamedExpression) {
        final name = argument.name.label.name;
        if (name == 'key') {
          return true;
        }
      }
    }
    return false;
  }
}
