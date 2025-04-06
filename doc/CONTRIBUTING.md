# Contributing to Flutter Key Lints

Thank you for your interest in contributing to Flutter Key Lints! This document outlines the process for contributing to this project.

## Getting Started

1. Fork the repository
2. Clone your fork: `git clone https://github.com/jmadler/flutter_key_lints.git`
3. Set up your development environment: `dart pub get`
4. Run tests to ensure everything is working: `flutter test`

## Development Workflow

1. Create a new branch for your feature or bugfix: `git checkout -b feature/your-feature-name`
2. Make your changes
3. Test your changes:
   - Run the linter on itself: `dart run custom_lint`
   - Run the example app: `cd example && dart run custom_lint`
   - Run tests: `flutter test`
4. Submit a pull request

## Adding a New Rule

To add a new rule:

1. Create a new file in `lib/src/rules/` (e.g., `your_rule_name_rule.dart`)
2. Implement the rule by extending `DartLintRule`
3. Add your rule to `lib/key_lints.dart`
4. Add tests in the `test` directory
5. Update documentation to reflect the new rule

Here's a template for a new rule:

```dart
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

/// A rule that...
class YourRuleNameRule extends DartLintRule {
  /// Creates a new instance of [YourRuleNameRule]
  const YourRuleNameRule()
      : super(
          code: const LintCode(
            name: 'your_rule_name',
            problemMessage: 'Clear description of the issue',
            correctionMessage: 'Suggestion on how to fix it',
          ),
        );

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    // Implement your rule logic here
  }
}
```

## Code Style

- Follow Dart's official [style guide](https://dart.dev/guides/language/effective-dart/style)
- Use `dart format` to format your code
- Add documentation comments to all public APIs

## Reporting Issues

If you find a bug or have a feature request, please open an issue on the GitHub repository.

## Code of Conduct

Please be respectful and inclusive in your interactions with others. We aim to foster an open and welcoming community. 