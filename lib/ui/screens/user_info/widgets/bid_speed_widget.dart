import 'package:flutter/material.dart';

import 'package:app_2i2i/infrastructure/commons/theme.dart';

class BidSpeedWidget extends StatelessWidget {
  final String speed;
  final String unit;

  const BidSpeedWidget(
      {Key? key, required this.speed, required this.unit})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: EdgeInsets.all(6),
          decoration: BoxDecoration(
              color: Theme.of(context).primaryColorLight,
              boxShadow: [
                BoxShadow(
                    offset: Offset(2, 4),
                    blurRadius: 8,
                    color:
                        Color.fromRGBO(0, 0, 0, 0.12) // changes position of shadow
                    ),
              ],
              borderRadius: BorderRadius.circular(72)),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            // mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Text('$speed',
                    style: Theme.of(context).textTheme.headline6!.copyWith(
                        fontWeight: FontWeight.w800, color: AppTheme().green)),
              ),
              Text('$unit',
                  style: Theme.of(context).textTheme.subtitle2!.copyWith(
                        fontWeight: FontWeight.w400,
                      )),
              SizedBox(width: 6),
              Image.asset(
                'assets/algo_logo.png',
                width: 35,
                height: 35,
              )
            ],
          ),
        ),
      ],
    );
  }
}
