# Flutter Key Lints

A Flutter custom lint package to enforce proper widget key usage for better Flutter application performance.

## Why Keys Matter

Keys in Flutter are essential for:

1. **Widget Reconciliation**: Help Flutter distinguish between widget instances during rebuilds
2. **State Preservation**: Ensure widget state is maintained when widgets change position
3. **Performance Optimization**: Reduce unnecessary widget rebuilds
4. **Animation**: Enable smooth transitions between widget states

## Installation

Add to your `pubspec.yaml`:

```yaml
dev_dependencies:
  custom_lint: ^0.7.5
  flutter_key_lints: ^0.1.0
```

Configure in your `analysis_options.yaml`:

```yaml
analyzer:
  plugins:
    - custom_lint

custom_lint:
  rules:
    - require_widget_key: true
    - list_item_key: true
    - appropriate_key_type: true
    - animation_key: true
    - performance_impact: true
```

## Usage

Run custom lint to identify widgets missing keys:

```bash
dart run custom_lint
```

## Rule Details

The package provides several rules to enforce best practices for widget keys:

### 1. `require_widget_key` 

Flags widgets that should have keys but don't:

❌ **Incorrect** (missing key):
```dart
ListView(
  children: [
    ListTile(
      title: Text('Item 1'),
    ),
  ],
);
```

✅ **Correct** (with key):
```dart
ListView(
  children: [
    ListTile(
      key: ValueKey('item-1'),
      title: Text('Item 1'),
    ),
  ],
);
```

### 2. `list_item_key`

Specifically targets list items in ListView.builder, GridView.builder, etc., to ensure they have keys:

❌ **Incorrect** (missing key in list item):
```dart
ListView.builder(
  itemBuilder: (context, index) => ListTile(
    title: Text('Item $index'),
  ),
);
```

✅ **Correct** (with key):
```dart
ListView.builder(
  itemBuilder: (context, index) => ListTile(
    key: ValueKey(index),
    title: Text('Item $index'),
  ),
);
```

### 3. `appropriate_key_type`

Enforces the use of appropriate key types in different scenarios:

❌ **Incorrect** (overuse of GlobalKey):
```dart
// GlobalKey shouldn't be used unless needed for state access
Container(key: GlobalKey());
```

❌ **Incorrect** (raw Key usage):
```dart
// Raw Key constructor should be avoided
Container(key: Key('my-key'));
```

✅ **Correct** (appropriate key types):
```dart
// ValueKey for value-based identification
Container(key: ValueKey('container-1'));

// UniqueKey for truly unique instances
Container(key: UniqueKey());

// GlobalKey when state access is needed
final formKey = GlobalKey<FormState>();
Form(key: formKey, child: Container());
```

### 4. `animation_key`

Enforces the use of keys in animation widgets to prevent flickering and state loss:

❌ **Incorrect** (missing key for animation):
```dart
AnimatedContainer(
  duration: Duration(milliseconds: 300),
  color: isActive ? Colors.blue : Colors.grey,
  width: isActive ? 100 : 50,
); // Missing key
```

✅ **Correct** (with key for animation):
```dart
AnimatedContainer(
  key: ValueKey('my-animated-container'),
  duration: Duration(milliseconds: 300),
  color: isActive ? Colors.blue : Colors.grey,
  width: isActive ? 100 : 50,
);
```

### 5. `performance_impact`

Analyzes the potential performance impact of missing keys and provides severity levels:

❌ **Critical Impact** (high performance penalty):
```dart
ListView.builder(
  itemBuilder: (context, index) => ListTile(
    // No key results in complete list rebuilds
    title: Text('Item $index'),
  ),
);
```

❌ **High Impact** (significant performance penalty):
```dart
// Conditional widget without key causes state loss
if (isLoggedIn) {
  return UserDashboard();
} else {
  return LoginScreen();
}
```

✅ **With Performance Analysis** (showing the fix):
```dart
// Conditional widget with key preserves state
if (isLoggedIn) {
  return UserDashboard(key: ValueKey('dashboard'));
} else {
  return LoginScreen(key: ValueKey('login'));
}
```

## Customizing Rules

You can customize rule behavior in your `analysis_options.yaml`:

```yaml
custom_lint:
  rules:
    # Enable/disable specific rules
    - require_widget_key: true
    - list_item_key: true
    - appropriate_key_type: true
    - animation_key: true
    - performance_impact: true
    
    # Custom configuration for require_widget_key
    # Override the default exempt widget list
    require_widget_key:
      exempt_widgets: 
        - "SizedBox"
        - "Divider"
        - "Padding"
        - "Container"  # Add your own exemptions
```

## Exempt Widgets

Some widgets don't require keys by default:
- Layout widgets (SizedBox, Divider, Padding, etc.)
- Decoration widgets (Opacity, Transform, etc.)
- Inherited widgets

## Best Practices

1. Always use keys for items in lists, grids, or any reorderable content
2. Use keys when conditionally rendering widgets
3. Choose appropriate key types:
   - `ValueKey`: For value-based identification
   - `UniqueKey`: For truly unique instances
   - `GlobalKey`: When you need to access the widget's state

## Known Issues & Workarounds

If you encounter compatibility issues between `custom_lint` and `analyzer` versions:

1. **Pin versions**: Ensure compatible analyzer and custom_lint versions
2. **Manual review**: Check list items and conditionally rendered widgets
3. **Use IDE linting**: VS Code/Android Studio Flutter plugins also help identify key issues

## License

MIT (c) Jordan M. Adler 2025

## Additional information

This package is designed to help Flutter developers improve their code quality by enforcing proper widget key usage. Keys are often overlooked but can significantly impact performance and state management.

### Contributing

Contributions are welcome! Here's how you can help:

1. Report issues: If you find a bug or have a feature request, please open an issue
2. Submit pull requests: Feel free to improve the package or add new lint rules
3. Share feedback: Let us know how this package helps your development workflow

### Running Tests

To run the tests for this package:

```bash
flutter test
```

## Documentation

For more in-depth information about widget keys in Flutter:

- [Widget Keys Guide](doc/KEYS_GUIDE.md) - Comprehensive guide to understanding and using keys
- [Widget Keys Cheatsheet](doc/WIDGET_KEYS_CHEATSHEET.md) - Quick reference for proper key usage
- [Rules Reference](doc/RULES.md) - Detailed information about each lint rule
- [Contributing Guide](doc/CONTRIBUTING.md) - How to contribute to the project
- [Troubleshooting](doc/TROUBLESHOOTING.md) - Solutions to common issues

Additional documentation can be found in the [doc directory](doc).
