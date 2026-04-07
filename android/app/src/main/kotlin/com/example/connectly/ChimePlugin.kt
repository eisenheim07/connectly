package com.example.connectly

import android.content.Context
import android.util.Log
import com.amazonaws.services.chime.sdk.meetings.audiovideo.AudioVideoFacade
import com.amazonaws.services.chime.sdk.meetings.audiovideo.AudioVideoObserver
import com.amazonaws.services.chime.sdk.meetings.audiovideo.video.VideoTileObserver
import com.amazonaws.services.chime.sdk.meetings.audiovideo.video.VideoTileState
import com.amazonaws.services.chime.sdk.meetings.session.CreateAttendeeResponse
import com.amazonaws.services.chime.sdk.meetings.session.CreateMeetingResponse
import com.amazonaws.services.chime.sdk.meetings.session.DefaultMeetingSession
import com.amazonaws.services.chime.sdk.meetings.session.Meeting
import com.amazonaws.services.chime.sdk.meetings.session.MeetingSession
import com.amazonaws.services.chime.sdk.meetings.session.MeetingSessionConfiguration
import com.amazonaws.services.chime.sdk.meetings.session.MeetingSessionStatus
import com.amazonaws.services.chime.sdk.meetings.session.MeetingSessionStatusCode
import com.amazonaws.services.chime.sdk.meetings.utils.logger.ConsoleLogger
import com.amazonaws.services.chime.sdk.meetings.utils.logger.LogLevel
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

class ChimePlugin : FlutterPlugin, MethodCallHandler {
    private lateinit var channel: MethodChannel
    private var context: Context? = null
    private var meetingSession: MeetingSession? = null
    private var audioVideo: AudioVideoFacade? = null
    private val logger = ConsoleLogger(LogLevel.INFO)
    private var videoViewFactory: ChimeVideoViewFactory? = null
    
    // Track video tiles that need to be bound
    private var localTileId: Int? = null
    private var remoteTileId: Int? = null

    companion object {
        private const val TAG = "ChimePlugin"
        private const val CHANNEL_NAME = "com.connectly/chime"
    }

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        context = flutterPluginBinding.applicationContext
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, CHANNEL_NAME)
        channel.setMethodCallHandler(this)
        
        // Register video view factory
        videoViewFactory = ChimeVideoViewFactory()
        flutterPluginBinding
            .platformViewRegistry
            .registerViewFactory("chime-video-view", videoViewFactory!!)
        
        Log.d(TAG, "ChimePlugin attached to engine")
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "initializeMeeting" -> initializeMeeting(call, result)
            "startLocalVideo" -> startLocalVideo(result)
            "stopLocalVideo" -> stopLocalVideo(result)
            "muteLocalAudio" -> muteLocalAudio(result)
            "unmuteLocalAudio" -> unmuteLocalAudio(result)
            "switchCamera" -> switchCamera(result)
            "leaveMeeting" -> leaveMeeting(result)
            "getAttendees" -> getAttendees(result)
            "dispose" -> dispose(result)
            "rebindVideoTiles" -> rebindVideoTiles(result)
            else -> result.notImplemented()
        }
    }

    private fun bindVideoTile(tileId: Int, isLocal: Boolean) {
        val videoView = if (isLocal) {
            videoViewFactory?.getLocalVideoView()
        } else {
            videoViewFactory?.getRemoteVideoView()
        }

        videoView?.let { view ->
            audioVideo?.bindVideoView(view.getVideoRenderView(), tileId)
            Log.d(TAG, "✅ Video tile $tileId bound to ${if (isLocal) "local" else "remote"} view ${view.viewId}")
        } ?: run {
            Log.w(TAG, "⚠️ No video view available for tile $tileId (isLocal: $isLocal)")
        }
    }

    private fun rebindVideoTiles(result: Result) {
        try {
            Log.d(TAG, "Rebinding video tiles...")
            localTileId?.let { bindVideoTile(it, true) }
            remoteTileId?.let { bindVideoTile(it, false) }
            result.success(true)
        } catch (e: Exception) {
            Log.e(TAG, "Failed to rebind video tiles", e)
            result.error("REBIND_ERROR", "Failed to rebind: ${e.message}", null)
        }
    }

    private fun initializeMeeting(call: MethodCall, result: Result) {
        try {
            val meetingId = call.argument<String>("meetingId") ?: throw Exception("Missing meetingId")
            val externalMeetingId = call.argument<String>("externalMeetingId")
            val mediaRegion = call.argument<String>("mediaRegion") ?: throw Exception("Missing mediaRegion")
            val audioHostUrl = call.argument<String>("audioHostUrl") ?: throw Exception("Missing audioHostUrl")
            val audioFallbackUrl = call.argument<String>("audioFallbackUrl") ?: throw Exception("Missing audioFallbackUrl")
            val signalingUrl = call.argument<String>("signalingUrl") ?: throw Exception("Missing signalingUrl")
            val turnControlUrl = call.argument<String>("turnControlUrl") ?: throw Exception("Missing turnControlUrl")
            val attendeeId = call.argument<String>("attendeeId") ?: throw Exception("Missing attendeeId")
            val externalUserId = call.argument<String>("externalUserId") ?: throw Exception("Missing externalUserId")
            val joinToken = call.argument<String>("joinToken") ?: throw Exception("Missing joinToken")

            Log.d(TAG, "Initializing meeting: $meetingId")

            // Create meeting configuration
            val meetingResponse = CreateMeetingResponse(
                Meeting(
                    ExternalMeetingId = externalMeetingId,
                    MediaPlacement = com.amazonaws.services.chime.sdk.meetings.session.MediaPlacement(
                        AudioHostUrl = audioHostUrl,
                        AudioFallbackUrl = audioFallbackUrl,
                        SignalingUrl = signalingUrl,
                        TurnControlUrl = turnControlUrl,
                        EventIngestionUrl = null
                    ),
                    MediaRegion = mediaRegion,
                    MeetingId = meetingId
                )
            )

            val attendeeResponse = CreateAttendeeResponse(
                com.amazonaws.services.chime.sdk.meetings.session.Attendee(
                    AttendeeId = attendeeId,
                    ExternalUserId = externalUserId,
                    JoinToken = joinToken
                )
            )

            val configuration = MeetingSessionConfiguration(
                meetingResponse,
                attendeeResponse
            )

            // Create meeting session
            meetingSession = DefaultMeetingSession(
                configuration,
                logger,
                context!!
            )

            audioVideo = meetingSession?.audioVideo

            // Add observers
            audioVideo?.addAudioVideoObserver(object : AudioVideoObserver {
                override fun onAudioSessionStartedConnecting(reconnecting: Boolean) {
                    Log.d(TAG, "Audio session started connecting")
                }

                override fun onAudioSessionStarted(reconnecting: Boolean) {
                    Log.d(TAG, "Audio session started")
                    channel.invokeMethod("onAudioSessionStarted", null)
                }

                override fun onAudioSessionStopped(sessionStatus: MeetingSessionStatus) {
                    Log.d(TAG, "Audio session stopped: ${sessionStatus.statusCode}")
                    channel.invokeMethod("onAudioSessionStopped", mapOf("statusCode" to sessionStatus.statusCode?.value))
                }

                override fun onAudioSessionCancelledReconnect() {
                    Log.d(TAG, "Audio session cancelled reconnect")
                }

                override fun onAudioSessionDropped() {
                    Log.d(TAG, "Audio session dropped")
                }

                override fun onVideoSessionStartedConnecting() {
                    Log.d(TAG, "Video session started connecting")
                }

                override fun onVideoSessionStarted(sessionStatus: MeetingSessionStatus) {
                    Log.d(TAG, "Video session started")
                    channel.invokeMethod("onVideoSessionStarted", null)
                }

                override fun onVideoSessionStopped(sessionStatus: MeetingSessionStatus) {
                    Log.d(TAG, "Video session stopped: ${sessionStatus.statusCode}")
                    channel.invokeMethod("onVideoSessionStopped", mapOf("statusCode" to sessionStatus.statusCode?.value))
                }

                override fun onConnectionBecamePoor() {
                    Log.d(TAG, "Connection became poor")
                    channel.invokeMethod("onConnectionBecamePoor", null)
                }

                override fun onConnectionRecovered() {
                    Log.d(TAG, "Connection recovered")
                    channel.invokeMethod("onConnectionRecovered", null)
                }

                override fun onCameraSendAvailabilityUpdated(available: Boolean) {
                    Log.d(TAG, "Camera send availability: $available")
                }

                override fun onRemoteVideoSourceAvailable(sources: List<com.amazonaws.services.chime.sdk.meetings.audiovideo.video.RemoteVideoSource>) {
                    Log.d(TAG, "Remote video sources available: ${sources.size}")
                }

                override fun onRemoteVideoSourceUnavailable(sources: List<com.amazonaws.services.chime.sdk.meetings.audiovideo.video.RemoteVideoSource>) {
                    Log.d(TAG, "Remote video sources unavailable: ${sources.size}")
                }
            })

            audioVideo?.addVideoTileObserver(object : VideoTileObserver {
                override fun onVideoTileAdded(tileState: VideoTileState) {
                    Log.d(TAG, "Video tile added: ${tileState.tileId}, isLocal: ${tileState.isLocalTile}, attendeeId: ${tileState.attendeeId}")
                    
                    // Store tile IDs for later binding
                    if (tileState.isLocalTile) {
                        localTileId = tileState.tileId
                    } else {
                        remoteTileId = tileState.tileId
                    }
                    
                    // Try to bind immediately
                    bindVideoTile(tileState.tileId, tileState.isLocalTile)
                    
                    channel.invokeMethod("onVideoTileAdded", mapOf(
                        "tileId" to tileState.tileId,
                        "attendeeId" to tileState.attendeeId,
                        "isLocalTile" to tileState.isLocalTile
                    ))
                }

                override fun onVideoTileRemoved(tileState: VideoTileState) {
                    Log.d(TAG, "Video tile removed: ${tileState.tileId}")
                    
                    // Clear stored tile IDs
                    if (tileState.isLocalTile) {
                        localTileId = null
                    } else {
                        remoteTileId = null
                    }

                    // Unbind video tile
                    audioVideo?.unbindVideoView(tileState.tileId)
                    
                    channel.invokeMethod("onVideoTileRemoved", mapOf("tileId" to tileState.tileId))
                }

                override fun onVideoTilePaused(tileState: VideoTileState) {
                    Log.d(TAG, "Video tile paused: ${tileState.tileId}")
                }

                override fun onVideoTileResumed(tileState: VideoTileState) {
                    Log.d(TAG, "Video tile resumed: ${tileState.tileId}")
                }

                override fun onVideoTileSizeChanged(tileState: VideoTileState) {
                    Log.d(TAG, "Video tile size changed: ${tileState.tileId}")
                }
            })

            // Start audio and video
            audioVideo?.start()
            audioVideo?.startRemoteVideo()

            Log.d(TAG, "Meeting initialized successfully")
            result.success(true)
        } catch (e: Exception) {
            Log.e(TAG, "Failed to initialize meeting", e)
            result.error("INIT_ERROR", "Failed to initialize meeting: ${e.message}", null)
        }
    }

    private fun startLocalVideo(result: Result) {
        try {
            audioVideo?.startLocalVideo()
            Log.d(TAG, "Local video started")
            result.success(true)
        } catch (e: Exception) {
            Log.e(TAG, "Failed to start local video", e)
            result.error("VIDEO_ERROR", "Failed to start video: ${e.message}", null)
        }
    }

    private fun stopLocalVideo(result: Result) {
        try {
            audioVideo?.stopLocalVideo()
            Log.d(TAG, "Local video stopped")
            result.success(true)
        } catch (e: Exception) {
            Log.e(TAG, "Failed to stop local video", e)
            result.error("VIDEO_ERROR", "Failed to stop video: ${e.message}", null)
        }
    }

    private fun muteLocalAudio(result: Result) {
        try {
            val muted = audioVideo?.realtimeLocalMute() ?: false
            Log.d(TAG, "Local audio muted: $muted")
            result.success(muted)
        } catch (e: Exception) {
            Log.e(TAG, "Failed to mute audio", e)
            result.error("AUDIO_ERROR", "Failed to mute audio: ${e.message}", null)
        }
    }

    private fun unmuteLocalAudio(result: Result) {
        try {
            val unmuted = audioVideo?.realtimeLocalUnmute() ?: false
            Log.d(TAG, "Local audio unmuted: $unmuted")
            result.success(unmuted)
        } catch (e: Exception) {
            Log.e(TAG, "Failed to unmute audio", e)
            result.error("AUDIO_ERROR", "Failed to unmute audio: ${e.message}", null)
        }
    }

    private fun switchCamera(result: Result) {
        try {
            audioVideo?.switchCamera()
            Log.d(TAG, "Camera switched")
            result.success(true)
        } catch (e: Exception) {
            Log.e(TAG, "Failed to switch camera", e)
            result.error("CAMERA_ERROR", "Failed to switch camera: ${e.message}", null)
        }
    }

    private fun leaveMeeting(result: Result) {
        try {
            audioVideo?.stopLocalVideo()
            audioVideo?.stopRemoteVideo()
            audioVideo?.stop()
            meetingSession = null
            audioVideo = null
            Log.d(TAG, "Left meeting")
            result.success(true)
        } catch (e: Exception) {
            Log.e(TAG, "Failed to leave meeting", e)
            result.error("LEAVE_ERROR", "Failed to leave meeting: ${e.message}", null)
        }
    }

    private fun getAttendees(result: Result) {
        try {
            // TODO: Implement attendee list retrieval
            val attendees = emptyList<String>()
            result.success(attendees)
        } catch (e: Exception) {
            Log.e(TAG, "Failed to get attendees", e)
            result.error("ATTENDEE_ERROR", "Failed to get attendees: ${e.message}", null)
        }
    }

    private fun dispose(result: Result) {
        try {
            audioVideo?.stopLocalVideo()
            audioVideo?.stopRemoteVideo()
            audioVideo?.stop()
            meetingSession = null
            audioVideo = null
            Log.d(TAG, "Resources disposed")
            result.success(null)
        } catch (e: Exception) {
            Log.e(TAG, "Failed to dispose", e)
            result.error("DISPOSE_ERROR", "Failed to dispose: ${e.message}", null)
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
        audioVideo?.stop()
        meetingSession = null
        audioVideo = null
        context = null
        Log.d(TAG, "ChimePlugin detached from engine")
    }
}
