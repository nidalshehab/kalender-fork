import 'dart:math';

import 'package:flutter/material.dart';
import 'package:kalender/kalender.dart';
import 'package:kalender/src/extensions.dart';
import 'package:kalender/src/models/controllers/view_controller.dart';
import 'package:kalender/src/models/providers/calendar_provider.dart';
import 'package:kalender/src/models/providers/day_provider.dart';
import 'package:kalender/src/widgets/components/day_separator.dart';
import 'package:kalender/src/widgets/components/hour_lines.dart';
import 'package:kalender/src/widgets/components/time_indicator.dart';
import 'package:kalender/src/widgets/components/time_line.dart';
import 'package:kalender/src/widgets/drag_targets/day_drag_target.dart';
import 'package:kalender/src/widgets/events_widgets/day_events_widget.dart';
import 'package:kalender/src/widgets/gesture_detectors/day_gesture_detector.dart';

/// This widget is used to display a multi-day body.
class MonthBody<T extends Object?> extends StatelessWidget {
  /// The [EventsController] that will be used by the [MonthBody].
  final EventsController<T>? eventsController;

  /// The [CalendarController] that will be used by the [MonthBody].
  final CalendarController<T>? calendarController;

  /// The [MultiDayBodyConfiguration] that will be used by the [MonthBody].
  final MultiDayBodyConfiguration? configuration;

  /// The callbacks used by the [MonthBody].
  final CalendarCallbacks<T>? callbacks;

  /// The tile components used by the [MonthBody].
  final TileComponents<T> tileComponents;

  /// The components used by the [MonthBody].
  final MultiDayBodyComponents? components;

  /// The styles of the components.
  final MultiDayBodyComponentStyles? componentStyles;

  /// The [ValueNotifier] containing the [heightPerMinute] value.
  final ValueNotifier<double>? heightPerMinute;

  /// The [ScrollController] used by the scrollable body.
  final ScrollController? scrollController;

  /// Creates a new [MonthBody].
  const MonthBody({
    super.key,
    this.eventsController,
    this.calendarController,
    this.callbacks,
    required this.tileComponents,
    this.components,
    this.componentStyles,
    this.scrollController,
    this.heightPerMinute,
    this.configuration,
  });

  @override
  Widget build(BuildContext context) {
    var eventsController = this.eventsController;
    var calendarController = this.calendarController;
    var callbacks = this.callbacks;

    final provider = CalendarProvider.maybeOf<T>(context);
    if (provider == null) {
      assert(
        eventsController != null,
        'The eventsController needs to be provided when the $MonthBody<$T> is not wrapped in a $CalendarProvider<$T>.',
      );
      assert(
        calendarController != null,
        'The calendarController needs to be provided when the $MonthBody<$T> is not wrapped in a $CalendarProvider<$T>.',
      );
    } else {
      eventsController ??= provider.eventsController;
      calendarController ??= provider.calendarController;
      callbacks ??= provider.callbacks;
    }

    assert(
      calendarController!.isAttached,
      'The CalendarController needs to be attached to a $ViewController<$T>.',
    );

    assert(
      calendarController!.viewController is MultiDayViewController<T>,
      'The CalendarController\'s $ViewController<$T> needs to be a $MultiDayViewController<$T>',
    );

    final viewController =
        calendarController!.viewController as MultiDayViewController<T>;
    final viewConfiguration = viewController.viewConfiguration;
    final timeOfDayRange = viewConfiguration.timeOfDayRange;
    final numberOfDays = viewConfiguration.numberOfDays;
    final pageNavigation = viewConfiguration.pageNavigationFunctions;
    final eventBeingDragged = viewController.eventBeingDragged;
    final bodyConfiguration = this.configuration ?? MultiDayBodyConfiguration();

    // Override the height per minute if it is provided.
    if (heightPerMinute != null) {
      viewController.heightPerMinute = heightPerMinute!;
    }

    // Override the scroll controller if it is provided.
    if (scrollController != null) {
      viewController.scrollController = scrollController!;
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate the width of the page.
        final timelineWidth = viewConfiguration.timelineWidth;
        final pageWidth = constraints.maxWidth - timelineWidth;

        // Calculate the width of a single day.
        final dayWidth = pageWidth / numberOfDays;

        final viewPortHeight = constraints.maxHeight;

        return ValueListenableBuilder(
          valueListenable: viewController.heightPerMinute,
          builder: (context, heightPerMinute, child) {
            // Calculate the height of the page.
            final dayDuration = timeOfDayRange.duration;
            final pageHeight = heightPerMinute * dayDuration.inMinutes;

            final hourLinesStyle = componentStyles?.hourLinesStyle;
            final hourLines = components?.hourLines?.call(
                  heightPerMinute,
                  timeOfDayRange,
                  hourLinesStyle,
                ) ??
                HourLines(
                  timeOfDayRange: timeOfDayRange,
                  heightPerMinute: heightPerMinute,
                  style: hourLinesStyle,
                );

            final timelineStyle = componentStyles?.timelineStyle;
            final timeline = components?.timeline?.call(
                  heightPerMinute,
                  timeOfDayRange,
                  timelineStyle,
                ) ??
                TimeLine(
                  timeOfDayRange: timeOfDayRange,
                  heightPerMinute: heightPerMinute,
                  style: timelineStyle,
                  eventBeingDragged: eventBeingDragged,
                );

            final timeIndicatorStyle = componentStyles?.timeIndicatorStyle;
            late final timeIndicator = components?.timeIndicator?.call(
                  timeOfDayRange,
                  heightPerMinute,
                  timelineWidth,
                  timeIndicatorStyle,
                ) ??
                TimeIndicator(
                  timeOfDayRange: timeOfDayRange,
                  heightPerMinute: heightPerMinute,
                  timelineWidth: timelineWidth,
                  style: timeIndicatorStyle,
                );

            final daySeparatorStyle = componentStyles?.daySeparatorStyle;
            final daySeparator =
                components?.daySeparator?.call(daySeparatorStyle) ??
                    DaySeparator(style: daySeparatorStyle);
            final daySeparators = List.generate(
              numberOfDays,
              (index) {
                final left = timelineWidth + (dayWidth * index);
                return Positioned(
                  top: 0,
                  bottom: 0,
                  left: left,
                  child: daySeparator,
                );
              },
            );

            final pageView = PageView.builder(
              key: ValueKey(viewConfiguration.name),
              controller: viewController.pageController,
              itemCount: viewController.numberOfPages,
              physics: configuration?.pageScrollPhysics,
              onPageChanged: (index) {
                final visibleRange = pageNavigation.dateTimeRangeFromIndex(
                  index,
                );
                viewController.visibleDateTimeRange.value = visibleRange;
              },
              itemBuilder: (context, index) {
                final visibleRange = pageNavigation.dateTimeRangeFromIndex(
                  index,
                );

                final visibleDates = visibleRange.datesSpanned;
                final timeIndicatorDateIndex = visibleDates.indexWhere(
                  (date) => date.isToday,
                );
                late final left = dayWidth * timeIndicatorDateIndex;

                final events = DayEventsWidget<T>(
                  visibleDateTimeRange: visibleRange,
                );

                final detector = DayGestureDetector<T>(
                  visibleDateTimeRange: visibleRange,
                );

                return Stack(
                  fit: StackFit.passthrough,
                  children: [
                    ...daySeparators,
                    Positioned.fill(left: timelineWidth, child: detector),
                    Positioned.fill(left: timelineWidth, child: events),
                    if (timeIndicatorDateIndex != -1)
                      Positioned(
                        top: 0,
                        bottom: 0,
                        left: left,
                        width: dayWidth + timelineWidth,
                        child: timeIndicator,
                      ),
                  ],
                );
              },
            );

            const dragTarget = DayDragTarget();

            return DayProvider(
              eventsController: eventsController!,
              viewController: viewController,
              feedbackWidgetSize: eventsController.feedbackWidgetSize,
              viewportHeight: viewPortHeight,
              pageWidth: pageWidth,
              dayWidth: dayWidth,
              components: components,
              componentStyles: componentStyles,
              callbacks: callbacks,
              tileComponents: tileComponents,
              bodyConfiguration: bodyConfiguration,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Scrollbar(
                      controller: viewController.scrollController,
                      child: SingleChildScrollView(
                        controller: viewController.scrollController,
                        physics: configuration?.scrollPhysics,
                        child: SizedBox(
                          height: pageHeight,
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              Positioned(
                                left: 0,
                                top: 0,
                                bottom: 0,
                                width: 56.0,
                                child: timeline,
                              ),
                              Positioned.fill(child: hourLines),
                              Positioned.fill(child: pageView),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 0,
                    right: 0,
                    left: timelineWidth,
                    height: min(pageHeight, viewPortHeight),
                    child: dragTarget,
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}