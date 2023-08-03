import 'package:flutter/material.dart';
import 'package:kalender/kalender.dart';
import 'package:kalender/src/models/tile_layout_controllers/multi_day_tile_layout_controller.dart';
import 'package:kalender/src/providers/calendar_scope.dart';

/// The [ChaningMultiDayTileStack] displays a single [PositionedMultiDayTileData] that is being modified.
class ChaningMultiDayTileStack<T> extends StatelessWidget {
  const ChaningMultiDayTileStack({
    super.key,
    required this.multiDayEventLayout,
  });

  final MultiDayLayoutController<T> multiDayEventLayout;

  @override
  Widget build(BuildContext context) {
    CalendarScope<T> scope = CalendarScope.of(context);

    return ListenableBuilder(
      listenable: scope.eventsController.chaningEvent!,
      builder: (BuildContext context, Widget? child) {
        PositionedMultiDayTileData<T> arragnedEvent = multiDayEventLayout.arrangeEvent(
          scope.eventsController.chaningEvent!,
        );
        return MouseRegion(
          cursor: SystemMouseCursors.resizeColumn,
          child: Stack(
            children: <Widget>[
              Positioned(
                top: arragnedEvent.top,
                left: arragnedEvent.left,
                width: arragnedEvent.width,
                height: arragnedEvent.height,
                child: scope.tileComponents.multiDayTileBuilder!(
                  arragnedEvent.event,
                  TileType.selected,
                  arragnedEvent.continuesBefore,
                  arragnedEvent.continuesAfter,
                ),
              )
            ],
          ),
        );
      },
    );
  }
}
