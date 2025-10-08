package com.tech_with_m.choy_ritur_golpo

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.graphics.BitmapFactory
import android.graphics.Color
import android.os.Handler
import android.os.Looper
import android.os.PowerManager
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import android.appwidget.AppWidgetProvider
import java.text.SimpleDateFormat
import java.util.Calendar
import java.util.Locale
import java.io.File
import kotlinx.coroutines.*

// Base widget provider class
abstract class BaseWeatherWidget : AppWidgetProvider() {
    companion object {
        private val DEFAULT_ICON = R.drawable.cloud
        private val UPDATE_INTERVAL = 1740000L // 15 minutes in milliseconds
        private val handler = Handler(Looper.getMainLooper())
        
        // Manual refresh method that can be called from system
        fun forceRefreshAllWidgets(context: Context) {
            try {
                val appWidgetManager = AppWidgetManager.getInstance(context)
                
                // Update 4x2 widgets
                val provider4x2 = ComponentName(context, OreoWidget4x2::class.java)
                val appWidgetIds4x2 = appWidgetManager.getAppWidgetIds(provider4x2)
                if (appWidgetIds4x2.isNotEmpty()) {
                    val intent4x2 = Intent(context, OreoWidget4x2::class.java)
                    intent4x2.action = AppWidgetManager.ACTION_APPWIDGET_UPDATE
                    intent4x2.putExtra(AppWidgetManager.EXTRA_APPWIDGET_IDS, appWidgetIds4x2)
                    context.sendBroadcast(intent4x2)
                }
                
                // Update 4x1 widgets
                val provider4x1 = ComponentName(context, OreoWidget4x1::class.java)
                val appWidgetIds4x1 = appWidgetManager.getAppWidgetIds(provider4x1)
                if (appWidgetIds4x1.isNotEmpty()) {
                    val intent4x1 = Intent(context, OreoWidget4x1::class.java)
                    intent4x1.action = AppWidgetManager.ACTION_APPWIDGET_UPDATE
                    intent4x1.putExtra(AppWidgetManager.EXTRA_APPWIDGET_IDS, appWidgetIds4x1)
                    context.sendBroadcast(intent4x1)
                }
                
                android.util.Log.d("WidgetDebug", "✅ Force refresh triggered for all widgets")
            } catch (e: Exception) {
                android.util.Log.e("WidgetDebug", "❌ Error in forceRefreshAllWidgets: ${e.message}")
            }
        }
    }
    
    protected abstract fun getLayoutId(): Int
    protected abstract fun isSmallWidget(): Boolean

    private fun acquireWakeLock(context: Context): PowerManager.WakeLock? {
        return try {
            val powerManager = context.getSystemService(Context.POWER_SERVICE) as PowerManager
            powerManager.newWakeLock(
                PowerManager.PARTIAL_WAKE_LOCK,
                "ChoyRiturGolpo::WidgetUpdate"
            ).apply {
                setReferenceCounted(false)  // Auto-release after timeout
                acquire(7000) // 7 seconds max
                android.util.Log.d("WidgetDebug", "✅ Wake lock acquired with 5s timeout")
            }
        } catch (e: Exception) {
            android.util.Log.e("WidgetDebug", "❌ Wake lock acquisition failed: ${e.message}")
            null
        }
    }

    override fun onEnabled(context: Context) {
        super.onEnabled(context)
        android.util.Log.d("WidgetDebug", "🔄 Widget enabled, triggering initial update")
        
        // Show loading state immediately
        try {
            val views = RemoteViews(context.packageName, getLayoutId())
            views.setInt(R.id.widget_background, "setBackgroundResource", R.drawable.widget_background_loading)
            views.setTextViewText(R.id.bangla_date, "লোড হচ্ছে...")
            views.setTextViewText(R.id.weather_description, "আবহাওয়ার তথ্য লোড হচ্ছে...")
            views.setTextViewText(R.id.temperature, "--°")
            views.setImageViewResource(R.id.weather_icon, R.drawable.cloud)
            
            // Set click intent with proper flags
            val pendingIntent = HomeWidgetLaunchIntent.getActivity(
                context,
                MainActivity::class.java,
                null  // data Uri
            )
            views.setOnClickPendingIntent(R.id.widget_container, pendingIntent)
            
            AppWidgetManager.getInstance(context).updateAppWidget(
                ComponentName(context, this::class.java),
                views
            )
            android.util.Log.d("WidgetDebug", "✅ Loading state set")
        } catch (e: Exception) {
            android.util.Log.e("WidgetDebug", "❌ Error setting loading state: ${e.message}")
        }
        
        // Launch app and trigger background update
        try {
            // Acquire wake lock with auto-release
            val wakeLock = acquireWakeLock(context)
            
            // Launch main activity once with proper flags for MIUI compatibility
            val launchIntent = context.packageManager.getLaunchIntentForPackage(context.packageName)?.apply {
                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or 
                        Intent.FLAG_ACTIVITY_RESET_TASK_IF_NEEDED)
                action = Intent.ACTION_MAIN
                addCategory(Intent.CATEGORY_LAUNCHER)
                putExtra("widget_update_requested", true)
                putExtra("widget_class", this@BaseWeatherWidget::class.java.name)
            }
            if (launchIntent != null) {
                context.startActivity(launchIntent)
            }
            android.util.Log.d("WidgetDebug", "✅ App launched with wake lock")
        } catch (e: Exception) {
            android.util.Log.e("WidgetDebug", "❌ Failed to launch app: ${e.message}")
        }
        
        // Send single background update intent with longer delay for MIUI
        handler.postDelayed({
            triggerBackgroundUpdate(context)
        }, 2000)  // 2 second delay to ensure smooth launch on MIUI
    }

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        try {
            android.util.Log.d("WidgetDebug", "🔄 Widget update started")
            // Show loading state immediately
            for (appWidgetId in appWidgetIds) {
                updateLoadingState(context, appWidgetManager, appWidgetId)
            }
            
            // Trigger background update with delay
            handler.postDelayed({
                triggerBackgroundUpdate(context)
            }, 800)
            
            // Process widget data update
            processWidgetUpdate(context, appWidgetManager, appWidgetIds)
            
        } catch (e: Exception) {
            android.util.Log.e("WidgetDebug", "❌ Fatal error in onUpdate: ${e.message}")
            e.printStackTrace()
        }
    }

    private fun updateLoadingState(context: Context, appWidgetManager: AppWidgetManager, appWidgetId: Int) {
        try {
            val views = RemoteViews(context.packageName, getLayoutId())
            views.setInt(R.id.widget_background, "setBackgroundResource", R.drawable.widget_background_loading)
            views.setTextViewText(R.id.weather_description, "আবহাওয়ার তথ্য লোড হচ্ছে...")
            views.setTextViewText(R.id.temperature, "--°")
            
            // Set click intent
            val pendingIntent = HomeWidgetLaunchIntent.getActivity(
                context,
                MainActivity::class.java,
                null  // data Uri
            )
            views.setOnClickPendingIntent(R.id.widget_container, pendingIntent)
            
            appWidgetManager.updateAppWidget(appWidgetId, views)
        } catch (e: Exception) {
            android.util.Log.e("WidgetDebug", "❌ Error showing loading state: ${e.message}")
        }
    }

    private fun triggerBackgroundUpdate(context: Context) {
        try {
            // Send single update intent
            val updateIntent = Intent("es.antonborri.home_widget.action.BACKGROUND")
            updateIntent.`package` = context.packageName
            context.sendBroadcast(updateIntent)
            android.util.Log.d("WidgetDebug", "✅ Update intent sent")
        } catch (e: Exception) {
            android.util.Log.e("WidgetDebug", "❌ Failed to trigger background update: ${e.message}")
        }
    }

    private fun processWidgetUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        try {
            // Try different SharedPreferences locations
            val preferenceNames = listOf(
                "HomeWidgetPreferences",
                "FlutterSharedPreferences",
                "es.antonborri.home_widget"
            )
            
            var homeWidgetPrefs: SharedPreferences? = null
            var usedName = ""
            
            for (prefName in preferenceNames) {
                val prefs = context.getSharedPreferences(prefName, Context.MODE_PRIVATE)
                if (prefs.all.isNotEmpty()) {
                    homeWidgetPrefs = prefs
                    usedName = prefName
                    android.util.Log.d("WidgetDebug", "✅ Found data in: $prefName")
                    break
                }
            }
            
            if (homeWidgetPrefs == null || homeWidgetPrefs.all.isEmpty()) {
                android.util.Log.d("WidgetDebug", "⚠️ No widget data found in any SharedPreferences")
                // Show loading state for all widgets
                for (appWidgetId in appWidgetIds) {
                    updateLoadingState(context, appWidgetManager, appWidgetId)
                }
                return
            }

            // Log available keys for debugging
            android.util.Log.d("WidgetDebug", "📊 Available keys: ${homeWidgetPrefs.all.keys}")

            // Update each widget instance
            for (appWidgetId in appWidgetIds) {
                try {
                    updateWidget(context, appWidgetManager, appWidgetId, homeWidgetPrefs, usedName)
                } catch (e: Exception) {
                    android.util.Log.e("WidgetDebug", "❌ Error updating widget $appWidgetId: ${e.message}")
                    showErrorState(context, appWidgetManager, appWidgetId)
                }
            }
        } catch (e: Exception) {
            android.util.Log.e("WidgetDebug", "❌ Critical error in processWidgetUpdate: ${e.message}")
            // Show error state for all widgets
            for (appWidgetId in appWidgetIds) {
                showErrorState(context, appWidgetManager, appWidgetId)
            }
        }
    }

    private fun showErrorState(context: Context, appWidgetManager: AppWidgetManager, appWidgetId: Int) {
        try {
            val views = RemoteViews(context.packageName, getLayoutId())
            views.setInt(R.id.widget_background, "setBackgroundResource", R.drawable.widget_background_error)
            views.setTextViewText(R.id.weather_description, "আবহাওয়ার তথ্য পাওয়া যায়নি")
            
            // Set click intent
            val pendingIntent = HomeWidgetLaunchIntent.getActivity(
                context,
                MainActivity::class.java,
                null  // data Uri
            )
            views.setOnClickPendingIntent(R.id.widget_container, pendingIntent)
            
            appWidgetManager.updateAppWidget(appWidgetId, views)
        } catch (e: Exception) {
            android.util.Log.e("WidgetDebug", "❌ Error showing error state: ${e.message}")
        }
    }

    private fun updateWidget(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetId: Int,
        widgetData: SharedPreferences,
        usedName: String
    ) {
        try {
            android.util.Log.d("WidgetDebug", "🔄 Starting widget update for ID: $appWidgetId")
            
            val views = RemoteViews(context.packageName, getLayoutId())
            
            // Set click intent
            val pendingIntent = HomeWidgetLaunchIntent.getActivity(
                context,
                MainActivity::class.java,
                null  // data Uri
            )
            views.setOnClickPendingIntent(R.id.widget_container, pendingIntent)

            // Get update status
            val updateStatus = widgetData.getString("update_status", "error")
            android.util.Log.d("WidgetDebug", "📊 Widget status: $updateStatus")
            
            // Apply background
            val backgroundRes = when (updateStatus) {
                "error" -> R.drawable.widget_background_error
                "loading", "initializing", "updating" -> R.drawable.widget_background_loading
                else -> R.drawable.widget_background_glass
            }
            views.setInt(R.id.widget_background, "setBackgroundResource", backgroundRes)

            // Update text and icon
            updateTextFields(views, widgetData, updateStatus)
            updateWeatherIcon(views, widgetData, context)

            // Set text colors
            val textColor = Color.WHITE
            views.setTextColor(R.id.bangla_date, textColor)
            views.setTextColor(R.id.weather_description, textColor)
            views.setTextColor(R.id.temperature, textColor)

            // Update widget
            appWidgetManager.updateAppWidget(appWidgetId, views)
            android.util.Log.d("WidgetDebug", "✅ Widget updated successfully")

        } catch (e: Exception) {
            android.util.Log.e("WidgetDebug", "❌ Error in updateWidget: ${e.message}")
            throw e
        }
    }

    private fun updateTextFields(
        views: RemoteViews,
        widgetData: SharedPreferences,
        updateStatus: String?
    ) {
        fun getText(key: String, default: String): String {
            return when (updateStatus) {
                "error" -> widgetData.getString(key, default) ?: default
                "loading", "initializing" -> "..."
                "updating" -> widgetData.getString(key, "...") ?: "..."
                else -> widgetData.getString(key, default) ?: default
            }
        }

        views.setTextViewText(R.id.bangla_date, getText("bangla_date", "-- ---, ----"))
        views.setTextViewText(R.id.weather_description, getText("weather_desc", "আবহাওয়ার তথ্য লোড হচ্ছে..."))
        views.setTextViewText(R.id.temperature, getText("temperature", "--°"))
    }

    private fun updateWeatherIcon(
        views: RemoteViews,
        widgetData: SharedPreferences,
        context: Context
    ) {
        try {
            val weatherIcon = widgetData.getString("weather_icon", null)
            if (weatherIcon != null) {
                val bitmap = BitmapFactory.decodeFile(weatherIcon)
                if (bitmap != null) {
                    views.setImageViewBitmap(R.id.weather_icon, bitmap)
                    return
                }
            }
        } catch (e: Exception) {
            android.util.Log.e("WidgetDebug", "❌ Failed to load weather icon: ${e.message}")
        }
        views.setImageViewResource(R.id.weather_icon, DEFAULT_ICON)
    }
}

// 4x2 Widget Provider
class OreoWidget4x2 : BaseWeatherWidget() {
    override fun getLayoutId(): Int = R.layout.weather_widget_4x2
    override fun isSmallWidget(): Boolean = false
}

// 4x1 Widget Provider  
class OreoWidget4x1 : BaseWeatherWidget() {
    override fun getLayoutId(): Int = R.layout.weather_widget_4x1
    override fun isSmallWidget(): Boolean = true
}