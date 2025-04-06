# Key Lints Example

This example app demonstrates how to integrate and use the `key_lints` package in a Flutter project.

## Getting Started

1. Run the analyzer to see linting warnings:

```bash
cd example
dart run custom_lint
```

2. Observe lint warnings related to widget keys in the output.

## Demonstrated Rules

This example demonstrates all three lint rules provided by the package:

1. `require_widget_key`: Check the main application code for widgets that should have keys
2. `list_item_key`: See how ListView.builder items need to have keys
3. `appropriate_key_type`: Observe warnings about improper key type usage

## Configuration

The configuration for the linter is in `analysis_options.yaml`:

```yaml
include: package:flutter_lints/flutter.yaml

analyzer:
  plugins:
    - custom_lint

custom_lint:
  rules:
    # Basic widget key rule
    - require_widget_key: true
      
    # List item keys rule
    - list_item_key: true
      
    # Appropriate key type rule
    - appropriate_key_type: true
```

## Tips for Using Widget Keys

1. Always add keys to items in lists or grids
2. Use ValueKey for items with unique identifiers
3. Use UniqueKey for truly dynamic items
4. Reserve GlobalKey for when you need to access widget state 