# Troubleshooting Flutter Key Lints

This guide helps solve common issues you might encounter when using the flutter_key_lints package.

## Common Issues

### 1. Linter Not Working

**Symptoms**: No errors or warnings are shown when running `dart run custom_lint`

**Possible Solutions**:

- Check your `analysis_options.yaml` has both the analyzer plugin and rules configured:
  ```yaml
  analyzer:
    plugins:
      - custom_lint
  
  custom_lint:
    rules:
      - require_widget_key: true
      - list_item_key: true
      - appropriate_key_type: true
  ```

- Verify custom_lint is properly installed:
  ```bash
  dart pub get
  ```

- Make sure you're running the command in the right directory.

### 2. False Positives

**Symptoms**: The linter flags widgets that should be exempt

**Solution**: Customize the exempt widgets list in your `analysis_options.yaml`:
```yaml
custom_lint:
  rules:
    require_widget_key:
      exempt_widgets: 
        - "SizedBox"
        - "Divider"
        - "YourCustomExemptWidget"
```

### 3. Version Conflicts

**Symptoms**: Error messages about incompatible versions when running pub get

**Solution**: Make sure you have compatible versions of analyzer and custom_lint:
```yaml
dependencies:
  analyzer: ^7.3.0
  custom_lint: ^0.7.5
```

### 4. Migrating from Older Versions

If you're upgrading from a previous version of Key Lints, you may need to:

1. Update your dependencies
2. Re-run `dart pub get`
3. Check for changes in rule names or configurations

## Debugging

To see more detailed diagnostic output, run:

```bash
dart run custom_lint --verbose
```

## Getting Help

If you're still experiencing issues:

1. Check existing [GitHub issues](https://github.com/jmadler/flutter_key_lints/issues)
2. Open a new issue with:
   - Version information (Flutter, Dart, flutter_key_lints, custom_lint)
   - A minimal reproduction example
   - Error messages or logs

We aim to respond to issues promptly. 