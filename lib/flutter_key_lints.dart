/// Flutter Widget Key Linting Rules
///
/// A set of custom lint rules to enforce proper widget key usage
/// for better Flutter application performance.
library key_lints;

import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'src/rules/require_widget_key_rule.dart';
import 'src/rules/list_item_key_rule.dart';
import 'src/rules/appropriate_key_type_rule.dart';
import 'src/rules/animation_key_rule.dart';
import 'src/rules/performance_impact_rule.dart';

export 'src/rules/require_widget_key_rule.dart';
export 'src/rules/list_item_key_rule.dart';
export 'src/rules/appropriate_key_type_rule.dart';
export 'src/rules/animation_key_rule.dart';
export 'src/rules/performance_impact_rule.dart';

/// This function creates the plugin for custom_lint
PluginBase createPlugin() {
  return _KeyLintsPlugin();
}

/// The plugin class for key lints
class _KeyLintsPlugin extends PluginBase {
  @override
  List<LintRule> getLintRules(CustomLintConfigs configs) => [
        const RequireWidgetKeyRule(severity: 'info'),
        const ListItemKeyRule(),
        const AppropriateKeyTypeRule(),
        const AnimationKeyRule(),
        const PerformanceImpactRule(),
      ];
}
