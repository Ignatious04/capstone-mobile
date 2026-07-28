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
      child: Container(
        width: double.infinity,
        height: 100,
        padding: EdgeInsets.all(0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style:
                          Theme.of(
                            context,
                          ).textTheme.bodyMedium?.copyWith(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    Text(
                      address,
                      style:
                          Theme.of(
                            context,
                          ).textTheme.bodySmall?.copyWith(
                            color: Colors.black,
                          ),
                    ),
                    Text(
                      "${distance.toStringAsFixed(2)} km",
                      style:
                          Theme.of(
                            context,
                          ).textTheme.bodySmall?.copyWith(
                            color: Colors.black,
                          ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: 10,
              ),
              IconButton(
                onPressed: () {},
                icon: Icon(Icons.call),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
