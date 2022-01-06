/*
Padding(
padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
child: SliderTheme(
data: SliderThemeData(
trackHeight: 40,
activeTrackColor: AppTheme().thumbColor,
thumbColor: Theme.of(context).primaryColor,
valueIndicatorColor: AppTheme().thumbColor,
activeTickMarkColor: AppTheme().thumbColor,
disabledActiveTickMarkColor: AppTheme().thumbColor,
disabledActiveTrackColor: AppTheme().thumbColor,
disabledInactiveTickMarkColor: AppTheme().thumbColor,
disabledInactiveTrackColor: AppTheme().thumbColor,
disabledThumbColor: AppTheme().thumbColor,
overlayColor: Colors.transparent,
inactiveTickMarkColor: AppTheme().thumbColor,
inactiveTrackColor: AppTheme().thumbColor,
overlappingShapeStrokeColor: AppTheme().thumbColor,
trackShape: CustomTrack(mainContext: context, image: widget.image),
overlayShape: RoundSliderOverlayShape(overlayRadius: 30),
thumbShape: CustomSliderThumbRect(
mainContext: context,
thumbRadius: 20,
thumbHeight: 55,
max: 0,
min: 10)),
child: Container(
width: double.infinity,
child: Slider(
value: _value,
onChanged: (val) {
_value = val;
setState(() {});
},
),
),
),
),*/
