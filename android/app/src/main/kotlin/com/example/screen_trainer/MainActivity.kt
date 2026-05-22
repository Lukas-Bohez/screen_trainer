package com.screentrainer.screen_trainer

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.net.Uri
import android.os.Build
import android.os.PowerManager
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
	private var screenStateReceiver: BroadcastReceiver? = null
	private var screenStateSink: EventChannel.EventSink? = null

	override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
		super.configureFlutterEngine(flutterEngine)

		MethodChannel(flutterEngine.dartExecutor.binaryMessenger, OVERLAY_CHANNEL).setMethodCallHandler { call, result ->
			when (call.method) {
				"showOverlay" -> {
					OverlayService.start(this)
					result.success(null)
				}
				"hideOverlay" -> {
					OverlayService.stop(this)
					result.success(null)
				}
				"isOverlayShowing" -> result.success(OverlayService.isShowing())
				"isScreenOn" -> result.success(isScreenInteractive())
				"requestOverlayPermission" -> {
					requestOverlayPermission()
					result.success(null)
				}
				"openAccessibilitySettings" -> {
					startActivity(Intent(Settings.ACTION_ACCESSIBILITY_SETTINGS).addFlags(Intent.FLAG_ACTIVITY_NEW_TASK))
					result.success(null)
				}
				else -> result.notImplemented()
			}
		}

		// Usage stats channel
		MethodChannel(flutterEngine.dartExecutor.binaryMessenger, USAGE_CHANNEL).setMethodCallHandler { call, result ->
			when (call.method) {
				"getTodayUsageMs" -> {
					val packageName = call.argument<String>("packageName") ?: packageName
					val ms = UsageStatsHelper.getTodayUsageMs(this, packageName)
					result.success(ms)
				}
				"hasUsagePermission" -> {
					result.success(UsageStatsHelper.hasUsagePermission(this))
				}
				else -> result.notImplemented()
			}
		}

		EventChannel(flutterEngine.dartExecutor.binaryMessenger, SCREEN_STATE_CHANNEL).setStreamHandler(object : EventChannel.StreamHandler {
			override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
				screenStateSink = events
				registerScreenReceiver()
				events?.success(if (isScreenInteractive()) "screen_on" else "screen_off")
			}

			override fun onCancel(arguments: Any?) {
				unregisterScreenReceiver()
				screenStateSink = null
			}
		})
	}

	private fun registerScreenReceiver() {
		if (screenStateReceiver != null) return
		screenStateReceiver = object : BroadcastReceiver() {
			override fun onReceive(context: Context?, intent: Intent?) {
				val state = when (intent?.action) {
					Intent.ACTION_SCREEN_OFF -> "screen_off"
					else -> "screen_on"
				}
				screenStateSink?.success(state)
			}
		}
		val filter = IntentFilter().apply {
			addAction(Intent.ACTION_SCREEN_ON)
			addAction(Intent.ACTION_SCREEN_OFF)
		}
		registerReceiver(screenStateReceiver, filter)
	}

	private fun unregisterScreenReceiver() {
		val receiver = screenStateReceiver ?: return
		unregisterReceiver(receiver)
		screenStateReceiver = null
	}

	private fun requestOverlayPermission() {
		if (Build.VERSION.SDK_INT < Build.VERSION_CODES.M || Settings.canDrawOverlays(this)) return
		val intent = Intent(Settings.ACTION_MANAGE_OVERLAY_PERMISSION, Uri.parse("package:$packageName")).apply {
			addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
		}
		startActivity(intent)
	}

	private fun isScreenInteractive(): Boolean {
		val powerManager = getSystemService(Context.POWER_SERVICE) as PowerManager
		return powerManager.isInteractive
	}

	companion object {
		private const val OVERLAY_CHANNEL = "com.screentrainer/overlay"
		private const val USAGE_CHANNEL = "com.screentrainer/usage"
		private const val SCREEN_STATE_CHANNEL = "com.screentrainer/screen_state"
	}
}
