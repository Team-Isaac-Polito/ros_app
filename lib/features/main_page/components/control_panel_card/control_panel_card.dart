import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:isaac_app/features/main_page/models/folder/folder.dart';

/// A specialized UI component representing a navigational entry point in the Control Panel.
///
/// This [StatelessWidget] acts as a bridge between the high-level feature overview
/// and individual functional modules (e.g., Camera, Sensors). It utilizes the
/// [Folder] data model to dynamically render its visual identity and routing logic.
///
/// References:
/// * Flutter Navigation: https://docs.flutter.dev/ui/navigation
/// * Flutter Layout Strategy: https://docs.flutter.dev/ui/layout
/// * Material Design Cards: https://m3.material.io/components/cards/overview
///
/// Design Decisions:
/// * **Visual Consistency**: Uses a fixed fractional width ([MediaQuery]) to ensure
///   a uniform grid-like appearance across various tablet or mobile screen sizes.
/// * **Modular Routing**: Implements the **Imperative Navigation** pattern (Navigator 1.0)
///   to push the specific module page defined within the [element] model.
/// * **User Feedback**: Wrapped in a [GestureDetector] to provide a clear hit area
///   for touch interactions, essential for robot operator interfaces.
class ControlPanelCard extends StatefulWidget {
  /// The underlying data model containing the icon, name, and destination route.
  final Folder element;

  const ControlPanelCard({super.key, required this.element});

  @override
  State<ControlPanelCard> createState() => _ControlPanelCardState();
}

class _ControlPanelCardState extends State<ControlPanelCard> {
  void _navigateToSection() {
    // Navigates to the page defined in the Folder model.
    // MaterialPageRoute handles the platform-specific transition animations.
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (BuildContext context) {
          return widget.element.goTopage;
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      onFocusChange: (hasFocus) => setState(() {}),
      onKeyEvent: (node, KeyEvent event) {
        if (event is KeyDownEvent &&
                (event.logicalKey == LogicalKeyboardKey.enter) ||
            (event.logicalKey == LogicalKeyboardKey.select) ||
            (event.logicalKey == LogicalKeyboardKey.gameButtonA)) {
          _navigateToSection();
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
      child: Builder(
        builder: (BuildContext context) {
          final bool isFocused = Focus.of(context).hasFocus;

          return InkWell(
            focusColor: Colors.transparent,
            onTap: () => _navigateToSection(),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  color: isFocused ? Colors.blue : Colors.transparent,
                  width: 3,
                ),
              ),
              child: Column(
                spacing: 10,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Icon Container: Provides the visual anchor for the module.
                  Container(
                    padding: const EdgeInsets.all(15),
                    // Dynamic sizing based on the current viewport width.
                    width: MediaQuery.of(context).size.width / 4,
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.all(Radius.circular(10)),
                      color: Colors
                          .blue, // Primary brand color for navigational elements.
                    ),
                    child: Icon(
                      widget.element.icon,
                      // Inherits size from the primary display text theme for design scaling.
                      size: Theme.of(context).textTheme.displayMedium!.fontSize,
                      color: Colors.white,
                    ),
                  ),
                  // Formatted label retrieved from the Folder model helper.
                  Text(widget.element.formatName(widget.element.name)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
