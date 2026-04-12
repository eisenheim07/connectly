import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

import '../theme/app_colors.dart';

class ChimeVideoView extends StatelessWidget {
  final int? tileId;
  final bool isLocalVideo;

  const ChimeVideoView({
    super.key,
    this.tileId,
    this.isLocalVideo = false,
  });

  @override
  Widget build(BuildContext context) {
    const String viewType = 'chime-video-view';
    
    final Map<String, dynamic> creationParams = <String, dynamic>{
      'tileId': tileId,
      'isLocalVideo': isLocalVideo,
    };

    if (defaultTargetPlatform == TargetPlatform.android) {
      return AndroidView(
        viewType: viewType,
        layoutDirection: TextDirection.ltr,
        creationParams: creationParams,
        creationParamsCodec: const StandardMessageCodec(),
        gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
          Factory<OneSequenceGestureRecognizer>(
            () => EagerGestureRecognizer(),
          ),
        },
      );
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      return UiKitView(
        viewType: viewType,
        layoutDirection: TextDirection.ltr,
        creationParams: creationParams,
        creationParamsCodec: const StandardMessageCodec(),
        gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
          Factory<OneSequenceGestureRecognizer>(
            () => EagerGestureRecognizer(),
          ),
        },
      );
    }

    return Container(
      color: AppColors.black,
      child: const Center(
        child: Text(
          'Platform not supported',
          style: TextStyle(color: AppColors.white),
        ),
      ),
    );
  }
}
