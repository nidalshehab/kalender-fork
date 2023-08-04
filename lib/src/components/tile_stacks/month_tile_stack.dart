import 'package:flutter/material.dart';

import 'package:kalender/src/components/gesture_detectors/month_tile_gesture_detector.dart';
import 'package:kalender/src/components/tile_stacks/chaning_month_tile_stack.dart';
import 'package:kalender/src/enumerations.dart';

import 'package:kalender/src/models/calendar/calendar_event_controller.dart';
import 'package:kalender/src/models/tile_layout_controllers/month_tile_layout_controller.dart';
import 'package:kalender/src/models/tile_layout_controllers/multi_day_tile_layout_controller.dart';
import 'package:kalender/src/providers/calendar_scope.dart';

class PositionedMonthTileStack<T> extends StatelessWidget {
  const PositionedMonthTileStack({
    super.key,
    required this.pageWidth,
    required this.cellWidth,
    required this.cellHeight,
    required this.monthEventLayout,
    required this.visibleDateRange,
    required this.monthVisibleDateRange,
  });

  /// The width of the page.
  final double pageWidth;

  /// The width a single day.
  final double cellWidth;

  final double cellHeight;

  /// The [MultiDayLayoutController]
  final MonthLayoutController<T> monthEventLayout;

  final DateTimeRange visibleDateRange;

  final DateTimeRange monthVisibleDateRange;

  @override
  Widget build(BuildContext context) {
    CalendarScope<T> scope = CalendarScope.of(context);

    return RepaintBoundary(
      child: ListenableBuilder(
        listenable: scope.eventsController,
        builder: (BuildContext context, Widget? child) {
          /// Arrange the events.
          List<PositionedMonthTileData<T>> arragedEvents = monthEventLayout.arrageEvents(
            scope.eventsController.getEventsFromDateRange(visibleDateRange),
            selectedEvent: scope.eventsController.chaningEvent,
          );

          return SizedBox(
            width: pageWidth,
            height: cellWidth,
            child: Stack(
              children: <Widget>[
                // MultiDayGestureDetector<T>(
                //   pageWidth: pageWidth,
                //   height: monthEventLayout.stackHeight,
                //   dayWidth: cellWidth,
                //   multidayEventHeight: monthEventLayout.tileHeight,
                //   numberOfRows: monthEventLayout.numberOfRows,
                //   visibleDates: scope.state.visibleDateTimeRange.value.datesSpanned,
                // ),
                ...arragedEvents.map(
                  (PositionedMonthTileData<T> e) {
                    return MonthTileStack<T>(
                      controller: scope.eventsController,
                      visibleDateRange: scope.state.visibleDateTimeRange.value,
                      monthEventLayout: monthEventLayout,
                      monthVisibleDateRange: monthVisibleDateRange,
                      arragnedEvent: e,
                      horizontalStep: cellWidth,
                      horizontalDurationStep: const Duration(days: 1),
                      verticalStep: cellHeight,
                      verticalDurationStep: const Duration(days: 7),
                    );
                  },
                ).toList(),
                if (scope.eventsController.hasChaningEvent)
                  ChaningMonthTileStack<T>(
                    monthEventLayout: monthEventLayout,
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class MonthTileStack<T> extends StatelessWidget {
  const MonthTileStack({
    super.key,
    required this.controller,
    required this.visibleDateRange,
    required this.monthEventLayout,
    required this.monthVisibleDateRange,
    required this.arragnedEvent,
    required this.horizontalStep,
    required this.horizontalDurationStep,
    required this.verticalStep,
    required this.verticalDurationStep,
  });

  final CalendarEventsController<T> controller;

  final DateTimeRange visibleDateRange;
  final DateTimeRange monthVisibleDateRange;
  final MonthLayoutController<T> monthEventLayout;
  final PositionedMonthTileData<T> arragnedEvent;

  final double horizontalStep;
  final Duration horizontalDurationStep;

  final double verticalStep;
  final Duration verticalDurationStep;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (BuildContext context, Widget? child) {
        bool isMoving = controller.chaningEvent == arragnedEvent.event;
        return Stack(
          children: <Widget>[
            Positioned(
              top: arragnedEvent.top,
              left: arragnedEvent.left,
              width: arragnedEvent.width,
              height: arragnedEvent.height,
              child: MonthTileGestureDetector<T>(
                horizontalDurationStep: horizontalDurationStep,
                event: arragnedEvent.event,
                horizontalStep: horizontalStep,
                verticalDurationStep: verticalDurationStep,
                verticalStep: verticalStep,
                visibleDateRange: monthVisibleDateRange,
                child: CalendarScope.of<T>(context).tileComponents.monthTileBuilder!(
                  arragnedEvent.event,
                  isMoving ? TileType.ghost : TileType.normal,
                  arragnedEvent.dateRange.start,
                  arragnedEvent.continuesBefore,
                  arragnedEvent.continuesAfter,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
