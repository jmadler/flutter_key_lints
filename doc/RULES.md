# Flutter Key Lints Rules Reference

This document provides detailed information about each rule in the flutter_key_lints package.

## Available Rules

| Rule ID | Description | Default | Configuration |
|---------|-------------|---------|---------------|
| `require_widget_key` | Requires widgets to have key parameters | Enabled | Exempt widget list |
| `list_item_key` | Requires items in list/grid views to have keys | Enabled | None |
| `appropriate_key_type` | Enforces proper key type usage | Enabled | None |
| `animation_key` | Enforces key usage in animation widgets | Enabled | None |
| `performance_impact` | Analyzes performance impact of missing keys | Enabled | None |

## Rule Details

### require_widget_key

This rule enforces that widgets have key parameters to improve performance and state management.

#### Rationale

Widget keys are essential for:
- Helping Flutter identify widgets during reconciliation
- Preserving state when widgets change position
- Ensuring correct animations

#### Configuration

You can customize which widgets are exempt from this rule:

```yaml
custom_lint:
  rules:
    require_widget_key:
      exempt_widgets:
        - "SizedBox"
        - "Divider"
        # Add your own exempt widgets here
```

#### Examples

❌ **Incorrect**:
```dart
ListView(
  children: [
    ListTile(title: Text('Item')), // Missing key
  ],
);
```

✅ **Correct**:
```dart
ListView(
  children: [
    ListTile(
      key: ValueKey('item'),
      title: Text('Item'),
    ),
  ],
);
```

### list_item_key

This rule specifically targets items in list builders to ensure they have keys.

#### Rationale

Items in list/grid views that are built dynamically should always have keys to:
- Prevent unnecessary rebuilds
- Maintain state when items change positions
- Ensure correct animations during list changes

#### Examples

❌ **Incorrect**:
```dart
ListView.builder(
  itemBuilder: (context, index) => ListTile( // Missing key
    title: Text('Item $index'),
  ),
);
```

✅ **Correct**:
```dart
ListView.builder(
  itemBuilder: (context, index) => ListTile(
    key: ValueKey(index), // Good: key based on index
    title: Text('Item $index'),
  ),
);

// Even better - key based on unique data
ListView.builder(
  itemBuilder: (context, index) => ListTile(
    key: ValueKey(items[index].id), // Best: key based on unique ID
    title: Text(items[index].title),
  ),
);
```

### appropriate_key_type

This rule checks that the appropriate type of key is used in different scenarios.

#### Rationale

Different key types serve different purposes:
- `ValueKey` - For keys based on a value (ID, name, etc.)
- `UniqueKey` - For truly unique instances
- `GlobalKey` - Only when you need to access widget state

#### Detected Patterns

1. **GlobalKey Overuse**
   - Using GlobalKey when not needed for state access

2. **Raw Key Usage**
   - Using the basic Key constructor instead of more specific types

3. **Unwrapped Primitive Values**  
   - Using a primitive value directly as a key without wrapping it in ValueKey

#### Examples

❌ **Incorrect**:
```dart
// Overuse of GlobalKey
Container(key: GlobalKey());

// Raw Key usage
Container(key: Key('container'));

// Unwrapped primitive
Container(key: 'container');
```

✅ **Correct**:
```dart
// ValueKey for value-based identification
Container(key: ValueKey('container-1'));

// UniqueKey for truly unique instances
Container(key: UniqueKey());

// GlobalKey when state access is needed
final formKey = GlobalKey<FormState>();
Form(key: formKey, child: Container());
```

### animation_key

This rule enforces that animation-related widgets have keys to prevent flickering and state loss during animations.

#### Rationale

Keys are crucial for animations because they:
- Prevent widget flickering during rebuilds
- Maintain state during animations
- Help Flutter correctly identify widgets during transitions

#### Detected Patterns

The rule detects animation widgets without keys, including:
- Widgets with "Animated" in their name (e.g., AnimatedContainer)
- Widgets with "Animation" in their name
- Widgets with "Transition" in their name
- Hero widgets

#### Examples

❌ **Incorrect**:
```dart
AnimatedContainer(
  duration: Duration(milliseconds: 300),
  color: isActive ? Colors.blue : Colors.grey,
  width: isActive ? 100 : 50,
); // Missing key
```

✅ **Correct**:
```dart
AnimatedContainer(
  key: ValueKey('my-animated-container'),
  duration: Duration(milliseconds: 300),
  color: isActive ? Colors.blue : Colors.grey,
  width: isActive ? 100 : 50,
);
```

### performance_impact

This rule analyzes the codebase to identify potential performance issues related to missing widget keys and provides detailed impact analysis.

#### Rationale

Different key usage patterns have varying performance implications:
- Missing keys in lists or grids cause unnecessary rebuilds of all items
- Conditional widgets without keys can cause state loss and flickering
- Complex widgets benefit more from keys than simple ones
- Deep widget trees amplify the performance impact of missing keys

#### Detected Patterns

The rule evaluates several factors to determine the performance impact:

1. **Critical Impact**
   - Missing keys in lists, grids, and other collection widgets
   
2. **High Impact**
   - Conditional widgets without keys (in if statements)
   - Complex widgets without keys (Forms, Tables, Animations)
   
3. **Medium Impact**
   - Widgets deep in the widget tree without keys
   - Multiple instances of the same widget type without keys

#### Examples

❌ **Critical Performance Impact**:
```dart
ListView.builder(
  itemBuilder: (context, index) => ListTile(
    // No key - causes complete list rebuilds
    title: Text('Item $index'),
  ),
);
```

❌ **High Performance Impact**:
```dart
// Conditional widget without key - causes flickering and state loss
if (isLoggedIn) {
  return UserDashboard();
} else {
  return LoginScreen();
}
```

✅ **Improved Performance**:
```dart
// Conditional widget with key - preserves state and prevents flickering
if (isLoggedIn) {
  return UserDashboard(key: ValueKey('dashboard'));
} else {
  return LoginScreen(key: ValueKey('login'));
}
```

## Disabling Rules

You can disable specific rules for particular lines using code comments:

```dart
// ignore: require_widget_key
ListTile(title: Text('Item'));

// ignore: list_item_key, appropriate_key_type
ListView.builder(
  itemBuilder: (context, index) => ListTile(
    key: Key('item'), // This won't trigger warnings
    title: Text('Item $index'),
  ),
);
``` 