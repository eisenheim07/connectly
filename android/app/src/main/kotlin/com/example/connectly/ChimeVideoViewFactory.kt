package com.example.connectly

import android.content.Context
import android.util.Log
import android.view.View
import android.widget.FrameLayout
import com.amazonaws.services.chime.sdk.meetings.audiovideo.video.DefaultVideoRenderView
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory

class ChimeVideoViewFactory : PlatformViewFactory(StandardMessageCodec.INSTANCE) {
    private val videoViews = mutableMapOf<Int, ChimeVideoView>()
    
    override fun create(context: Context, viewId: Int, args: Any?): PlatformView {
        val params = args as? Map<*, *>
        val isLocalVideo = params?.get("isLocalVideo") as? Boolean ?: false
        
        val videoView = ChimeVideoView(context, viewId, isLocalVideo)
        videoViews[viewId] = videoView
        
        Log.d("ChimeVideoViewFactory", "Created video view $viewId, isLocal: $isLocalVideo")
        return videoView
    }
    
    fun getVideoView(viewId: Int): ChimeVideoView? = videoViews[viewId]
    
    fun getAllVideoViews(): List<ChimeVideoView> = videoViews.values.toList()
    
    fun getRemoteVideoView(): ChimeVideoView? = videoViews.values.firstOrNull { !it.isLocalVideo }
    
    fun getLocalVideoView(): ChimeVideoView? = videoViews.values.firstOrNull { it.isLocalVideo }
}

class ChimeVideoView(context: Context, val viewId: Int, val isLocalVideo: Boolean) : PlatformView {
    private val videoRenderView: DefaultVideoRenderView = DefaultVideoRenderView(context)

    override fun getView(): View {
        return videoRenderView
    }

    override fun dispose() {
        // Clean up resources
        Log.d("ChimeVideoView", "Disposing video view $viewId")
    }

    fun getVideoRenderView(): DefaultVideoRenderView {
        return videoRenderView
    }
}
