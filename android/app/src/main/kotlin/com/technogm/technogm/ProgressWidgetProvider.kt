package com.technogm.technogm

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.widget.RemoteViews
import java.util.Locale

class ProgressWidgetProvider : AppWidgetProvider() {

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
            val steps = prefs.getInt("steps", 0)
            val calories = prefs.getInt("calories", 0)
            val activeMinutes = prefs.getInt("active_minutes", 0)
            val waterMl = prefs.getInt("water_ml", 0)
            val streak = prefs.getInt("streak", 0)

            val views = RemoteViews(context.packageName, R.layout.progress_widget)

            views.setTextViewText(R.id.steps_value, String.format(Locale.getDefault(), "%,d", steps))
            views.setProgressBar(R.id.steps_progress, 10000, steps.coerceAtMost(10000), false)

            views.setTextViewText(R.id.active_value, "$activeMinutes MIN")
            views.setProgressBar(R.id.active_progress, 30, activeMinutes.coerceAtMost(30), false)

            views.setTextViewText(R.id.calories_value, "$calories KCAL")
            views.setProgressBar(R.id.calories_progress, 500, calories.coerceAtMost(500), false)

            views.setTextViewText(R.id.water_value, String.format(Locale.getDefault(), "%,d mL", waterMl))
            views.setProgressBar(R.id.water_progress, 2000, waterMl.coerceAtMost(2000), false)

            views.setTextViewText(R.id.streak_value, "$streak WKS")

            // Tap anywhere → open app
            val intent = Intent(context, MainActivity::class.java).apply {
                flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
            }
            val pendingIntent = PendingIntent.getActivity(
                context, 0, intent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
            views.setOnClickPendingIntent(R.id.widget_root, pendingIntent)

            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }
}
