import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

typedef ScrollableDrawerOverlayBuilder = Widget Function(
  BuildContext context,
  double scrollingProgress,
  Widget child,
);

class ScrollableDrawerScaffold extends StatefulWidget {
  const ScrollableDrawerScaffold({
    required this.drawer,
    required this.body,
    this.dismissible = true,
    this.duration = _defaultDuration,
    this.drawerFraction = _defaultDrawerFraction,
    this.bodyOverlayBuilder,
    this.drawerOverlayBuilder,
    Key? key,
  })  : assert(0 < drawerFraction && drawerFraction <= 1),
        super(key: key);

  final Duration duration;
  final double drawerFraction;
  final Widget body;
  final Widget drawer;
  final bool dismissible;
  final ScrollableDrawerOverlayBuilder? bodyOverlayBuilder;
  final ScrollableDrawerOverlayBuilder? drawerOverlayBuilder;

  static const _defaultDrawerFraction = .78;
  static const _defaultDuration = Duration(milliseconds: 160);

  static ScrollableDrawerScaffoldState of(BuildContext context) {
    final result =
        context.findAncestorStateOfType<ScrollableDrawerScaffoldState>();
    if (result != null) {
      return result;
    }
    throw FlutterError.fromParts(<DiagnosticsNode>[
      ErrorSummary(
          'ScrollableDrawerScaffold.of() called with a context that does not '
          'contain a ScrollableDrawerScaffold.'),
      ErrorDescription(
          'No ScrollableDrawerScaffold ancestor could be found starting from '
          'the context that was passed to ScrollableDrawerScaffold.of(). This '
          'usually happens when the context provided is from the same '
          'StatefulWidget as that whose build function actually creates '
          'the ScrollableDrawerScaffold widget being sought.'),
      ErrorHint(
          'There are several ways to avoid this problem. The simplest is to '
          'use a Builder to get a context that is "under" the '
          'ScrollableDrawerScaffold. For an example of this, please see '
          'the documentation for ScrollableDrawerScaffold.of():\n'
          // TODO(heavenOSK): Replace following url
          '  https://api.flutter.dev/flutter/material/Scaffold/of.html'),
      ErrorHint(
          'A more efficient solution is to split your build function into '
          'several widgets. This introduces a new context from which you can '
          'obtain the ScrollableDrawerScaffold. In this solution, you '
          'would have an outer widget that creates the '
          'ScrollableDrawerScaffold populated by instances of your new inner '
          'widgets, and then in these inner widgets you would use '
          'ScrollableDrawerScaffold.of().\n A less elegant but more expedient '
          'solution is assign a GlobalKey to the ScrollableDrawerScaffold, '
          'then use the key.currentState property to obtain the '
          'ScrollableDrawerScaffold rather than using the '
          'ScrollableDrawerScaffold.of() function.'),
      context.describeElement('The context used was')
    ]);
  }

  @override
  ScrollableDrawerScaffoldState createState() =>
      ScrollableDrawerScaffoldState();
}

class ScrollableDrawerScaffoldState extends State<ScrollableDrawerScaffold> {
  double? _bodyStartPosition;
  ScrollController? _controller;
  late final double _drawerFraction = widget.drawerFraction;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _bodyStartPosition ??= MediaQuery.of(context).size.width * _drawerFraction;
    _controller ??= ScrollController(
      initialScrollOffset: _bodyStartPosition!,
    );
  }

  bool get _openingDrawer => _drawerScrollingProgress >= 1;

  double get _drawerScrollingProgress {
    final rate =
        (_bodyStartPosition! - _controller!.offset) / _bodyStartPosition!;
    if (rate < 0) {
      return 0;
    } else if (1 < rate) {
      return 1;
    } else {
      return rate;
    }
  }

  double get _bodyScrollingProgress => 1 - _drawerScrollingProgress;

  void closeDrawer() {
    _controller!.animateTo(
      _bodyStartPosition!,
      duration: widget.duration,
      curve: Curves.easeOut,
    );
  }

  void openDrawer() {
    _controller!.animateTo(
      0,
      duration: widget.duration,
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scrollable(
      dragStartBehavior: DragStartBehavior.start,
      axisDirection: AxisDirection.right,
      controller: _controller,
      physics: const PageScrollPhysics(parent: ClampingScrollPhysics()),
      viewportBuilder: (BuildContext context, ViewportOffset position) {
        return Viewport(
          cacheExtent: 1,
          cacheExtentStyle: CacheExtentStyle.viewport,
          axisDirection: AxisDirection.right,
          offset: position,
          slivers: <Widget>[
            SliverFillViewport(
              viewportFraction: _drawerFraction,
              padEnds: false,
              delegate: SliverChildListDelegate(
                [
                  AnimatedBuilder(
                    animation: _controller!,
                    builder: (context, child) {
                      final wrapped = widget.drawerOverlayBuilder?.call(
                        context,
                        _drawerScrollingProgress,
                        child!,
                      );
                      return wrapped ?? child!;
                    },
                    child: widget.drawer,
                  ),
                ],
              ),
            ),
            SliverFillViewport(
              viewportFraction: 1,
              delegate: SliverChildListDelegate(
                [
                  AnimatedBuilder(
                    animation: _controller!,
                    builder: (context, child) {
                      final wrapped = widget.bodyOverlayBuilder?.call(
                        context,
                        _bodyScrollingProgress,
                        child!,
                      );
                      return GestureDetector(
                        onTap: _openingDrawer
                            ? () {
                                if (widget.dismissible) {
                                  closeDrawer();
                                }
                              }
                            : null,
                        behavior: HitTestBehavior.opaque,
                        child: IgnorePointer(
                          ignoring: _openingDrawer,
                          child: wrapped ?? child!,
                        ),
                      );
                    },
                    child: widget.body,
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
    _controller?.dispose();
  }
}
