import 'package:flutter/material.dart';
import 'package:guess_bulgaria/configs/player_colors.dart';

class ColorPicker extends StatefulWidget {
  final int colorsPerRow;
  final double iconSize;
  final double iconMargin;
  final int selectedColor;
  final List<int>? usedColors;
  final String title;
  final Function onColorChange;

  const ColorPicker({
    Key? key,
    required this.selectedColor,
    required this.onColorChange,
    this.title = "Избери цвят",
    this.colorsPerRow = 4,
    this.iconMargin = 2,
    this.iconSize = 30.0,
    this.usedColors,
  }) : super(key: key);

  @override
  State<ColorPicker> createState() => _ColorPickerState();
}

class _ColorPickerState extends State<ColorPicker> {

  void onClick(int i) {
    setState(() {
      widget.onColorChange(i);
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = PlayerColors.colors;
    return Column(
      children: [
        Text(widget.title),
        for (int row = 0;
        row < (colors.length / widget.colorsPerRow).ceil();
        row++)
          Row(
            children: [
              for (int i = 0 + (row * widget.colorsPerRow);
              i < ((row + 1) * widget.colorsPerRow) && i < colors.length;
              i++)
                Container(
                  padding: EdgeInsets.all(widget.iconMargin),
                  child: i == widget.selectedColor ||
                      (widget.usedColors ?? []).contains(i)
                      ? Stack(children: [
                    Center(
                      child: Icon(Icons.circle,
                          color: colors[i], size: widget.iconSize),
                    ),
                    Container(
                      margin: const EdgeInsets.only(top: 5, left: 5),
                      child: Icon(
                          i == widget.selectedColor ? Icons.check : Icons.close,
                          color: Colors.black,
                          size: widget.iconSize - 10),
                    )
                  ])
                      : InkWell(
                    hoverColor: Colors.transparent,
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    onTap: () => onClick(i),
                    child: Icon(Icons.circle,
                        color: colors[i], size: widget.iconSize),
                  ),
                )
            ],
          )
      ],
    );
  }
}
