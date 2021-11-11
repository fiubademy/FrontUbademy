import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import 'package:fiubademy/src/pages/home.dart';

class LocationRequestPage extends StatelessWidget {
  const LocationRequestPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ubademy'),
      ),
      body: SafeArea(
        child: Container(
          constraints: const BoxConstraints.expand(),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                Icons.location_off_outlined,
                size: 170,
                color: Theme.of(context).colorScheme.secondaryVariant,
              ),
              const SizedBox(height: 16.0),
              Text(
                'Whoops! It looks like your location isn\'t enabled.',
                style: Theme.of(context).textTheme.headline6,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16.0),
              Text('Please enable Ubademy to access your location to continue',
                  style: Theme.of(context).textTheme.subtitle1,
                  textAlign: TextAlign.center),
              const SizedBox(height: 32.0),
              ElevatedButton(
                onPressed: () async {
                  if (await Geolocator.isLocationServiceEnabled()) {
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const HomePage()));
                  }
                },
                child: Text('Enable Location'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
