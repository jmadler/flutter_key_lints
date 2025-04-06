## 0.1.0

Initial release of the flutter_key_lints package.

### Features:
- `require_widget_key`: Lint rule to detect widgets without key parameters
- `list_item_key`: Specialized lint rule for list/grid item keys
- `appropriate_key_type`: Lint rule to enforce proper key type usage
- `animation_key`: Lint rule to ensure animated widgets have keys
- `performance_impact`: Lint rule that analyzes potential performance impact of missing keys
- Configurable exempt widget list through analysis_options.yaml
- Comprehensive documentation and examples
- Unit tests for all lint rules

### Implementation details:
- Built with custom_lint 0.7.5
- Compatible with analyzer 7.3.0 and above
- Compatible with Flutter 3.0.0 and above
- Customizable rule configuration
