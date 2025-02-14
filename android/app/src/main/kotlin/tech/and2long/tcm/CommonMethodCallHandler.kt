package tech.and2long.tcm

import android.content.Context
import android.content.Intent
import android.provider.Settings
import android.util.Log
import android.widget.Toast
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
}