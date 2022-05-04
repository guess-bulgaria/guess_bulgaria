import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';

import 'navigation_button.dart';

class RoomRow extends StatelessWidget {
  final dynamic room;
  final Function clickCallback;

  const RoomRow(this.room, this.clickCallback, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var roomId = room['roomId'];
    var creatorName = room['creatorName'];
    var playerCount = room['playerCount'];
    var maxRounds = room['settings']['maxRounds'];
    var answerTime = room['settings']['answerTimeInSeconds'];
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      height: 60,
      child: ElevatedButton(
        onPressed: () => clickCallback(roomId),
        child: Row(
          children: [
            Expanded(
              flex: 14,
              child: Container(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Container(
                        margin: EdgeInsets.only(bottom: 4),
                        child: Text(creatorName, textAlign: TextAlign.left),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              const Icon(Icons.people),
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text("$playerCount"),
                              )
                            ],
                          ),
                        ),
                        Expanded(
                          child: Row(
                            children: [
                              const Icon(Icons.gamepad_outlined),
                              maxRounds == 0
                                  ? SvgPicture.asset(
                                      "assets/icons/infinity.svg",
                                      height: 20,
                                      color: Theme.of(context)
                                          .secondaryHeaderColor,
                                    )
                                  : FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: Text("$maxRounds"),
                                    )
                            ],
                          ),
                        ),
                        Expanded(
                          child: Row(
                            children: [
                              const Icon(Icons.timer),
                              answerTime == 0
                                  ? SvgPicture.asset(
                                      "assets/icons/infinity.svg",
                                      height: 20,
                                      color: Theme.of(context)
                                          .secondaryHeaderColor,
                                    )
                                  : FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: Text("$answerTime"),
                                    )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            VerticalDivider(
              thickness: 1,
              color: Theme.of(context).primaryColor,
            ),
            const Expanded(
              child: Icon(Icons.play_circle_outline),
            ),
          ],
        ),
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all<Color>(
              Theme.of(context).colorScheme.secondary),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5.0),
              side: const BorderSide(color: Colors.transparent, width: 4),
            ),
          ),
        ),
      ),
    );

    //   Row(

    // );
  }
}
