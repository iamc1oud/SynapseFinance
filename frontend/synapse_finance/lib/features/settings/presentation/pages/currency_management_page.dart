import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/currency_management_cubit.dart';
import '../bloc/currency_management_state.dart';
import '../constants/fiat_currencies.dart';
import 'change_primary_currency_page.dart';


class CurrencyManagementPage extends StatefulWidget {
  const CurrencyManagementPage({super.key});

  @override
  State<CurrencyManagementPage> createState() =>
      _CurrencyManagementPageState();
}

class _CurrencyManagementPageState extends State<CurrencyManagementPage> {
  @override
  void initState() {
    super.initState();
    context.read<CurrencyManagementCubit>().loadCurrencies();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF0A1A0A) : const Color(0xFFF0F4F0);
    final surface = isDark ? const Color(0xFF122112) : const Color(0xFFFFFFFF);
    final onSurface = isDark ? Colors.white : const Color(0xFF0D1B0D);
    final secondary =
        isDark ? const Color(0xFF8B9E8B) : const Color(0xFF4A5C4A);
    final sectionLabel =
        isDark ? const Color(0xFF6B7E6B) : const Color(0xFF6B7C6B);
    final divider =
        isDark ? const Color(0xFF243624) : const Color(0xFFD8E8D8);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: onSurface),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Currency Management',
          style: TextStyle(
            color: onSurface,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.info_outline, color: const Color(0xFF3B82F6)),
            onPressed: () => _showInfoDialog(context, isDark),
          ),
        ],
      ),
      body: BlocConsumer<CurrencyManagementCubit, CurrencyManagementState>(
        listener: (context, state) {
          if (state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage!),
                backgroundColor: const Color(0xFFF85149),
              ),
            );
          }
        },
        builder: (context, state) {
          if (state.status == CurrencyManagementStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),

                      // ── BASE CURRENCY ──
                      Padding(
                        padding: const EdgeInsets.only(left: 4, bottom: 8),
                        child: Text(
                          'BASE CURRENCY',
                          style: TextStyle(
                            color: sectionLabel,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                      if (state.mainCurrency != null)
                        GestureDetector(
                          onTap: () => _showChangePrimaryCurrencySheet(
                            context,
                            state,
                            isDark,
                          ),
                          child: _BaseCurrencyCard(
                            currencyCode: state.mainCurrency!.currency,
                            surface: surface,
                            onSurface: onSurface,
                            secondary: secondary,
                          ),
                        ),

                      const SizedBox(height: 24),

                      // ── SUB-CURRENCIES header ──
                      Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 4),
                            child: Text(
                              'SUB-CURRENCIES',
                              style: TextStyle(
                                color: sectionLabel,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ),
                          const Spacer(),
                          if (state.isRefreshing)
                            const SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          else
                            GestureDetector(
                              onTap: () => context
                                  .read<CurrencyManagementCubit>()
                                  .refreshRates(),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.refresh,
                                    size: 14,
                                    color: const Color(0xFF3B82F6),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    _timeSinceUpdate(state.lastUpdated),
                                    style: const TextStyle(
                                      color: Color(0xFF3B82F6),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // ── Sub-currency list ──
                      ...state.subCurrencies.map((sc) {
                        final rate = state.getRateForCurrency(
                          sc.currency,
                          state.mainCurrency?.currency ?? '',
                        );
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _SubCurrencyCard(
                            currencyCode: sc.currency,
                            exchangeRate: rate ?? sc.exchangeRate,
                            mainCurrencyCode:
                                state.mainCurrency?.currency ?? '',
                            surface: surface,
                            onSurface: onSurface,
                            secondary: secondary,
                            divider: divider,
                            onEdit: () => _showEditRateSheet(
                              context,
                              sc.id,
                              sc.currency,
                              rate ?? sc.exchangeRate,
                              state.mainCurrency?.currency ?? '',
                              isDark,
                            ),
                            onDelete: () => context
                                .read<CurrencyManagementCubit>()
                                .deleteSubCurrency(sc.id),
                          ),
                        );
                      }),

                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),

              // ── Add Currency button ──
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: () => _showAddCurrencySheet(
                      context,
                      state,
                      isDark,
                    ),
                    icon: const Icon(Icons.add_circle_outline, size: 20),
                    label: const Text(
                      'Add Currency',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3B82F6),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  String _timeSinceUpdate(DateTime? lastUpdated) {
    if (lastUpdated == null) return 'Tap to refresh';
    final diff = DateTime.now().difference(lastUpdated);
    if (diff.inMinutes < 1) return 'Updated just now';
    if (diff.inMinutes < 60) return 'Updated ${diff.inMinutes}m ago';
    if (diff.inHours < 24) return 'Updated ${diff.inHours}h ago';
    return 'Updated ${diff.inDays}d ago';
  }

  void _showInfoDialog(BuildContext context, bool isDark) {
    final bg = isDark ? const Color(0xFF122112) : const Color(0xFFFFFFFF);
    final onSurface = isDark ? Colors.white : const Color(0xFF0D1B0D);
    final secondary =
        isDark ? const Color(0xFF8B9E8B) : const Color(0xFF4A5C4A);

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: bg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: secondary.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'About Currency Management',
              style: TextStyle(
                color: onSurface,
                fontSize: 17,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Add sub-currencies to track expenses in multiple currencies. '
              'Exchange rates are fetched automatically but you can also set '
              'custom rates by tapping the edit icon on any sub-currency. '
              'During transactions, you can override the exchange rate as needed.',
              style: TextStyle(color: secondary, fontSize: 14, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditRateSheet(
    BuildContext context,
    int subCurrencyId,
    String currencyCode,
    double currentRate,
    String mainCurrencyCode,
    bool isDark,
  ) {
    final bg = isDark ? const Color(0xFF122112) : const Color(0xFFFFFFFF);
    final onSurface = isDark ? Colors.white : const Color(0xFF0D1B0D);
    final secondary =
        isDark ? const Color(0xFF8B9E8B) : const Color(0xFF4A5C4A);
    final controller = TextEditingController(text: currentRate.toString());

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: bg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => Padding(
        padding: EdgeInsets.fromLTRB(
          24,
          20,
          24,
          MediaQuery.of(sheetContext).viewInsets.bottom + 32,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: secondary.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Edit Exchange Rate',
              style: TextStyle(
                color: onSurface,
                fontSize: 17,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '1 $currencyCode = ? $mainCurrencyCode',
              style: TextStyle(color: secondary, fontSize: 14),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              autofocus: true,
              style: TextStyle(color: onSurface, fontSize: 16),
              decoration: InputDecoration(
                filled: true,
                fillColor: isDark
                    ? const Color(0xFF0A1A0A)
                    : const Color(0xFFF0F4F0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                hintText: 'Enter exchange rate',
                hintStyle: TextStyle(color: secondary),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  final rate = double.tryParse(controller.text);
                  if (rate != null && rate > 0) {
                    context
                        .read<CurrencyManagementCubit>()
                        .updateExchangeRate(subCurrencyId, rate);
                    Navigator.of(sheetContext).pop();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3B82F6),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Update Rate',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddCurrencySheet(
    BuildContext context,
    CurrencyManagementState state,
    bool isDark,
  ) {
    final existingCodes = <String>{
      if (state.mainCurrency != null) state.mainCurrency!.currency,
      ...state.subCurrencies.map((s) => s.currency),
    };

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor:
          isDark ? const Color(0xFF122112) : const Color(0xFFFFFFFF),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (_, scrollController) => _AddCurrencySearchSheet(
          excludedCodes: existingCodes,
          isDark: isDark,
          scrollController: scrollController,
          onSelect: (code) {
            context.read<CurrencyManagementCubit>().addSubCurrency(code);
            Navigator.of(sheetContext).pop();
          },
        ),
      ),
    );
  }

  void _showChangePrimaryCurrencySheet(
    BuildContext context,
    CurrencyManagementState state,
    bool isDark,
  ) {
    final currentCode = state.mainCurrency?.currency ?? '';

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? const Color(0xFF122112) : const Color(0xFFFFFFFF),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (_, scrollController) => _CurrencySearchSheet(
          currentCode: currentCode,
          isDark: isDark,
          scrollController: scrollController,
          onSelect: (code) {
            Navigator.of(sheetContext).pop();
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => BlocProvider.value(
                  value: context.read<CurrencyManagementCubit>(),
                  child: ChangePrimaryCurrencyPage(
                    newCurrency: code,
                    currentCurrency: currentCode,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// ─── Base Currency Card ──────────────────────────────────────────────────────

class _BaseCurrencyCard extends StatelessWidget {
  final String currencyCode;
  final Color surface;
  final Color onSurface;
  final Color secondary;

  const _BaseCurrencyCard({
    required this.currencyCode,
    required this.surface,
    required this.onSurface,
    required this.secondary,
  });

  @override
  Widget build(BuildContext context) {
    final info = fiatCurrencies[currencyCode];
    final name = info?.$1 ?? currencyCode;
    final symbol = info?.$2 ?? '';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFF3B82F6).withValues(alpha: 0.3),
          width: 0.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFF1E3A5F),
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: Text(
              symbol.length <= 2 ? symbol : currencyCode[0],
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    color: onSurface,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$currencyCode ($symbol)',
                  style: TextStyle(color: secondary, fontSize: 13),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF3B82F6).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: const Color(0xFF3B82F6).withValues(alpha: 0.3),
                width: 0.5,
              ),
            ),
            child: const Text(
              'PRIMARY',
              style: TextStyle(
                color: Color(0xFF3B82F6),
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Sub-Currency Card ───────────────────────────────────────────────────────

class _SubCurrencyCard extends StatelessWidget {
  final String currencyCode;
  final double exchangeRate;
  final String mainCurrencyCode;
  final Color surface;
  final Color onSurface;
  final Color secondary;
  final Color divider;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _SubCurrencyCard({
    required this.currencyCode,
    required this.exchangeRate,
    required this.mainCurrencyCode,
    required this.surface,
    required this.onSurface,
    required this.secondary,
    required this.divider,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final info = fiatCurrencies[currencyCode];
    final name = info?.$1 ?? currencyCode;
    final symbol = info?.$2 ?? '';

    return Container(
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 12, 10),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E3A5F),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    symbol.length <= 2 ? symbol : currencyCode[0],
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: TextStyle(
                          color: onSurface,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '$currencyCode ($symbol)',
                        style: TextStyle(color: secondary, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.edit_outlined,
                    color: const Color(0xFF3B82F6),
                    size: 20,
                  ),
                  onPressed: onEdit,
                ),
              ],
            ),
          ),
          Divider(height: 1, thickness: 0.5, indent: 16, endIndent: 16, color: divider),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
            child: Row(
              children: [
                Text(
                  'EXCHANGE RATE',
                  style: TextStyle(
                    color: secondary,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.8,
                  ),
                ),
                const Spacer(),
                RichText(
                  text: TextSpan(
                    style: TextStyle(fontSize: 15),
                    children: [
                      TextSpan(
                        text: '1  $currencyCode  =  ',
                        style: TextStyle(
                          color: onSurface,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      TextSpan(
                        text: exchangeRate.toStringAsFixed(2),
                        style: const TextStyle(
                          color: Color(0xFF3B82F6),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      TextSpan(
                        text: '  $mainCurrencyCode',
                        style: TextStyle(
                          color: onSurface,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Currency Search Sheet ───────────────────────────────────────────────────

class _CurrencySearchSheet extends StatefulWidget {
  final String currentCode;
  final bool isDark;
  final ScrollController scrollController;
  final ValueChanged<String> onSelect;

  const _CurrencySearchSheet({
    required this.currentCode,
    required this.isDark,
    required this.scrollController,
    required this.onSelect,
  });

  @override
  State<_CurrencySearchSheet> createState() => _CurrencySearchSheetState();
}

class _CurrencySearchSheetState extends State<_CurrencySearchSheet> {
  String _query = '';

  List<MapEntry<String, (String, String)>> get _filtered {
    final entries = fiatCurrencies.entries
        .where((e) => e.key != widget.currentCode)
        .toList();

    if (_query.isEmpty) return entries;

    final q = _query.toLowerCase();
    return entries
        .where((e) =>
            e.key.toLowerCase().contains(q) ||
            e.value.$1.toLowerCase().contains(q))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final onSurface =
        widget.isDark ? Colors.white : const Color(0xFF0D1B0D);
    final secondary =
        widget.isDark ? const Color(0xFF8B9E8B) : const Color(0xFF4A5C4A);
    final bg = widget.isDark
        ? const Color(0xFF0A1A0A)
        : const Color(0xFFF0F4F0);

    final filtered = _filtered;

    return Column(
      children: [
        // Handle
        Padding(
          padding: const EdgeInsets.only(top: 12, bottom: 8),
          child: Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: secondary.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ),

        // Title + warning
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Change Primary Currency',
                style: TextStyle(
                  color: onSurface,
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Warning: This will delete all your data',
                style: TextStyle(
                  color: const Color(0xFFF85149),
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),

        // Search
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
          child: TextField(
            onChanged: (v) => setState(() => _query = v),
            style: TextStyle(color: onSurface, fontSize: 15),
            decoration: InputDecoration(
              hintText: 'Search currency...',
              hintStyle: TextStyle(color: secondary),
              prefixIcon: Icon(Icons.search, color: secondary, size: 20),
              filled: true,
              fillColor: bg,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),

        // Currency list
        Expanded(
          child: ListView.builder(
            controller: widget.scrollController,
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
            itemCount: filtered.length,
            itemBuilder: (context, index) {
              final entry = filtered[index];
              final code = entry.key;
              final name = entry.value.$1;
              final symbol = entry.value.$2;

              return Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: GestureDetector(
                  onTap: () => widget.onSelect(code),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: secondary.withValues(alpha: 0.2),
                        width: 0.5,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E3A5F),
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            symbol.length <= 2 ? symbol : code[0],
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                name,
                                style: TextStyle(
                                  color: onSurface,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '$code ($symbol)',
                                style: TextStyle(
                                  color: secondary,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.chevron_right_rounded,
                          color: secondary,
                          size: 22,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

// ─── Add Currency Search Sheet ──────────────────────────────────────────────

class _AddCurrencySearchSheet extends StatefulWidget {
  final Set<String> excludedCodes;
  final bool isDark;
  final ScrollController scrollController;
  final ValueChanged<String> onSelect;

  const _AddCurrencySearchSheet({
    required this.excludedCodes,
    required this.isDark,
    required this.scrollController,
    required this.onSelect,
  });

  @override
  State<_AddCurrencySearchSheet> createState() =>
      _AddCurrencySearchSheetState();
}

class _AddCurrencySearchSheetState extends State<_AddCurrencySearchSheet> {
  String _query = '';

  List<MapEntry<String, (String, String)>> get _filtered {
    final entries = fiatCurrencies.entries
        .where((e) => !widget.excludedCodes.contains(e.key))
        .toList();

    if (_query.isEmpty) return entries;

    final q = _query.toLowerCase();
    return entries
        .where((e) =>
            e.key.toLowerCase().contains(q) ||
            e.value.$1.toLowerCase().contains(q))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final onSurface =
        widget.isDark ? Colors.white : const Color(0xFF0D1B0D);
    final secondary =
        widget.isDark ? const Color(0xFF8B9E8B) : const Color(0xFF4A5C4A);
    final bg = widget.isDark
        ? const Color(0xFF0A1A0A)
        : const Color(0xFFF0F4F0);

    final filtered = _filtered;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 12, bottom: 8),
          child: Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: secondary.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Add Currency',
              style: TextStyle(
                color: onSurface,
                fontSize: 17,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
          child: TextField(
            onChanged: (v) => setState(() => _query = v),
            style: TextStyle(color: onSurface, fontSize: 15),
            decoration: InputDecoration(
              hintText: 'Search currency...',
              hintStyle: TextStyle(color: secondary),
              prefixIcon: Icon(Icons.search, color: secondary, size: 20),
              filled: true,
              fillColor: bg,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            controller: widget.scrollController,
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
            itemCount: filtered.length,
            itemBuilder: (context, index) {
              final entry = filtered[index];
              final code = entry.key;
              final name = entry.value.$1;
              final symbol = entry.value.$2;

              return Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: GestureDetector(
                  onTap: () => widget.onSelect(code),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: secondary.withValues(alpha: 0.2),
                        width: 0.5,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E3A5F),
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            symbol.length <= 2 ? symbol : code[0],
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                name,
                                style: TextStyle(
                                  color: onSurface,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '$code ($symbol)',
                                style: TextStyle(
                                  color: secondary,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.add_circle_outline,
                          color: const Color(0xFF3B82F6),
                          size: 22,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
