import 'package:flutter/material.dart';

// void main() {
//   runApp(const GetStartedPage());
// }
//
// class GetStartedPage extends StatelessWidget {
//   const GetStartedPage({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       routes: {'dashBoardForWorker': (context) => const DashboardForWorker()},
//       home: const RoleSelectionPage(),
//     );
//   }
// }

class GetStartedPage extends StatefulWidget {
  const GetStartedPage({super.key});

  @override
  GetStartedPageState createState() => GetStartedPageState();
}

class GetStartedPageState extends State<GetStartedPage> {
  String selectedRole = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text(''),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SizedBox(
                  height: 150, width: 150, child: Image.asset('assets/labour_services_logo.png')),
              const SizedBox(
                height: 50,
              ),
              const Text(
                'Select your Role',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(
                height: 20,
              ),
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 100, vertical: 15),
                  backgroundColor: selectedRole == 'client'
                      ? Colors.orangeAccent.withOpacity(0.5)
                      : Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  side: BorderSide(
                    color: selectedRole == 'client' ? Colors.transparent : Colors.black,
                  ),
                ),
                onPressed: () {
                  setState(() {
                    selectedRole = 'client';
                  });
                  // Optionally navigate to a specific page based on the role
                  // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => ClientDashboard()));
                },
                child: Text(
                  'Client',
                  style: TextStyle(
                    color: selectedRole == 'client' ? Colors.white : Colors.black,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 96, vertical: 15),
                  backgroundColor: selectedRole == 'worker'
                      ? Colors.orangeAccent.withOpacity(0.5)
                      : Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  side: BorderSide(
                    color: selectedRole == 'worker' ? Colors.transparent : Colors.black,
                  ),
                ),
                onPressed: () {
                  Navigator.pushNamed(context, '/dashBoardForWorker');
                  setState(() {
                    selectedRole = 'worker';
                  });
                  // Optionally navigate to a specific page based on the role
                  // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => WorkerDashboard()));
                },
                child: Text(
                  'Worker',
                  style: TextStyle(
                    color: selectedRole == 'worker' ? Colors.white : Colors.black,
                  ),
                ),
              ),
            ],
          ),
        ));
  }
}
