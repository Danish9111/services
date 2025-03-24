import 'package:flutter/material.dart';

class RoleSelectionPage extends StatefulWidget {
  const RoleSelectionPage({super.key});

  @override
  RoleSelectionPageState createState() => RoleSelectionPageState();
}

class RoleSelectionPageState extends State<RoleSelectionPage> {
  String _selectedRole = '';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: const Text(''),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/labour_services_logo.png',
                width: MediaQuery.of(context).size.width * .4,
                height: MediaQuery.of(context).size.width * .4,
              ),
              const Text(
                'Select your role',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(
                height: 20,
              ),
              OutlinedButton(
                  onPressed: () {
                    _selectedRole = 'worker';
                    Navigator.pushNamed(context, 'dashBoardForWorker');
                  },
                  style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 100, vertical: 15),
                      side: const BorderSide(
                        width: 1,
                      )),
                  child: const Text(
                    'Worker',
                    style: TextStyle(color: Colors.black),
                  )),
              const SizedBox(
                height: 20,
              ),
              OutlinedButton(
                  onPressed: () {
                    _selectedRole = 'client';
                    Navigator.pushNamed(context, 'dashBoardForWorker');
                  },
                  style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      side: const BorderSide(width: 1),
                      padding: const EdgeInsets.symmetric(horizontal: 105, vertical: 15)),
                  child: const Text(
                    'Client',
                    style: TextStyle(color: Colors.black),
                  )),
            ],
          ),
        ));
  }
}
