package com.technogm.technogm

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.net.Uri
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetBackgroundIntent
import java.util.Locale

class WaterWidgetProvider : AppWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        for (id in appWidgetIds) {
            updateWidget(context, appWidgetManager, id)
        }
    }

    companion object {
        fun updateWidget(context: Context, appWidgetManager: AppWidgetManager, appWidgetId: Int) {
            val prefs = context.getSharedPreferences("HomeWidgetPlugin", Context.MODE_PRIVATE)
            val waterMl = prefs.getInt("water_ml", 0)

            val views = RemoteViews(context.packageName, R.layout.water_widget)

            views.setTextViewText(
                R.id.water_amount,
                String.format(Locale.getDefault(), "%,d mL", waterMl)
            )
            views.setTextViewText(
                R.id.water_goal_label,
                String.format(Locale.getDefault(), "/ 2,000 mL  (%d%%)", (waterMl * 100 / 2000).coerceAtMost(100))
            )
            views.setProgressBar(R.id.water_progress, 2000, waterMl.coerceAtMost(2000), false)

            // Background callbacks — add water without opening the app
            views.setOnClickPendingIntent(
                R.id.btn_water_100,
                HomeWidgetBackgroundIntent.getBroadcast(
                    context, Uri.parse("technogm://addwater?amount=100")
                )
            )
            views.setOnClickPendingIntent(
                R.id.btn_water_250,
                HomeWidgetBackgroundIntent.getBroadcast(
                    context, Uri.parse("technogm://addwater?amount=250")
                )
            )
            views.setOnClickPendingIntent(
                R.id.btn_water_500,
                HomeWidgetBackgroundIntent.getBroadcast(
                    context, Uri.parse("technogm://addwater?amount=500")
                )
            )

            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }
}
