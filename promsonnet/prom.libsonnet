{
  // In this file, the word 'update' refers to retrofitting maps and _order
  // lists to data structures that lack them.

  v1: {
    local v1 = self,
    ruleGroupSet: {
      new():: {
        local this = self,
        groups_map:: {},
        groups_order:: [],
        groups: [this.groups_map[group] for group in this.groups_order],
      },

      addGroup(group):: {
        groups_map+:: {
          [group.name]: group,
        },
        groups_order+:: [group.name],
      },

      update():: {
        local groups = super.groups,
        local this = self,
        local groupsAsMap(group, acc) = acc { [group.name]+: group + v1.ruleGroup.update() },
        local groupsAsList(group, acc) = acc + [group.name],
        groups_map:: std.foldr(groupsAsMap, groups, {}),
        groups_order:: std.foldr(groupsAsList, groups, []),
        groups: [this.groups_map[group] for group in this.groups_order],
      },
    },

    ruleGroup: {
      new(name):: {
        name: name,
        rules_map:: {},
        rules_order:: [],
        local rules_map = self.rules_map,
        local rules_order = self.rules_order,
        rules: [rules_map[rule] for rule in rules_order],
      },

      rule: {
        newAlert(name, rule):: {
          rules_map+:: {
            [name]: rule { alert: name },
          },
          rules_order+:: [name],
        },
        newRecording(name, rule):: {
          rules_map+:: {
            [name]: rule { record: name },
          },
          rules_order+:: [name],
        },
      },

      update():: {
        local rules = super.rules,
        local this = self,
        local ruleName(rule) = if 'alert' in rule then rule.alert else rule.record,
        local rulesAsMap(rule, acc) = acc { [ruleName(rule)]: rule },
        local rulesAsList(rule, acc) = acc + [ruleName(rule)],
        rules_map:: std.foldr(rulesAsMap, rules, {}),
        rules_order:: std.foldr(rulesAsList, rules, []),
        rules: [this.rules_map[rule] for rule in this.rules_order],
      },
    },

    patchRule(group, rule, patch):: {
      groups_map+:: {
        [group]+: {
          rules_map+:: {
            [rule]+: patch,
          },
        },
      },
    },

    mixin: {
      updateMixin(mixin):: {
        [mixin]+: {
          prometheusRules+: v1.ruleGroupSet.update(),
          prometheusAlerts+: v1.ruleGroupSet.update(),
        },
      },
      patchRule(mixin, group, rule, patch):: {
        [mixin]+: {
          prometheusRules+: v1.patchRule(group, rule, patch),
          prometheusAlerts+: v1.patchRule(group, rule, patch),
        },
      },
    },
  },
}
