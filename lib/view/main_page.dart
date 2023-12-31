// ignore_for_file: inference_failure_on_instance_creation, lines_longer_than_80_chars, use_build_context_synchronously

import 'package:explorecos/plants/bloc/nature_bloc.dart';
import 'package:explorecos/view/results_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:inaturalist_repository/inaturalist_repository.dart';

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<NatureBloc>(
      create: (_) => NatureBloc(
        inaturalistRepository: context.read<iNaturalistRepository>(),
      ),
      child: const MainPageView(),
    );
  }
}

class MainPageView extends StatefulWidget {
  const MainPageView({super.key});

  @override
  State<MainPageView> createState() => _MainPageViewState();
}

class _MainPageViewState extends State<MainPageView> {
  LocationPermission hasPermission = LocationPermission.denied;
  double latitude = 0;
  double longitude = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<NatureBloc, NatureState>(listener: (context, state) {
        if (state is NatureLoadSuccess) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ResultPage(natureList: state.natureList),
            ),
          );
        }
      }, builder: (BuildContext context, NatureState state) {
        if (state is NatureLoadFailure) {
          return const Center(
            child: Text('Could not load nature list'),
          );
        } else if (state is NatureLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else {
          if (hasPermission == LocationPermission.denied) {}
          return FutureBuilder(
            future: setPermissions(),
            builder: (context, snapshot) {
              return Stack(
                fit: StackFit.expand,
                children: <Widget>[
                  Image.asset(
                    'assets/background.jpg',
                    fit: BoxFit.cover,
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      //child
                      const Text(
                        'ExplorEcos',
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 48,
                            color: Color.fromARGB(255, 3, 65, 5)),
                      ),
                      const SizedBox(height: 30),
                      const Text(
                        'What would you \n like to Explore?',
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 100),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                              side: const BorderSide(
                                  width: 2,
                                  color: Color.fromARGB(255, 12, 80, 12))),
                          backgroundColor:
                              const Color.fromARGB(255, 72, 138, 25),
                          foregroundColor:
                              const Color.fromARGB(255, 255, 255, 255),
                          enableFeedback: true,
                        ),
                        onPressed: () {
                          context
                              .read<NatureBloc>()
                              .add(PlantsRequested(latitude, longitude));
                        },
                        child: const Text('Plants'),
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                              side: const BorderSide(
                                  width: 2,
                                  color: Color.fromARGB(255, 77, 37, 14))),
                          backgroundColor:
                              const Color.fromARGB(255, 119, 63, 17),
                          foregroundColor:
                              const Color.fromARGB(255, 255, 255, 255),
                          enableFeedback: true,
                        ),
                        onPressed: () {
                          context
                              .read<NatureBloc>()
                              .add(AnimalsRequested(latitude, longitude));
                          //placeholder
                        },
                        child: const Text('Animals'),
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
                  //MORE STUFF GOES HERE
                ],
              );
            },
          );
        }
      }),
    );
  }

  Future<void> setPermissions() async {
    await Geolocator.requestPermission();
    final hasPerm = await Geolocator.checkPermission();
    final userLoc = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    setState(() {
      hasPermission = hasPerm;
      latitude = userLoc.latitude;
      longitude = userLoc.longitude;
    });
  }
}
