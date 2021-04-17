// /*
//  * This widget modifies [CupertinoScrollbar] a little,
//  * so that the horizontal and vertical scroll controllers work together.
// */

// // All values eyeballed.
// import 'dart:async';

// import 'package:flutter/cupertino.dart';
// import 'package:flutter/gestures.dart';
// import 'package:flutter/services.dart';

// const double _kScrollbarMinLength = 36.0;
// const double _kScrollbarMinOverscrollLength = 8.0;
// const Duration _kScrollbarTimeToFade = Duration(milliseconds: 1200);
// const Duration _kScrollbarFadeDuration = Duration(milliseconds: 250);
// const Duration _kScrollbarResizeDuration = Duration(milliseconds: 100);

// // Extracted from iOS 13.1 beta using Debug View Hierarchy.
// const Color _kScrollbarColor = CupertinoDynamicColor.withBrightness(
//   color: Color(0xff03C7C3),
//   darkColor: Color(0x80FFFFFF),
// );

// // This is the amount of space from the top of a vertical scrollbar to the
// // top edge of the scrollable, measured when the vertical scrollbar overscrolls
// // to the top.
// // TODO(LongCatIsLooong): fix https://github.com/flutter/flutter/issues/32175
// const double _kScrollbarMainAxisMargin = 3.0;
// const double _kScrollbarCrossAxisMargin = 3.0;

// class PlutoScrollbar extends StatefulWidget {
//   const PlutoScrollbar({
//     Key key,
//     this.horizontalController,
//     this.verticalController,
//     this.isAlwaysShown = false,
//     this.thickness = defaultThickness,
//     this.thicknessWhileDragging = defaultThicknessWhileDragging,
//     this.radius = defaultRadius,
//     this.radiusWhileDragging = defaultRadiusWhileDragging,
//     @required this.child,
//   })  : assert(thickness != null),
//         assert(thickness < double.infinity),
//         assert(thicknessWhileDragging != null),
//         assert(thicknessWhileDragging < double.infinity),
//         assert(radius != null),
//         assert(radiusWhileDragging != null),
//         assert(!isAlwaysShown ||
//             (horizontalController != null || verticalController != null)),
//         super(key: key);

//   static const double defaultThickness = 3;

//   static const double defaultThicknessWhileDragging = 8.0;

//   static const Radius defaultRadius = Radius.circular(1.5);

//   static const Radius defaultRadiusWhileDragging = Radius.circular(4.0);

//   final Widget child;

//   final ScrollController horizontalController;

//   final ScrollController verticalController;

//   final bool isAlwaysShown;

//   final double thickness;

//   final double thicknessWhileDragging;

//   final Radius radius;

//   final Radius radiusWhileDragging;

//   @override
//   _CupertinoScrollbarState createState() => _CupertinoScrollbarState();
// }

// class _CupertinoScrollbarState extends State<PlutoScrollbar>
//     with TickerProviderStateMixin {
//   final GlobalKey _customPaintKey = GlobalKey();
//   ScrollbarPainter _painter;

//   AnimationController _fadeoutAnimationController;
//   Animation<double> _fadeoutOpacityAnimation;
//   AnimationController _thicknessAnimationController;
//   Timer _fadeoutTimer;
//   double _dragScrollbarAxisPosition;
//   Drag _drag;

//   double get _thickness {
//     return widget.thickness +
//         _thicknessAnimationController.value *
//             (widget.thicknessWhileDragging - widget.thickness);
//   }

//   Radius get _radius {
//     return Radius.lerp(widget.radius, widget.radiusWhileDragging,
//         _thicknessAnimationController.value);
//   }

//   ScrollController _currentController;

//   ScrollController get _controller {
//     if (_currentAxis == null) {
//       return widget.verticalController ??
//           widget.horizontalController ??
//           PrimaryScrollController.of(context);
//     }

//     return _currentAxis == Axis.vertical
//         ? widget.verticalController
//         : widget.horizontalController;
//   }

//   Axis _currentAxis;

//   @override
//   void initState() {
//     super.initState();
//     _fadeoutAnimationController = AnimationController(
//       vsync: this,
//       duration: _kScrollbarFadeDuration,
//     );
//     _fadeoutOpacityAnimation = CurvedAnimation(
//       parent: _fadeoutAnimationController,
//       curve: Curves.fastOutSlowIn,
//     );
//     _thicknessAnimationController = AnimationController(
//       vsync: this,
//       duration: _kScrollbarResizeDuration,
//     );
//     _thicknessAnimationController.addListener(() {
//       _painter.updateThickness(_thickness, _radius);
//     });
//   }

//   @override
//   void didChangeDependencies() {
//     super.didChangeDependencies();
//     if (_painter == null) {
//       _painter = _buildCupertinoScrollbarPainter(context);
//     } else {
//       _painter
//         ..textDirection = Directionality.of(context)
//         ..color = CupertinoDynamicColor.resolve(_kScrollbarColor, context)
//         ..padding = MediaQuery.of(context).padding;
//     }
//     _triggerScrollbar();
//   }

//   @override
//   void didUpdateWidget(PlutoScrollbar oldWidget) {
//     super.didUpdateWidget(oldWidget);
//     assert(_painter != null);
//     _painter.updateThickness(_thickness, _radius);
//     if (widget.isAlwaysShown != oldWidget.isAlwaysShown) {
//       if (widget.isAlwaysShown == true) {
//         _triggerScrollbar();
//         _fadeoutAnimationController.animateTo(1.0);
//       } else {
//         _fadeoutAnimationController.reverse();
//       }
//     }
//   }

//   /// Returns a [ScrollbarPainter] visually styled like the iOS scrollbar.
//   ScrollbarPainter _buildCupertinoScrollbarPainter(BuildContext context) {
//     return ScrollbarPainter(
//       color: CupertinoDynamicColor.resolve(_kScrollbarColor, context),
//       textDirection: Directionality.of(context),
//       thickness: _thickness,
//       fadeoutOpacityAnimation: _fadeoutOpacityAnimation,
//       mainAxisMargin: _kScrollbarMainAxisMargin,
//       crossAxisMargin: _kScrollbarCrossAxisMargin,
//       radius: _radius,
//       padding: MediaQuery.of(context).padding,
//       minLength: _kScrollbarMinLength,
//       minOverscrollLength: _kScrollbarMinOverscrollLength,
//     );
//   }

//   // Wait one frame and cause an empty scroll event.  This allows the thumb to
//   // show immediately when isAlwaysShown is true.  A scroll event is required in
//   // order to paint the thumb.
//   void _triggerScrollbar() {
//     WidgetsBinding.instance.addPostFrameCallback((Duration duration) {
//       if (widget.isAlwaysShown) {
//         _fadeoutTimer?.cancel();
//         if (widget.verticalController.hasClients) {
//           widget.verticalController.position.didUpdateScrollPositionBy(0);
//         }
//       }
//     });
//   }

//   // Handle a gesture that drags the scrollbar by the given amount.
//   void _dragScrollbar(double primaryDelta) {
//     assert(_currentController != null);

//     // Convert primaryDelta, the amount that the scrollbar moved since the last
//     // time _dragScrollbar was called, into the coordinate space of the scroll
//     // position, and create/update the drag event with that position.
//     final double scrollOffsetLocal = _painter.getTrackToScroll(primaryDelta);
//     final double scrollOffsetGlobal =
//         scrollOffsetLocal + _currentController.position.pixels;
//     final Axis direction = _currentController.position.axis;

//     if (_drag == null) {
//       _drag = _currentController.position.drag(
//         DragStartDetails(
//           globalPosition: direction == Axis.vertical
//               ? Offset(0.0, scrollOffsetGlobal)
//               : Offset(scrollOffsetGlobal, 0.0),
//         ),
//         () {},
//       );
//     } else {
//       _drag.update(DragUpdateDetails(
//         globalPosition: direction == Axis.vertical
//             ? Offset(0.0, scrollOffsetGlobal)
//             : Offset(scrollOffsetGlobal, 0.0),
//         delta: direction == Axis.vertical
//             ? Offset(0.0, -scrollOffsetLocal)
//             : Offset(-scrollOffsetLocal, 0.0),
//         primaryDelta: -scrollOffsetLocal,
//       ));
//     }
//   }

//   void _startFadeoutTimer() {
//     if (!widget.isAlwaysShown) {
//       _fadeoutTimer?.cancel();
//       _fadeoutTimer = Timer(_kScrollbarTimeToFade, () {
//         _fadeoutAnimationController.reverse();
//         _fadeoutTimer = null;
//       });
//     }
//   }

//   Axis _getDirection() {
//     try {
//       return _currentController.position.axis;
//     } catch (_) {
//       // Ignore the gesture if we cannot determine the direction.
//       return null;
//     }
//   }

//   double _pressStartAxisPosition = 0.0;

//   // Long press event callbacks handle the gesture where the user long presses
//   // on the scrollbar thumb and then drags the scrollbar without releasing.
//   void _handleLongPressStart(LongPressStartDetails details) {
//     _currentController = _controller;
//     final Axis direction = _getDirection();
//     if (direction == null) {
//       return;
//     }
//     _fadeoutTimer?.cancel();
//     _fadeoutAnimationController.forward();
//     switch (direction) {
//       case Axis.vertical:
//         _pressStartAxisPosition = details.localPosition.dy;
//         _dragScrollbar(details.localPosition.dy);
//         _dragScrollbarAxisPosition = details.localPosition.dy;
//         break;
//       case Axis.horizontal:
//         _pressStartAxisPosition = details.localPosition.dx;
//         _dragScrollbar(details.localPosition.dx);
//         _dragScrollbarAxisPosition = details.localPosition.dx;
//         break;
//     }
//   }

//   void _handleLongPress() {
//     if (_getDirection() == null) {
//       return;
//     }
//     _fadeoutTimer?.cancel();
//     _thicknessAnimationController.forward().then<void>(
//           (_) => HapticFeedback.mediumImpact(),
//         );
//   }

//   void _handleLongPressMoveUpdate(LongPressMoveUpdateDetails details) {
//     final Axis direction = _getDirection();
//     if (direction == null) {
//       return;
//     }
//     switch (direction) {
//       case Axis.vertical:
//         _dragScrollbar(details.localPosition.dy - _dragScrollbarAxisPosition);
//         _dragScrollbarAxisPosition = details.localPosition.dy;
//         break;
//       case Axis.horizontal:
//         _dragScrollbar(details.localPosition.dx - _dragScrollbarAxisPosition);
//         _dragScrollbarAxisPosition = details.localPosition.dx;
//         break;
//     }
//   }

//   void _handleLongPressEnd(LongPressEndDetails details) {
//     final Axis direction = _getDirection();
//     if (direction == null) {
//       return;
//     }
//     switch (direction) {
//       case Axis.vertical:
//         _handleDragScrollEnd(details.velocity.pixelsPerSecond.dy, direction);
//         if (details.velocity.pixelsPerSecond.dy.abs() < 10 &&
//             (details.localPosition.dy - _pressStartAxisPosition).abs() > 0) {
//           HapticFeedback.mediumImpact();
//         }
//         break;
//       case Axis.horizontal:
//         _handleDragScrollEnd(details.velocity.pixelsPerSecond.dx, direction);
//         if (details.velocity.pixelsPerSecond.dx.abs() < 10 &&
//             (details.localPosition.dx - _pressStartAxisPosition).abs() > 0) {
//           HapticFeedback.mediumImpact();
//         }
//         break;
//     }
//     _currentController = null;
//   }

//   void _handleDragScrollEnd(double trackVelocity, Axis direction) {
//     _startFadeoutTimer();
//     _thicknessAnimationController.reverse();
//     _dragScrollbarAxisPosition = null;
//     final double scrollVelocity = _painter.getTrackToScroll(trackVelocity);
//     _drag?.end(DragEndDetails(
//       primaryVelocity: -scrollVelocity,
//       velocity: Velocity(
//         pixelsPerSecond: direction == Axis.vertical
//             ? Offset(0.0, -scrollVelocity)
//             : Offset(-scrollVelocity, 0.0),
//       ),
//     ));
//     _drag = null;
//   }

//   bool _handleScrollNotification(ScrollNotification notification) {
//     final ScrollMetrics metrics = notification.metrics;
//     if (metrics.maxScrollExtent <= metrics.minScrollExtent) {
//       return false;
//     }

//     _currentAxis = axisDirectionToAxis(metrics.axisDirection);

//     if (notification is ScrollUpdateNotification ||
//         notification is UserScrollNotification ||
//         notification is OverscrollNotification) {
//       // Any movements always makes the scrollbar start showing up.
//       if (_fadeoutAnimationController.status != AnimationStatus.forward) {
//         _fadeoutAnimationController.forward();
//       }

//       _fadeoutTimer?.cancel();
//       _painter.update(metrics, metrics.axisDirection);
//     } else if (notification is ScrollEndNotification) {
//       // On iOS, the scrollbar can only go away once the user lifted the finger.
//       if (_dragScrollbarAxisPosition == null) {
//         _startFadeoutTimer();
//       }
//     }
//     return false;
//   }

//   // Get the GestureRecognizerFactories used to detect gestures on the scrollbar
//   // thumb.
//   Map<Type, GestureRecognizerFactory> get _gestures {
//     final Map<Type, GestureRecognizerFactory> gestures =
//         <Type, GestureRecognizerFactory>{};

//     gestures[_ThumbPressGestureRecognizer] =
//         GestureRecognizerFactoryWithHandlers<_ThumbPressGestureRecognizer>(
//       () => _ThumbPressGestureRecognizer(
//         debugOwner: this,
//         customPaintKey: _customPaintKey,
//       ),
//       (_ThumbPressGestureRecognizer instance) {
//         instance
//           ..onLongPressStart = _handleLongPressStart
//           ..onLongPress = _handleLongPress
//           ..onLongPressMoveUpdate = _handleLongPressMoveUpdate
//           ..onLongPressEnd = _handleLongPressEnd;
//       },
//     );

//     return gestures;
//   }

//   @override
//   void dispose() {
//     _fadeoutAnimationController.dispose();
//     _thicknessAnimationController.dispose();
//     _fadeoutTimer?.cancel();
//     _painter.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return NotificationListener<ScrollNotification>(
//       onNotification: _handleScrollNotification,
//       child: RepaintBoundary(
//         child: RawGestureDetector(
//           gestures: _gestures,
//           child: CustomPaint(
//             key: _customPaintKey,
//             foregroundPainter: _painter,
//             child: RepaintBoundary(child: widget.child),
//           ),
//         ),
//       ),
//     );
//   }
// }

// // A longpress gesture detector that only responds to events on the scrollbar's
// // thumb and ignores everything else.
// class _ThumbPressGestureRecognizer extends LongPressGestureRecognizer {
//   _ThumbPressGestureRecognizer({
//     double postAcceptSlopTolerance,
//     PointerDeviceKind kind,
//     @required Object debugOwner,
//     @required GlobalKey customPaintKey,
//   })  : _customPaintKey = customPaintKey,
//         super(
//           postAcceptSlopTolerance: postAcceptSlopTolerance,
//           kind: kind,
//           debugOwner: debugOwner,
//           duration: const Duration(milliseconds: 100),
//         );

//   final GlobalKey _customPaintKey;

//   @override
//   bool isPointerAllowed(PointerDownEvent event) {
//     if (!_hitTestInteractive(_customPaintKey, event.position)) {
//       return false;
//     }
//     return super.isPointerAllowed(event);
//   }
// }

// // foregroundPainter also hit tests its children by default, but the
// // scrollbar should only respond to a gesture directly on its thumb, so
// // manually check for a hit on the thumb here.
// bool _hitTestInteractive(GlobalKey customPaintKey, Offset offset) {
//   if (customPaintKey.currentContext == null) {
//     return false;
//   }
//   final CustomPaint customPaint =
//       customPaintKey.currentContext.widget as CustomPaint;
//   final ScrollbarPainter painter =
//       customPaint.foregroundPainter as ScrollbarPainter;
//   final RenderBox renderBox =
//       customPaintKey.currentContext.findRenderObject() as RenderBox;
//   final Offset localOffset = renderBox.globalToLocal(offset);
//   return painter.hitTestInteractive(localOffset);
// }

// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';

import 'package:flutter/material.dart';

const double _kScrollbarThickness = 8.0;
const double _kScrollbarThicknessWithTrack = 12.0;
const double _kScrollbarMargin = 2.0;
const double _kScrollbarMinLength = 48.0;
const Radius _kScrollbarRadius = Radius.circular(8.0);
const Duration _kScrollbarFadeDuration = Duration(milliseconds: 300);
const Duration _kScrollbarTimeToFade = Duration(milliseconds: 600);

/// A Material Design scrollbar.
///
/// To add a scrollbar to a [ScrollView], wrap the scroll view
/// widget in a [Scrollbar] widget.
///
/// {@macro flutter.widgets.Scrollbar}
///
/// Dynamically changes to an iOS style scrollbar that looks like
/// [CupertinoScrollbar] on the iOS platform.
///
/// The color of the Scrollbar will change when dragged. A hover animation is
/// also triggered when used on web and desktop platforms. A scrollbar track
/// can also been drawn when triggered by a hover event, which is controlled by
/// [showTrackOnHover]. The thickness of the track and scrollbar thumb will
/// become larger when hovering, unless overridden by [hoverThickness].
///
/// {@tool dartpad --template=stateless_widget_scaffold}
/// This sample shows a [Scrollbar] that executes a fade animation as scrolling occurs.
/// The Scrollbar will fade into view as the user scrolls, and fade out when scrolling stops.
/// ```dart
/// Widget build(BuildContext context) {
///   return Scrollbar(
///     child: GridView.builder(
///       itemCount: 120,
///       gridDelegate:
///         const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
///       itemBuilder: (BuildContext context, int index) {
///         return Center(
///           child: Text('item $index'),
///         );
///       },
///     ),
///   );
/// }
/// ```
/// {@end-tool}
///
/// {@tool dartpad --template=stateful_widget_scaffold}
/// When isAlwaysShown is true, the scrollbar thumb will remain visible without the
/// fade animation. This requires that a ScrollController is provided to controller,
/// or that the PrimaryScrollController is available.
/// ```dart
/// final ScrollController _controllerOne = ScrollController();
///
/// @override
/// Widget build(BuildContext context) {
///   return Scrollbar(
///     controller: _controllerOne,
///     isAlwaysShown: true,
///     child: GridView.builder(
///       controller: _controllerOne,
///       itemCount: 120,
///       gridDelegate:
///         const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
///       itemBuilder: (BuildContext context, int index) {
///         return Center(
///           child: Text('item $index'),
///         );
///       },
///     ),
///   );
/// }
/// ```
/// {@end-tool}
///
/// See also:
///
///  * [RawScrollbar], a basic scrollbar that fades in and out, extended
///    by this class to add more animations and behaviors.
///  * [ScrollbarTheme], which configures the Scrollbar's appearance.
///  * [CupertinoScrollbar], an iOS style scrollbar.
///  * [ListView], which displays a linear, scrollable list of children.
///  * [GridView], which displays a 2 dimensional, scrollable array of children.
class Scrollbar extends StatefulWidget {
  /// Creates a material design scrollbar that by default will connect to the
  /// closest Scrollable descendant of [child].
  ///
  /// The [child] should be a source of [ScrollNotification] notifications,
  /// typically a [Scrollable] widget.
  ///
  /// If the [controller] is null, the default behavior is to
  /// enable scrollbar dragging using the [PrimaryScrollController].
  ///
  /// When null, [thickness] defaults to 8.0 pixels on desktop and web, and 4.0
  /// pixels when on mobile platforms. A null [radius] will result in a default
  /// of an 8.0 pixel circular radius about the corners of the scrollbar thumb,
  /// except for when executing on [TargetPlatform.android], which will render the
  /// thumb without a radius.
  const Scrollbar({
    Key key,
    @required this.child,
    this.controller,
    this.isAlwaysShown,
    this.showTrackOnHover,
    this.hoverThickness,
    this.thickness,
    this.radius,
    this.notificationPredicate,
    this.interactive,
  }) : super(key: key);

  /// {@macro flutter.widgets.Scrollbar.child}
  final Widget child;

  /// {@macro flutter.widgets.Scrollbar.controller}
  final ScrollController controller;

  /// {@macro flutter.widgets.Scrollbar.isAlwaysShown}
  final bool isAlwaysShown;

  /// Controls if the track will show on hover and remain, including during drag.
  ///
  /// If this property is null, then [ScrollbarThemeData.showTrackOnHover] of
  /// [ThemeData.scrollbarTheme] is used. If that is also null, the default value
  /// is false.
  final bool showTrackOnHover;

  /// The thickness of the scrollbar when a hover state is active and
  /// [showTrackOnHover] is true.
  ///
  /// If this property is null, then [ScrollbarThemeData.thickness] of
  /// [ThemeData.scrollbarTheme] is used to resolve a thickness. If that is also
  /// null, the default value is 12.0 pixels.
  final double hoverThickness;

  /// The thickness of the scrollbar in the cross axis of the scrollable.
  ///
  /// If null, the default value is platform dependent. On [TargetPlatform.android],
  /// the default thickness is 4.0 pixels. On [TargetPlatform.iOS],
  /// [CupertinoScrollbar.defaultThickness] is used. The remaining platforms have a
  /// default thickness of 8.0 pixels.
  final double thickness;

  /// The [Radius] of the scrollbar thumb's rounded rectangle corners.
  ///
  /// If null, the default value is platform dependent. On [TargetPlatform.android],
  /// no radius is applied to the scrollbar thumb. On [TargetPlatform.iOS],
  /// [CupertinoScrollbar.defaultRadius] is used. The remaining platforms have a
  /// default [Radius.circular] of 8.0 pixels.
  final Radius radius;

  /// {@macro flutter.widgets.Scrollbar.interactive}
  final bool interactive;

  /// {@macro flutter.widgets.Scrollbar.notificationPredicate}
  final ScrollNotificationPredicate notificationPredicate;

  @override
  _ScrollbarState createState() => _ScrollbarState();
}

class _ScrollbarState extends State<Scrollbar> {
  bool get _useCupertinoScrollbar =>
      Theme.of(context).platform == TargetPlatform.iOS;

  @override
  Widget build(BuildContext context) {
    if (_useCupertinoScrollbar) {
      return CupertinoScrollbar(
        child: widget.child,
        isAlwaysShown: widget.isAlwaysShown ?? false,
        thickness: widget.thickness ?? CupertinoScrollbar.defaultThickness,
        thicknessWhileDragging: widget.thickness ??
            CupertinoScrollbar.defaultThicknessWhileDragging,
        radius: widget.radius ?? CupertinoScrollbar.defaultRadius,
        radiusWhileDragging:
            widget.radius ?? CupertinoScrollbar.defaultRadiusWhileDragging,
        controller: widget.controller,
        notificationPredicate: widget.notificationPredicate,
      );
    }
    return _MaterialScrollbar(
      child: widget.child,
      controller: widget.controller,
      isAlwaysShown: widget.isAlwaysShown,
      showTrackOnHover: widget.showTrackOnHover,
      hoverThickness: widget.hoverThickness,
      thickness: widget.thickness,
      radius: widget.radius,
      notificationPredicate: widget.notificationPredicate,
      interactive: widget.interactive,
    );
  }
}

class _MaterialScrollbar extends RawScrollbar {
  const _MaterialScrollbar({
    Key key,
    @required Widget child,
    ScrollController controller,
    bool isAlwaysShown,
    this.showTrackOnHover,
    this.hoverThickness,
    double thickness,
    Radius radius,
    ScrollNotificationPredicate notificationPredicate,
    bool interactive,
  }) : super(
          key: key,
          child: child,
          controller: controller,
          isAlwaysShown: isAlwaysShown,
          thickness: thickness,
          radius: radius,
          fadeDuration: _kScrollbarFadeDuration,
          timeToFade: _kScrollbarTimeToFade,
          pressDuration: Duration.zero,
          notificationPredicate:
              notificationPredicate ?? defaultScrollNotificationPredicate,
          interactive: interactive,
        );

  final bool showTrackOnHover;
  final double hoverThickness;

  @override
  _MaterialScrollbarState createState() => _MaterialScrollbarState();
}

class _MaterialScrollbarState extends RawScrollbarState<_MaterialScrollbar> {
  late AnimationController _hoverAnimationController;
  bool _dragIsActive = false;
  bool _hoverIsActive = false;
  late ColorScheme _colorScheme;
  late ScrollbarThemeData _scrollbarTheme;
  // On Android, scrollbars should match native appearance.
  late bool _useAndroidScrollbar;

  @override
  bool get showScrollbar =>
      widget.isAlwaysShown ?? _scrollbarTheme.isAlwaysShown ?? false;

  @override
  bool get enableGestures =>
      widget.interactive ??
      _scrollbarTheme.interactive ??
      !_useAndroidScrollbar;

  bool get _showTrackOnHover =>
      widget.showTrackOnHover ?? _scrollbarTheme.showTrackOnHover ?? false;

  Set<MaterialState> get _states => <MaterialState>{
        if (_dragIsActive) MaterialState.dragged,
        if (_hoverIsActive) MaterialState.hovered,
      };

  MaterialStateProperty<Color> get _thumbColor {
    final Color onSurface = _colorScheme.onSurface;
    final Brightness brightness = _colorScheme.brightness;
    late Color dragColor;
    late Color hoverColor;
    late Color idleColor;
    switch (brightness) {
      case Brightness.light:
        dragColor = onSurface.withOpacity(0.6);
        hoverColor = onSurface.withOpacity(0.5);
        idleColor = _useAndroidScrollbar
            ? Theme.of(context).highlightColor.withOpacity(1.0)
            : onSurface.withOpacity(0.1);
        break;
      case Brightness.dark:
        dragColor = onSurface.withOpacity(0.75);
        hoverColor = onSurface.withOpacity(0.65);
        idleColor = _useAndroidScrollbar
            ? Theme.of(context).highlightColor.withOpacity(1.0)
            : onSurface.withOpacity(0.3);
        break;
    }

    return MaterialStateProperty.resolveWith((Set<MaterialState> states) {
      if (states.contains(MaterialState.dragged))
        return _scrollbarTheme.thumbColor.resolve(states) ?? dragColor;

      // If the track is visible, the thumb color hover animation is ignored and
      // changes immediately.
      if (states.contains(MaterialState.hovered) && _showTrackOnHover)
        return _scrollbarTheme.thumbColor.resolve(states) ?? hoverColor;

      return Color.lerp(
        _scrollbarTheme.thumbColor.resolve(states) ?? idleColor,
        _scrollbarTheme.thumbColor.resolve(states) ?? hoverColor,
        _hoverAnimationController.value,
      )!;
    });
  }

  MaterialStateProperty<Color> get _trackColor {
    final Color onSurface = _colorScheme.onSurface;
    final Brightness brightness = _colorScheme.brightness;
    return MaterialStateProperty.resolveWith((Set<MaterialState> states) {
      if (states.contains(MaterialState.hovered) && _showTrackOnHover) {
        return _scrollbarTheme.trackColor.resolve(states) ??
            (brightness == Brightness.light
                ? onSurface.withOpacity(0.03)
                : onSurface.withOpacity(0.05));
      }
      return const Color(0x00000000);
    });
  }

  MaterialStateProperty<Color> get _trackBorderColor {
    final Color onSurface = _colorScheme.onSurface;
    final Brightness brightness = _colorScheme.brightness;
    return MaterialStateProperty.resolveWith((Set<MaterialState> states) {
      if (states.contains(MaterialState.hovered) && _showTrackOnHover) {
        return _scrollbarTheme.trackBorderColor.resolve(states) ??
            (brightness == Brightness.light
                ? onSurface.withOpacity(0.1)
                : onSurface.withOpacity(0.25));
      }
      return const Color(0x00000000);
    });
  }

  MaterialStateProperty<double> get _thickness {
    return MaterialStateProperty.resolveWith((Set<MaterialState> states) {
      if (states.contains(MaterialState.hovered) && _showTrackOnHover)
        return widget.hoverThickness ??
            _scrollbarTheme.thickness.resolve(states) ??
            _kScrollbarThicknessWithTrack;
      // The default scrollbar thickness is smaller on mobile.
      return widget.thickness ??
          _scrollbarTheme.thickness.resolve(states) ??
          (_kScrollbarThickness / (_useAndroidScrollbar ? 2 : 1));
    });
  }

  @override
  void initState() {
    super.initState();
    _hoverAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _hoverAnimationController.addListener(() {
      updateScrollbarPainter();
    });
  }

  @override
  void didChangeDependencies() {
    final ThemeData theme = Theme.of(context);
    _colorScheme = theme.colorScheme;
    _scrollbarTheme = theme.scrollbarTheme;
    switch (theme.platform) {
      case TargetPlatform.android:
        _useAndroidScrollbar = true;
        break;
      case TargetPlatform.iOS:
      case TargetPlatform.linux:
      case TargetPlatform.fuchsia:
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
        _useAndroidScrollbar = false;
        break;
    }
    super.didChangeDependencies();
  }

  @override
  void updateScrollbarPainter() {
    scrollbarPainter
      ..color = _thumbColor.resolve(_states)
      ..trackColor = _trackColor.resolve(_states)
      ..trackBorderColor = _trackBorderColor.resolve(_states)
      ..textDirection = Directionality.of(context)
      ..thickness = _thickness.resolve(_states)
      ..radius = widget.radius ??
          _scrollbarTheme.radius ??
          (_useAndroidScrollbar ? null : _kScrollbarRadius)
      ..crossAxisMargin = _scrollbarTheme.crossAxisMargin ??
          (_useAndroidScrollbar ? 0.0 : _kScrollbarMargin)
      ..mainAxisMargin = _scrollbarTheme.mainAxisMargin ?? 0.0
      ..minLength = _scrollbarTheme.minThumbLength ?? _kScrollbarMinLength
      ..padding = MediaQuery.of(context).padding;
  }

  @override
  void handleThumbPressStart(Offset localPosition) {
    super.handleThumbPressStart(localPosition);
    setState(() {
      _dragIsActive = true;
    });
  }

  @override
  void handleThumbPressEnd(Offset localPosition, Velocity velocity) {
    super.handleThumbPressEnd(localPosition, velocity);
    setState(() {
      _dragIsActive = false;
    });
  }

  @override
  void handleHover(PointerHoverEvent event) {
    super.handleHover(event);
    // Check if the position of the pointer falls over the painted scrollbar
    if (isPointerOverScrollbar(event.position, event.kind)) {
      // Pointer is hovering over the scrollbar
      setState(() {
        _hoverIsActive = true;
      });
      _hoverAnimationController.forward();
    } else if (_hoverIsActive) {
      // Pointer was, but is no longer over painted scrollbar.
      setState(() {
        _hoverIsActive = false;
      });
      _hoverAnimationController.reverse();
    }
  }

  @override
  void handleHoverExit(PointerExitEvent event) {
    super.handleHoverExit(event);
    setState(() {
      _hoverIsActive = false;
    });
    _hoverAnimationController.reverse();
  }

  @override
  void dispose() {
    _hoverAnimationController.dispose();
    super.dispose();
  }
}
