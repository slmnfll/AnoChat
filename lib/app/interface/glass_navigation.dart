import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class GlassNavigation extends StatefulWidget {
  final int selected;
  final ValueChanged<int> onChanged;
  const GlassNavigation({
    super.key,
    required this.selected,
    required this.onChanged,
  });
  @override
  State<GlassNavigation> createState() => _GlassNavigationState();
}

class _GlassNavigationState extends State<GlassNavigation> {
  MethodChannel? channel;
  double? drag;
  static const labels = ['Lounge', 'Rooms', 'Friends', 'Your account'];
  static const icons = [
    CupertinoIcons.house,
    CupertinoIcons.square_grid_2x2,
    CupertinoIcons.chat_bubble_2,
    CupertinoIcons.person,
  ];
  @override
  void didUpdateWidget(GlassNavigation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selected != widget.selected)
      channel?.invokeMethod<void>('select', widget.selected);
  }

  @override
  void dispose() {
    channel?.setMethodCallHandler(null);
    super.dispose();
  }

  void select(int index) {
    if (index != widget.selected) {
      HapticFeedback.selectionClick();
      widget.onChanged(index);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.iOS) {
      return SizedBox(
        height: 72,
        child: UiKitView(
          viewType: 'ano/liquid-tabs',
          creationParams: {'selected': widget.selected},
          creationParamsCodec: const StandardMessageCodec(),
          onPlatformViewCreated: (id) {
            channel = MethodChannel('ano/liquid-tabs/$id');
            channel!.setMethodCallHandler((call) async {
              if (call.method == 'select' && mounted)
                widget.onChanged(call.arguments as int);
            });
          },
        ),
      );
    }
    return LayoutBuilder(
      builder: (context, constraints) {
        final cell = (constraints.maxWidth - 12) / 4;
        void track(double x) {
          setState(() => drag = ((x - 6) / cell - .5).clamp(0, 3));
          select(((x - 6) / cell).floor().clamp(0, 3));
        }

        return GestureDetector(
          onHorizontalDragStart: (d) => track(d.localPosition.dx),
          onHorizontalDragUpdate: (d) => track(d.localPosition.dx),
          onHorizontalDragEnd: (_) => setState(() => drag = null),
          onHorizontalDragCancel: () => setState(() => drag = null),
          onLongPressStart: (d) => track(d.localPosition.dx),
          onLongPressMoveUpdate: (d) => track(d.localPosition.dx),
          onLongPressEnd: (_) => setState(() => drag = null),
          child: Container(
            height: 72,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(38),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x1829372d),
                  blurRadius: 24,
                  offset: Offset(0, 7),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(38),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: .55),
                    borderRadius: BorderRadius.circular(38),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: .8),
                    ),
                  ),
                  child: Stack(
                    children: [
                      AnimatedPositioned(
                        duration: Duration(
                          milliseconds: drag == null ? 260 : 40,
                        ),
                        curve: Curves.easeOutCubic,
                        left: 6 + (drag ?? widget.selected.toDouble()) * cell,
                        top: drag == null ? 7 : 4,
                        bottom: drag == null ? 7 : 4,
                        width: cell,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(32),
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Colors.white.withValues(alpha: .9),
                                const Color(0xffdce4d4).withValues(alpha: .7),
                              ],
                            ),
                            border: Border.all(color: Colors.white),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x1529372d),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 12,
                        ),
                        child: Row(
                          children: List.generate(
                            4,
                            (i) => Expanded(
                              child: Semantics(
                                selected: widget.selected == i,
                                child: IconButton(
                                  tooltip: labels[i],
                                  onPressed: () => select(i),
                                  icon: Icon(
                                    icons[i],
                                    color: const Color(0xff40523e),
                                    size: 25,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
