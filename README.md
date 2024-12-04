This Flutter package offers a Calendar Widget featuring a Day, MultiDay and Month views. Moreover, it empowers you to tailor the visual and behavioral aspects of the calendar.

## Note
- Consider v0.5.0 a new package as it has undergone major changes.
- This is a WIP package so there will be breaking changes until version 1.0.0.

## Web Example

Try it out [here](https://werner-scholtz.github.io/kalender/)

## Features

* **Views:** Day, Multi-day and Month.
* **Reschedule:** Drag and Drop events. 
* **Resize:** Resize events on desktop and mobile.
* **Controllers:** Manage your calendar widget with these controllers. [find out more](#controllers)
* **Behavior:** Decide how you want to handle interaction with the calendar. [find out more](#customizing-the-behavior)
* **Appearance:** Customize the default components or provide custom builders. [find out more](#general-components)
* **Event layout:** Use a provided layout strategy or create a custom one. [find out more](#event-layout)

<img src="https://github.com/werner-scholtz/kalender/blob/calendar_rework/readme_assets/all_views.png?raw=true" width="100%"/> 

...

## Planned Features

* **Views:** Add Schedule and FreeScroll, improvements to the Month view.
* **Directionality:** Right to Left directionality.
* **Repeating Events:** Repeating events that only have to be added once.
* **Event layout:** More examples of how to leverage this to achieve specific tasks.

...

## Basic Usage

```dart
final eventsController = EventsController();
final calendarController = CalendarController();
final tileComponents = TileComponents(
  tileBuilder: (event) => Container(color: Colors.green),
);

@override
void initState() {
  super.initState();

  /// Add [CalendarEvent]s to the [EventsController].
  eventsController.addEvents([...]);
}

Widget build(BuildContext context) {  
  return CalendarView(
    eventsController: eventsController,
    calendarController: calendarController,
    viewConfiguration: MultiDayViewConfiguration.singleDay(),
    callbacks: CalendarCallbacks(
      onEventTapped: (event, renderBox) => controller.selectEvent(event),
      onEventCreate: (event) => event.copyWith(data: "Some data"),
      onEventCreated: (event) => eventsController.addEvent(event),
    ),
    header: CalendarHeader(
      multiDayTileComponents: tileComponents,
    ),
    body: CalendarBody(
      multiDayTileComponents: tileComponents,
      monthTileComponents: tileComponents,
    ),
  );
}
```

## Controllers

The two controllers EventsController and CalendarController do what their names imply:

### EventsController

The [EventsController](https://github.com/werner-scholtz/kalender/blob/d79a8ea7fa1474a9085cb835e25a89ed9b7872a5/lib/src/models/controllers/events_controller.dart#L8) manages and exposes events to calendar widgets.
It has a few functions to manipulate events:
- `addEvent` Add a new event.
- `addEvents` Add multiple new events.
- `removeEvent` Remove a event.
- `removeWhere` Remove events where they match a test case.
- `updateEvent` Updates an event.
- `clearEvents` Clear all the stored events.

### CalendarController

The [CalendarController](https://github.com/werner-scholtz/kalender/blob/d79a8ea7fa1474a9085cb835e25a89ed9b7872a5/lib/src/models/controllers/calendar_controller.dart#L15) allows you to manage a single calendar widget, and it also exposes details about what the widget is displaying.
This controller has a few functions for navigating:
- `jumpToPage`: Jump to a specific page.
- `jumpToDate`: Jump to a specific date.
- `animateToNextPage`: Animate to the next page.
- `animateToPreviousPage`: Animate to the previous page.
- `animateToDate`: Animate to the given date.
- `animateToDateTime`: Animate to the given date time.
- `animateToEvent` Animate to the given event.

Note:
- The CalendarController makes use of a [ViewController](https://github.com/werner-scholtz/kalender/blob/d79a8ea7fa1474a9085cb835e25a89ed9b7872a5/lib/src/models/controllers/view_controller.dart#L8) which implements these functions for a specific view type (MultiDay, Month).
  These specific implementations of the ViewController ([MultiDayViewController](https://github.com/werner-scholtz/kalender/blob/d79a8ea7fa1474a9085cb835e25a89ed9b7872a5/lib/src/models/controllers/view_controller.dart#L70), [MonthViewController](https://github.com/werner-scholtz/kalender/blob/d79a8ea7fa1474a9085cb835e25a89ed9b7872a5/lib/src/models/controllers/view_controller.dart#L243)) uses a [ViewConfiguration](https://github.com/werner-scholtz/kalender/blob/d79a8ea7fa1474a9085cb835e25a89ed9b7872a5/lib/src/models/view_configurations/view_configuration.dart#L11),
  which has specific implementations these functions.
 
## Customizing the behavior

### Callbacks

The calendar has a few useful callback functions, which can change how interactions with the calendar widget is handled.

<details>
  <summary>CalendarCallbacks details</summary>

  ```dart
  CalendarCallbacks(
    // Called when an event is tapped.
    onEventTapped: (event, renderBox) {},

    // Called when an event is about to be created.
    onEventCreate: (event) {
      // This allows you to modify the event before it is created.
      return event.copyWith(data: data);
    }
    
    // Called when a new event has been created.
    onEventCreated: (event) {
      // Add the event to the eventsController.
      eventsController.addEvent(event);
    },

    // Called before a event is changed.
    onEventChange: (event) {}

    // Called when a event has been changed (rescheduled / resized)
    onEventChanged: (event, updatedEvent) {
      // Do something with the updated event.
      // ex. Update it in your database/long term storage.
    },

    // Called when a page is changed.
    //
    // Alternatively you can listen to the [CalendarController.visibleDateTimeRange] for updates.
    onPageChanged: (visibleDateTimeRange) {},
  )
  ```
  </summary>
</details>


### Header and Body

The `CalendarHeader` and `CalendarBody` both take configuration object's for the different `ViewConfigurations`.
These configuration classes allow you to choose what interactions are allowed and how they work.

Some behaviors that can be customized:
- Allow the user to create events.
- Allow the user to resize events.
- Allow the user to reschedule events.
- The trigger to create a new event.
- Event snapping.
- Page/Scroll navigation when rescheduling events.
- Page/Scroll physics.
- Event layout strategy.


Examples:
<details>
  <summary>MultiDayHeaderConfiguration</summary>

  ```dart
  CalendarHeader(
    multiDayHeaderConfiguration: MultiDayHeaderConfiguration(
      // Whether to show event tiles, useful if you want to display the header but not the tiles.
      showTiles: true,
      // The height of the tiles.
      tileHeight: 24,
      // Allow events to be resized.
      allowResizing: true,
      // Allow events to be rescheduled.
      allowRescheduling: true,
      // Allow events to be created.
      allowEventCreation: true,
      // The layout strategy used to layout events.
      eventLayoutStrategy: defaultMultiDayLayoutStrategy,
      // The configuration for triggering page navigation.
      pageTriggerConfiguration: PageTriggerConfiguration(),
      // The configuration for triggering scroll navigation.
      scrollTriggerConfiguration: ScrollTriggerConfiguration(),
    ),
  );
  ```
  </summary>
</details>

<details>
  <summary>MultiDayBodyConfiguration</summary>

  ```dart
  CalendarBody(
    multiDayBodyConfiguration: MultiDayBodyConfiguration(
      // Whether to show events that are longer than 1 day.
      showMultiDayEvents: true,
      // Allow events to be resized.
      allowResizing: true,
      // Allow events to be rescheduled.
      allowRescheduling: true,
      // Allow events to be created.
      allowEventCreation: true,
      // The gesture used to create new events.
      createEventGesture: CreateEventGesture.tap,
      // The snap interval ex. 15 events will snap to every 15 minute interval.
      snapIntervalMinutes: 15,
      // Whether to snap to the time indicator.
      snapToTimeIndicator: true,
      // Whether to snap to other events.
      snapToOtherEvents: true,
      // The range in which events will be snapped, 
      // ex. 15 minutes: A event will snap to other events that are within 15 minutes from it.
      snapRange: Duration(minutes: 5),
      // The duration of events created by the `createEventGesture`
      newEventDuration: Duration(minutes: 30),
      // The configuration for triggering page navigation.
      pageTriggerConfiguration: PageTriggerConfiguration(),
      // The configuration for triggering scroll navigation.
      scrollTriggerConfiguration: ScrollTriggerConfiguration(),
      // The layout strategy used by the body to layout events.
      eventLayoutStrategy: overlapLayoutStrategy,
      // The physics used by the scrollable body.
      scrollPhysics: BouncingScrollPhysics(),
      // The physics used by the page view.
      pageScrollPhysics: BouncingScrollPhysics(),
    ),
  );
  ```
  </summary>
</details>

<details>
  <summary>MultiDayHeaderConfiguration</summary>

  ```dart
  CalendarBody(
    // The MonthBody makes use the MultiDayHeaderConfiguration
    monthBodyConfiguration: MultiDayHeaderConfiguration(
      // Whether to show event tiles, useful if you want to display the header but not the tiles.
      showTiles: true,
      // The height of the tiles.
      tileHeight: 24,
      // Allow events to be resized.
      allowResizing: true,
      // Allow events to be rescheduled.
      allowRescheduling: true,
      // Allow events to be created.
      allowEventCreation: true,
      // The layout strategy used to layout events.
      eventLayoutStrategy: defaultMultiDayLayoutStrategy,
      // The configuration for triggering page navigation.
      pageTriggerConfiguration: PageTriggerConfiguration(),
      // The configuration for triggering scroll navigation.
      scrollTriggerConfiguration: ScrollTriggerConfiguration(),
    ), 
  );
  ```
  </summary>
</details>

## Customizing the look

There are a few ways to customize the look of the calendar:
- [Tile Components](#tile-components) allows you change the look of events rendered in the calendar.

General Components:
- [Multi-day Components](#month-components) allows you to change the look of the day and multi-day views.
- [Month Components](#tile-components) allows you to change the look of the month view.

### Tile Components

The `TileComponents` object is used to customize the look of the tiles displayed in the calendar.
The `CalendarBody` and `CalendarHeader` have a `TileComponents` object that can be customized.

<details>
  <summary>TileComponents details</summary>

  ```dart
  TileComponents(
    // The default builder for stationary event tiles.
    tileBuilder: (event) => Container(),

    // The builder for the stationary event tile. (When it is being dragged)
    tileWhenDraggingBuilder: (event) => Container(),

    // The builder for the feedback tile, follows the cursor/finger. (When it is being dragged)
    feedbackTileBuilder: (event, dropTargetWidgetSize) => Container(),

    // The builder for the drop target event tile.
    dropTargetTile: (event) => Container(),

    // The dragAnchorStrategy used by the [feedbackTileBuilder].
    dragAnchorStrategy: childDragAnchorStrategy,

    // A widget that allows you to customize where the resize handles are placed vertically.
    // Your widget should extend the `ResizeHandlePositionerWidget`
    verticalHandlePositioner: (startResizeHandle, endResizeHandle, showStart, showEnd) => ResizeHandlePositionerWidget() , 

    // The vertical resize handle.
    verticalResizeHandle: Container(),

    // A widget that allows you to customize where the resize handles are placed horizontally.
    // Your widget should extend the `ResizeHandlePositionerWidget`
    horizontalHandlePositioner: (startResizeHandle, endResizeHandle, showStart, showEnd) => ResizeHandlePositionerWidget() ,

    // The horizontal resize handle.
    horizontalResizeHandle: Container(),
  )
  ```
  </summary>
</details>



### General Components

The CalendarView takes a components object.

- For every type of `ViewConfiguration` there are `Header` and `Body` components which can be customized.

By default the calendar uses default components which can be customized with `ComponentStyles`, you have the option to override these components by supplying a builder to the `Components` object.


<details>
  <summary>MonthComponents</summary>

  ```dart
  CalendarView(
    components: CalendarComponents(
      monthComponents: MonthComponents(
        headerComponents: MonthHeaderComponents(
          // Custom day header builder.
          weekDayHeaderBuilder: (date, style) => SizedBox(),
        ),
        bodyComponents: MonthBodyComponents(
          // Custom grid builder.
          monthGridBuilder: (style) => SizedBox(),
          
          // Custom left trigger. (Must constrain the width)
          leftTriggerBuilder: (pageWidth) => SizedBox(),
          
          // Custom right trigger. (Must constrain the width)
          rightTriggerBuilder: (pageWidth) => SizedBox(),
        ),
      ),
    ),
  );
  ```
  </summary>
</details>


<details>
  <summary>MultiDayComponents</summary>

  ```dart
  CalendarView(
    components: CalendarComponents(
      multiDayComponents: MultiDayComponents(
        headerComponents: MultiDayHeaderComponents(
          // Custom Day Header builder.
          dayHeaderBuilder: (date, style) => CustomWidget(),

          // Custom Week Number builder.
          weekNumberBuilder: (visibleDateTimeRange, style) => CustomWidget(),

          // Custom left trigger. (Must constrain the width)
          leftTriggerBuilder: (pageWidth) => SizedBox(width: pageWidth / 20),

          // Custom right trigger. (Must constrain the width)
          rightTriggerBuilder: (pageWidth) => SizedBox(width: pageWidth / 20),
        ),
        bodyComponents: MultiDayBodyComponents(
          // Custom Hour Line builder.
          hourLines: (heightPerMinute, timeOfDayRange, style) => CustomWidget(),

          // Custom time line builder.
          timeline: (heightPerMinute, timeOfDayRange, style) => CustomWidget(),

          // Custom day separator builder.
          daySeparator: (style) => CustomWidget(),

          // Custom event indicator builder.
          timeIndicator: (timeOfDayRange, heightPerMinute, timelineWidth, style) => CustomWidget(),

          // Left trigger. (Must constrain the width)
          leftTriggerBuilder: (pageHeight) => SizedBox(width: pageHeight / 20),

          // Right trigger. (Must constrain the width)
          rightTriggerBuilder: (pageHeight) => SizedBox(width: pageHeight / 20),

          // Top trigger. (Must constrain the height)
          topTriggerBuilder: (viewPortHeight) => SizedBox(height: viewPortHeight / 20),

          // Bottom trigger. (Must constrain the height)
          bottomTriggerBuilder: (viewPortHeight) => SizedBox(height: viewPortHeight / 20),
        ),
      ),
    ),
  );
  ```
  </summary>
</details>


### Event layout

The packages makes use of [CustomMultiChildLayout](https://api.flutter.dev/flutter/widgets/CustomMultiChildLayout-class.html) to layout event tiles.
The `CustomMultiChildLayout` uses a [MultiChildLayoutDelegate](https://api.flutter.dev/flutter/rendering/MultiChildLayoutDelegate-class.html) to determine the positions of tiles.

The package provides some default layoutStrategies, [overlapLayoutStrategy](https://github.com/werner-scholtz/kalender/blob/d79a8ea7fa1474a9085cb835e25a89ed9b7872a5/lib/src/layout_delegates/event_layout_delegate.dart#L26) and [sideBySideLayoutStrategy](https://github.com/werner-scholtz/kalender/blob/d79a8ea7fa1474a9085cb835e25a89ed9b7872a5/lib/src/layout_delegates/event_layout_delegate.dart#L41) for day/multi-day views.
You can create your own layoutStrategy, using the two provided strategies as a reference might be useful.