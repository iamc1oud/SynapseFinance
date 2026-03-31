import 'dart:io';

import 'package:home_widget/home_widget.dart';
import 'package:injectable/injectable.dart';

import '../constants/constants.dart';

@lazySingleton
class WidgetTestService {
  Future<void> testBasicWidget() async {
    try {
      await HomeWidget.setAppGroupId(appGroupId);
      
      // Save test data
      await HomeWidget.saveWidgetData<String>('net_worth_formatted', '\$1,234.56');
      await HomeWidget.saveWidgetData<String>('last_updated', DateTime.now().toIso8601String());
      
      print('✅ Widget data saved successfully');
      
      // Try to update the widget using different approaches
      if (Platform.isAndroid) {
        try {
          // Try with simple class name first
          await HomeWidget.updateWidget(
            name: 'SynapseFinanceWidgetReceiver',
          );
          print('✅ Android widget update with simple name succeeded');
        } catch (e) {
          print('⚠️ Simple name failed: $e');
          try {
            // Try with qualified name
            await HomeWidget.updateWidget(
              qualifiedAndroidName: 'com.example.synapse_finance.SynapseFinanceWidgetReceiver',
            );
            print('✅ Android widget update with qualified name succeeded');
          } catch (e2) {
            print('❌ Both Android widget update methods failed: $e2');
            rethrow;
          }
        }
      } else if (Platform.isIOS) {
        await HomeWidget.updateWidget(
          iOSName: 'SynapseFinanceWidget',
        );
        print('✅ iOS widget update called');
      }
      
      print('✅ Widget test completed successfully');
    } catch (e) {
      print('❌ Widget test failed: $e');
      rethrow;
    }
  }
}