import 'package:flutter/material.dart';

/// A granular control component for toggling individual camera hardware states.
///
/// This [StatefulWidget] manages its own internal [bool] state to provide
/// immediate visual feedback during user interaction. In a robotics context,
/// this represents an isolated hardware switch used for manual override or
/// camera selection.
///
/// References:
/// * Flutter StatefulWidget: https://docs.flutter.dev/ui/interactive#stateful-and-stateless-widgets
/// * Material Switch: https://m3.material.io/components/switch/overview
/// * Flutter Layout (Column): https://docs.flutter.dev/ui/layout#standard-widgets
///
/// Design Decisions:
/// * **Encapsulated State**: Uses local [setState] to manage the toggle status (`V`),
///   ensuring that interaction with one camera switch does not trigger
///   rebuilds in other independent camera modules.
/// * **Vertical Ergonomics**: Employs a [Column] with defined spacing to create
///   a clear visual association between the camera label and its corresponding control.
/// * **Interaction Pattern**: Implements a standard [Switch] widget for binary
///   hardware control, following mobile-first industrial interface standards.
class CameraSwitch extends StatefulWidget {
  /// The label or identifier for the specific camera (e.g., "Camera 01").
  final String cameraNumber;

  const CameraSwitch({super.key, required this.cameraNumber});

  @override
  State<CameraSwitch> createState() => _CameraSwitchState();
}

class _CameraSwitchState extends State<CameraSwitch> {
  /// The local state variable representing the current 'ON/OFF' status.
  bool V = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      // Modern Flutter 'spacing' property for consistent vertical separation.
      spacing: 20,
      children: [
        // Displaying the specific hardware identifier.
        Text(widget.cameraNumber),

        // The interactive toggle component.
        Switch(
          value: V,
          onChanged: (bool value) {
            // Updating the local UI state to reflect the new toggle position.
            setState(() {
              V = value; // Direct assignment is preferred over negation for clarity.
            });
          },
        ),
      ],
    );
  }
}
