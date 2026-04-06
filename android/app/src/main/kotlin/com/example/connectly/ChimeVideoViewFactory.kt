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
    
    // Get the MOST RECENTLY created remote video view (likely the one currently displayed)
    fun getRemoteVideoView(): ChimeVideoView? {
        val remoteViews = videoViews.values.filter { !it.isLocalVideo }
        Log.d("ChimeVideoViewFactory", "Getting remote view from ${remoteViews.size} remote views")
        return remoteViews.lastOrNull() // Return most recent
    }
    
    // Get the MOST RECENTLY created local video view (likely the one currently displayed)
    fun getLocalVideoView(): ChimeVideoView? {
        val localViews = videoViews.values.filter { it.isLocalVideo }
        Log.d("ChimeVideoViewFactory", "Getting local view from ${localViews.size} local views")
        return localViews.lastOrNull() // Return most recent
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
