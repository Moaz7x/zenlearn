import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Drop this file anywhere in `lib/`, import it, and profit 🤘
class CustomText extends StatefulWidget {
  /// Full text to reveal
  final String text;

  /// Callback when the typing finishes (optional)
  final VoidCallback? onFinished;

  /// Style of the text
  final TextStyle? textStyle;

  /// Delay between each letter (defaults to 80 ms)
  final Duration letterDelay;

  /// Size of the ball (defaults to 10 px)
  final double ballSize;

  /// How high the ball bounces (defaults to 8 px)
  final double ballBounceHeight;

  /// Color of the ball
  final Color ballColor;

  /// Duration of one up-and-down bounce
  final Duration ballBounceDuration;

  /// Whether the ball should keep bouncing after typing is done
  final bool keepBouncingAfterFinish;

  const CustomText({
    super.key,
    required this.text,
    this.onFinished,
    this.textStyle,
    this.letterDelay = const Duration(milliseconds: 80),
    this.ballSize = 15,
    this.ballBounceHeight = 8,
    this.ballColor = Colors.blue,
    this.ballBounceDuration = const Duration(milliseconds: 400),
    this.keepBouncingAfterFinish = true,
  });

  @override
  State<CustomText> createState() => _CustomTextState();
}

class _CustomTextState extends State<CustomText>
    with TickerProviderStateMixin {
  late final AnimationController _textCtrl;
  late final AnimationController _ballCtrl;
  int _visibleChars = 0;

  @override
  void initState() {
    super.initState();

    // ---- TEXT ANIMATION -----------------------------------------------------
    final totalDuration = widget.letterDelay * widget.text.length;
    _textCtrl = AnimationController(
      vsync: this,
      duration: totalDuration,
    )
      ..addListener(() {
        setState(() {
          _visibleChars =
              (_textCtrl.value * widget.text.length).floor().clamp(0, widget.text.length);
        });
      })
      ..forward().whenComplete(() {
        widget.onFinished?.call();
        if (!widget.keepBouncingAfterFinish) _ballCtrl.stop();
      });

    // ---- BALL ANIMATION -----------------------------------------------------
    _ballCtrl = AnimationController(
      vsync: this,
      duration: widget.ballBounceDuration,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _textCtrl.dispose();
    _ballCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final displayed = widget.text.substring(0, _visibleChars);

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // BOUNCING BALL
       
        Text(
          displayed,
          style: widget.textStyle ?? DefaultTextStyle.of(context).style,
        ),
        const SizedBox(width: 6),
         AnimatedBuilder(
          animation: _ballCtrl,
          builder: (_, child) {
            // Simple sine-wave bounce (0 → π)
            final dy = -math.sin(_ballCtrl.value * math.pi) * widget.ballBounceHeight;
            return Transform.translate(offset: Offset(0, dy), child: child);
          },
          child: Container(
            width: widget.ballSize,
            height: widget.ballSize,
            decoration: BoxDecoration(
              color: widget.ballColor,
              shape: BoxShape.circle,
            ),
          ),
        ),
        
        // TYPING TEXT
      ],
    );
  }
}
