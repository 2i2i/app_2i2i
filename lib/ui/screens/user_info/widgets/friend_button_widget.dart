import 'package:flutter/material.dart';

class FriendButtonWidget extends StatefulWidget {
  final ValueChanged<bool>? onTap;
  final bool value;

  const FriendButtonWidget({Key? key, this.onTap, this.value = false})
      : super(key: key);

  @override
  _FriendButtonWidgetState createState() => _FriendButtonWidgetState();
}

class _FriendButtonWidgetState extends State<FriendButtonWidget> {
  bool onTaped = false;

  @override
  void initState() {
    super.initState();
    onTaped = widget.value;
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        onTaped = !onTaped;
        widget.onTap?.call(onTaped);
        setState(() {});
      },
      child: Container(
        height: 40,
        decoration: BoxDecoration(
          color: onTaped
              ? Theme.of(context).colorScheme.secondary
              : Theme.of(context).primaryColorLight,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Theme.of(context).colorScheme.secondary),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              onTaped ? Icons.favorite : Icons.favorite_border_rounded,
              color: onTaped
                  ? Theme.of(context).primaryColorLight
                  : Theme.of(context).colorScheme.secondary,
            ),
            SizedBox(width: 6),
            Text(
              onTaped ? 'You are friends' : 'Friend',
              maxLines: 2,
              style: Theme.of(context).textTheme.bodyText2?.copyWith(
                  // fontWeight: FontWeight.w600,
                  color: onTaped
                      ? Theme.of(context).primaryColorLight
                      : Theme.of(context).colorScheme.secondary,
              ),
            )
          ],
        ),
      ),
    );
  }
}
