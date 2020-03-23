import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

const _defaultDrawerFraction = .78;
const _defaultDuration = Duration(milliseconds: 100);

class ScrollableDrawerScaffold extends StatefulWidget {
  const ScrollableDrawerScaffold({
    @required this.body,
    @required this.drawer,
    this.duration = _defaultDuration,
    this.drawerFraction = _defaultDrawerFraction,
    Key key,
  })  : assert(body != null),
        assert(drawer != null),
        assert(duration != null),
        assert(
          drawerFraction != null &&
              (0.0 < drawerFraction && drawerFraction <= 1.0),
        ),
        super(key: key);

  final Widget body;
  final Widget drawer;
  final Duration duration;
  final double drawerFraction;

  static ScrollableDrawerScaffoldState of(
    BuildContext context, {
    bool nullOk = false,
  }) {
    assert(nullOk != null);
    assert(context != null);
    final result =
        context.findAncestorStateOfType<ScrollableDrawerScaffoldState>();
    if (nullOk || result != null) {
      return result;
    }
    throw FlutterError.fromParts(
      <DiagnosticsNode>[
        ErrorSummary(
          'ScrollableDrawerScaffold.of() called with a context '
          'that does not contain a ScrollableDrawerScaffold.',
        ),
        context.describeElement('The context used was')
      ],
    );
  }

  @override
  ScrollableDrawerScaffoldState createState() =>
      ScrollableDrawerScaffoldState();
}

class ScrollableDrawerScaffoldState extends State<ScrollableDrawerScaffold> {
  double initialOffset;
  ScrollController controller;

  void openDrawer() {
    controller.animateTo(
      initialOffset,
      duration: widget.duration,
      curve: Curves.linearToEaseOut,
    );
  }

  void closeDrawer() {
    controller.animateTo(
      initialOffset,
      duration: widget.duration,
      curve: Curves.linearToEaseOut,
    );
  }

  @override
  void didChangeDependencies() {
    initialOffset ??= _getMediaQueryData().size.width * widget.drawerFraction;
    controller ??= ScrollController(initialScrollOffset: initialOffset);
    super.didChangeDependencies();
  }

  MediaQueryData _getMediaQueryData() {
    final query = context.dependOnInheritedWidgetOfExactType<MediaQuery>();
    if (query != null) {
      return query.data;
    }
    throw FlutterError.fromParts(<DiagnosticsNode>[
      ErrorSummary(
        'ScrollableDrawerScaffoldState mounted with a context that '
        'does not contain a MediaQuery.',
      ),
      ErrorDescription(
        'No MediaQuery ancestor could be found starting from the '
        'ScrollableDrawerScaffoldState#didChangeDependencies process.'
        'This can happen because you do not have a WidgetsApp or '
        'MaterialApp widget (those widgets introduce a MediaQuery), '
        'or it can happen if the context you use comes from a widget '
        'above those widgets.',
      ),
      context.describeElement('The context used was')
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scrollable(
      dragStartBehavior: DragStartBehavior.start,
      axisDirection: AxisDirection.right,
      controller: controller,
      physics: const PageScrollPhysics(parent: ClampingScrollPhysics()),
      viewportBuilder: (BuildContext context, ViewportOffset position) {
        return Viewport(
          cacheExtent: 1,
          cacheExtentStyle: CacheExtentStyle.viewport,
          axisDirection: AxisDirection.right,
          offset: position,
          slivers: <Widget>[
            SliverFillViewport(
              viewportFraction: widget.drawerFraction,
              padEnds: false,
              delegate: SliverChildListDelegate(
                [
                  AnimatedBuilder(
                    animation: controller,
                    builder: (context, child) {
                      return Opacity(
                        opacity: 1 - (controller.offset / initialOffset.ceil()),
                        child: child,
                      );
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
                    animation: controller,
                    builder: (context, child) {
                      return GestureDetector(
                        onTap: controller.offset < initialOffset
                            ? closeDrawer
                            : null,
                        child: AbsorbPointer(
                          absorbing: controller.offset < initialOffset,
                          child: Opacity(
                            opacity: 0.25 +
                                (controller.offset / initialOffset.ceil()) *
                                    0.75,
                            child: child,
                          ),
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
}
