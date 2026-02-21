import 'package:flutter/material.dart';

class SymbolLegend extends StatelessWidget {
  const SymbolLegend({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 15,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Active modules: 5 su 60"),
        SizedBox(
          width: MediaQuery.of(context).size.width,
          child: ExpansionTile(
            title: Text('Legenda simboli'),
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.check, color: Colors.green),
                title: Text('working ok'),
              ),
              ListTile(
                leading: Icon(Icons.warning, color: Colors.orange),
                title: Text('Warning'),
              ),
              ListTile(
                leading: Icon(Icons.offline_bolt, color: Colors.red),
                title: Text('Offline'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
