# Flutter Widget Keys Cheat Sheet

## Quick Reference

| Widget Type | Key Needed? | Example |
|-------------|------------|---------|
| In Lists/Grids | ✅ Essential | `key: ValueKey<String>('item_${item.id}')` |
| Reorderable Items | ✅ Essential | `key: ValueKey<String>('task_${task.id}')` |
| Conditionally Rendered | ✅ Recommended | `key: const ValueKey<String>('details_view')` |
| Stateful Widgets | ✅ Recommended | `key: ValueKey<String>('form_$formId')` |
| Const Widgets | ⛔ Not needed | `const Text('Hello')` |
| Simple Containers | ⚠️ Optional | `key: const ValueKey<String>('wrapper')` |
| Layout Widgets | ⚠️ Optional | `key: const ValueKey<String>('main_column')` |

## Key Types at a Glance

| Key Type | When to Use | Example |
|----------|-------------|---------|
| `ValueKey` | Simple identifier (string/int) | `ValueKey<String>('user_$userId')` |
| `ObjectKey` | Complex object identity | `ObjectKey(complexItem)` |
| `UniqueKey` | Always unique for each instance | `UniqueKey()` |
| `GlobalKey` | Access widget state from outside | `GlobalKey<FormState>()` |
| `PageStorageKey` | Preserve scroll position | `PageStorageKey<String>('feed_list')` |
| `LocalKey` | Base class (don't use directly) | N/A |

## Priority Widget Types for Keys

1. **ListView/GridView items**
2. **TabBarView pages**
3. **Animated widgets**
4. **Form elements**
5. **Draggable/reorderable items**
6. **Conditionally rendered widgets**
7. **Dialog/Modal content**

## Common Patterns

```dart
// List items
ListView.builder(
  itemBuilder: (context, index) => ItemTile(
    key: ValueKey<String>('item_${items[index].id}'),
    item: items[index],
  ),
)

// Tab content
TabBarView(
  children: [
    FirstTab(key: const PageStorageKey<String>('first_tab')),
    SecondTab(key: const PageStorageKey<String>('second_tab')),
  ],
)

// Form
Form(
  key: _formKey, // GlobalKey<FormState>
  child: TextFormField(
    key: const ValueKey<String>('email_field'),
  ),
)

// Animated widgets
AnimatedSwitcher(
  child: expanded
    ? ExpandedView(key: const ValueKey<String>('expanded'))
    : CollapsedView(key: const ValueKey<String>('collapsed')),
)

// Bottom sheets
showModalBottomSheet(
  context: context,
  builder: (context) => Container(
    key: const ValueKey<String>('settings_sheet'),
    child: SettingsPanel(),
  ),
)
```

## When Keys are NOT Needed

- Const widgets (they never rebuild)
- Simple text labels
- Icons, Dividers, SizedBox
- Most wrapper widgets (Padding, Center, etc.)
- Widgets that never move in the tree

## Performance Impact

- ✅ Benefits: Reduced rebuilds, preserved state, proper animations
- ⚠️ Costs: Minimal memory overhead, code verbosity
- ⚡ Net impact: Significant performance gain when used properly
- 🎯 Target: ~80% key coverage on interactive/list widgets

## Common Mistakes

- Using index as key in a reorderable list
- Creating non-const UniqueKey in build method
- Overusing GlobalKey when ValueKey would suffice
- Forgetting keys in conditionally built widgets
- Not providing specific enough keys ("button" vs "save_button") 