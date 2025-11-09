import 'package:flutter/material.dart';
import 'package:isaac_app/features/main_page/models/folder/folder.dart';

/*
* This is the card rendered in the control panel page
* @params:
*    - element: the element to jump when the card is clicked
*
* */
class ControlPanelCard extends StatelessWidget {
  final Folder element;
  const ControlPanelCard({super.key, required this.element});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
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
                size: Theme.of(context).textTheme.displayLarge!.fontSize,
                color: Colors.white,
              ),
            ),
            Text(element.formatName(element.name)),
          ],
        ),
      ),
    );
  }
}
