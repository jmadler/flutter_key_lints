# Flutter Key Lints Tests

This directory contains comprehensive tests for all the lint rules provided by the `flutter_key_lints` package.

## Test Structure

- **flutter_key_lints_test.dart**: Main test file that runs all individual rule tests and verifies the plugin exports.
- **src/rules/**: Directory containing individual test files for each lint rule:
  - **appropriate_key_type_rule_test.dart**: Tests for proper key type usage detection
  - **animation_key_rule_test.dart**: Tests for key usage in animations
  - **list_item_key_rule_test.dart**: Tests for key usage in list items
  - **performance_impact_rule_test.dart**: Tests for performance impact detection of missing keys
  - **require_widget_key_rule_test.dart**: Tests for the basic rule requiring keys on widgets

## Test Approach

Since custom_lint rules are challenging to test directly without the analyzer infrastructure, we take a hybrid approach:

1. **Widget Testing**: We build widgets that would normally trigger the rules and verify they render correctly
2. **Metadata Testing**: We verify the rule metadata (name, problem message, correction message)
3. **Rule Existence Testing**: We verify all rules are correctly exported and accessible

## Running Tests

Run all tests with:

```bash
flutter test
```

Run a specific test file with:

```bash
flutter test test/src/rules/appropriate_key_type_rule_test.dart
```

## Testing Coverage

The tests cover:

- Basic rule metadata verification
- Positive cases (widgets that should trigger the rule)
- Negative cases (widgets that should not trigger the rule)
- Edge cases for each rule
- Plugin configuration and exports

Note that these tests don't directly invoke the analyzer or verify that the rules are triggered in actual code analysis - that would require integration with the custom_lint infrastructure, which is out of scope for these unit tests. 