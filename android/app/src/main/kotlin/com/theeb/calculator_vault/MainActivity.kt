package com.theeb.calculator

import android.os.Build
import android.security.keystore.KeyGenParameterSpec
import android.security.keystore.KeyProperties
import android.view.WindowManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.security.KeyStore
import java.util.UUID
import javax.crypto.KeyGenerator

class MainActivity : FlutterActivity() {
    private companion object {
        const val SECURITY_CHANNEL = "com.theeb.calculator/security"
        const val KEY_CHANNEL = "calculator/platform_keys"
        const val KEYSTORE = "AndroidKeyStore"
        const val ALIAS_PREFIX = "calculator_vault_"
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        val messenger = flutterEngine.dartExecutor.binaryMessenger
        MethodChannel(messenger, SECURITY_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "setProtectedContent" -> {
                    val enabled = call.argument<Boolean>("enabled")
                    if (enabled == null) {
                        result.error("INVALID_ARGUMENT", "enabled must be boolean", null)
                        return@setMethodCallHandler
                    }
                    runOnUiThread {
                        if (enabled) window.addFlags(WindowManager.LayoutParams.FLAG_SECURE)
                        else window.clearFlags(WindowManager.LayoutParams.FLAG_SECURE)
                        result.success(null)
                    }
                }
                else -> result.notImplemented()
            }
        }
        MethodChannel(messenger, KEY_CHANNEL).setMethodCallHandler { call, result ->
            try {
                when (call.method) {
                    "createVaultKey" -> result.success(createVaultKey())
                    "containsVaultKey" -> result.success(containsVaultKey(call.arguments as? String))
                    "destroyVaultKey" -> {
                        destroyVaultKey(call.arguments as? String)
                        result.success(null)
                    }
                    // Data-key wrapping/unwrap is intentionally fail-closed until the
                    // authenticated envelope implementation is wired to this native key.
                    "unwrapDataKey" -> result.error("NOT_IMPLEMENTED", "Native authenticated unwrap is not wired yet", null)
                    else -> result.notImplemented()
                }
            } catch (error: Exception) {
                result.error("KEYSTORE_FAILURE", "Platform key operation failed", error.javaClass.simpleName)
            }
        }
    }

    private fun createVaultKey(): String {
        val id = UUID.randomUUID().toString().replace("-", "")
        val alias = ALIAS_PREFIX + id
        val generator = KeyGenerator.getInstance(KeyProperties.KEY_ALGORITHM_AES, KEYSTORE)
        val builder = KeyGenParameterSpec.Builder(
            alias,
            KeyProperties.PURPOSE_ENCRYPT or KeyProperties.PURPOSE_DECRYPT
        ).setBlockModes(KeyProperties.BLOCK_MODE_GCM)
            .setEncryptionPaddings(KeyProperties.ENCRYPTION_PADDING_NONE)
            .setKeySize(256)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
            // Prefer StrongBox when available; retry without it when hardware lacks it.
            try {
                generator.init(builder.setIsStrongBoxBacked(true).build())
                generator.generateKey()
                return id
            } catch (_: Exception) {
                // Fall through to Android Keystore-backed generation.
            }
        }
        generator.init(builder.setIsStrongBoxBacked(false).build())
        generator.generateKey()
        return id
    }

    private fun containsVaultKey(id: String?): Boolean {
        if (!validId(id)) return false
        return KeyStore.getInstance(KEYSTORE).apply { load(null) }.containsAlias(ALIAS_PREFIX + id)
    }

    private fun destroyVaultKey(id: String?) {
        require(validId(id)) { "Invalid opaque key handle" }
        KeyStore.getInstance(KEYSTORE).apply { load(null) }.deleteEntry(ALIAS_PREFIX + id)
    }

    private fun validId(id: String?): Boolean = id != null && id.matches(Regex("^[a-f0-9]{32}$"))
}
