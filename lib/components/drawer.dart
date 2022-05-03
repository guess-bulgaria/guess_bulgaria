import 'package:flutter/material.dart';
import 'package:guess_bulgaria/components/open_drawer_button.dart';

class GbDrawer extends StatelessWidget {
  final List<Widget> children;
  final double heightFactor;
  final double topMarginFactor;
  final double buttonWidthScale;
  final double buttonTop;
  final bool isEnd;
  final double? width;
  final IconData? icon;

  const GbDrawer(
      {Key? key,
      required this.children,
      this.heightFactor = 2,
      this.topMarginFactor = 4,
      this.buttonTop = 2.7,
      this.buttonWidthScale = 2.6,
      this.icon,
      this.width = 0,
      this.isEnd = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(
        bottom: MediaQuery.of(context).size.height / topMarginFactor,
      ),
      width: width == 0 ? MediaQuery.of(context).size.width / 2.2 : width,
      height: MediaQuery.of(context).size.height / heightFactor,
      child: Stack(
        children: [
          Material(
            color: Colors.transparent,
            elevation: 1000,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                OpenDrawerButton(
                  isEnd: isEnd,
                  icon: icon,
                  clickCallback: () => Navigator.pop(context),
                  left: ((width ?? 0) > 0
                      ? width!
                      : MediaQuery.of(context).size.width) /
                      buttonWidthScale,
                  top: buttonTop,
                )
              ],
            ),
          ),
          Positioned(
            child: Drawer(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                    topRight: Radius.circular(!isEnd ? 55 : 0),
                    topLeft: Radius.circular(isEnd ? 55 : 0),
                    bottomRight: Radius.circular(!isEnd ? 105 : 0),
                    bottomLeft: Radius.circular(isEnd ? 105 : 0)),
              ),
              backgroundColor: Theme.of(context).colorScheme.secondary,
              elevation: 1,
              child: ListView(
                padding: const EdgeInsets.only(top: 10, left: 8, right: 8),
                children: children,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
