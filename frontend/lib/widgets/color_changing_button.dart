import 'package:flutter/material.dart';

class ColorChangingButton extends StatefulWidget {
  final String text;
  final Color selectedColor;
  final Color unselectedColor;
  final onTap;

  // ignore: use_key_in_widget_constructors
  const ColorChangingButton(
    this.text,
    this.selectedColor,
    this.unselectedColor,
    this.onTap,
  );

  @override
  State<ColorChangingButton> createState() => _ColorChangingButtonState();
}

class _ColorChangingButtonState extends State<ColorChangingButton> {
  bool _isSelected = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Toggle the selection state
        widget.onTap();
        setState(() {
          _isSelected = !_isSelected;
        });
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey),
          color: _isSelected ? widget.selectedColor : widget.unselectedColor,
        ),
        padding: const EdgeInsets.all(10),
        child: Text(
          widget.text,
          style: TextStyle(
            color: _isSelected ? Colors.white : Color(0xff3D3D3D),
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}
