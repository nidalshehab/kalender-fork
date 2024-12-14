import './../widgets/tile/resize_handles.dart';
import 'package:flutter/material.dart';
import 'package:kalender/kalender.dart';

import './../data/event.dart';
import './../widgets/tile/tiles.dart';

TileComponents<Event> get multiDayBodyComponents {
  const margin = EdgeInsets.symmetric(horizontal: 1);
  const titlePadding = EdgeInsets.all(8);
  return TileComponents(
    tileBuilder: (event, tileRange) =>
        EventTile(event: event, margin: margin, titlePadding: titlePadding),
    dropTargetTile: (event) => DropTargetTile(event: event, margin: margin),
    tileWhenDraggingBuilder: (event) =>
        TileWhenDragging(event: event, margin: margin),
    feedbackTileBuilder: (event, size) =>
        FeedbackTile(event: event, margin: margin, size: size),
    horizontalResizeHandle: const HorizontalResizeHandle(),
    verticalResizeHandle: const VerticalResizeHandle(),
  );
}

TileComponents<Event> get multiDayHeaderTileComponents {
  const margin = EdgeInsets.symmetric(vertical: 1);
  const titlePadding = EdgeInsets.symmetric(vertical: 1, horizontal: 8);
  return TileComponents(
    tileBuilder: (event, tileRange) =>
        EventTile(event: event, margin: margin, titlePadding: titlePadding),
    dropTargetTile: (event) => DropTargetTile(event: event, margin: margin),
    tileWhenDraggingBuilder: (event) =>
        TileWhenDragging(event: event, margin: margin),
    feedbackTileBuilder: (event, size) =>
        FeedbackTile(event: event, margin: margin, size: size),
    horizontalResizeHandle: const HorizontalResizeHandle(),
    verticalResizeHandle: const VerticalResizeHandle(),
  );
}
