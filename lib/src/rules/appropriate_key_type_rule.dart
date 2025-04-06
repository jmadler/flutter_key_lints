import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

/// A rule that enforces the appropriate key type usage
class AppropriateKeyTypeRule extends DartLintRule {
  /// Creates a new instance of [AppropriateKeyTypeRule]
  const AppropriateKeyTypeRule()
      : super(
          code: const LintCode(
            name: 'appropriate_key_type',
            problemMessage: 'Potentially inappropriate key type',
            correctionMessage:
                'Consider using ValueKey for value-based identification or '
                'UniqueKey for truly unique instances',
          ),
        );

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addNamedExpression((node) {
      // Check for key parameters
      if (node.name.label.name == 'key') {
        final expression = node.expression;

        // Check for GlobalKey usage
        if (expression is InstanceCreationExpression) {
          final constructorType = expression.constructorName.type;
          final typeName = constructorType.toString();

          // GlobalKey should only be used when widget state access is needed
          if (typeName.contains('GlobalKey')) {
            reporter.atNode(
              expression,
              const LintCode(
                name: 'global_key_overuse',
                problemMessage: 'GlobalKey has performance implications',
                correctionMessage: 'Only use GlobalKey when you need to access '
                    'widget state or for navigation. Otherwise, prefer ValueKey or UniqueKey',
              ),
            );
          }

          // Check for raw Key usage
          else if (typeName.contains('Key') &&
              expression.constructorName.name == null) {
            reporter.atNode(
              expression,
              const LintCode(
                name: 'raw_key_usage',
                problemMessage: 'Raw Key instantiation',
                correctionMessage:
                    'Use a specific key type like ValueKey or UniqueKey instead',
              ),
            );
          }
        }

        // Check for potential primitive value directly passed without ValueKey
        else if (expression is StringLiteral ||
            expression is IntegerLiteral ||
            expression is BooleanLiteral) {
          // Report the issue with a more specific code
          reporter.atNode(
            expression,
            const LintCode(
              name: 'unwrapped_key_value',
              problemMessage: 'Primitive value used directly as key',
              correctionMessage:
                  'Wrap primitive values with ValueKey for better type safety',
            ),
          );
        }
      }
    });
  }
}
