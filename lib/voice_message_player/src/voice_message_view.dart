import 'package:flutter/material.dart';
import 'package:voice_message_recorder/voice_message_player/src/helpers/play_status.dart';
import 'package:voice_message_recorder/voice_message_player/src/helpers/utils.dart';

import '../voice_message_player.dart';
import 'widgets/noises.dart';
import 'widgets/play_pause_button.dart';

/// A widget that displays a voice message view with play/pause functionality.
///
/// The [VoiceMessagePlayer] widget is used to display a voice message with customizable appearance and behavior.
/// It provides a play/pause button, a progress slider, and a counter for the remaining time.
/// The appearance of the widget can be customized using various properties such as background color, slider color, and text styles.
///
class VoiceMessagePlayer extends StatefulWidget {
  const VoiceMessagePlayer(
      {Key? key,
      required this.controller,
      this.backgroundColor = Colors.white,
      this.activeSliderColor = Colors.red,
      this.notActiveSliderColor,
      this.circlesColor = Colors.grey,
      this.innerPadding = 12,
      this.cornerRadius = 20,
      // this.playerWidth = 170,
      this.size = 38,
      this.refreshIcon = const Icon(
        Icons.refresh,
        color: Colors.white,
      ),
      this.pauseIcon = const Icon(
        Icons.pause_rounded,
        color: Colors.white,
      ),
      this.playIcon = const Icon(
        Icons.play_arrow_rounded,
        color: Colors.white,
      ),
      this.stopDownloadingIcon = const Icon(
        Icons.close,
        color: Colors.white,
      ),
      this.playPauseButtonDecoration,
      this.circlesTextStyle = const TextStyle(
        color: Colors.white,
        fontSize: 10,
        fontWeight: FontWeight.bold,
      ),
      this.counterTextStyle = const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w500,
      ),
      this.playPauseButtonLoadingColor = Colors.white})
      : super(key: key);

  /// The controller for the voice message view.
  final VoiceController controller;

  /// The background color of the voice message view.
  final Color backgroundColor;

  ///
  final Color circlesColor;

  /// The color of the active slider.
  final Color activeSliderColor;

  /// The color of the not active slider.
  final Color? notActiveSliderColor;

  /// The text style of the circles.
  final TextStyle circlesTextStyle;

  /// The text style of the counter.
  final TextStyle counterTextStyle;

  /// The padding between the inner content and the outer container.
  final double innerPadding;

  /// The corner radius of the outer container.
  final double cornerRadius;

  /// The size of the play/pause button.
  final double size;

  /// The refresh icon of the play/pause button.
  final Widget refreshIcon;

  /// The pause icon of the play/pause button.
  final Widget pauseIcon;

  /// The play icon of the play/pause button.
  final Widget playIcon;

  /// The stop downloading icon of the play/pause button.
  final Widget stopDownloadingIcon;

  /// The play Decoration of the play/pause button.
  final Decoration? playPauseButtonDecoration;

  /// The loading Color of the play/pause button.
  final Color playPauseButtonLoadingColor;

  @override
  State<VoiceMessagePlayer> createState() => _VoiceMessagePlayerState();
}

class _VoiceMessagePlayerState extends State<VoiceMessagePlayer> {
  @override
  void dispose() async {
    widget.controller.dispose();
    widget.controller.cancelDownload();
    widget.controller.stopPlaying();
    super.dispose();
  }

  @override

  /// Build voice message view.
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final color = widget.circlesColor;
    final newTHeme = theme.copyWith(
      sliderTheme: SliderThemeData(
        trackShape: CustomTrackShape(),
        thumbShape: SliderComponentShape.noThumb,
        minThumbSeparation: 0,
      ),
      splashColor: Colors.transparent,
    );

    return Container(
      width: 160 + (widget.controller.noiseCount * .72.w()),
      padding: EdgeInsets.all(widget.innerPadding),
      decoration: BoxDecoration(
        color: widget.backgroundColor,
        borderRadius: BorderRadius.circular(widget.cornerRadius),
      ),
      child: ValueListenableBuilder(
        /// update ui when change play status
        valueListenable: widget.controller.updater,
        builder: (context, value, child) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              /// play pause button
              PlayPauseButton(
                controller: widget.controller,
                color: color,
                loadingColor: widget.playPauseButtonLoadingColor,
                size: widget.size,
                refreshIcon: widget.refreshIcon,
                pauseIcon: widget.pauseIcon,
                playIcon: widget.playIcon,
                stopDownloadingIcon: widget.stopDownloadingIcon,
                buttonDecoration: widget.playPauseButtonDecoration,
              ),

              ///
              const SizedBox(width: 10),

              /// slider & noises
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    _noises(newTHeme),
                    const SizedBox(height: 4),
                    Text(widget.controller.remindingTime,
                        style: widget.counterTextStyle),
                  ],
                ),
              ),

              ///
              const SizedBox(width: 12),

              /// speed button
              _changeSpeedButton(color),

              ///
              const SizedBox(width: 10),
            ],
          );
        },
      ),
    );
  }

  SizedBox _noises(ThemeData newTHeme) => SizedBox(
        height: 30,
        width: widget.controller.noiseWidth,
        child: Stack(
          alignment: Alignment.center,
          children: [
            /// noises

            Noises(
              rList: widget.controller.randoms!,
              activeSliderColor: widget.activeSliderColor,
            ),

            /// slider
            AnimatedBuilder(
              animation: CurvedAnimation(
                parent: widget.controller.animController,
                curve: Curves.ease,
              ),
              builder: (BuildContext context, Widget? child) {
                return Positioned(
                  left: widget.controller.animController.value,
                  child: Container(
                    width: widget.controller.noiseWidth,
                    height: 6.w(),
                    color: widget.notActiveSliderColor ??
                        widget.backgroundColor.withOpacity(.4),
                  ),
                );
              },
            ),
            Opacity(
              opacity: 0,
              child: Container(
                width: widget.controller.noiseWidth,
                color: Colors.transparent.withOpacity(1),
                child: Theme(
                  data: newTHeme,
                  child: Slider(
                    value: widget.controller.currentMillSeconds,
                    max: widget.controller.maxMillSeconds,
                    onChangeStart: widget.controller.onChangeSliderStart,
                    onChanged: widget.controller.onChanging,
                    onChangeEnd: (value) {
                      widget.controller.onSeek(
                        Duration(milliseconds: value.toInt()),
                      );
                      widget.controller.play();
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      );

  Transform _changeSpeedButton(Color color) => Transform.translate(
        offset: const Offset(0, -7),
        child: GestureDetector(
          onTap: () {
            widget.controller.changeSpeed();
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 2),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              widget.controller.speed.playSpeedStr,
              style: widget.circlesTextStyle,
            ),
          ),
        ),
      );
}

///
/// A custom track shape for a slider that is rounded rectangular in shape.
/// Extends the [RoundedRectSliderTrackShape] class.
class CustomTrackShape extends RoundedRectSliderTrackShape {
  @override

  /// Returns the preferred rectangle for the voice message view.
  ///
  /// The preferred rectangle is calculated based on the current state and layout
  /// of the voice message view. It represents the area where the view should be
  /// displayed on the screen.
  ///
  /// Returns a [Rect] object representing the preferred rectangle.
  Rect getPreferredRect({
    required RenderBox parentBox,
    Offset offset = Offset.zero,
    required SliderThemeData sliderTheme,
    bool isEnabled = false,
    bool isDiscrete = false,
  }) {
    const double trackHeight = 10;
    final double trackLeft = offset.dx,
        trackTop = offset.dy + (parentBox.size.height - trackHeight) / 2;
    final double trackWidth = parentBox.size.width;
    return Rect.fromLTWH(trackLeft, trackTop, trackWidth, trackHeight);
  }
}
