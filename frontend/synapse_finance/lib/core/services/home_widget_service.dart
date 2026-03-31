import 'dart:io';

import 'package:home_widget/home_widget.dart';
import 'package:injectable/injectable.dart';

import '../constants/constants.dart';
import '../../features/ledger/domain/usecases/get_net_worth_usecase.dart';

@lazySingleton
class HomeWidgetService {
  final GetNetWorthUseCase _getNetWorthUseCase;

  HomeWidgetService(this._getNetWorthUseCase);

  Future<void> initialize() async {
    await HomeWidget.setAppGroupId(appGroupId);
  }

  Future<void> updateNetWorthWidget() async {
    try {
      final result = await _getNetWorthUseCase();
      
      await result.fold(
        (failure) async {
          // On failure, show error message
          await _saveWidgetData('net_worth', 'Error loading data');
          await _saveWidgetData('net_worth_formatted', 'N/A');
        },
        (netWorth) async {
          // Format the net worth value
          final formattedNetWorth = _formatCurrency(netWorth);
          
          await _saveWidgetData('net_worth', netWorth.toString());
          await _saveWidgetData('net_worth_formatted', formattedNetWorth);
          await _saveWidgetData('last_updated', DateTime.now().toIso8601String());
        },
      );

      // Update the widget
      await _updateWidget();
    } catch (e) {
      // Fallback error handling
      await _saveWidgetData('net_worth_formatted', 'Error: $e');
      await _updateWidget();
    }
  }

  Future<void> _saveWidgetData(String key, String value) async {
    await HomeWidget.saveWidgetData<String>(key, value);
  }

  Future<void> _updateWidget() async {
    if (Platform.isAndroid) {
      try {
        // Try with simple class name first
        await HomeWidget.updateWidget(
          name: 'SynapseFinanceWidgetReceiver',
        );
      } catch (e) {
        // Fallback to qualified name
        await HomeWidget.updateWidget(
          qualifiedAndroidName: 'com.example.synapse_finance.SynapseFinanceWidgetReceiver',
        );
      }
    } else if (Platform.isIOS) {
      await HomeWidget.updateWidget(
        iOSName: 'SynapseFinanceWidget',
      );
    }
  }

  String _formatCurrency(double amount) {
    if (amount >= 1000000) {
      return '\$${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return '\$${(amount / 1000).toStringAsFixed(1)}K';
    } else {
      return '\$${amount.toStringAsFixed(2)}';
    }
  }
}