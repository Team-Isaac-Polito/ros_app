import 'package:flutter/cupertino.dart';

class Folder {
  final String name;
  final IconData icon;
  final Widget goTopage;
  const Folder({required this.name, required this.icon, required this.goTopage});

  String formatName(String name){
    return name[0].toUpperCase() + name.substring(1,);
  }
}