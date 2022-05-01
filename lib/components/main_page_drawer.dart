import 'package:flutter/material.dart';
import 'package:guess_bulgaria/components/color_picker.dart';
import 'package:guess_bulgaria/components/open_drawer_button.dart';
import 'package:guess_bulgaria/storage/user_data.dart';

class MainPageDrawer extends StatefulWidget{
  final TextEditingController usernameController;

  const MainPageDrawer({Key? key, required this.usernameController}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _MainPageDrawerState();
}

class _MainPageDrawerState extends State<MainPageDrawer>{

  void setDefaultColor(int i) async {
    await UserData().setDefaultColor(i);
    setState(() => {});
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: MediaQuery.of(context).size.height / 4),
      width: MediaQuery.of(context).size.width / 2.2,
      height: MediaQuery.of(context).size.height / 2,
      child: Stack(
        children: [
          Material(
            color: Colors.transparent,
            elevation: 1000,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                OpenDrawerButton(clickCallback: () => Navigator.pop(context), left: MediaQuery.of(context).size.width / 2.6, top: 24)
              ],
            ),
          ),
          Positioned(
            child: Drawer(
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                    topRight: Radius.circular(55),
                    bottomRight: Radius.circular(105)),
              ),
              backgroundColor: Theme.of(context).colorScheme.secondary,
              elevation: 1,
              child: ListView(
                padding: const EdgeInsets.only(top: 49, left: 14, right: 14),
                children: [
                  const Text(
                    "Потребителско име",
                    textAlign: TextAlign.center,
                  ),
                  TextFormField(
                    textAlign: TextAlign.center,
                    controller: widget.usernameController,
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 10),
                    child: ColorPicker(
                      iconMargin: 3,
                      selectedColor: UserData.defaultColor,
                      title: "Предпочитан цвят",
                      onColorChange: setDefaultColor,
                    ),
                  ),
                  const Divider(thickness: 0.7)
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

}