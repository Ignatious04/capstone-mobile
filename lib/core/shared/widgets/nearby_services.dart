import 'package:capstone/core/shared/widgets/text/card_title_text.dart';
import 'package:capstone/core/shared/widgets/text/sub_title_text.dart';
import 'package:flutter/material.dart';

class NearbyServices extends StatelessWidget {
  const NearbyServices({
    super.key,
    required this.name,
    required this.address,
    required this.distance,
  });

  final String name;
  final String address;
  final double distance;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CardTitleText(
                    value: "Service Name",
                    isBold: true,
                  ),
                  SubtitleText(value: "Address"),
                  SubtitleText(value: "${distance.toStringAsFixed(2)} km"),
                ],
              ),
            ),
            const SizedBox(
              width: 10,
            ),
            IconButton(
              onPressed: () {},
              icon: Icon(Icons.call, size: 30),
            ),
          ],
        ),
      ),
    );
  }
}
