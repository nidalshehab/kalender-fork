import 'dart:math';

import 'package:flutter/material.dart';
import 'package:kalender/src/export.dart';
import 'package:kalender/src/extensions.dart';
import 'package:kalender/src/models/components/_export.dart';
import 'package:kalender/src/models/controllers/view_controller.dart';
import 'package:kalender/src/models/providers/multi_day_provider.dart';
import 'package:kalender/src/widgets/components/navigation_trigger.dart';

class MultiDayDragTarget<T extends Object?> extends StatefulWidget {
  final bool allowSingleDayEvents;

  const MultiDayDragTarget({
    super.key,
    this.allowSingleDayEvents = true,
  });

  @override
  State<MultiDayDragTarget<T>> createState() => _MultiDayDragTargetState<T>();
}

class _MultiDayDragTargetState<T extends Object?>
    extends State<MultiDayDragTarget<T>> {
  MultiDayProvider<T> get provider => MultiDayProvider.of<T>(context);
  EventsController<T> get eventsController => provider.eventsController;
  CalendarCallbacks<T>? get callbacks => provider.callbacks;
  MultiDayViewController<T> get viewController => provider.viewController;
  TileComponents<T> get tileComponents => provider.tileComponents;
  List<DateTime> get visibleDates =>
      provider.visibleDateTimeRangeValue.datesSpanned;
  ValueNotifier<CalendarEvent<T>?> get eventBeingDragged =>
      provider.eventBeingDragged;
  ValueNotifier<Size> get feedbackWidgetSize => provider.feedbackWidgetSize;
  double get dayWidth => provider.dayWidth;
  double get pageWidth => provider.pageWidth;

  /// The position of the widget.
  Offset? widgetPosition;

  /// Calculate the relative cursor position.
  Offset? _calculateRelativeCursorPosition(Offset cursorPosition) {
    if (widgetPosition == null) return null;

    // Calculate the widget offset.
    final feedbackWidgetOffset = Offset(dayWidth / 2, 0);

    // Calculate the position of the cursor relative to the current widget.
    final relativeCursorPosition =
        cursorPosition + feedbackWidgetOffset - widgetPosition!;

    return relativeCursorPosition;
  }

  /// Calculate the date of the cursor.
  DateTime? _calculateCursorDate(Offset cursorPosition) {
    // Calculate the date of the cursor.
    final cursorDate = (cursorPosition.dx / dayWidth);
    final cursorDateIndex = cursorDate.floor();
    if (cursorDateIndex < 0) return null;
    final date = visibleDates.elementAtOrNull(cursorDateIndex);
    return date;
  }

  DateTime _calculateStartTime(DateTime start, DateTime date) {
    return start.copyWith(
      year: date.year,
      month: date.month,
      day: date.day,
    );
  }

  CalendarEvent<T>? _updateEvent(CalendarEvent<T> event, Offset offset) {
    // Calculate the relative cursor position.
    final cursorPosition = _calculateRelativeCursorPosition(offset);
    if (cursorPosition == null) return null;

    // Calculate the date of the cursor.
    final date = _calculateCursorDate(cursorPosition);
    if (date == null) return null;

    // Calculate the new dateTimeRange for the event.
    final newStartTime = _calculateStartTime(
      event.dateTimeRange.start,
      date,
    );
    final duration = event.dateTimeRange.duration;
    final endTime = newStartTime.add(duration);
    final newRange = DateTimeRange(start: newStartTime, end: endTime);

    // Update the event with the new start time.
    final updatedEvent = event.copyWith(dateTimeRange: newRange);

    return updatedEvent;
  }

  @override
  Widget build(BuildContext context) {
    return DragTarget<CalendarEvent<T>>(
      onWillAcceptWithDetails: (details) {
        final event = details.data;

        if (!widget.allowSingleDayEvents && !event.isMultiDayEvent) {
          return false;
        }

        // Find the global position of the drop target widget.
        final renderObject = context.findRenderObject()! as RenderBox;
        final globalPosition = renderObject.localToGlobal(Offset.zero);

        widgetPosition = globalPosition;

        // Set the size of the feedback widget.
        final feedBackWidth = dayWidth * event.datesSpanned.length;
        provider.feedbackWidgetSize.value = Size(
          min(pageWidth, feedBackWidth),
          provider.tileHeight,
        );

        return true;
      },
      onMove: (details) {
        final event = details.data;
        final updatedEvent = _updateEvent(event, details.offset);
        if (updatedEvent == null) return;

        // Update the event being dragged.
        eventBeingDragged.value = updatedEvent;
        viewController.draggingEventId = event.id;
      },
      onAcceptWithDetails: (details) {
        final event = details.data;
        final updatedEvent = _updateEvent(event, details.offset);
        if (updatedEvent == null) return;

        // Update the event in the events controller.
        eventsController.updateEvent(event: event, updatedEvent: updatedEvent);

        widgetPosition = null;
        eventsController.feedbackWidgetSize.value = Size.zero;
        eventBeingDragged.value = null;
        viewController.draggingEventId = null;
      },
      onLeave: (data) {
        widgetPosition = null;
        eventBeingDragged.value = null;
        viewController.draggingEventId = null;
      },
      builder: (context, candidateData, rejectedData) {
        // TODO: implement navigation ?

        // Check if the candidateData is null.
        if (candidateData.firstOrNull == null) return const SizedBox();

        final pageTriggerSetup =
            provider.headerConfiguration.pageTriggerConfiguration;
        final triggerWidth = pageTriggerSetup.triggerWidth.call(pageWidth);
        final pageAnimationDuration = pageTriggerSetup.animationDuration;
        final pageTriggerDelay = pageTriggerSetup.triggerDelay;
        final pageAnimationCurve = pageTriggerSetup.animationCurve;

        final rightTrigger = NavigationTrigger(
          triggerDelay: pageTriggerDelay,
          onTrigger: () {
            viewController.animateToNextPage(
              duration: pageAnimationDuration,
              curve: pageAnimationCurve,
            );
          },
          child: pageTriggerSetup.rightTriggerWidget,
        );

        final leftTrigger = NavigationTrigger(
          triggerDelay: pageTriggerDelay,
          onTrigger: () {
            viewController.animateToPreviousPage(
              duration: pageAnimationDuration,
              curve: pageAnimationCurve,
            );
          },
          child: pageTriggerSetup.leftTriggerWidget,
        );

        return Stack(
          children: [
            Positioned(
              right: 0,
              top: 0,
              bottom: 0,
              width: triggerWidth,
              child: rightTrigger,
            ),
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              width: triggerWidth,
              child: leftTrigger,
            ),
          ],
        );
      },
    );
  }
}