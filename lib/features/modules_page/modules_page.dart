import 'package:flutter/material.dart';

class ModulesPage extends StatelessWidget {
  const ModulesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Modules"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 10,
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
                      leading: Icon(Icons.warning, color: Colors.orange,),
                      title: Text('Warning'),
                    ),
                    ListTile(
                      leading: Icon(Icons.offline_bolt, color: Colors.red,),
                      title: Text('Offline'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
