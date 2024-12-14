import './../data/event.dart';
import './../main.dart';
import './../widgets/navigation_header.dart';
import './../widgets/tile_components.dart';
import './../widgets/zoom.dart';
import 'package:flutter/material.dart';
import 'package:kalender/kalender.dart';

class CalendarWidget extends StatelessWidget {
  final CalendarController<Event> controller;
  final CalendarCallbacks<Event> callbacks;
  final ValueNotifier<ViewConfiguration> view;
  const CalendarWidget({
    required this.controller,
    required this.callbacks,
    required this.view,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: view,
      builder: (context, value, child) {
        return CalendarView<Event>(
          eventsController: App.eventsController(context),
          calendarController: controller,
          viewConfiguration: value,
          callbacks: callbacks,
          header: Material(
            color: Theme.of(context).colorScheme.surface,
            surfaceTintColor: Theme.of(context).colorScheme.surfaceTint,
            elevation: 2,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                NavigationHeader(controller: controller, view: view),
                CalendarHeader(
                    multiDayTileComponents: multiDayHeaderTileComponents),
              ],
            ),
          ),
          body: CalendarZoomDetector(
            controller: controller,
            child: CalendarBody(
              multiDayTileComponents: multiDayBodyComponents,
              monthTileComponents: multiDayHeaderTileComponents,
            ),
          ),
        );
      },
    );
  }
}
