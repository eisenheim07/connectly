package com.example.connectly

import android.content.Context
import android.view.View
import android.widget.FrameLayout
import com.amazonaws.services.chime.sdk.meetings.audiovideo.video.DefaultVideoRenderView
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory

class ChimeVideoViewFactory : PlatformViewFactory(StandardMessageCodec.INSTANCE) {
    private var currentVideoView: ChimeVideoView? = null
    
    override fun create(context: Context, viewId: Int, args: Any?): PlatformView {
        val videoView = ChimeVideoView(context)
        currentVideoView = videoView
        return videoView
    }
    
    fun getVideoView(): ChimeVideoView? = currentVideoView
}

class ChimeVideoView(context: Context) : PlatformView {
    private val videoRenderView: DefaultVideoRenderView = DefaultVideoRenderView(context)

    override fun getView(): View {
        return videoRenderView
    }

    override fun dispose() {
        // Clean up resources
    }

    fun getVideoRenderView(): DefaultVideoRenderView {
        return videoRenderView
    }
}
