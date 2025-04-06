import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

/// A rule that requires all widget instantiations to have a key parameter
class RequireWidgetKeyRule extends DartLintRule {
  /// List of widgets that don't need keys by default
  static const List<String> _defaultExemptWidgets = <String>[
    'Divider',
    'SizedBox',
    'Spacer',
    'Opacity',
    'Padding',
    'Center',
    'Align',
    'AspectRatio',
    'Semantics',
    'IgnorePointer',
    'Transform',
    'ClipRect',
    'ClipOval',
    'ClipRRect',
    'AnimatedBuilder',
    'InheritedWidget',
    'DefaultTextStyle',
    'MediaQuery',
    'Theme',
  ];

  /// The list of widget types that don't require keys
  final List<String> exemptWidgets;

  /// Creates a new instance of [RequireWidgetKeyRule]
  const RequireWidgetKeyRule({
    this.exemptWidgets = _defaultExemptWidgets,
    required severity,
  }) : super(
          code: const LintCode(
            name: 'require_widget_key',
            problemMessage:
                'All widgets should have a key parameter for better performance',
            correctionMessage:
                'Consider adding a key parameter to enhance widget rebuilding efficiency',
          ),
        );

  /// Create a rule instance from the given [json] configuration.
  factory RequireWidgetKeyRule.fromJson(Map<String, dynamic> json) {
    return RequireWidgetKeyRule(
      exemptWidgets: json['exempt_widgets'] is List
          ? List<String>.from(json['exempt_widgets'] as List)
          : _defaultExemptWidgets,
      severity: (json['severity'] as String?) ?? 'warning',
    );
  }

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addInstanceCreationExpression((node) {
      // Skip if this is a const constructor (const widgets are optimized already)
      if (node.isConst) return;

      final type = node.constructorName.type.type;
      if (type == null) return;

      // Skip certain widgets that don't benefit from keys or are used in contexts
      // where keys aren't typically needed
      final String typeName = type.toString();
      if (_isExemptWidget(typeName)) return;

      // Check if it's a Widget subclass
      if (_isWidgetType(type) && !_hasKeyParameter(node)) {
        reporter.atNode(node, code);
      }
    });
  }

  bool _isExemptWidget(String typeName) {
    // List of widgets that don't necessarily need keys or are used in contexts
    // where keys aren't typically needed
    return exemptWidgets.contains(typeName);
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
