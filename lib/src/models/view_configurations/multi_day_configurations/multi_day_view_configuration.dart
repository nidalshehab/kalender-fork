import 'package:kalender/src/models/calendar/slot_size.dart';
import 'package:kalender/src/models/view_configurations/view_configuration.dart';

/// This is the base class for all [MultiDayViewConfiguration]s.
abstract class MultiDayViewConfiguration extends ViewConfiguration {
  const MultiDayViewConfiguration();

  /// The width of the timeline.
  double get timelineWidth;

  /// The overlap of the hourlines and the timeline.
  double get hourlineTimelineOverlap;

  /// The height of the multiday tiles.
  double get multidayTileHeight;

  /// The vertical step duration.
  Duration get horizontalDurationStep;

  /// The size of the minute slots.
  ///
  /// This determines the initial [DateTimeRange] of a new [CalendarEvent].
  SlotSize get slotSize;

  /// Paint the week number.
  bool get paintWeekNumber;

  /// Enable snapping to events.
  bool get eventSnapping;

  /// Enable snapping to the time indicator.
  bool get timeIndicatorSnapping;

  /// The first day of the week.
  int get firstDayOfWeek;

  /// The duration of the vertical drag step.
  Duration get verticalStepDuration;
}
