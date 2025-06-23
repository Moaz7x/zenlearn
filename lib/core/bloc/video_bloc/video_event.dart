import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class InitializeVideo extends VideoEvent {
  final String videoPath;
  InitializeVideo(this.videoPath);

  @override
  List<Object?> get props => [videoPath];
}

class LongPressEndEvent extends VideoEvent {
  final bool isdone;
  LongPressEndEvent(this.isdone);

  @override
  List<Object?> get props => [[]];
}

class LongPressEvent extends VideoEvent {
  final double speed;
  LongPressEvent(this.speed);

  @override
  List<Object?> get props => [speed];
}

class NightModeEvent extends VideoEvent {}

class PauseVideo extends VideoEvent {}

class PlayVideo extends VideoEvent {}

class SeekBackward extends VideoEvent {
  final Duration duration;
  SeekBackward([this.duration = const Duration(seconds: 10)]);

  @override
  List<Object?> get props => [duration];
}

class SeekForward extends VideoEvent {
  final Duration duration;
  SeekForward([this.duration = const Duration(seconds: 10)]);

  @override
  List<Object?> get props => [duration];
}

class SeekVideo extends VideoEvent {
  final Duration position;
  SeekVideo(this.position);

  @override
  List<Object?> get props => [position];
}

class TakeScreenshot extends VideoEvent {
  @override
  List<Object?> get props => [];
}

class TakeScreenshotEnd extends VideoEvent {
  @override
  List<Object?> get props => [];
}

class ToggleBrightness extends VideoEvent {}

class ToggleBrightnessEnd extends VideoEvent {}

class ToggleControls extends VideoEvent {}

class ToggleFloatingControls extends VideoEvent {}

class ToggleFloatingMore extends VideoEvent {}

class ToggleFullScreen extends VideoEvent {}

class ToggleMute extends VideoEvent {
  final bool isMuted;
  ToggleMute(this.isMuted);

  @override
  List<Object?> get props => [isMuted];
}
class LockEvent extends VideoEvent {

}
class UnLockEvent extends VideoEvent {

}

class ToggleNightMode extends VideoEvent {
  final bool isNightMode;
  ToggleNightMode(this.isNightMode);

  @override
  List<Object?> get props => [isNightMode];
}

class ToggleScreenRotation extends VideoEvent {
  final bool isLandscape;
  ToggleScreenRotation(this.isLandscape);

  @override
  List<Object?> get props => [isLandscape];
}

class ToggleVolume extends VideoEvent {}

class ToggleVolumeEnd extends VideoEvent {}

class UpdateAspectRatio extends VideoEvent {
  final int aspectRatioIndex;
  UpdateAspectRatio(this.aspectRatioIndex);

  @override
  List<Object?> get props => [aspectRatioIndex];
}

class UpdateBrightness extends VideoEvent {
  final double brightness;
  UpdateBrightness(this.brightness);

  @override
  List<Object?> get props => [brightness];
}
class TakeScreenShotEvent extends VideoEvent {
  final BuildContext context;
  TakeScreenShotEvent(this.context);

  @override
  List<Object?> get props => [context];
}

class UpdateGestureFeedback extends VideoEvent {
  final String feedback;

  UpdateGestureFeedback(this.feedback);

  @override
  List<Object?> get props => [feedback];
}

class UpdatePlaybackSpeed extends VideoEvent {
  final double speed;
  UpdatePlaybackSpeed(this.speed);

  @override
  List<Object?> get props => [speed];
}

class UpdateVolume extends VideoEvent {
  final double volume;
  UpdateVolume(this.volume);

  @override
  List<Object?> get props => [volume];
}

class VideoError extends VideoEvent {
  final String message;
  VideoError(this.message);

  @override
  List<Object?> get props => [message];
}

abstract class VideoEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class VideoPositionChanged extends VideoEvent {
  final Duration position;
  final Duration duration;
  VideoPositionChanged(this.position, this.duration);

  @override
  List<Object?> get props => [position, duration];
}
