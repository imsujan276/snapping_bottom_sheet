# Snapping Bottom Sheet

A widget that can be dragged, scrolled and snapped to a list of extents. 

#### Example:
![Example](./example.gif)

## Usage
There are two ways in which you can use a `SnappingBottomSheet`: 

- As a `Widget` in your widget tree 
- As a `BottomSheetDialog`. 

### As a Widget

This method can be used to show the `SnappingBottomSheet` permanently (usually above your other widget) as shown in the example.

```dart
@override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: Colors.grey.shade200,
    appBar: AppBar(
      title: Text('Simple Example'),
    ),
    body: SnappingBottomSheet(
      elevation: 8,
      cornerRadius: 16,
      snapSpec: const SnapSpec(
        snap: true,
        snappings: [0.4, 0.7, 1.0],
        positioning: SnapPositioning.relativeToAvailableSpace,
      ),
      body: Center(
        child: Text('This widget is below the SnappingBottomSheet'),
      ),
      builder: (context, state) {
        return Container(
          height: 500,
          child: Center(
            child: Text('This is the content of the sheet'),
          ),
        );
      },
    ),
  );
}
```

### As a BottomSheetDialog

This method can be used to show a `SnappingBottomSheet` as a `BottomSheetDialog` by calling the `showSnappingBottomSheet` function and returning and instance of `SnappingBottomSheetDialog`.

```dart
void showAsBottomSheet() async {
  final result = await showSnappingBottomSheet(
    context,
    builder: (context) {
      return SnappingBottomSheetDialog(
        elevation: 8,
        cornerRadius: 16,
        snapSpec: const SnapSpec(
          snap: true,
          snappings: [0.4, 0.7, 1.0],
          positioning: SnapPositioning.relativeToAvailableSpace,
        ),
        builder: (context, state) {
          return Container(
            height: 400,
            child: Center(
              child: Material(
                child: InkWell(
                  onTap: () => Navigator.pop(context, 'This is the result.'),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'This is the content of the sheet',
                      style: Theme.of(context).textTheme.body1,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      );
    }
  );

  print(result); // This is the result.
}
```


### Snapping

A `SnappingBottomSheet` can snap to multiple extents or to no at all. You can customize the snapping behavior by
passing an instance of `SnapSpec` to the `SnappingBottomSheet`.

 Parameter | Description 
--- | ---
snap | If true, the `SnappingBottomSheet` will snap to the provided `snappings`. If false, the `SnappingBottomSheet` will slide from minExtent to maxExtent and then begin to scroll, if the content is bigger than the available height.
snappings | The extents that the `SnappingBottomSheet` will snap to, when the user ends a drag interaction. The minimum and maximum values will represent the bounds in which the `SnappingBottomSheet` will slide until it reaches the maximum from which on it will scroll.
positioning | Can be set to one of these three values: `SnapPositioning.relativeToAvailableSpace` - Positions the snaps relative to total available height that the `SnappingBottomSheet` can expand to. All values must be between 0 and 1. E.g. a snap of `0.5` in a `Scaffold` without an `AppBar` would mean that the snap would be positioned at 40% of the screen height, irrespective of the height of the `SnappingBottomSheet`. `SnapPositioning.relativeToSheetHeight` - Positions the snaps relative to the total height of the sheet. All values must be between 0 and 1. E.g. a snap of `0.5` and a total sheet size of 300 pixels would mean the snap would be positioned at a 150 pixel offset from the bottom. `SnapPositioning.pixelOffset` - Positions the snaps at a fixed pixel offset. `double.infinity` can be used to refer to the total available space without having to compute it yourself.
onSnap | A callback function that gets invoked when the `SnappingBottomSheet` snaps to an extent.



There are also some prebuild snaps you can facilitate to snap for example to headers or footers as shown in the example.

 Snap | Description 
--- | ---
SnapSpec.headerFooterSnap | The snap extent that makes header and footer fully visible without account for vertical padding on the `SnappingBottomSheet`.
SnapSpec.headerSnap | The snap extent that makes the header fully visible without account for top padding on the `SnappingBottomSheet`.
SnapSpec.footerSnap | The snap extent that makes the footer fully visible without account for bottom padding on the `SnappingBottomSheet`.
SnapSpec.expanded | The snap extent that expands the whole `SnappingBottomSheet`.

### SheetController

The `SheetController` can be used to change the state of a `SnappingBottomSheet` manually, simply passing an instance of `SheetController` to a `SnappingBottomSheet`. Note that the methods can only be used after the `SnappingBottomSheet` has been rendered, however calling them before wont throw an exception.

Note that you can also use the static `SheetController.of(context)` method to obtain an instance of the `SheetController` of the closest `SnappingBottomSheet`. This also works if you didn't assign a `SheetController` explicitly on the `SnappingBottomSheet`.

 Method | Description 
--- | ---
`expand()` | Expands the `SnappingBottomSheet` to the maximum extent.
`collapse()` | Collapses the `SnappingBottomSheet` to the minimum extent.
`snapToExtent()` | Snaps the `SnappingBottomSheet` to an arbitrary extent. The extent will be clamped to the minimum and maximum extent. If the scroll offset is > 0, the `SnappingBottomSheet` will first scroll to the top and then slide to the extent.
`scrollTo()` | Scrolls the `SnappingBottomSheet` to the given offset. If the `SnappingBottomSheet` is not yet at its maximum extent, it will first snap to the maximum extent and then scroll to the given offset.
`rebuild()` | Calls all builders of the `SnappingBottomSheet` to rebuild their children. This method can be used to reflect changes in the `SnappingBottomSheet`s children without calling `setState(() {});` on the parent widget to improve performance.
`show()` | Visually shows the `SnappingBottomSheet` if it was previously hidden. Note that calling this method wont have an effect for `SnappingBottomSheetDialogs`.
`hide()` | Visually hides the `SnappingBottomSheet` until you call `show()` again. Note that calling this method wont have an effect for `SnappingBottomSheetDialogs`.

### Headers and Footers

Headers and footers are UI elements of a `SnappingBottomSheet` that will be displayed at the top or bottom of a `SnappingBottomSheet` respectively and will not get scrolled. The scrollable content will then live in between the header and the footer if specified. Delegating the touch events to the `SnappingBottomSheet` is done for you. Example:

```dart
@override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: Colors.grey.shade200,
    appBar: AppBar(
      title: Text('Simple Example'),
    ),
    body: Stack(
      children: <Widget>[
        SnappingBottomSheet(
          elevation: 8,
          cornerRadius: 16,
          snapSpec: const SnapSpec(
            snap: true,
            snappings: [112, 400, double.infinity],
            positioning: SnapPositioning.pixelOffset,
          ),
          builder: (context, state) {
            return Container(
              height: 500,
              child: Center(
                child: Text(
                  'This is the content of the sheet',
                  style: Theme.of(context).textTheme.body1,
                ),
              ),
            );
          },
          headerBuilder: (context, state) {
            return Container(
              height: 56,
              width: double.infinity,
              color: Colors.green,
              alignment: Alignment.center,
              child: Text(
                'This is the header',
                style: Theme.of(context).textTheme.body1.copyWith(color: Colors.white),
              ),
            );
          },
          footerBuilder: (context, state) {
            return Container(
              height: 56,
              width: double.infinity,
              color: Colors.yellow,
              alignment: Alignment.center,
              child: Text(
                'This is the footer',
                style: Theme.of(context).textTheme.body1.copyWith(color: Colors.black),
              ),
            );
          },
        ),
      ],
    ),
  );
}
```

### ListViews and Columns

The children of a `SnappingBottomSheet` are not allowed to have an inifinite (unbounded) height. Therefore when using a `ListView`, make sure to set `shrinkWrap` to `true` and `physics` to `NeverScrollableScrollPhysics`. Similarly when using a `Column` as a child of a `SnappingBottomSheet`, make sure to set the `mainAxisSize` to `MainAxisSize.min`.

### Material Effects

In order to change the UI when the sheet gets interacted with, you can pass a callback to the `listener` field of a `SnappingBottomSheet` that gets called with the current `SheetState` whenever the sheet slides or gets scrolled. You can then rebuild your UI accordingly. When using the `SnappingBottomSheet` as a `bottomSheetDialog` you can also use `SheetController.rebuild()` to rebuild the sheet, if you want to change certain paramerters.

For rebuilding individual children of a `SnappingBottomSheet` (e.g. elevating the header when content gets scrolled under it), you can also use the `SheetListenerBuilder`:

~~~dart
return SheetListenerBuilder(
  // buildWhen can be used to only rebuild the widget when needed.
  buildWhen: (oldState, newState) => oldState.isAtTop != newState.isAtTop,
  builder: (context, state) {
    return AnimatedContainer(
      elevation: !state.isAtTop ? elevation : 0.0,
      duration: const Duration(milliseconds: 400),
      child: child,
    );
  },
);
~~~

The example for instance decreases the corner radius of the `SnappingBottomSheet` as it gets dragged to the top and increases the headers top padding by the status bar height. Also, when content gets scrolled under the header it elevates.

Because these are common Material behaviors, `SnappingBottomSheet` supports those out of the box, which can be achieved by setting the `avoidStatusBar` field to `true`, `cornerRadiusOnFullscreen` to `0` and `liftOnScrollHeaderElevation` to the elevation.

### Contribution
If you feel like the package is lacking some feature, you are always welcome to create a pull request.
