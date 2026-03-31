package com.example.synapse_finance

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetPlugin

class SynapseFinanceWidgetReceiver : AppWidgetProvider() {
    
    companion object {
        private const val TAG = "SynapseFinanceWidget"
    }
    
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        try {
            for (appWidgetId in appWidgetIds) {
                updateAppWidget(context, appWidgetManager, appWidgetId)
            }
        } catch (e: Exception) {
            android.util.Log.e(TAG, "Error updating widget", e)
        }
    }

    private fun updateAppWidget(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetId: Int
    ) {
        val views = RemoteViews(context.packageName, R.layout.synapse_finance_widget)
        
        // Get data from SharedPreferences
        val widgetData = HomeWidgetPlugin.getData(context)
        val netWorthFormatted = widgetData?.getString("net_worth_formatted", "$0.00") ?: "$0.00"
        val lastUpdated = widgetData?.getString("last_updated", null)
        
        // Update the widget views
        views.setTextViewText(R.id.net_worth_value, netWorthFormatted)
        
        // Format last updated time
        val lastUpdatedText = if (lastUpdated != null) {
            try {
                val dateTime = java.time.Instant.parse(lastUpdated)
                val formatter = java.time.format.DateTimeFormatter.ofPattern("MMM dd, HH:mm")
                val formattedTime = dateTime.atZone(java.time.ZoneId.systemDefault()).format(formatter)
                "Updated: $formattedTime"
            } catch (e: Exception) {
                "Tap to refresh"
            }
        } else {
            "Tap to refresh"
        }
        
        views.setTextViewText(R.id.last_updated, lastUpdatedText)
        
        // Set up click intent to open the app with refresh action
        val intent = Intent(context, MainActivity::class.java).apply {
            action = Intent.ACTION_VIEW
            data = Uri.parse("synapseFinance://refresh")
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
        }
        
        val pendingIntent = PendingIntent.getActivity(
            context,
            appWidgetId,
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
        
        views.setOnClickPendingIntent(R.id.net_worth_value, pendingIntent)
        
        // Update the widget
        appWidgetManager.updateAppWidget(appWidgetId, views)
    }
}