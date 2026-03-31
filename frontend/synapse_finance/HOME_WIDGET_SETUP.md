# Home Widget Setup Guide

This guide explains how to set up and use the Synapse Finance home widget to display your net worth on your device's home screen.

## Features

- **Real-time Net Worth Display**: Shows your total net worth calculated from all active accounts
- **Automatic Updates**: Updates every 15 minutes in the background
- **Manual Refresh**: Tap the widget to refresh data immediately
- **Cross-platform**: Works on both Android and iOS

## Setup Instructions

### 1. Build and Install the App

First, make sure to regenerate the dependency injection code:

```bash
flutter packages pub run build_runner build --delete-conflicting-outputs
```

Then build and install the app:

```bash
flutter run
```

### 2. Android Widget Setup

1. Long press on your Android home screen
2. Select "Widgets" from the menu
3. Find "Synapse Finance" in the widget list
4. Drag the "Net Worth" widget to your home screen
5. The widget will automatically start displaying your net worth

### 3. iOS Widget Setup

1. Long press on your iOS home screen until apps start wiggling
2. Tap the "+" button in the top-left corner
3. Search for "Synapse Finance" or scroll to find it
4. Select the widget size you prefer (Small or Medium)
5. Tap "Add Widget"
6. The widget will automatically start displaying your net worth

## How It Works

### Data Flow
1. The app fetches account data from your backend API
2. Net worth is calculated by summing all active account balances
3. The calculated value is saved to the device's widget storage
4. The widget displays the formatted net worth value

### Background Updates
- **Automatic**: Every 15 minutes via WorkManager (Android) / Background App Refresh (iOS)
- **Manual**: Tap the widget to trigger an immediate refresh
- **App Launch**: Updates when you open the Synapse Finance app

### Data Format
- Values under $1,000: Shows exact amount (e.g., "$542.30")
- Values over $1,000: Shows abbreviated format (e.g., "$1.2K", "$2.5M")
- Error states: Shows "Error loading data" or "N/A"

## Troubleshooting

### Widget Not Updating
1. Check that background app refresh is enabled for Synapse Finance
2. Ensure you have an active internet connection
3. Try manually refreshing by tapping the widget
4. Restart the app to reinitialize the widget service

### Widget Shows "Error loading data"
1. Check your internet connection
2. Ensure you're logged into the app
3. Verify that your account data is accessible in the main app
4. Try logging out and back in to refresh your authentication

### Widget Not Appearing in Widget List (Android)
1. Make sure the app is properly installed
2. Check that the widget receiver is properly registered in AndroidManifest.xml
3. Verify the package name matches in all configuration files
4. Try rebuilding the app with `flutter clean && flutter build apk`

### Widget Not Appearing in Widget List (iOS)
1. Make sure the app is properly installed
2. Check that the widget extension is included in the build
3. Verify the app group ID is correctly configured
4. Restart your device

### "No Widget found with Name" Error (Android)
This error typically occurs when:
1. The widget class name doesn't match the registered receiver
2. The package name is incorrect
3. The widget receiver isn't properly registered in AndroidManifest.xml

**Solution**: 
- Ensure the widget receiver class is named `SynapseFinanceWidgetReceiver`
- Verify it's registered in `android/app/src/main/AndroidManifest.xml`
- Check that the package name is `com.example.synapse_finance`
- Try using the simple class name instead of the qualified name in Flutter code

## Technical Details

### Files Modified/Created
- `lib/core/services/home_widget_service.dart` - Main widget service
- `lib/features/ledger/domain/usecases/get_net_worth_usecase.dart` - Net worth calculation
- `lib/features/home/presentation/widgets/net_worth_card.dart` - In-app net worth display
- Android widget files in `android/app/src/main/`
- iOS widget files in `ios/SynapseFinanceWidget/`

### Dependencies
- `home_widget: ^0.6.0` - Cross-platform widget support
- `workmanager: ^0.5.2` - Background task scheduling

### Permissions
- **Android**: No additional permissions required
- **iOS**: Background App Refresh should be enabled for optimal performance

## Privacy & Security

- Widget data is stored locally on your device
- No sensitive account details are displayed in the widget
- Only the total net worth amount is shown
- Data is encrypted using platform-standard widget storage mechanisms

## Customization

The widget appearance can be customized by modifying:
- **Android**: Layout files in `android/app/src/main/res/layout/`
- **iOS**: SwiftUI views in `ios/SynapseFinanceWidget/SynapseFinanceWidget.swift`
- **Colors**: Update color resources in respective platform folders