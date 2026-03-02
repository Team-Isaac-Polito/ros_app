import 'package:flutter/material.dart';
import 'package:isaac_app/features/main_page/models/folder/folder.dart';

<<<<<<< HEAD
/*
* This is the card rendered in the control panel page
* @params:
*    - element: the element to jump when the card is clicked
*
* */
class ControlPanelCard extends StatelessWidget {
  final Folder element;
=======
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
class ControlPanelCard extends StatelessWidget {
  /// The underlying data model containing the icon, name, and destination route.
  final Folder element;

>>>>>>> ed34974 (Modifiche a modules_page)
  const ControlPanelCard({super.key, required this.element});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
<<<<<<< HEAD
=======
        // Navigates to the page defined in the Folder model.
        // MaterialPageRoute handles the platform-specific transition animations.
>>>>>>> ed34974 (Modifiche a modules_page)
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (BuildContext context) {
              return element.goTopage;
            },
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(right: 20),
        child: Column(
          spacing: 10,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
<<<<<<< HEAD
            Container(
              margin: const EdgeInsets.symmetric(vertical: 20),
              padding: const EdgeInsets.all(15),
              width: MediaQuery.of(context).size.width / 4,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(10)),
                color: Colors.blue,
              ),
              child: Icon(
                element.icon,
=======
            // Icon Container: Provides the visual anchor for the module.
            Container(
              margin: const EdgeInsets.symmetric(vertical: 20),
              padding: const EdgeInsets.all(15),
              // Dynamic sizing based on the current viewport width.
              width: MediaQuery.of(context).size.width / 4,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(Radius.circular(10)),
                color: Colors
                    .blue, // Primary brand color for navigational elements.
              ),
              child: Icon(
                element.icon,
                // Inherits size from the primary display text theme for design scaling.
>>>>>>> ed34974 (Modifiche a modules_page)
                size: Theme.of(context).textTheme.displayLarge!.fontSize,
                color: Colors.white,
              ),
            ),
<<<<<<< HEAD
=======
            // Formatted label retrieved from the Folder model helper.
>>>>>>> ed34974 (Modifiche a modules_page)
            Text(element.formatName(element.name)),
          ],
        ),
      ),
    );
  }
}
