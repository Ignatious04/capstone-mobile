import 'package:capstone/core/shared/widgets/text/card_title_text.dart';
import 'package:capstone/core/shared/widgets/text/sub_title_text.dart';
import 'package:flutter/material.dart';

class NearbyServicesCard extends StatelessWidget {
  const NearbyServicesCard({
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
                    value: name,
                    isBold: true,
                  ),
                  SubtitleText(value: address),
                  SubtitleText(value: "Distance: ${distance.toStringAsFixed(2)} km"),
                ],
              ),
            ),
            const SizedBox(
              width: 10,
            ),
            IconButton(
              onPressed: () {},
              icon: Icon(
                Icons.call,
                size: 30,
                color: Colors.deepOrange,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
