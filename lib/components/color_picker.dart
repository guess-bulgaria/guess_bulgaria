import 'package:flutter/material.dart';
import 'package:guess_bulgaria/configs/player_colors.dart';

class ColorPicker extends StatefulWidget {
  final int colorsPerRow;
  final double iconSize;
  final double iconMargin;
  final int selectedColor;
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
  }) : super(key: key);

  @override
  State<ColorPicker> createState() => _ColorPickerState();
}

class _ColorPickerState extends State<ColorPicker> {
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
                  child: i == widget.selectedColor
                      ? Stack(children: [
                          Icon(Icons.circle,
                              color: colors[i], size: widget.iconSize),
                          Icon(Icons.check,
                              color: Colors.black, size: widget.iconSize)
                        ])
                      : InkWell(
                          hoverColor: Colors.transparent,
                          splashColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          onTap: () => widget.onColorChange(i),
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