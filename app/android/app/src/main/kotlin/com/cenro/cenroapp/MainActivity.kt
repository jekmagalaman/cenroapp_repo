package com.cenro.cenroapp

import android.content.ContentValues
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.os.Environment
import android.provider.MediaStore
import android.provider.DocumentsContract
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File

class MainActivity : FlutterActivity() {
    private val channelName = "com.cenro.cenroapp/file_storage"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "openCertificateFolder" -> {
                        try {
                            openCertificateFolder()
                            result.success(null)
                        } catch (e: Exception) {
                            result.error("OPEN_FOLDER_FAILED", e.message, null)
                        }
                    }

                    "saveToDocuments" -> {
                        try {
                            val args = call.arguments as Map<*, *>
                            val folderName = (args["folderName"] as String?) ?: "Certificate_Inspection"
                            val filename = (args["filename"] as String?) ?: "export.bin"
                            val mimeType = (args["mimeType"] as String?) ?: "application/octet-stream"
                            val bytes = args["bytes"] as ByteArray

                            val uri = saveToDocuments(folderName, filename, mimeType, bytes)
                            result.success(uri.toString())
                        } catch (e: Exception) {
                            result.error("SAVE_FAILED", e.message, null)
                        }
                    }

                    else -> result.notImplemented()
                }
            }
    }

    private fun openCertificateFolder() {
        // Tries to open the folder in the system file manager / DocumentsUI.
        // Path: Internal Storage/Documents/Certificate_Inspection
        val target = "content://com.android.externalstorage.documents/document/primary:Documents/Certificate_Inspection"
        val uri = Uri.parse(target)

        val intent = Intent(Intent.ACTION_VIEW).apply {
            setDataAndType(uri, DocumentsContract.Document.MIME_TYPE_DIR)
            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
        }

        try {
            startActivity(intent)
        } catch (_: Exception) {
            // Fallback: open Documents root if the folder view intent isn't supported.
            val fallbackUri = Uri.parse("content://com.android.externalstorage.documents/document/primary:Documents")
            val fallbackIntent = Intent(Intent.ACTION_VIEW).apply {
                setDataAndType(fallbackUri, DocumentsContract.Document.MIME_TYPE_DIR)
                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
            }
            startActivity(fallbackIntent)
        }
    }

    private fun saveToDocuments(
        folderName: String,
        filename: String,
        mimeType: String,
        bytes: ByteArray
    ): Uri {
        val relativePath = Environment.DIRECTORY_DOCUMENTS + File.separator + folderName + File.separator

        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            // Scoped storage path (Android 10+): use MediaStore with RELATIVE_PATH
            val values = ContentValues().apply {
                put(MediaStore.MediaColumns.DISPLAY_NAME, filename)
                put(MediaStore.MediaColumns.MIME_TYPE, mimeType)
                put(MediaStore.MediaColumns.RELATIVE_PATH, relativePath)
                put(MediaStore.MediaColumns.IS_PENDING, 1)
            }

            val collection = MediaStore.Files.getContentUri(MediaStore.VOLUME_EXTERNAL_PRIMARY)
            val uri = contentResolver.insert(collection, values)
                ?: throw IllegalStateException("Failed to create MediaStore record")

            contentResolver.openOutputStream(uri)?.use { out ->
                out.write(bytes)
                out.flush()
            } ?: throw IllegalStateException("Failed to open output stream")

            values.clear()
            values.put(MediaStore.MediaColumns.IS_PENDING, 0)
            contentResolver.update(uri, values, null, null)

            uri
        } else {
            // Legacy path (Android 9 and below): direct filesystem write
            val documentsDir =
                Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_DOCUMENTS)
            val targetDir = File(documentsDir, folderName)
            if (!targetDir.exists()) targetDir.mkdirs()

            val file = File(targetDir, filename)
            file.outputStream().use { out ->
                out.write(bytes)
                out.flush()
            }

            Uri.fromFile(file)
        }
    }
}
