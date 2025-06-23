import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:screenshot/screenshot.dart';
import 'package:video_player/video_player.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../bloc/video_bloc/video_bloc.dart';
// import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import '../bloc/video_bloc/video_event.dart';
import '../bloc/video_bloc/video_state.dart';
import 'custom_slider.dart';

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

// ======== NEW FEATURE: BUILD FLOATING BUTTON ========
Widget _buildFloatingButton({
  required IconData icon,
  required String label,
  required VoidCallback onTap,
  bool isActive = false,
}) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      width: 70,
      margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(35),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(100),
                color: isActive ? Colors.blue : Colors.black38),
            child: Icon(
              icon,
              color: Colors.white,
              size: 26,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 8,
            ),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    ),
  );
}

class MXLikeVideoPlayer extends StatefulWidget {
  const MXLikeVideoPlayer({
    super.key,
    required this.videoPath,
    this.title = 'Video Player',
    this.forceInitialLandscape = true,
  });
  final String videoPath;
  final String title;
  final bool forceInitialLandscape;

  @override
  State<MXLikeVideoPlayer> createState() => _MXLikeVideoPlayerState();
}

class _MXLikeVideoPlayerState extends State<MXLikeVideoPlayer> with SingleTickerProviderStateMixin {
  late AnimationController _controlsFadeController;
  late Animation<double> _controlsFadeAnimation;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => VideoBloc()..add(InitializeVideo(widget.videoPath)),
      child: BlocBuilder<VideoBloc, VideoState>(
        builder: (context, state) {
          if (state.hasError) {
            return _buildErrorView(state.errorMessage);
          }

          if (!state.isControllerInitialized) {
            return _buildLoadingView();
          }

          return _buildVideoPlayer(context, state);
        },
      ),
    );
  }

  @override
  void dispose() {
    _controlsFadeController.dispose();
    setAllOrientations();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    WakelockPlus.disable();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _controlsFadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _controlsFadeAnimation = CurvedAnimation(
      parent: _controlsFadeController,
      curve: Curves.easeOut,
    );
    _controlsFadeController.forward();

    if (widget.forceInitialLandscape) {
      setLandscapeOrientation();
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    }
    context.read<VideoBloc>().add(InitializeVideo(widget.videoPath));
    WakelockPlus.enable();
  }

  void showFeedback(BuildContext context, String message) {
    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        bottom: 50.0,
        left: MediaQuery.of(context).size.width * 0.1,
        right: MediaQuery.of(context).size.width * 0.1,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.7),
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Text(
              message,
              style: const TextStyle(color: Colors.white, fontSize: 16.0),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);

    Future.delayed(const Duration(seconds: 2), () {
      overlayEntry.remove();
    });
  }

  Widget _buildBottomBar(BuildContext context) {
    final videoBloc = context.read<VideoBloc>();

    return BlocBuilder<VideoBloc, VideoState>(
      builder: (context, state) {
        if (!state.showControls || state.isLocked) {
          return const SizedBox.shrink();
        }

        final progress = state.duration.inMilliseconds > 0
            ? state.position.inMilliseconds / state.duration.inMilliseconds
            : 0.0;

        return Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: <Color>[
                Colors.black87,
                Colors.black54,
                Colors.transparent,
              ],
              stops: [0.0, 0.7, 1.0],
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Slider and time row
              Row(
                children: [
                  Text(
                    formatDuration(state.position),
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: SliderTheme(
                      data: SliderThemeData(
                        trackHeight: 3,
                        activeTrackColor: Theme.of(context).colorScheme.primary,
                        inactiveTrackColor: Colors.white30,
                        thumbColor: Theme.of(context).colorScheme.primary,
                        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
                        overlayShape: const RoundSliderOverlayShape(overlayRadius: 18),
                        overlayColor: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                      ),
                      child: CustomSlider(
                        value: progress.clamp(0.0, 1.0),
                        showValueIndicator: false,
                        onChanged: (value) {
                          final newPosition = Duration(
                            milliseconds: (state.duration.inMilliseconds * value).toInt(),
                          );
                          videoBloc.add(SeekVideo(newPosition));
                        },
                        onChangeStart: (value) {
                          state.controller?.pause();
                        },
                        onChangeEnd: (value) {
                          if (state.isPlaying) {
                            state.controller?.play();
                          }
                          videoBloc.add(ToggleControls());
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    formatDuration(state.duration),
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Media controls row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    flex: 30,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.skip_previous_rounded,
                            color: Colors.white,
                            size: 30,
                          ),
                          onPressed: () => videoBloc.add(VideoError('not implemented error')),
                          tooltip: 'previous',
                          padding: const EdgeInsets.all(12.0),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.replay_10_rounded,
                            color: Colors.white,
                            size: 30,
                          ),
                          onPressed: () => videoBloc.add(SeekBackward(const Duration(seconds: 10))),
                          tooltip: '10-',
                          padding: const EdgeInsets.all(12.0),
                        ),
                        GestureDetector(
                          onTap: () => videoBloc.add(
                            state.isPlaying ? PauseVideo() : PlayVideo(),
                          ),
                          child: Container(
                            width: 100,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.0),
                            ),
                            child: Icon(
                              state.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                              color: Colors.white,
                              size: 34,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.forward_10,
                            color: Colors.white,
                            size: 30,
                          ),
                          onPressed: () {
                            videoBloc.add(SeekForward(const Duration(seconds: 10)));
                          },
                          tooltip: '10+',
                          padding: const EdgeInsets.all(12.0),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.skip_next_rounded,
                            color: Colors.white,
                            size: 30,
                          ),
                          onPressed: () => videoBloc.add(VideoError('next video not implemented')),
                          tooltip: 'next video',
                          padding: const EdgeInsets.all(12.0),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBrightnessAlert(BuildContext context) {
    final videoBloc = context.read<VideoBloc>();
    final brightness = videoBloc.state.currentBrightness;

    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.only(right: 16),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.black54,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.brightness_6, color: Colors.white, size: 24),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: Container(
                width: 8,
                height: 100,
                color: Colors.white24,
                child: FractionallySizedBox(
                  alignment: Alignment.bottomCenter,
                  heightFactor: brightness,
                  child: Container(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorView(String message) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(title: Text(widget.title)),
      body: Center(
        child: Text(
          message,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildFloatingButtonsRow(BuildContext context) {
    final videoBloc = context.read<VideoBloc>();
    if (!videoBloc.state.showControls || videoBloc.state.isLocked) {
      return const SizedBox.shrink();
    }
    return BlocBuilder<VideoBloc, VideoState>(
      builder: (context, state) {
        return SizedBox(
          width: MediaQuery.of(context).orientation == Orientation.portrait
              ? MediaQuery.of(context).size.width / 1.1
              : MediaQuery.of(context).size.width / 1.1,
          height: 100,
          child: ListView(
            scrollDirection: Axis.horizontal,
            reverse: true,
            shrinkWrap: true,
            children: [
              Row(
                children: [
                  _buildFloatingButton(
                    icon: state.isMuted ? Icons.volume_off : Icons.volume_up,
                    label: 'mute',
                    onTap: () => toggleMute(context),
                  ),
                  _buildFloatingButton(
                    icon: state.isLandscape ? Icons.screen_rotation : Icons.screen_lock_rotation,
                    label: 'rotate',
                    onTap: () => rotateScreen(context),
                  ),
                  _buildFloatingButton(
                    icon: Icons.speed,
                    label: 'speed',
                    onTap: () => showSpeedDialog(context),
                  ),
                  if (state.isMore) ...[
                    _buildFloatingButton(
                      icon: Icons.aspect_ratio,
                      label: 'aspectratio',
                      onTap: () => showAspectRatioDialog(context),
                    ),
                    _buildFloatingButton(
                      icon: state.isNightMode ? Icons.dark_mode : Icons.light_mode,
                      label: 'night mood',
                      onTap: () => videoBloc.add(NightModeEvent()),
                    ),
                    _buildFloatingButton(
                      icon: Icons.screenshot,
                      label: 'screenshot',
                      onTap: () => videoBloc.add(TakeScreenShotEvent(context)),
                    ),
                  ],
                  _buildFloatingButton(
                    icon:
                        state.isMore ? Icons.arrow_forward_ios_outlined : Icons.arrow_back_ios_new,
                    label: state.isMore ? 'less' : 'more',
                    onTap: () => videoBloc.add(ToggleFloatingMore()),
                  ),
                ],
              )
            ],
          ),
        );
      },
    );
  }

  Widget _buildFloatingControl({
    required IconData icon,
    required double value,
    required String label,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.white),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: Container(
            width: 100,
            height: 4,
            color: Colors.white24,
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: value,
              child: Container(color: Colors.white),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${(value * 100).round()}%',
          style: const TextStyle(color: Colors.white, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildFloatingControlsRow(BuildContext context, VideoState state) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildFloatingControl(
            icon: Icons.brightness_6,
            value: state.currentBrightness,
            label: 'brightness',
          ),
          _buildFloatingControl(
            icon: Icons.volume_up,
            value: state.currentVolume,
            label: 'volume',
          ),
        ],
      ),
    );
  }

  Widget _buildGestureFeedback(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: const TextStyle(color: Colors.white),
      ),
    );
  }

  Widget _buildLoadingView() {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(title: Text(widget.title)),
      body: const Center(
        child: CircularProgressIndicator(color: Colors.red),
      ),
    );
  }

  Widget _buildScreenshotProcessingOverlay() {
    return Container(
      color: Colors.black54,
      child: const Center(
        child: CircularProgressIndicator(color: Colors.white),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context, VideoState state) {
    if (!state.showControls || state.isLocked) {
      return const SizedBox.shrink();
    }
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[
            Colors.black87,
            Colors.black54,
            Colors.transparent,
          ],
          stops: [0.0, 0.7, 1.0],
        ),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
          Expanded(
            child: Text(
              widget.title,
              style:
                  const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w500),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoPlayer(BuildContext context, VideoState state) {
    final videoBloc = context.read<VideoBloc>();

    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: () {
          videoBloc.add(ToggleControls());
        },
        onDoubleTapDown: (details) => handleDoubleTapDown(context, details),
        onHorizontalDragUpdate: (details) => handleHorizontalDragUpdate(context, details),
        onVerticalDragStart: (details) => handleVerticalDragStart(context, details),
        onVerticalDragUpdate: (details) => handleVerticalDragUpdate(context, details),
        onVerticalDragEnd: (details) => handleVerticalDragEnd(context, details),
        onLongPress: () => handleOnLongPress(context),
        onLongPressUp: () => handleOnLongPressEnd(context),
        child: Center(
          child: Stack(
            alignment: Alignment.center,
            children: [
              if (state.isLocked == false) ...[
                // Video content
                if (state.controller != null)
                  state.forcedAspectRatio != null
                      ? AspectRatio(
                          aspectRatio: state.forcedAspectRatio!,
                          child: Screenshot(
                              controller: videoBloc.state.screenshotController,
                              child: VideoPlayer(state.controller!)),
                        )
                      : AspectRatio(
                          aspectRatio: state.controller!.value.aspectRatio,
                          child: Screenshot(
                              controller: videoBloc.state.screenshotController,
                              child: VideoPlayer(state.controller!)),
                        ),

                // Screenshot processing indicator
                if (state.isProcessingScreenshot) _buildScreenshotProcessingOverlay(),

                // Controls overlay
                if (!state.isLocked)
                  FadeTransition(
                    opacity: _controlsFadeAnimation,
                    child: Stack(
                      children: [
                        // Top Bar
                        Positioned(
                          top: MediaQuery.of(context).orientation == Orientation.portrait ? 10 : 0,
                          left: 0,
                          right: 0,
                          child: _buildTopBar(context, state),
                        ),

                        Positioned(
                            top: 75, // Fixed top gap
                            left: MediaQuery.of(context).orientation == Orientation.portrait
                                ? 0
                                : 75, // Fixed left gap
                            right:
                                MediaQuery.of(context).orientation == Orientation.portrait ? 0 : 75,
                            child: _buildFloatingButtonsRow(context)),
                        // Floating Controls

                        if (state.showFloatingControls)
                          Positioned(
                            top: MediaQuery.of(context).orientation == Orientation.portrait
                                ? 90
                                : 60,
                            left: 0,
                            right: MediaQuery.of(context).orientation == Orientation.portrait
                                ? 0
                                : 250,
                            child: _buildFloatingControlsRow(context, state),
                          ),

                        // Bottom Bar
                        Positioned(
                          bottom:
                              MediaQuery.of(context).orientation == Orientation.portrait ? 50 : 0,
                          left: 0,
                          right: 0,
                          child: _buildBottomBar(context),
                        ),

                        Positioned(
                          right: MediaQuery.of(context).orientation == Orientation.portrait ? 5 : 5,
                          bottom:
                              MediaQuery.of(context).orientation == Orientation.portrait ? 150 : 10,
                          child: !state.showControls || state.isLocked
                              ? const SizedBox.shrink()
                              : IconButton(
                                  onPressed: () {
                                    videoBloc.add(ToggleFullScreen());
                                  },
                                  icon: state.isFullScreen
                                      ? const Icon(
                                          Icons.fullscreen_exit,
                                          size: 30,
                                        )
                                      : const Icon(
                                          Icons.fullscreen,
                                          size: 30,
                                        )),
                        ),
                        Positioned(
                            left: 0,
                            top: (MediaQuery.of(context).size.height / 2) - 60,
                            child: _buildVolumeAlert(context)),
                        Positioned(
                            top: (MediaQuery.of(context).size.height / 2) - 60,
                            right: 0,
                            child: _buildBrightnessAlert(context)),
                        !state.showControls
                            ? const SizedBox.shrink()
                            : Positioned(
                                left: MediaQuery.of(context).orientation == Orientation.portrait
                                    ? 5
                                    : 5,
                                bottom: MediaQuery.of(context).orientation == Orientation.portrait
                                    ? 150
                                    : 10,
                                child: IconButton(
                                    onPressed: () => videoBloc.add(LockEvent()),
                                    icon: const Icon(Icons.lock))),
                      ],
                    ),
                  ),
                Positioned(
                    right: MediaQuery.of(context).orientation == Orientation.portrait
                        ? (MediaQuery.of(context).size.width / 2) - 50
                        : state.showControls
                            ? (MediaQuery.of(context).size.width / 2) - 50
                            : (MediaQuery.of(context).size.width / 2) - 120,
                    top: MediaQuery.of(context).orientation == Orientation.portrait
                        ? state.isLocked
                            ? 0
                            : 250
                        : 50,
                    child: state.isLongPressed
                        ? Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(30),
                                color: const Color.fromARGB(80, 0, 0, 0)),
                            width: 100,
                            height: 30,
                            alignment: Alignment.center,
                            child: const Text('speed 2x'),
                          )
                        : Container()),
                state.isTenForward
                    ? Positioned(
                        right: 0,
                        child: Container(
                          width: MediaQuery.of(context).orientation == Orientation.portrait
                              ? MediaQuery.of(context).size.width / 2
                              : MediaQuery.of(context).size.width / 2 - 150,
                          height: MediaQuery.of(context).size.height,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(1000), bottomLeft: Radius.circular(1000)),
                            color: Colors.black.withOpacity(0.4),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.fast_forward_rounded,
                                color: Colors.white,
                                size: 32,
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: const Text(
                                  '10s',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ))
                    : const SizedBox.shrink(),
                state.isTenBackward
                    ? Positioned(
                        left: 0,
                        child: Container(
                          width: MediaQuery.of(context).size.width / 2 - 150,
                          height: MediaQuery.of(context).size.height,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            shape: BoxShape.rectangle,
                            borderRadius: const BorderRadius.only(
                                topRight: Radius.circular(1000),
                                bottomRight: Radius.circular(1000)),
                            color: Colors.black.withOpacity(0.4),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.fast_rewind,
                                color: Colors.white,
                                size: 32,
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: const Text(
                                  '10s',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ))
                    : const SizedBox.shrink(),
                // Gesture feedback
                if (state.gestureFeedbackText != null)
                  _buildGestureFeedback(state.gestureFeedbackText!),
              ] else ...[
                if (state.controller != null)
                  state.forcedAspectRatio != null
                      ? AspectRatio(
                          aspectRatio: state.forcedAspectRatio!,
                          child: Screenshot(
                              controller: videoBloc.state.screenshotController,
                              child: VideoPlayer(state.controller!)),
                        )
                      : AspectRatio(
                          aspectRatio: state.controller!.value.aspectRatio,
                          child: Screenshot(
                              controller: videoBloc.state.screenshotController,
                              child: VideoPlayer(state.controller!)),
                        ),
                Positioned(
                    bottom: MediaQuery.of(context).orientation == Orientation.portrait ? 5 : 5,
                    left: 0,
                    child: IconButton(
                        onPressed: () => videoBloc.add(UnLockEvent()),
                        icon: const Icon(Icons.lock_open))),
                state.isTenForward
                    ? Positioned(
                        right: 0,
                        child: Container(
                          width: MediaQuery.of(context).orientation == Orientation.portrait
                              ? MediaQuery.of(context).size.width / 2
                              : MediaQuery.of(context).size.width / 2 - 150,
                          height: MediaQuery.of(context).size.height,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            shape: BoxShape.rectangle,
                            borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(1000), bottomLeft: Radius.circular(1000)),
                            color: Colors.black.withOpacity(0.4),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.fast_forward_rounded,
                                color: Colors.white,
                                size: 32,
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: const Text(
                                  '10s',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ))
                    : const SizedBox.shrink(),
                state.isTenBackward
                    ? Positioned(
                        left: 0,
                        child: Container(
                          width: MediaQuery.of(context).orientation == Orientation.portrait
                              ? MediaQuery.of(context).size.width / 2
                              : MediaQuery.of(context).size.width / 2 - 150,
                          height: MediaQuery.of(context).size.height,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.only(
                                topRight: Radius.circular(1000),
                                bottomRight: Radius.circular(1000)),
                            color: Colors.black.withOpacity(0.4),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.fast_rewind,
                                color: Colors.white,
                                size: 32,
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: const Text(
                                  '10s',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ))
                    : const SizedBox.shrink(),
                Positioned(
                    right: MediaQuery.of(context).orientation == Orientation.portrait
                        ? (MediaQuery.of(context).size.width / 2) - 50
                        : (MediaQuery.of(context).size.width / 2) - 120,
                    top: MediaQuery.of(context).orientation == Orientation.portrait
                        ? state.isLocked
                            ? 0
                            : 150
                        : 60,
                    child: state.isLongPressed
                        ? Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(30),
                                color: const Color.fromARGB(80, 0, 0, 0)),
                            width: 100,
                            height: 30,
                            alignment: Alignment.center,
                            child: const Text('speed 2x'),
                          )
                        : Container()),
              ]
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVolumeAlert(BuildContext context) {
    var videoBloc = context.read<VideoBloc>();
    var volume = videoBloc.state.currentVolume;

    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.only(right: 16),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.black54,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.volume_up, color: Colors.white, size: 24),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: Container(
                width: 8,
                height: 100,
                color: Colors.white24,
                child: FractionallySizedBox(
                  alignment: Alignment.bottomCenter,
                  heightFactor: volume,
                  child: Container(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
