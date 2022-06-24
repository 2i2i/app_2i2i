import 'package:app_2i2i/infrastructure/commons/theme.dart';
import 'package:flutter/material.dart';

class ModeWidgets extends StatelessWidget {
  final bool isDarkMode;
  final bool isSelected;
  final GestureTapCallback? onTap;

  const ModeWidgets({Key? key, required this.isDarkMode, required this.isSelected, this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      hoverColor: Colors.transparent,
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: Column(
        children: [
          Container(
            margin: EdgeInsets.all(6),
            decoration:
                BoxDecoration(borderRadius: BorderRadius.circular(8), border: isSelected ? Border.all(width: 2) : Border.fromBorderSide(BorderSide.none)),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              margin: EdgeInsets.all(6),
              child: Container(
                decoration: BoxDecoration(color: isDarkMode ? AppTheme().black : AppTheme().lightGray, borderRadius: BorderRadius.circular(8)),
                width: MediaQuery.of(context).size.height * 0.14,
                height: MediaQuery.of(context).size.height * 0.22,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      decoration: BoxDecoration(color: isDarkMode ? AppTheme().lightGray : AppTheme().black, borderRadius: BorderRadius.circular(8)),
                      width: MediaQuery.of(context).size.height * 0.12,
                      height: MediaQuery.of(context).size.height * 0.04,
                    ),
                    SizedBox(height: 6),
                    Container(
                      decoration: BoxDecoration(color: isDarkMode ? AppTheme().lightGray : AppTheme().black, borderRadius: BorderRadius.circular(8)),
                      width: MediaQuery.of(context).size.height * 0.12,
                      height: MediaQuery.of(context).size.height * 0.04,
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(height: 4),
          Text(isDarkMode ? 'Dark' : 'Light', style: Theme.of(context).textTheme.subtitle1)
        ],
      ),
    );
  }
}
