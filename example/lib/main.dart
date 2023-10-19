import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:snapping_bottom_sheet/snapping_bottom_sheet.dart';

import 'utils/util.dart';

const Color mapsBlue = Color(0xFF4185F3);

void main() => runApp(
      const MaterialApp(
        title: 'Example App',
        debugShowCheckedModeBanner: false,
        home: Example(),
      ),
    );

class Example extends StatefulWidget {
  const Example({super.key});

  @override
  ExampleState createState() => ExampleState();
}

class ExampleState extends State<Example> {
  SheetController controller = SheetController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(child: Column(children: [Expanded(child: buildSheet())])),
    );
  }

  Widget buildSheet() {
    return SnappingBottomSheet(
      duration: const Duration(milliseconds: 900),
      controller: controller,
      color: Colors.white,
      shadowColor: Colors.black26,
      elevation: 12,
      maxWidth: 500,
      cornerRadius: 16,
      cornerRadiusOnFullscreen: 0.0,
      closeOnBackdropTap: true,
      closeOnBackButtonPressed: true,
      addTopViewPaddingOnFullscreen: true,
      isBackdropInteractable: true,
      border: Border.all(
        color: Colors.grey.shade300,
        width: 3,
      ),
      snapSpec: SnapSpec(
        snap: true,
        positioning: SnapPositioning.relativeToAvailableSpace,
        snappings: const [
          SnapSpec.headerFooterSnap,
          0.5,
          0.75,
          SnapSpec.expanded,
        ],
        onSnap: (state, snap) {
          log('Snapped to $snap');
        },
      ),
      parallaxSpec: const ParallaxSpec(
        enabled: true,
        amount: 0.35,
        endExtent: 0.6,
      ),
      liftOnScrollHeaderElevation: 12.0,
      liftOnScrollFooterElevation: 12.0,
      body: _buildBody(),
      headerBuilder: buildHeader,
      footerBuilder: buildFooter,
      // builder: buildChild,
      customBuilder: buildInfiniteChild,
    );
  }

  Widget buildHeader(BuildContext context, SheetState state) {
    return CustomContainer(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      shadowColor: Colors.black12,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const SizedBox(height: 2),
          Align(
            alignment: Alignment.topCenter,
            child: CustomContainer(
              width: 16,
              height: 4,
              borderRadius: 2,
              color: Colors.grey
                  .withOpacity(.5 * (1 - interval(0.7, 1.0, state.progress))),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: <Widget>[
              const Text(
                '5h 36m',
                style: TextStyle(
                  color: Color(0xFFF0BA64),
                  fontSize: 22,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '(353 mi)',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 21,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Fastest route now due to traffic conditions.',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget buildFooter(BuildContext context, SheetState state) {
    Widget button(
      Icon icon,
      Text text,
      VoidCallback onTap, {
      BorderSide? border,
      Color? color,
    }) {
      final child = Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          icon,
          const SizedBox(width: 8),
          text,
        ],
      );

      const shape = RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
      );

      return border == null
          ? ElevatedButton(
              onPressed: onTap,
              style: ElevatedButton.styleFrom(shape: shape),
              child: child,
            )
          : OutlinedButton(
              onPressed: onTap,
              style: OutlinedButton.styleFrom(shape: shape),
              child: child,
            );
    }

    return CustomContainer(
      shadowDirection: ShadowDirection.top,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.white,
      shadowColor: Colors.black12,
      child: Row(
        children: <Widget>[
          button(
            const Icon(
              Icons.navigation,
              color: Colors.white,
            ),
            const Text(
              'Start',
              style: TextStyle(
                color: Colors.white,
                fontSize: 15,
              ),
            ),
            () async {
              // Inherit from context...
              await SheetController.of(context)!.hide();
              Future.delayed(const Duration(milliseconds: 1500), () {
                // or use the controller
                controller.show();
              });
            },
            color: mapsBlue,
          ),
          const SizedBox(width: 8),
          SheetListenerBuilder(
            buildWhen: (oldState, newState) =>
                oldState.isExpanded != newState.isExpanded,
            builder: (context, state) {
              final isExpanded = state.isExpanded;

              return button(
                Icon(
                  !isExpanded ? Icons.list : Icons.map,
                  color: mapsBlue,
                ),
                Text(
                  !isExpanded ? 'Steps & more' : 'Show map',
                  style: const TextStyle(
                    fontSize: 15,
                    color: Colors.black,
                  ),
                ),
                !isExpanded
                    ? () => controller.scrollTo(state.maxScrollExtent)
                    : controller.collapse,
                color: Colors.white,
                border: BorderSide(
                  color: Colors.grey.shade400,
                  width: 2,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget buildInfiniteChild(
    BuildContext context,
    ScrollController controller,
    SheetState state,
  ) {
    return ListView.separated(
      controller: controller,
      itemBuilder: (context, index) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Text('$index'),
      ),
      separatorBuilder: (context, index) => const Divider(),
      itemCount: 100,
    );
  }

  Future<void> showBottomSheetDialog(BuildContext context) async {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    final controller = SheetController();
    bool isDismissable = false;

    await showSnappingBottomSheet(
      context,
      // The parentBuilder can be used to wrap the sheet inside a parent.
      // This can be for example a Theme or an AnnotatedRegion.
      parentBuilder: (context, sheet) {
        return Theme(
          data: ThemeData.dark(),
          child: sheet,
        );
      },
      // The builder to build the dialog. Calling rebuilder on the dialogController
      // will call the builder, allowing react to state changes while the sheet is shown.
      builder: (context) {
        return SnappingBottomSheetDialog(
          controller: controller,
          duration: const Duration(milliseconds: 500),
          snapSpec: const SnapSpec(
            snap: true,
            initialSnap: 0.7,
            snappings: [
              0.3,
              0.7,
            ],
          ),
          scrollSpec: const ScrollSpec(
            showScrollbar: true,
          ),
          color: Colors.teal,
          maxWidth: 500,
          minHeight: 700,
          isDismissable: isDismissable,
          dismissOnBackdropTap: true,
          isBackdropInteractable: true,
          onDismissPrevented: (backButton, backDrop) async {
            HapticFeedback.heavyImpact();

            if (backButton || backDrop) {
              const duration = Duration(milliseconds: 300);
              await controller.snapToExtent(0.2,
                  duration: duration, clamp: false);
              await controller.snapToExtent(0.4, duration: duration);
              // or Navigator.pop(context);
            }

            // Or pop the route
            // if (backButton) {
            //   Navigator.pop(context);
            // }

            log('Dismiss prevented');
          },
          builder: (context, state) {
            return Container(
              padding: const EdgeInsets.all(32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Confirm purchase',
                    style: textTheme.headlineMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Praesent sagittis tellus lacus, et pulvinar orci eleifend in.',
                          style: textTheme.titleMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 24),
                      Icon(
                        isDismissable ? Icons.check : Icons.error,
                        color: Colors.white,
                        size: 56,
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
          footerBuilder: (context, state) {
            return Container(
              color: Colors.teal.shade700,
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'Cancel',
                      style: textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  TextButton(
                    onPressed: () {
                      if (!isDismissable) {
                        isDismissable = true;
                        SheetController.of(context)!.rebuild();
                      } else {
                        Navigator.pop(context);
                      }
                    },
                    child: Text(
                      'Approve',
                      style: textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildBody() {
    return Stack(
      children: <Widget>[
        buildMap(),
        Align(
          alignment: Alignment.topRight,
          child: Padding(
            padding: EdgeInsets.fromLTRB(
                0, MediaQuery.of(context).padding.top + 16, 16, 0),
            child: FloatingActionButton(
              backgroundColor: Colors.white,
              onPressed: () async {
                await showBottomSheetDialog(context);
              },
              child: const Icon(
                Icons.layers,
                color: mapsBlue,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget buildMap() {
    return Column(
      children: <Widget>[
        Expanded(
          child: Image.asset(
            'assets/map.jpeg',
            width: double.infinity,
            height: double.infinity,
            alignment: Alignment.center,
            fit: BoxFit.cover,
          ),
        ),
      ],
    );
  }
}
