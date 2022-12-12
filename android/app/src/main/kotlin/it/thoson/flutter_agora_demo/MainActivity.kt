package it.thoson.flutter_agora_demo

import android.graphics.Bitmap
import android.graphics.Matrix
import android.util.Log
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.EventChannel.EventSink
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.github.crow_misia.libyuv.I420Buffer
import java.io.ByteArrayOutputStream
import java.nio.ByteBuffer

class MainActivity : FlutterActivity() {
    val TAG = "AGORA PROCESS IMAGE"

    private val CHANNEL = "it.thoson/image"
    private val CHANNEL_STREAM = "it.thoson/image_stream"

    private var attachEvent: EventSink? = null


    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL
        ).setMethodCallHandler { call, result ->
            if (call.method == "process_image") {
                processImage(call, result)
            } else {
                result.notImplemented()
            }
        }

        EventChannel(flutterEngine?.dartExecutor?.binaryMessenger, CHANNEL_STREAM).setStreamHandler(
            object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                    attachEvent = events;
                }

                override fun onCancel(arguments: Any?) {
                    attachEvent = null;
                }
            },
        )
    }


    //    override fun onCreate(savedInstanceState: Bundle?) {
//        super.onCreate(savedInstanceState)
//        if (OpenCVLoader.initDebug()) {
//            Log.d("Check", "OpenCv configured successfully")
//        } else {
//            Log.d("Check", "OpenCv doesn’t configured successfully")
//        }
//    }
    var newI420: I420Buffer? = null
    var newBitmap: Bitmap? = null
    var bitmap: Bitmap? = null
    private val i420Map = mutableMapOf<String, Any>()

    private fun processImage(call: MethodCall, result: MethodChannel.Result) {
        if (call.arguments !is Map<*, *>) {
            Log.d(TAG, "Invalid data")
            result.error("", "", "")
            return
        }
        val arguments = call.arguments as Map<*, *>
        val width: Int = arguments["width"] as Int
        val height: Int = arguments["height"] as Int
        val yBuffer: ByteArray = arguments["yBuffer"] as ByteArray
        val uBuffer: ByteArray = arguments["uBuffer"] as ByteArray
        val vBuffer: ByteArray = arguments["vBuffer"] as ByteArray
        val yStride: Int = arguments["yStride"] as Int
        val uStride: Int = arguments["uStride"] as Int
        val vStride: Int = arguments["vStride"] as Int
        val i420: ByteArray = YUVUtils.toWrappedI420(
            ByteBuffer.wrap(yBuffer),
            ByteBuffer.wrap(uBuffer),
            ByteBuffer.wrap(vBuffer),
            width,
            height
        )
        bitmap = YUVUtils.NV21ToBitmap(
            baseContext,
            YUVUtils.I420ToNV21(i420, width, height),
            width,
            height
        )
        val matrix = Matrix()
        matrix.setRotate(270f)
        // 围绕原地进行旋转
        // 围绕原地进行旋转
        newBitmap = Bitmap.createBitmap(bitmap!!, 0, 0, width, height, matrix, false)
//        val mat = Mat()
//        Utils.bitmapToMat(newBitmap, mat)
        //Todo
        newI420 = YUVUtils.bitmapToI420(newBitmap!!)
        i420Map["width"] = newI420!!.width
        i420Map["height"] = newI420!!.height
        i420Map["yBuffer"] = ByteArray(newI420!!.bufferY.capacity())
        i420Map["uBuffer"] = ByteArray(newI420!!.bufferU.capacity())
        i420Map["vBuffer"] = ByteArray(newI420!!.bufferV.capacity())

//        val stream = ByteArrayOutputStream()
//        bitmap.compress(Bitmap.CompressFormat.PNG, 100, stream)
//        val byteArray: ByteArray = stream.toByteArray()
//        i420Map["byteArray"] = byteArray
        result.success(null)
        attachEvent?.success(i420Map)

        newI420?.release()
        bitmap?.recycle()
        newBitmap?.recycle()

        newI420 = null
        bitmap = null
        newBitmap = null
    }
}
