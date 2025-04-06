import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

/// A rule that requires list items to have a key that uses their index
class ListItemKeyRule extends DartLintRule {
  /// Creates a new instance of [ListItemKeyRule]
  const ListItemKeyRule()
      : super(
          code: const LintCode(
            name: 'list_item_key',
            problemMessage: 'List items should have a key based on unique data',
            correctionMessage:
                'Consider adding a key using ValueKey with a unique identifier',
          ),
        );

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addInstanceCreationExpression((node) {
      final type = node.constructorName.type.type;
      if (type == null) return;

      final String typeName = type.toString();

      // Check for ListView.builder, GridView.builder, etc.
      if (_isListViewBuilder(typeName, node)) {
        // Find the itemBuilder parameter
        for (final argument in node.argumentList.arguments) {
          if (argument is NamedExpression &&
              argument.name.label.name == 'itemBuilder') {
            _checkItemBuilder(argument.expression, reporter);
          }
        }
      }
    });
  }

  bool _isListViewBuilder(String typeName, InstanceCreationExpression node) {
    if (typeName == 'ListView' || typeName == 'GridView') {
      final constructorName = node.constructorName.name?.name;
      return constructorName == 'builder' || constructorName == 'separated';
    }
    return false;
  }

  void _checkItemBuilder(Expression expression, ErrorReporter reporter) {
    if (expression is! FunctionExpression) return;

    // Analyze the function body for widgets that might need keys
    final body = expression.body;
    if (body is BlockFunctionBody) {
      final returnStatement =
          body.block.statements.whereType<ReturnStatement>().firstOrNull;
      if (returnStatement != null) {
        _checkWidgetForKey(returnStatement.expression, reporter);
      }
    } else if (body is ExpressionFunctionBody) {
      _checkWidgetForKey(body.expression, reporter);
    }
  }

  void _checkWidgetForKey(Expression? expression, ErrorReporter reporter) {
    if (expression == null) return;

    // If it's a widget creation that doesn't have a key parameter
    if (expression is InstanceCreationExpression) {
      final type = expression.constructorName.type.type;
      if (type == null) return;

      if (_isWidgetType(type) && !_hasKeyParameter(expression)) {
        reporter.atNode(expression, code);
      }
    }
  }

  bool _isWidgetType(DartType type) {
    // Check if it's a Widget type or subtype
    if (type is InterfaceType) {
      if (_isWidgetTypeName(type.element.name)) {
        return true;
      }

      // Check superclasses
      var supertype = type.superclass;
      while (supertype != null) {
        if (_isWidgetTypeName(supertype.element.name)) {
          return true;
        }
        supertype = supertype.superclass;
      }
    }
    return false;
  }

  bool _isWidgetTypeName(String name) {
    return name == 'Widget' || name.endsWith('Widget');
  }

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
