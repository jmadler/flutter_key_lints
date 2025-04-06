import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'src/rules/require_widget_key_rule.dart';

/// This is the entrypoint for the linter
PluginBase createPlugin() {
  return _KeyLintsPlugin();
}

/// The plugin class for key lints
class _KeyLintsPlugin extends PluginBase {
  @override
  List<LintRule> getLintRules(CustomLintConfigs configs) => [
        const RequireWidgetKeyRule(severity: null),
      ];
}
