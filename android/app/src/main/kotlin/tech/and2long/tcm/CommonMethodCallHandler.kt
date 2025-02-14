package tech.and2long.tcm

import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.provider.Settings
import android.util.Log
import android.widget.Toast
import androidx.core.content.ContextCompat.startActivity
import androidx.core.content.FileProvider
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.io.BufferedReader
import java.io.DataOutputStream
import java.io.File
import java.io.IOException
import java.io.InputStreamReader
import java.nio.charset.Charset


class CommonMethodCallHandler(private val context: Context) : MethodChannel.MethodCallHandler {

    companion object {
        private const val TAG = "CommonMethodCallHandler"
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "open_file_manager" -> {
                val intent = Intent(Intent.ACTION_GET_CONTENT)
                intent.setType("*/*")
                intent.addCategory(Intent.CATEGORY_OPENABLE)
                context.startActivity(intent)
            }

            "open_launcher" -> {
                try {
                    val intent = Intent(Intent.ACTION_MAIN)
                    intent.addCategory(Intent.CATEGORY_HOME)
                    intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK

                    // 强制弹出选择器
                    val chooser = Intent.createChooser(intent, "Select Home Launcher")
                    context.startActivity(chooser)
                } catch (e: Exception) {
                    e.printStackTrace()
                    Toast.makeText(
                        context,
                        "Failed to open home screen: ${e.message}",
                        Toast.LENGTH_SHORT
                    ).show()
                }
            }

            "open_phone_settings" -> {
                val intent = Intent(Settings.ACTION_SETTINGS)
                context.startActivity(intent)
            }

            "silence_install" -> {
                val apkFile = File(context.cacheDir, "app.apk")
                installSilent(apkFile.path)
            }

            "common_install" -> {
                val apkFile = File(context.cacheDir, "app.apk")
                installAPK(apkFile)
            }

        }
    }

    private fun installSilent(path: String): Boolean {
        var result = false
        var es: BufferedReader? = null
        var os: DataOutputStream? = null
        try {
            val process = Runtime.getRuntime().exec("su")
            os = DataOutputStream(process.outputStream)
            val command = "pm install -r $path\n"
            os.write(command.toByteArray(Charset.forName("utf-8")))
            os.flush()
            os.writeBytes("exit\n")
            os.flush()
            process.waitFor()
            es = BufferedReader(InputStreamReader(process.errorStream))
            var line: String?
            val builder = StringBuilder()
            while (es.readLine().also { line = it } != null) {
                builder.append(line)
            }
            Log.d(TAG, "install msg is $builder")

            /* Installation is considered a Failure if the result contains
            the Failure character, or a success if it is not.
             */if (!builder.toString().contains("Failure")) {
                result = true
            }
        } catch (e: Exception) {
            Log.e(TAG, e.message, e)
        } finally {
            try {
                os?.close()
                es?.close()
            } catch (e: IOException) {
                Log.e(TAG, e.message, e)
            }
        }
        return result
    }

    private fun installAPK(apkFile: File) {
        if (apkFile.exists()) {
            val apkUri = FileProvider.getUriForFile(
                context,
                context.packageName + ".fileprovider", apkFile
            )

            val intent = Intent(Intent.ACTION_VIEW)
            intent.setData(apkUri)

            // Grant temporary read permission to the content URI
            intent.addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
            intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)

            //设置安装控制
            intent.setFlags(Intent.FLAG_ACTIVITY_NO_HISTORY)
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                if (!context.packageManager.canRequestPackageInstalls()) {
                    // 引导用户去设置安装APK
                    val settingsIntent = Intent(
                        Settings.ACTION_MANAGE_UNKNOWN_APP_SOURCES,
                        Uri.parse("package:" + context.packageName)
                    )
                    context.startActivity(settingsIntent)
                } else {
                    context.startActivity(intent)
                }
            } else {
                context.startActivity(intent)
            }
        } else {
            // APK文件不存在的提示
            println("APK file does not exist")
        }
    }

}