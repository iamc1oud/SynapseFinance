import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class ChatCommand {
  final String name;
  final String description;
  final IconData icon;
  final String systemPrompt;

  const ChatCommand({
    required this.name,
    required this.description,
    required this.icon,
    required this.systemPrompt,
  });
}

const kBuiltInCommands = [
  ChatCommand(
    name: '/spend',
    description: 'Spending analysis',
    icon: Icons.analytics_outlined,
    systemPrompt:
        'Analyze my spending for the current month. Break down by category.',
  ),
  ChatCommand(
    name: '/pf',
    description: 'Portfolio overview',
    icon: Icons.account_balance_outlined,
    systemPrompt:
        'Give a portfolio overview: all accounts with balances, total assets, and net worth.',
  ),
  ChatCommand(
    name: '/bills',
    description: 'Recurring bills',
    icon: Icons.receipt_long_outlined,
    systemPrompt:
        'Show my upcoming bills and subscriptions. Highlight any that are due soon.',
  ),
  ChatCommand(
    name: '/add',
    description: 'Quick add transaction',
    icon: Icons.add_circle_outline,
    systemPrompt:
        'I want to add a transaction. Ask: expense/income/transfer? Amount? Account? Category?',
  ),
  ChatCommand(
    name: '/budget',
    description: 'Budget management',
    icon: Icons.pie_chart_outline,
    systemPrompt:
        'Help me set a monthly budget. Show current spending by category first, then suggest budget limits.',
  ),
  ChatCommand(
    name: '/goal',
    description: 'Savings goals',
    icon: Icons.flag_outlined,
    systemPrompt:
        'I want to create a savings goal. Ask about target amount, timeline, and which account to save from.',
  ),
];

class CommandOverlay extends StatelessWidget {
  final ValueChanged<ChatCommand> onCommandSelected;

  const CommandOverlay({super.key, required this.onCommandSelected});

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    return Container(
      constraints: const BoxConstraints(maxHeight: 280),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: c.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 8),
        shrinkWrap: true,
        itemCount: kBuiltInCommands.length,
        separatorBuilder: (_, index) => Divider(
          color: c.border,
          height: 1,
          indent: 16,
          endIndent: 16,
        ),
        itemBuilder: (context, index) {
          final cmd = kBuiltInCommands[index];
          return ListTile(
            dense: true,
            leading: Icon(cmd.icon, color: c.primary, size: 20),
            title: Text(
              cmd.name,
              style: TextStyle(
                color: c.primary,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
            subtitle: Text(
              cmd.description,
              style: TextStyle(color: c.textSecondary, fontSize: 12),
            ),
            onTap: () => onCommandSelected(cmd),
          );
        },
      ),
    );
  }
}
