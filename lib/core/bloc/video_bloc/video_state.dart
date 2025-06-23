import 'package:equatable/equatable.dart';
import 'package:screenshot/screenshot.dart';
import 'package:video_player/video_player.dart';

class VideoState extends Equatable {
  final VideoPlayerController? controller;
  final bool isControllerInitialized;
  final bool isPlaying;
  final Duration duration;
  final Duration position;
  final bool isBuffering;
  final bool isNightMode;
  final bool isMuted;
  final bool hasError;
  final bool volumeChanged;
  final bool brightnessChanged;
  final String errorMessage;
  final bool showControls;
  final bool isFullScreen;
  final bool isLongPressed;
  final bool isTenForward;
  final bool isTenBackward;
  final double currentVolume;
  final double originalBrightness;
  final double currentBrightness;
  final bool isHandlingVerticalDrag;
  final bool isLocked;
  final bool showFloatingControls;
  final bool isProcessingScreenshot;
  final List<String> speedOptions;
  final int currentSpeedIndex;
  final List<String> aspectRatioOptions;
  final int currentAspectRatioIndex;
  final double? forcedAspectRatio;
  final String? gestureFeedbackText;
  final ScreenshotController screenshotController; // Add this
  final bool isMore;
  final bool isLandscape;

  const VideoState({
    this.controller,
    this.isControllerInitialized = false,
    this.isPlaying = false,
    this.duration = Duration.zero,
    this.position = Duration.zero,
    this.isBuffering = false,
    this.isMuted = false,
    this.isTenForward = false,
    this.isTenBackward = false,
    this.isNightMode = false,
    this.hasError = false,
    this.volumeChanged = false,
    required this.screenshotController, // Initialize in constructor
    this.brightnessChanged = false,
    this.errorMessage = '',
    this.showControls = true,
    this.isFullScreen = false,
    this.isLongPressed = false,
    this.currentVolume = 1.0,
    this.originalBrightness = 1.0,
    this.currentBrightness = 1.0,
    this.isHandlingVerticalDrag = false,
    this.isLocked = false,
    this.showFloatingControls = false,
    this.isProcessingScreenshot = false,
    this.speedOptions = const [
      '0.5',
      '0.75',
      '1.0',
      '1.25',
      '1.5',
      '2.0',
      '2.25',
      '2.5',
      '2.75',
      '3.0'
    ],
    this.currentSpeedIndex = 2,
    this.aspectRatioOptions = const [
      'Auto', // Index 0: Use video's natural aspect ratio
      '16:9', // Index 1: Standard Widescreen
      '4:3', // Index 2: Standard (Fullscreen)
      'Stretch', // Index 3: Stretch to fill (potentially distorting)
      'Zoom', // Index 4: Originally 21:9, let's keep it as a wide cinematic option
      '1:1', // Index 5: Square
      '1.85:1', // Index 6: Cinematic Standard Widescreen
      '2.39:1', // Index 7: Anamorphic Widescreen (Scope)
      '9:16', // Index 8: Vertical (for mobile/stories)
      '2:1', // Index 9: Univisium
    ],
    this.currentAspectRatioIndex = 0,
    this.forcedAspectRatio,
    this.gestureFeedbackText,
    this.isMore = false,
    this.isLandscape = false,
  });

  factory VideoState.initial() {
    return VideoState(
      screenshotController: ScreenshotController(), // Initialize here

      // ... other initial values
    );
  }

  @override
  List<Object?> get props => [
        isControllerInitialized,
        isPlaying,
        duration,
        position,
        isBuffering,
        hasError,
        volumeChanged,
        brightnessChanged,
        errorMessage,
        isMuted,
        showControls,
        isFullScreen,
        isLongPressed,
        isTenForward,
        isTenBackward,
        currentVolume,
        currentBrightness,
        isHandlingVerticalDrag,
        isLocked,
        originalBrightness,
        isNightMode,
        screenshotController,
        showFloatingControls,
        isProcessingScreenshot,
        currentSpeedIndex,
        currentAspectRatioIndex,
        forcedAspectRatio,
        gestureFeedbackText,
        isMore,
        isLandscape,
      ];
  VideoState copyWith({
    VideoPlayerController? controller,
    bool? isControllerInitialized,
    bool? isPlaying,
    Duration? duration,
    Duration? position,
    bool? isBuffering,
    bool? hasError,
    bool? isMuted,
    bool? volumeChanged,
    ScreenshotController? screenshotController,
    bool? brightnessChanged,
    String? errorMessage,
    bool? showControls,
    bool? isNightMode,
    bool? isFullScreen,
    bool? isLongPressed,
    bool? isTenForward,
    bool? isTenBackward,
    double? currentVolume,
    double? originalBrightness,
    double? currentBrightness,
    bool? isHandlingVerticalDrag,
    bool? isLocked,
    bool? showFloatingControls,
    bool? isProcessingScreenshot,
    List<String>? speedOptions,
    int? currentSpeedIndex,
    List<String>? aspectRatioOptions,
    int? currentAspectRatioIndex,
    double? forcedAspectRatio,
    String? gestureFeedbackText,
    bool? isMore,
    bool? isLandscape,
  }) {
    return VideoState(
      controller: controller ?? this.controller,
      isControllerInitialized:
          isControllerInitialized ?? this.isControllerInitialized,
      isPlaying: isPlaying ?? this.isPlaying,
      duration: duration ?? this.duration,
      position: position ?? this.position,
      screenshotController: screenshotController ?? this.screenshotController,
      isMuted: isMuted ?? this.isMuted,
      originalBrightness: originalBrightness ?? this.originalBrightness,
      isNightMode: isNightMode ?? this.isNightMode,
      isBuffering: isBuffering ?? this.isBuffering,
      hasError: hasError ?? this.hasError,
      volumeChanged: volumeChanged ?? this.volumeChanged,
      brightnessChanged: brightnessChanged ?? this.brightnessChanged,
      errorMessage: errorMessage ?? this.errorMessage,
      showControls: showControls ?? this.showControls,
      isFullScreen: isFullScreen ?? this.isFullScreen,
      isLongPressed: isLongPressed ?? this.isLongPressed,
      currentVolume: currentVolume ?? this.currentVolume,
      currentBrightness: currentBrightness ?? this.currentBrightness,
      isHandlingVerticalDrag:
          isHandlingVerticalDrag ?? this.isHandlingVerticalDrag,
      isLocked: isLocked ?? this.isLocked,
      showFloatingControls: showFloatingControls ?? this.showFloatingControls,
      isProcessingScreenshot:
          isProcessingScreenshot ?? this.isProcessingScreenshot,
      speedOptions: speedOptions ?? this.speedOptions,
      currentSpeedIndex: currentSpeedIndex ?? this.currentSpeedIndex,
      aspectRatioOptions: aspectRatioOptions ?? this.aspectRatioOptions,
      currentAspectRatioIndex:
          currentAspectRatioIndex ?? this.currentAspectRatioIndex,
      forcedAspectRatio: forcedAspectRatio ?? this.forcedAspectRatio,
      gestureFeedbackText: gestureFeedbackText ?? this.gestureFeedbackText,
      isMore: isMore ?? this.isMore,
      isTenBackward: isTenBackward ?? this.isTenBackward,
      isTenForward: isTenForward ?? this.isTenForward,
      isLandscape: isLandscape ?? this.isLandscape,
    );
  }
}
