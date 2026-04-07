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
    
    companion object {
        fun removeDisposedView(viewId: Int) {
            // This will be called from ChimeVideoView.dispose()
        }
    }

    override fun create(context: Context, viewId: Int, args: Any?): PlatformView {
        val params = args as? Map<*, *>
        val isLocalVideo = params?.get("isLocalVideo") as? Boolean ?: false
        
        val videoView = ChimeVideoView(context, viewId, isLocalVideo, this)
        videoViews[viewId] = videoView
        
        Log.d("ChimeVideoViewFactory", "Created video view $viewId, isLocal: $isLocalVideo")
        Log.d("ChimeVideoViewFactory", "Total views: ${videoViews.size} (local: ${videoViews.values.count { it.isLocalVideo }}, remote: ${videoViews.values.count { !it.isLocalVideo }})")
        return videoView
    }
    
    fun removeView(viewId: Int) {
        videoViews.remove(viewId)
        Log.d("ChimeVideoViewFactory", "Removed video view $viewId. Remaining views: ${videoViews.size}")
    }

    fun getVideoView(viewId: Int): ChimeVideoView? = videoViews[viewId]
    
    fun getAllVideoViews(): List<ChimeVideoView> = videoViews.values.toList()
    
    // Get the first available remote video view (there should only be one)
    fun getRemoteVideoView(): ChimeVideoView? {
        val remoteViews = videoViews.values.filter { !it.isLocalVideo }
        Log.d("ChimeVideoViewFactory", "Getting remote view from ${remoteViews.size} remote views")
        if (remoteViews.isNotEmpty()) {
            Log.d("ChimeVideoViewFactory", "  -> Returning remote view ${remoteViews.first().viewId}")
        }
        return remoteViews.firstOrNull()
    }
    
    // Get the first available local video view (there should only be one)
    fun getLocalVideoView(): ChimeVideoView? {
        val localViews = videoViews.values.filter { it.isLocalVideo }
        Log.d("ChimeVideoViewFactory", "Getting local view from ${localViews.size} local views")
        if (localViews.isNotEmpty()) {
            Log.d("ChimeVideoViewFactory", "  -> Returning local view ${localViews.first().viewId}")
        }
        return localViews.firstOrNull()
    }
}

class ChimeVideoView(
    context: Context,
    val viewId: Int,
    val isLocalVideo: Boolean,
    private val factory: ChimeVideoViewFactory
) : PlatformView {
    private val videoRenderView: DefaultVideoRenderView = DefaultVideoRenderView(context)

    override fun getView(): View {
        return videoRenderView
    }

    override fun dispose() {
        // Clean up resources
        Log.d("ChimeVideoView", "Disposing video view $viewId (isLocal: $isLocalVideo)")
        videoRenderView.release()
        factory.removeView(viewId)
    }

    fun getVideoRenderView(): DefaultVideoRenderView {
        return videoRenderView
    }
}
