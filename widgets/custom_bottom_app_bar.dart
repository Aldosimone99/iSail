import 'package:flutter/material.dart';

class CustomBottomAppBar extends StatelessWidget {
  final VoidCallback onAnchorPressed;
  final VoidCallback onDocumentsPressed;
  final VoidCallback onSettingsPressed;

  const CustomBottomAppBar({super.key, 
    required this.onAnchorPressed,
    required this.onDocumentsPressed,
    required this.onSettingsPressed,
  });

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      shape: CircularNotchedRectangle(),
      notchMargin: 6.0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: onSettingsPressed,
          ),
          IconButton(
            icon: Icon(Icons.description),
            onPressed: onDocumentsPressed,
          ),
        ],
      ),
    );
  }
}
