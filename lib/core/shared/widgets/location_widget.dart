import 'package:capstone/core/shared/widgets/text/text_title_small.dart';
import 'package:flutter/material.dart';

class LocationWidget extends StatelessWidget {
  const LocationWidget({super.key, required this.address});

  final String address;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 5.0),
            child: TextTitleSmall(title: "MEAS"),
          ),
          Row(
            children: [
              Icon(
                Icons.location_pin,
                color: Colors.deepOrange,
              ),
              Text(
                address,
                style:
                    Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(
                      color: Colors.red,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
