import 'package:flutter/material.dart';
import 'package:isaac_app/utils/palette.dart';

class AddRobotButton extends StatelessWidget {
  const AddRobotButton({super.key});

  @override
  Widget build(BuildContext context) {
    final _formKey = GlobalKey<FormState>();

    return ElevatedButton.icon(
        onPressed: () {
            showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text("Add a robot"),
                    content: Form(
                      key: _formKey,
                        child: TextFormField(
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: "Inserisci link websocket",
                            hintText: "ws://<indirizzo_robot>:9090",
                          ),
                        ),
                    ),
                    actions: [
                      TextButton(
                          onPressed: (){
                            Navigator.pop(context);
                          },
                          child: Text("retry"),
                      ),
                      ElevatedButton(
                        onPressed: (){
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: gray,
                        ),
                        child: Text(
                          "add",
                          style: TextStyle(
                            color: white,
                          ),
                        ),
                      ),
                    ],
                  );
                }
            );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: gray,
          minimumSize: Size(150, 100)
        ),
        icon: Icon(Icons.add, color: white,),
        label: Text(
            "Add a robot",
          style: TextStyle(color: white),
        ),
    );
  }
}
