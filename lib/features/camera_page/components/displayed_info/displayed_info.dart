import 'package:flutter/material.dart';

class DisplayedInfo extends StatelessWidget {
  const DisplayedInfo({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
      height: double.maxFinite,
      width: MediaQuery.of(context).size.width / 4,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(
          Radius.circular(10),
        ),
        color: Colors.red,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Informazioni mostrate",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                letterSpacing: Theme.of(context).textTheme.bodyLarge!.letterSpacing,
                fontSize: Theme.of(context).textTheme.bodyLarge!.fontSize
                ),
              )
          ],
        ),
      ),
    );
  }
}