package com.andresmontano.native_haptics_and_audio

import android.content.Context
import android.os.Vibrator
import org.junit.Before
import org.junit.Test
import org.mockito.Mock
import org.mockito.Mockito
import org.mockito.MockitoAnnotations

class NativeHapticsAndAudioPluginTest {

    @Mock
    private lateinit var mockContext: Context

    @Mock
    private lateinit var mockVibrator: Vibrator

    private lateinit var plugin: NativeHapticsAndAudioPlugin

    @Before
    fun setUp() {
        MockitoAnnotations.openMocks(this)
        
        // Mock Vibrator service (plugin falls back to this on older APIs, or we can just mock it)
        Mockito.`when`(mockContext.getSystemService(Context.VIBRATOR_SERVICE)).thenReturn(mockVibrator)

        plugin = NativeHapticsAndAudioPlugin()
        
        // Inject context directly since we are bypassing onAttachedToEngine for simplicity
        val contextField = NativeHapticsAndAudioPlugin::class.java.getDeclaredField("context")
        contextField.isAccessible = true
        contextField.set(plugin, mockContext)
    }

    @Test
    fun testPlayHapticSuccess() {
        plugin.playHaptic(PosHaptic.SUCCESS)
        
        // Verify vibrator was triggered. 
        Mockito.verify(mockVibrator).vibrate(Mockito.any(android.os.VibrationEffect::class.java) ?: Mockito.any())
    }

    @Test
    fun testPlayHapticWarning() {
        plugin.playHaptic(PosHaptic.WARNING)
        Mockito.verify(mockVibrator).vibrate(Mockito.any(android.os.VibrationEffect::class.java) ?: Mockito.any())
    }

    @Test
    fun testPlayHapticError() {
        plugin.playHaptic(PosHaptic.ERROR)
        Mockito.verify(mockVibrator).vibrate(Mockito.any(android.os.VibrationEffect::class.java) ?: Mockito.any())
    }
}
