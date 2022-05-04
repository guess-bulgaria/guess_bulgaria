import 'package:flutter/material.dart';
import 'package:guess_bulgaria/components/navigation_button.dart';

class LeaveGameConfirmationDialog extends StatefulWidget {
  const LeaveGameConfirmationDialog({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _LeaveGameConfirmationDialogState();
}

class _LeaveGameConfirmationDialogState
    extends State<LeaveGameConfirmationDialog> {
  leave() {
    Navigator.of(context).popUntil(ModalRoute.withName('/'));
  }

  cancel() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Theme.of(context).colorScheme.secondary,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(40.0),
        ),
      ),
      content: Container(
        width: 100,
        child: Wrap(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Сигурен ли си, че искаш да напуснеш играта?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Theme.of(context).secondaryHeaderColor,
                    fontSize: 20.0,
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 20),
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(right: 3),
                                child: Icon(
                                  Icons.sensor_door_outlined,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                              Text(
                                "Да",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Theme.of(context).colorScheme.primary),
                              ),
                            ],
                          ),
                          onPressed: leave,
                        ),
                      ),
                      const VerticalDivider(),
                      Expanded(
                        child: ElevatedButton(
                          child: Text(
                            "Не",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.primary),
                          ),
                          onPressed: leave,
                        ),
                      )
                    ],
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
