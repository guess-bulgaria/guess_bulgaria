import 'package:flutter/material.dart';
import 'package:guess_bulgaria/components/color_picker.dart';
import 'package:guess_bulgaria/components/open_drawer_button.dart';
import 'package:guess_bulgaria/storage/user_data.dart';

class GbDrawer extends StatelessWidget {
  final List<Widget> children;
  final double? height;
  final double? width;
  final IconData? icon;

  const GbDrawer({Key? key, required this.children, this.height, this.icon, this.width = 0})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(
          bottom: (height ?? MediaQuery.of(context).size.height / 2) / 2),
      width: width == 0 ? MediaQuery.of(context).size.width / 2.2 : width ,
      height: (height ?? MediaQuery.of(context).size.height) / 2,
      child: Stack(
        children: [
          Material(
            color: Colors.transparent,
            elevation: 1000,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                OpenDrawerButton(
                  icon: icon,
                  clickCallback: () => Navigator.pop(context),
                  left: MediaQuery.of(context).size.width / 2.6,
                  top: 24,
                )
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
                padding: const EdgeInsets.only(top: 20, left: 14, right: 14),
                children: children,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
