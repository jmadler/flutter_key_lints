import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

/// A rule that enforces proper key usage in animations to prevent flickering and state loss
class AnimationKeyRule extends DartLintRule {
  /// Creates a new instance of [AnimationKeyRule]
  const AnimationKeyRule()
      : super(
          code: const LintCode(
            name: 'animation_key',
            problemMessage: 'Animations should have keys to prevent flickering',
            correctionMessage:
                'Add a key to help Flutter correctly identify this widget during animations',
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

      // Check for animation-related widgets
      if (_isAnimationWidget(typeName) && !_hasKeyParameter(node)) {
        reporter.atNode(node, code);
      }
    });
  }

  bool _isAnimationWidget(String typeName) {
    return typeName.contains('Animated') ||
        typeName.contains('Animation') ||
        typeName.contains('Transition') ||
        typeName == 'Hero';
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
