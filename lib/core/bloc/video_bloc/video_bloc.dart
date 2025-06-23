import 'dart:async';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:screen_brightness/screen_brightness.dart';
import 'package:video_player/video_player.dart';
import 'package:volume_controller/volume_controller.dart';

import 'video_event.dart';
import 'video_state.dart';

String formatDuration(Duration duration) {
  String twoDigits(int n) => n.toString().padLeft(2, '0');
  final hours = duration.inHours;
  final minutes = duration.inMinutes.remainder(60);
  final seconds = duration.inSeconds.remainder(60);
  return hours > 0
      ? '${twoDigits(hours)}:${twoDigits(minutes)}:${twoDigits(seconds)}'
      : '${twoDigits(minutes)}:${twoDigits(seconds)}';
}

//////////
void handleDoubleTapDown(BuildContext context, TapDownDetails details) {
  final videoBloc = context.read<VideoBloc>();
  final screenWidth = MediaQuery.of(context).size.width;
  final tapPosition = details.globalPosition.dx;

  if (tapPosition < screenWidth / 3) {
    // Left third of the screen
    videoBloc.add(SeekBackward(const Duration(seconds: 10)));
  } else if (tapPosition > 2 * screenWidth / 3) {
    // Right third of the screen
    videoBloc.add(SeekForward(const Duration(seconds: 10)));
  } else {
    // Center third of the screen
    if (videoBloc.state.isPlaying) {
      videoBloc.add(PauseVideo());
    } else {
      videoBloc.add(PlayVideo());
    }
  }
}

void handleHorizontalDragUpdate(BuildContext context, DragUpdateDetails details) {
  final videoBloc = context.read<VideoBloc>();
  final delta = details.primaryDelta ?? 0.0;

  // Define how much drag equals 1 second
  const dragSensitivity = 10.0; // pixels

  if (delta.abs() > dragSensitivity) {
    const seekDuration = Duration(seconds: 5);

    if (delta > 0) {
      videoBloc.add(SeekForward(seekDuration));
    } else {
      videoBloc.add(SeekBackward(seekDuration));
    }
  }
}

void handleOnLongPress(BuildContext context) {
  final videoBloc = context.read<VideoBloc>();
  videoBloc.add(LongPressEvent(1));
  videoBloc.add(UpdatePlaybackSpeed(2));
}

void handleOnLongPressEnd(BuildContext context) {
  final videoBloc = context.read<VideoBloc>();
  videoBloc.add(UpdatePlaybackSpeed(1));
  videoBloc.add(LongPressEndEvent(videoBloc.state.showControls));
}

void handleVerticalDragEnd(BuildContext context, DragEndDetails details) {
  final videoBloc = context.read<VideoBloc>();
  // Reset any temporary state or provide feedback if necessary
  videoBloc.add(UpdateBrightness(videoBloc.state.currentBrightness));
  videoBloc.add(UpdateVolume(videoBloc.state.currentVolume));
  videoBloc.add(ToggleVolumeEnd());
  videoBloc.add(ToggleBrightnessEnd());
}

void handleVerticalDragStart(BuildContext context, DragStartDetails details) {
  final screenWidth = MediaQuery.of(context).size.width;
  final isRightSide = details.globalPosition.dx > screenWidth / 2;
  final videoBloc = context.read<VideoBloc>();

  if (isRightSide) {
    // Start handling volume adjustment
    videoBloc.add(UpdateVolume(videoBloc.state.currentVolume));
    videoBloc.add(ToggleVolume());
  } else {
    // Start handling brightness adjustment
    videoBloc.add(UpdateBrightness(videoBloc.state.currentBrightness));
    videoBloc.add(ToggleBrightness());
  }
}

void handleVerticalDragUpdate(BuildContext context, DragUpdateDetails details) {
  final screenWidth = MediaQuery.of(context).size.width;
  final isRightSide = details.globalPosition.dx > screenWidth / 2;
  final videoBloc = context.read<VideoBloc>();

  if (isRightSide) {
    // Volume control
    final volumeDelta = -(details.primaryDelta ?? 0) / 500;
    final currentVolume = videoBloc.state.currentVolume;
    final newVolume = (currentVolume + volumeDelta).clamp(0.0, 1.0);
    videoBloc.add(UpdateVolume(newVolume));
  } else {
    // Brightness control
    final brightnessDelta = -(details.primaryDelta ?? 0) / 500;
    final currentBrightness = videoBloc.state.currentBrightness;
    final newBrightness = (currentBrightness + brightnessDelta).clamp(0.0, 1.0);
    videoBloc.add(UpdateBrightness(newBrightness));

    // Set system brightness
    setBrightness(context, newBrightness);
  }
}

void rotateScreen(BuildContext context) {
  final videoBloc = context.read<VideoBloc>();
  final isLandscape = videoBloc.state.isLandscape;
  videoBloc.add(ToggleScreenRotation(!isLandscape));
}

void setAllOrientations() {
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
}

Future<void> setBrightness(BuildContext context, double brightness) async {
  try {
    // Clamp brightness between 0.0 and 1.0
    final clampedBrightness = brightness.clamp(0.0, 1.0);
    await ScreenBrightness().setScreenBrightness(clampedBrightness);

    // Show brightness feedback
  } catch (e) {
    // Handle error if setting brightness fails
    print('Failed to set brightness: $e');
  }
}

void setLandscapeOrientation() {
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
}

Future<void> setSystemBrightness(double brightness) async {
  try {
    await ScreenBrightness().setScreenBrightness(brightness);
  } catch (e) {
    // Handle error if setting brightness fails
    print('Failed to set brightness: $e');
  }
}

Future<void> setSystemVolume(double volume) async {
  try {
    await VolumeController.instance.setVolume(volume);
  } catch (e) {
    // Handle error if setting volume fails
    print('Failed to set volume: $e');
  }
}

void showAspectRatioDialog(BuildContext context) {
  final videoBloc = context.read<VideoBloc>();
  final aspectRatioOptions = videoBloc.state.aspectRatioOptions;

  showDialog(
    context: context,
    builder: (context) => SimpleDialog(
      title: const Text('Aspect Ratio'),
      children: aspectRatioOptions.asMap().entries.map((entry) {
        final index = entry.key;
        final aspectRatio = entry.value;

        return SimpleDialogOption(
          onPressed: () {
            videoBloc.add(UpdateAspectRatio(index));
            Navigator.pop(context);
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(aspectRatio),
              if (index == videoBloc.state.currentAspectRatioIndex)
                const Icon(Icons.check, color: Colors.blue),
            ],
          ),
        );
      }).toList(),
    ),
  );
}

void showSpeedDialog(BuildContext context) {
  final videoBloc = context.read<VideoBloc>();
  final speedOptions = videoBloc.state.speedOptions;
  showDialog(
    context: context,
    builder: (context) => SimpleDialog(
        title: const Text('Playback Speed'),
        children: speedOptions.asMap().entries.map((entry) {
          final index = entry.key;
          final speedOption = entry.value;

          return SimpleDialogOption(
            onPressed: () {
              videoBloc.add(UpdatePlaybackSpeed(double.parse(speedOption)));
              Navigator.pop(context);
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(speedOption),
                if (index == videoBloc.state.currentAspectRatioIndex)
                  const Icon(Icons.check, color: Colors.blue),
              ],
            ),
          );
        }).toList()),
  );
}

void toggleMute(BuildContext context) {
  final videoBloc = context.read<VideoBloc>();
  final isMuted = videoBloc.state.isMuted;
  videoBloc.add(ToggleMute(!isMuted));
}

class VideoBloc extends Bloc<VideoEvent, VideoState> {
  Timer? _positionTimer;
  Timer? _hideControlsTimer;
  VideoBloc() : super(VideoState.initial()) {
    on<InitializeVideo>(_onInitializeVideo);
    on<PlayVideo>(_onPlayVideo);
    on<PauseVideo>(_onPauseVideo);
    on<SeekVideo>(_onSeekVideo);
    on<SeekForward>(_onSeekForward);
    on<SeekBackward>(_onSeekBackward);
    on<UpdatePlaybackSpeed>(_onUpdatePlaybackSpeed);
    on<ToggleFullScreen>(_onToggleFullScreen);
    on<ToggleControls>(_onToggleControls);
    on<ToggleFloatingControls>(_onToggleFloatingControls);
    on<ToggleFloatingMore>(_onToggleFloatingMore);
    on<UpdateVolume>(_onUpdateVolume);
    on<ToggleVolume>(_onToggleVolume);
    on<ToggleVolumeEnd>(_onToggleVolumeEnd);
    on<ToggleBrightness>(onToggleBrightness);
    on<ToggleBrightnessEnd>(onToggleBrightnessEnd);
    on<UpdateBrightness>(_onUpdateBrightness);
    on<LongPressEvent>(_onLongPress);
    on<LongPressEndEvent>(_onLongPressEnd);
    on<NightModeEvent>(_onNightMode);
    on<UpdateAspectRatio>(_onUpdateAspectRatio);
    on<VideoPositionChanged>(_onVideoPositionChanged);
    on<VideoError>(_onVideoError);
    on<TakeScreenshot>(_onTakeScreenshot);
    on<TakeScreenshotEnd>(_onTakeScreenshotEnd);
    on<UpdateGestureFeedback>(_onUpdateGestureFeedback);
    on<ToggleNightMode>(_onToggleNightMode);
    on<ToggleMute>(_onToggleMute);
    on<ToggleScreenRotation>(_onToggleScreenRotation);
    on<LockEvent>(_onLockEvent);
    on<UnLockEvent>(_onUnlockEvent);
    on<TakeScreenShotEvent>((event, emit) async {
      await takeScreenshotAndSimulateSave(event.context, state, emit);
    });
  }

  @override
  Future<void> close() {
    _positionTimer?.cancel();
    _hideControlsTimer?.cancel();
    state.controller?.dispose();
    return super.close();
  }

  Future<bool> ensureStoragePermission() async {
    final deviceInfo = await DeviceInfoPlugin().androidInfo;
    final sdkInt = deviceInfo.version.sdkInt;

    // Choose permission based on Android version
    Permission permission;
    if (sdkInt >= 33) {
      permission = Permission.storage; // Android 13+
    } else {
      permission = Permission.storage; // Android 12 and below
    }

    // Check current permission status
    var status = await permission.status;

    // If not granted, keep requesting
    while (!status.isGranted) {
      status = await permission.request();

      if (status.isPermanentlyDenied) {
        // If user permanently denied, open app settings
        await openAppSettings();
        break; // Break to avoid infinite loop
      }
    }

    return status.isGranted;
  }

  void onToggleBrightness(ToggleBrightness event, Emitter<VideoState> emit) {
    emit(state.copyWith(
      brightnessChanged: true,
      showControls: false,
    ));
  }

  void onToggleBrightnessEnd(ToggleBrightnessEnd event, Emitter<VideoState> emit) {
    emit(state.copyWith(
      brightnessChanged: false,
      showControls: true,
    ));
  }

  Future<void> takeScreenshotAndSimulateSave(
    BuildContext context,
    VideoState state,
    Emitter<VideoState> emit,
  ) async {
    emit(state.copyWith(isProcessingScreenshot: true)); // Show loading indicator

    try {
      // Access the screenshot controller from the current state
      final Uint8List? imageBytes = await state.screenshotController.capture();

      if (imageBytes != null) {
        print('Screenshot captured successfully.');

        // Define the simulated target directory and filename
        const String simulatedPublicDocsPath = '/storage/emulated/0/Documents/eduai';
        final String filename = 'screenshot_${DateTime.now().millisecondsSinceEpoch}.png';
        final String simulatedTargetFilePath = '$simulatedPublicDocsPath/$filename';

        // --- SIMULATION PART ---
        // Save to the app's temporary directory instead of the restricted public path
        try {
          final Directory? tempDir = await getDownloadsDirectory();
          final String tempFilePath = '${tempDir?.path}/$filename';
          final File tempFile = File(tempFilePath);

          // Write the image bytes to the temporary file
          await tempFile.writeAsBytes(imageBytes);

          print('Screenshot saved to temporary file: ${tempFile.path}');
          print('Simulating move to: $simulatedTargetFilePath');

          // Show success message using ScaffoldMessenger
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content:
                  Text('Screenshot captured and simulated save to Documents/eduai/$filename')));
        } catch (e) {
          print('Error saving screenshot to temporary directory: $e');
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Failed to save screenshot locally: ${e.toString()}')));
        }
      } else {
        print('Failed to capture screenshot.');
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Failed to capture screenshot.')));
      }
    } catch (e) {
      print('Error during screenshot capture or simulation: $e');
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Failed to capture screenshot.')));
    } finally {
      emit(state.copyWith(isProcessingScreenshot: false)); // Hide loading indicator
    }
  }

  void _cancelHideControlsTimer() {
    _hideControlsTimer?.cancel();
  }

  void _onInitializeVideo(InitializeVideo event, Emitter<VideoState> emit) async {
    try {
      late final VideoPlayerController controller;

      // Check if the path is an asset path
      if (event.videoPath.startsWith('assets/')) {
        controller = VideoPlayerController.asset(event.videoPath);
      } else if (event.videoPath.startsWith('http')) {
        controller = VideoPlayerController.network(event.videoPath);
      } else {
        controller = VideoPlayerController.file(File(event.videoPath));
      }

      await controller.initialize();

      _positionTimer?.cancel();
      _positionTimer = Timer.periodic(const Duration(milliseconds: 200), (_) async {
        if (!isClosed && controller.value.isInitialized) {
          final position = await controller.position;
          if (position != null) {
            add(VideoPositionChanged(position, controller.value.duration));
          }
        }
      });

      emit(state.copyWith(
        controller: controller,
        isControllerInitialized: true,
        duration: controller.value.duration,
      ));
    } catch (e) {
      emit(state.copyWith(
        hasError: true,
        errorMessage: 'Failed to initialize video: ${e.toString()}',
      ));
    }
  }

  void _onLockEvent(LockEvent event, Emitter<VideoState> emit) {
    print(state.isLocked);
    emit(state.copyWith(isLocked: true));
  }

  void _onLongPress(LongPressEvent event, Emitter<VideoState> emit) {
    _cancelHideControlsTimer();
    emit(state.copyWith(isLongPressed: true));
  }

  void _onLongPressEnd(LongPressEndEvent event, Emitter<VideoState> emit) {
    emit(state.copyWith(isLongPressed: false));

    // Start a timer to hide controls after 5 seconds
    _hideControlsTimer?.cancel();
    _cancelHideControlsTimer();
    _hideControlsTimer = Timer(const Duration(seconds: 5), () {
      if (!isClosed && state.showControls) {
        emit(state.copyWith(showControls: false));
      }
    });
  }

  void _onNightMode(NightModeEvent event, Emitter<VideoState> emit) async {
    final isNightModeEnabled = !state.isNightMode;
    emit(state.copyWith(isNightMode: isNightModeEnabled));

    if (isNightModeEnabled) {
      // Reduce brightness to half for night mode
      final reducedBrightness = (state.currentBrightness) / 2;
      emit(state.copyWith(currentBrightness: reducedBrightness));
      await setSystemBrightness(reducedBrightness);
    } else {
      // Restore brightness to original level

      final originalBrightness = state.originalBrightness;
      emit(state.copyWith(currentBrightness: originalBrightness));
      await setSystemBrightness(originalBrightness);
    }
  }

  void _onPauseVideo(PauseVideo event, Emitter<VideoState> emit) async {
    if (state.controller != null && state.isControllerInitialized) {
      await state.controller!.pause();
      emit(state.copyWith(isPlaying: false));
      _cancelHideControlsTimer();
    }
  }

  void _onPlayVideo(PlayVideo event, Emitter<VideoState> emit) async {
    if (state.controller != null && state.isControllerInitialized) {
      await state.controller!.play();
      emit(state.copyWith(isPlaying: true));
      _startHideControlsTimer();
    }
  }

  void _onSeekBackward(SeekBackward event, Emitter<VideoState> emit) async {
    if (state.controller != null && state.isControllerInitialized) {
      final newPosition = state.position - event.duration;
      final clampedPosition = newPosition.inMilliseconds.clamp(
        0,
        state.duration.inMilliseconds,
      );
      await state.controller!.seekTo(Duration(milliseconds: clampedPosition));
      emit(state.copyWith(isTenBackward: true));
      await Future.delayed(const Duration(milliseconds: 400));
      emit(state.copyWith(isTenBackward: false));
    }
  }

  void _onSeekForward(SeekForward event, Emitter<VideoState> emit) async {
    if (state.controller != null && state.isControllerInitialized) {
      final newPosition = state.position + event.duration;
      final clampedPosition = newPosition.inMilliseconds.clamp(
        0,
        state.duration.inMilliseconds,
      );
      await state.controller!.seekTo(Duration(milliseconds: clampedPosition));
      emit(state.copyWith(isTenForward: true));
      await Future.delayed(const Duration(milliseconds: 400));
      emit(state.copyWith(isTenForward: false));
    }
  }

  void _onSeekVideo(SeekVideo event, Emitter<VideoState> emit) async {
    if (state.controller != null && state.isControllerInitialized) {
      await state.controller!.seekTo(event.position);
      emit(state.copyWith(position: event.position));
    }
  }

  void _onTakeScreenshot(TakeScreenshot event, Emitter<VideoState> emit) {
    state.screenshotController.capture(delay: const Duration(milliseconds: 20)).then((image) async {
      if (image != null) {
        final hasPermission = await ensureStoragePermission();
        if (hasPermission) {
          // Save the screenshot to the device
          final directory = Directory('/storage/emulated/0/Pictures/Screenshots');
          if (!directory.existsSync()) {
            directory.createSync(recursive: true);
          }
          final filePath =
              '${directory.path}/screenshot_${DateTime.now().millisecondsSinceEpoch}.png';
          final file = File(filePath);
          await file.writeAsBytes(image);
          print('Screenshot saved to $filePath');
        } else {
          // Handle permission denied case
          print('Permission denied. Unable to save screenshot.');
        }
      }
    }).catchError((error) {
      // Handle error if capturing fails
      print('Failed to capture screenshot: $error');
    });
    emit(state.copyWith(
      isProcessingScreenshot: true,
      showControls: false,
    ));
  }

  void _onTakeScreenshotEnd(TakeScreenshotEnd event, Emitter<VideoState> emit) {
    emit(state.copyWith(
      isProcessingScreenshot: false,
      showControls: true,
    ));
  }

  void _onToggleControls(ToggleControls event, Emitter<VideoState> emit) {
    emit(state.copyWith(showControls: !state.showControls));

    if (state.showControls) {
      _startHideControlsTimer(); // Restart the timer when controls are shown
    } else {
      _hideControlsTimer?.cancel(); // Cancel the timer when controls are hidden
    }
  }

  void _onToggleFloatingControls(ToggleFloatingControls event, Emitter<VideoState> emit) {
    emit(state.copyWith(showFloatingControls: !state.showFloatingControls));
    _startHideControlsTimer();
  }

  void _onToggleFloatingMore(ToggleFloatingMore event, Emitter<VideoState> emit) {
    emit(state.copyWith(isMore: !state.isMore));
    _startHideControlsTimer();
  }

  void _onToggleFullScreen(ToggleFullScreen event, Emitter<VideoState> emit) {
    if (state.isFullScreen) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    } else {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    }
    emit(state.copyWith(isFullScreen: !state.isFullScreen));
  }

  void _onToggleMute(ToggleMute event, Emitter<VideoState> emit) {
    emit(state.copyWith(isMuted: event.isMuted));
    if (state.controller != null && state.isControllerInitialized) {
      state.controller!.setVolume(event.isMuted ? 0.0 : state.currentVolume);
    }
  }

  void _onToggleNightMode(ToggleNightMode event, Emitter<VideoState> emit) {
    emit(state.copyWith(isNightMode: event.isNightMode));
  }

  void _onToggleScreenRotation(ToggleScreenRotation event, Emitter<VideoState> emit) {
    emit(state.copyWith(isLandscape: event.isLandscape));
    if (event.isLandscape) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    } else {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
    }
  }

  void _onToggleVolume(ToggleVolume event, Emitter<VideoState> emit) {
    emit(state.copyWith(
      volumeChanged: true,
      showControls: false,
    ));
  }

  void _onToggleVolumeEnd(ToggleVolumeEnd event, Emitter<VideoState> emit) {
    emit(state.copyWith(
      volumeChanged: false,
      showControls: true,
    ));
  }

  void _onUnlockEvent(UnLockEvent event, Emitter<VideoState> emit) {
    emit(state.copyWith(isLocked: false));
  }

  void _onUpdateAspectRatio(UpdateAspectRatio event, Emitter<VideoState> emit) {
    double? aspectRatio;
    switch (event.aspectRatioIndex) {
      case 0: // Auto
        // When aspectRatio is null, the video player typically uses the video's
        // intrinsic aspect ratio. This case explicitly sets it to the controller's value.
        aspectRatio = state.controller?.value.aspectRatio;
        break;
      case 1: // 16:9
        aspectRatio = 16 / 9;
        break;
      case 2: // 4:3
        aspectRatio = 4 / 3;
        break;
      case 3: // Stretch (Stretch width, height adjusts freely)
        // By setting aspectRatio to null, we indicate that no specific aspect
        // ratio is being enforced by the video's content. This allows the UI
        // widget to size the video based on parent constraints, leading to stretch.
        aspectRatio = null;
        break;
      case 4: // Zoom (Keeping as 21:9 based on original code)
        aspectRatio = 21 / 9;
        break;
      case 5: // 1:1 (Square)
        aspectRatio = 1 / 1;
        break;
      case 6: // 1.85:1 (Cinematic Standard)
        aspectRatio = 1.85 / 1;
        break;
      case 7: // 2.39:1 (Anamorphic/Scope)
        aspectRatio = 2.39 / 1;
        break;
      case 8: // 9:16 (Vertical)
        aspectRatio = 9 / 16;
        break;
      case 9: // 2:1 (Univisium)
        aspectRatio = 2 / 1;
        break;
      default: // Fallback to Auto if index is out of bounds
        aspectRatio = state.controller?.value.aspectRatio;
        break;
    }
    emit(state.copyWith(
      currentAspectRatioIndex: event.aspectRatioIndex,
      forcedAspectRatio: aspectRatio,
    ));
  }

  void _onUpdateBrightness(UpdateBrightness event, Emitter<VideoState> emit) {
    emit(state.copyWith(
      currentBrightness: event.brightness,
      brightnessChanged: true, // Trigger brightness alert
    ));

    // Hide the brightness alert after a delay
    Future.delayed(const Duration(seconds: 2), () {
      if (!isClosed) {
        emit(state.copyWith(brightnessChanged: false));
      }
    });
  }

  void _onUpdateGestureFeedback(UpdateGestureFeedback event, Emitter<VideoState> emit) {
    emit(state.copyWith(gestureFeedbackText: event.feedback));

    // Clear feedback after 2 seconds
    Future.delayed(const Duration(seconds: 2), () {
      if (!isClosed) {
        emit(state.copyWith(gestureFeedbackText: null));
      }
    });
  }

  void _onUpdatePlaybackSpeed(UpdatePlaybackSpeed event, Emitter<VideoState> emit) async {
    if (state.controller != null && state.isControllerInitialized) {
      await state.controller!.setPlaybackSpeed(event.speed);
      final speedIndex = state.speedOptions.indexOf(event.speed.toString());
      if (speedIndex != -1) {
        emit(state.copyWith(currentSpeedIndex: speedIndex));
      }
    }
  }

  void _onUpdateVolume(UpdateVolume event, Emitter<VideoState> emit) async {
    if (state.controller != null && state.isControllerInitialized) {
      await state.controller!.setVolume(event.volume);
      emit(state.copyWith(currentVolume: event.volume));
      setSystemVolume(event.volume);
    }
  }

  void _onVideoError(VideoError event, Emitter<VideoState> emit) {
    emit(state.copyWith(
      hasError: true,
      errorMessage: event.message,
    ));
  }

  void _onVideoPositionChanged(VideoPositionChanged event, Emitter<VideoState> emit) {
    emit(state.copyWith(
      position: event.position,
      duration: event.duration,
    ));
  }

  void _startHideControlsTimer() {
    _hideControlsTimer?.cancel(); // Cancel any existing timer

    // Start a new timer to hide controls after 3 seconds
    _hideControlsTimer = Timer(const Duration(seconds: 3), () {
      if (!isClosed && state.showControls) {
        add(ToggleControls()); // Dispatch an event to update the state
      }
    });
  }
}
