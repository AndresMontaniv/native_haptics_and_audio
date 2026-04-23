package com.andresmontano.native_haptics_and_audio

import android.content.Context
import android.media.AudioAttributes
import android.media.SoundPool
import android.os.Build
import android.os.VibrationEffect
import android.os.Vibrator
import android.os.VibratorManager
import io.flutter.embedding.engine.plugins.FlutterPlugin
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext

/**
 * Android implementation of the [HapticsAndAudioApi] Pigeon interface.
 *
 * Uses [SoundPool] for zero-latency PCM playback and the [Vibrator]
 * service for native haptic feedback patterns.
 */
class NativeHapticsAndAudioPlugin :
    FlutterPlugin,
    HapticsAndAudioApi {

    private lateinit var context: Context
    private var soundPool: SoundPool? = null
    private val soundIds = mutableMapOf<PosSound, Int>()

    // ──────────────────────────────────────────────
    // FlutterPlugin lifecycle
    // ──────────────────────────────────────────────

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        context = binding.applicationContext
        HapticsAndAudioApi.setUp(binding.binaryMessenger, this)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        HapticsAndAudioApi.setUp(binding.binaryMessenger, null)
        releaseSoundPool()
    }

    // ──────────────────────────────────────────────
    // HapticsAndAudioApi – Pigeon interface
    // ──────────────────────────────────────────────

    /**
     * Pre-loads all `.wav` assets from `res/raw` into the [SoundPool].
     *
     * Disk I/O runs on [Dispatchers.IO]; the Pigeon [callback] is invoked
     * only after every asset has been fully loaded into native RAM.
     */
    override fun initialize(callback: (Result<Unit>) -> Unit) {
        CoroutineScope(Dispatchers.IO).launch {
            try {
                val audioAttributes = AudioAttributes.Builder()
                    .setUsage(AudioAttributes.USAGE_ASSISTANCE_SONIFICATION)
                    .setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION)
                    .build()

                val pool = SoundPool.Builder()
                    .setMaxStreams(4)
                    .setAudioAttributes(audioAttributes)
                    .build()

                soundPool = pool

                // Map each enum value to its corresponding raw resource.
                val resourceMap = mapOf(
                    PosSound.SCANNER_BEEP to R.raw.store_scanner_beep,
                    PosSound.WARNING_BEEP to R.raw.beep_warning,
                    PosSound.DOUBLE_WARNING_BEEP to R.raw.double_beep_warning,
                    PosSound.KACHING to R.raw.kaching,
                )

                for ((sound, resId) in resourceMap) {
                    soundIds[sound] = pool.load(context, resId, 1)
                }

                // Give SoundPool a moment to finish internal decoding.
                // SoundPool.load() is async internally; a brief yield
                // ensures buffers are ready for instant playback.
                kotlinx.coroutines.delay(150)

                withContext(Dispatchers.Main) {
                    callback(Result.success(Unit))
                }
            } catch (e: Exception) {
                withContext(Dispatchers.Main) {
                    callback(Result.failure(e))
                }
            }
        }
    }

    /** Instantly plays a pre-loaded audio asset at full volume. */
    override fun playSound(sound: PosSound) {
        val id = soundIds[sound]
            ?: throw FlutterError("SOUND_NOT_LOADED", "Sound $sound has not been loaded.")
        soundPool?.play(id, 1.0f, 1.0f, 1, 0, 1.0f)
    }

    /**
     * Triggers a native haptic vibration pattern.
     *
     * - [PosHaptic.SUCCESS] → short tick  (20 ms)
     * - [PosHaptic.WARNING] → medium buzz (100 ms)
     * - [PosHaptic.ERROR]   → heavy double-buzz (0, 80, 100, 80 ms pattern)
     */
    override fun playHaptic(haptic: PosHaptic) {
        val vibrator = getVibrator()

        when (haptic) {
            PosHaptic.SUCCESS -> {
                vibrator.vibrate(
                    VibrationEffect.createOneShot(65, 255)
                )
            }
            PosHaptic.WARNING -> {
                vibrator.vibrate(
                    VibrationEffect.createOneShot(100, VibrationEffect.DEFAULT_AMPLITUDE)
                )
            }
            PosHaptic.ERROR -> {
                vibrator.vibrate(
                    VibrationEffect.createWaveform(
                        longArrayOf(0, 80, 100, 80),
                        intArrayOf(0, 255, 0, 255),
                        -1
                    )
                )
            }
        }
    }

    /** Releases all [SoundPool] resources and clears the loaded sound map. */
    override fun release() {
        releaseSoundPool()
    }

    // ──────────────────────────────────────────────
    // Private helpers
    // ──────────────────────────────────────────────

    private fun releaseSoundPool() {
        soundPool?.release()
        soundPool = null
        soundIds.clear()
    }

    @Suppress("DEPRECATION")
    private fun getVibrator(): Vibrator {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            val vibratorManager =
                context.getSystemService(Context.VIBRATOR_MANAGER_SERVICE) as VibratorManager
            vibratorManager.defaultVibrator
        } else {
            context.getSystemService(Context.VIBRATOR_SERVICE) as Vibrator
        }
    }
}
