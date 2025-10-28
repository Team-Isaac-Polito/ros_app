import 'package:flutter/cupertino.dart';

class Folder {
  final String name;
  final IconData icon;
  const Folder({required this.name, required this.icon});

  String formatName(String name){
    return name[0].toUpperCase() + name.substring(1,);
  }
}