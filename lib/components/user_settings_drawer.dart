import 'package:flutter/material.dart';
import 'package:guess_bulgaria/components/color_picker.dart';
import 'package:guess_bulgaria/components/drawer.dart';
import 'package:guess_bulgaria/storage/user_data.dart';

class UserSettingsDrawer extends StatefulWidget {
  const UserSettingsDrawer({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _UserSettingsDrawerState();
}

class _UserSettingsDrawerState extends State<UserSettingsDrawer> {
  late TextEditingController _usernameController;

  void setDefaultColor(int i) async {
    setState(() => {UserData().setDefaultColor(i)});
  }

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController(text: UserData.username);
  }

  @override
  void dispose() {
    if (_usernameController.text.isNotEmpty) {
      UserData().setUsername(_usernameController.text);
    }
    _usernameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GbDrawer(
      children: [
        const Text(
          "Потребителско име",
          textAlign: TextAlign.center,
        ),
        TextFormField(
          decoration: const InputDecoration(
            prefixIconConstraints: BoxConstraints(minWidth: 22, maxHeight: 20),
            prefixIcon: Icon(Icons.edit, size: 16),
          ),
          textAlign: TextAlign.left,
          controller: _usernameController,
          // style: TextStyle(color: Colors.white70),
        ),
        Container(
          margin: const EdgeInsets.only(top: 10),
          child: FittedBox(
            child: ColorPicker(
              iconMargin: 3,
              selectedColor: UserData.defaultColor,
              title: "Предпочитан цвят",
              onColorChange: setDefaultColor,
            ),
          ),
        ),
        const Divider(thickness: 0.45)
      ],
    );
  }
}
