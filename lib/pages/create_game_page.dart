import 'package:flutter/material.dart';

class CreateGamePage extends StatelessWidget {
  const CreateGamePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.secondary,
      body: Align(
        alignment: Alignment.center,
        child: FractionallySizedBox(
          widthFactor: 0.9,
          heightFactor: 0.9,
          child: DecoratedBox(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black, width: 4.0)
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const <Widget>[
                Text('Code', style: TextStyle(fontSize: 20),),
                TextField(
                  enabled: false,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: "Random genereted code for room"
                  ),
                ),
              ].map( (el) => Padding(padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 25), child: el,)).toList(),
            ),
          ),
        ),
      ),
    );
  }
}