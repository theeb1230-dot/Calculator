package com.theeb.calculator

import android.os.Build
import android.security.keystore.KeyGenParameterSpec
import android.security.keystore.KeyProperties
import android.security.keystore.StrongBoxUnavailableException
import android.view.WindowManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.security.KeyStore
import java.security.SecureRandom
import java.util.UUID
import javax.crypto.Cipher
import javax.crypto.KeyGenerator
import javax.crypto.SecretKey
import javax.crypto.spec.GCMParameterSpec

class MainActivity : FlutterActivity() {
    private companion object {
        const val SECURITY_CHANNEL = "com.theeb.calculator/security"
        const val KEY_CHANNEL = "calculator/platform_keys"
        const val KEYSTORE = "AndroidKeyStore"
        const val HANDLE_PREFIX = "vault-key-"
        const val ALIAS_PREFIX = "calculator_vault_"
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        val messenger = flutterEngine.dartExecutor.binaryMessenger
        MethodChannel(messenger, SECURITY_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "setProtectedContent" -> {
                    val enabled = call.argument<Boolean>("enabled") ?: return@setMethodCallHandler result.error("INVALID_ARGUMENT", "enabled must be boolean", null)
                    runOnUiThread { if (enabled) window.addFlags(WindowManager.LayoutParams.FLAG_SECURE) else window.clearFlags(WindowManager.LayoutParams.FLAG_SECURE); result.success(null) }
                }
                else -> result.notImplemented()
            }
        }
        MethodChannel(messenger, KEY_CHANNEL).setMethodCallHandler { call, result ->
            try {
                when (call.method) {
                    "createVaultKey" -> result.success(createVaultKey())
                    "containsVaultKey" -> result.success(containsVaultKey(call.arguments as? String))
                    "destroyVaultKey" -> { destroyVaultKey(call.arguments as? String); result.success(null) }
                    "createWrappedDataKey" -> result.success(createWrappedDataKey(call.arguments as? Map<*, *>))
                    "unwrapDataKey" -> result.success(unwrapDataKey(call.arguments as? Map<*, *>))
                    else -> result.notImplemented()
                }
            } catch (error: Exception) { result.error("KEYSTORE_FAILURE", "Platform key operation failed", error.javaClass.simpleName) }
        }
    }

    private fun createVaultKey(): String {
        val id = UUID.randomUUID().toString().replace("-", ""); val alias = ALIAS_PREFIX + id
        fun spec(strongBox: Boolean): KeyGenParameterSpec {
            val builder = KeyGenParameterSpec.Builder(alias, KeyProperties.PURPOSE_ENCRYPT or KeyProperties.PURPOSE_DECRYPT).setBlockModes(KeyProperties.BLOCK_MODE_GCM).setEncryptionPaddings(KeyProperties.ENCRYPTION_PADDING_NONE).setKeySize(256)
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P && strongBox) builder.setIsStrongBoxBacked(true)
            return builder.build()
        }
        val generator = KeyGenerator.getInstance(KeyProperties.KEY_ALGORITHM_AES, KEYSTORE)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) try { generator.init(spec(true)); generator.generateKey(); return HANDLE_PREFIX + id } catch (_: StrongBoxUnavailableException) {}
        generator.init(spec(false)); generator.generateKey(); return HANDLE_PREFIX + id
    }

    private fun masterKey(handle: String?): SecretKey {
        val id = requireNotNull(rawId(handle)) { "Invalid opaque key handle" }
        val key = KeyStore.getInstance(KEYSTORE).apply { load(null) }.getKey(ALIAS_PREFIX + id, null)
        return key as? SecretKey ?: error("Vault key unavailable")
    }

    private fun createWrappedDataKey(args: Map<*, *>?): ByteArray {
        val handle = args?.get("handle") as? String; val context = args?.get("context") as? ByteArray ?: error("Context required")
        require(context.isNotEmpty())
        val dataKey = ByteArray(32).also { SecureRandom().nextBytes(it) }; val nonce = ByteArray(12).also { SecureRandom().nextBytes(it) }
        val cipher = Cipher.getInstance("AES/GCM/NoPadding"); cipher.init(Cipher.ENCRYPT_MODE, masterKey(handle), GCMParameterSpec(128, nonce)); cipher.updateAAD(context)
        val encrypted = cipher.doFinal(dataKey); dataKey.fill(0); return nonce + encrypted
    }

    private fun unwrapDataKey(args: Map<*, *>?): ByteArray {
        val handle = args?.get("handle") as? String; val wrapped = args?.get("wrappedDataKey") as? ByteArray ?: error("Wrapped key required"); val context = args?.get("context") as? ByteArray ?: error("Context required")
        require(wrapped.size == 60 && context.isNotEmpty()); val nonce = wrapped.copyOfRange(0, 12); val encrypted = wrapped.copyOfRange(12, wrapped.size)
        val cipher = Cipher.getInstance("AES/GCM/NoPadding"); cipher.init(Cipher.DECRYPT_MODE, masterKey(handle), GCMParameterSpec(128, nonce)); cipher.updateAAD(context)
        return cipher.doFinal(encrypted).also { require(it.size == 32) }
    }

    private fun rawId(handle: String?): String? { if (handle == null || !handle.matches(Regex("^vault-key-[a-f0-9]{32}$"))) return null; return handle.removePrefix(HANDLE_PREFIX) }
    private fun containsVaultKey(handle: String?): Boolean { val id = rawId(handle) ?: return false; return KeyStore.getInstance(KEYSTORE).apply { load(null) }.containsAlias(ALIAS_PREFIX + id) }
    private fun destroyVaultKey(handle: String?) { val id = requireNotNull(rawId(handle)); KeyStore.getInstance(KEYSTORE).apply { load(null) }.deleteEntry(ALIAS_PREFIX + id) }
}
