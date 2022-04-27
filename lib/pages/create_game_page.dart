import 'package:flutter/material.dart';

class CreateGamePage extends StatefulWidget {
  const CreateGamePage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _CreatePageState();
}
class _CreatePageState extends State<CreateGamePage> {

  int dropdownValue = 1;
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
                border: Border.all(color: Colors.black, width: 4.0)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text(
                  'Код за достъп',
                  style: TextStyle(fontSize: 20),
                ),
                const TextField(
                  enabled: false,
                  decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: "Random genereted code for room"),
                ),
                const Text(
                  'Брой рундове',
                  style: TextStyle(fontSize: 20),
                ),
                DropdownButton(
                  value: dropdownValue,
                  style: const TextStyle(color: Colors.black),
                  items: <int>[1, 2, 3, 4]
                      .map<DropdownMenuItem<int>>((int? value) {
                    return DropdownMenuItem<int>(
                      value: value,
                      child: Text(value.toString()),
                    );
                  }).toList(),
                  onChanged: (int? newValue) {
                    // set state 
                    setState(() {
                      dropdownValue = newValue!;
                    });
                  },
                  
                ),
              ]
                  .map((el) => Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 25),
                        child: el,
                      ))
                  .toList(),
            ),
          ),
        ),
      ),
    );
  }
}
