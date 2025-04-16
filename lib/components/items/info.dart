import 'package:flutter/material.dart';

class ItemExtraInfo extends StatelessWidget {
  final MapEntry<String, String> info;
  const ItemExtraInfo({required this.info, super.key});

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(text: '${info.key}: ', style: Theme.of(context).textTheme.bodyLarge!.copyWith(fontWeight: FontWeight.bold)
          ),
          TextSpan(
            text: info.value,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }
}
