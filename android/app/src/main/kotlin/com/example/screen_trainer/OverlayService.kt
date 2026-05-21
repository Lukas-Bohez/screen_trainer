package com.screentrainer.screen_trainer

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.Context
import android.content.Intent
import android.graphics.PixelFormat
import android.graphics.Typeface
import android.os.Build
import android.os.IBinder
import android.view.Gravity
import android.view.View
import android.view.WindowManager
import android.widget.FrameLayout
import android.widget.LinearLayout
import android.widget.TextView
import androidx.core.app.NotificationCompat
import androidx.core.content.ContextCompat

class OverlayService : Service() {
    private lateinit var windowManager: WindowManager
    private var overlayView: View? = null

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onCreate() {
        super.onCreate()
        windowManager = getSystemService(WINDOW_SERVICE) as WindowManager
        createNotificationChannel()
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        startForeground(NOTIFICATION_ID, buildNotification())
        when (intent?.action ?: ACTION_SHOW) {
            ACTION_HIDE -> hideOverlay()
            else -> showOverlay()
        }
        return START_STICKY
    }

    private fun showOverlay() {
        if (overlayView != null || !SettingsCompat.canDrawOverlays(this)) {
            showing.set(overlayView != null)
            return
        }

        val root = FrameLayout(this).apply {
            setBackgroundColor(0xCC004D40.toInt())
            setPadding(64, 96, 64, 96)
        }

        val content = LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            gravity = Gravity.CENTER
        }

        val title = TextView(this).apply {
            text = "ScreenTrainer"
            textSize = 28f
            setTypeface(typeface, Typeface.BOLD)
            setTextColor(0xFFFFFFFF.toInt())
            gravity = Gravity.CENTER
        }

        val body = TextView(this).apply {
            text = "Curtain locked — complete your challenge to unlock the screen."
            textSize = 18f
            setTextColor(0xFFE0F2F1.toInt())
            gravity = Gravity.CENTER
            setPadding(0, 24, 0, 0)
        }

        content.addView(title)
        content.addView(body)
        root.addView(
            content,
            FrameLayout.LayoutParams(
                FrameLayout.LayoutParams.MATCH_PARENT,
                FrameLayout.LayoutParams.WRAP_CONTENT,
                Gravity.CENTER,
            ),
        )

        val layoutParams = WindowManager.LayoutParams(
            WindowManager.LayoutParams.MATCH_PARENT,
            WindowManager.LayoutParams.MATCH_PARENT,
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY else WindowManager.LayoutParams.TYPE_PHONE,
            WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE or
                WindowManager.LayoutParams.FLAG_LAYOUT_IN_SCREEN or
                WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON or
                WindowManager.LayoutParams.FLAG_SECURE,
            PixelFormat.TRANSLUCENT,
        )

        windowManager.addView(root, layoutParams)
        overlayView = root
        showing.set(true)
    }

    private fun hideOverlay() {
        overlayView?.let { windowManager.removeView(it) }
        overlayView = null
        showing.set(false)
        stopForeground(true)
        stopSelf()
    }

    override fun onDestroy() {
        hideOverlay()
        super.onDestroy()
    }

    private fun buildNotification(): Notification {
        val launchIntent = packageManager.getLaunchIntentForPackage(packageName)
            ?: Intent(this, MainActivity::class.java)
        val pendingIntent = PendingIntent.getActivity(
            this,
            0,
            launchIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or pendingIntentFlags(),
        )

        return NotificationCompat.Builder(this, CHANNEL_ID)
            .setSmallIcon(android.R.drawable.ic_lock_lock)
            .setContentTitle("ScreenTrainer active")
            .setContentText("Curtain overlay is running")
            .setContentIntent(pendingIntent)
            .setOngoing(true)
            .build()
    }

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) return
        val channel = NotificationChannel(CHANNEL_ID, "ScreenTrainer Overlay", NotificationManager.IMPORTANCE_LOW)
        val manager = getSystemService(NOTIFICATION_SERVICE) as NotificationManager
        manager.createNotificationChannel(channel)
    }

    private fun pendingIntentFlags(): Int {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) PendingIntent.FLAG_IMMUTABLE else 0
    }

    companion object {
        const val ACTION_SHOW = "com.screentrainer.screen_trainer.overlay.SHOW"
        const val ACTION_HIDE = "com.screentrainer.screen_trainer.overlay.HIDE"
        private const val CHANNEL_ID = "screen_trainer_overlay"
        private const val NOTIFICATION_ID = 4201

        private val showing = java.util.concurrent.atomic.AtomicBoolean(false)

        fun start(context: Context) {
            val intent = Intent(context, OverlayService::class.java).apply { action = ACTION_SHOW }
            ContextCompat.startForegroundService(context, intent)
        }

        fun stop(context: Context) {
            val intent = Intent(context, OverlayService::class.java).apply { action = ACTION_HIDE }
            ContextCompat.startForegroundService(context, intent)
        }

        fun isShowing(): Boolean = showing.get()
    }
}

private object SettingsCompat {
    fun canDrawOverlays(context: Context): Boolean =
        Build.VERSION.SDK_INT < Build.VERSION_CODES.M || android.provider.Settings.canDrawOverlays(context)
}