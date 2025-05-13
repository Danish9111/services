// import 'dart:typed_data';
// import 'package:flutter/material.dart';
// import 'package:flutter/rendering.dart';
// import 'dart:ui';
// import 'package:image_gallery_saver/image_gallery_saver.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:qr_flutter/qr_flutter.dart';
// import 'package:intl/intl.dart';

// class ServiceCompletionCard extends StatefulWidget {
//   final String workerName;
//   final String clientName;
//   final String serviceType;
//   final DateTime completionDate;

//   const ServiceCompletionCard({
//     super.key,
//     required this.workerName,
//     required this.clientName,
//     required this.serviceType,
//     required this.completionDate,
//   });

//   @override
//   State<ServiceCompletionCard> createState() => _ServiceCompletionCardState();
// }

// class _ServiceCompletionCardState extends State<ServiceCompletionCard> {
//   final GlobalKey _globalKey = GlobalKey();

//   Future<void> _saveToGallery() async {
//     if (await _requestPermission()) {
//       try {
//         RenderRepaintBoundary boundary = _globalKey.currentContext!
//             .findRenderObject() as RenderRepaintBoundary;
//         var image = await boundary.toImage(pixelRatio: 3.0);
//         ByteData? byteData =
//             await image.toByteData(format: ImageByteFormat.png);
//         Uint8List pngBytes = byteData!.buffer.asUint8List();

//         await ImageGallerySaver.saveImage(pngBytes, quality: 100);
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Card saved to gallery!')),
//         );
//       } catch (e) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Error saving card: $e')),
//         );
//       }
//     }
//   }

//   Future<bool> _requestPermission() async {
//     Map<Permission, PermissionStatus> statuses = await [
//       Permission.storage,
//     ].request();

//     return statuses[Permission.storage] == PermissionStatus.granted;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Service Completion Certificate'),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.download),
//             onPressed: _saveToGallery,
//           ),
//         ],
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16.0),
//         child: RepaintBoundary(
//           key: _globalKey,
//           child: Card(
//             elevation: 8,
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(15),
//             ),
//             child: Container(
//               padding: const EdgeInsets.all(20),
//               decoration: BoxDecoration(
//                 gradient: const LinearGradient(
//                   colors: [Colors.blueAccent, Colors.lightBlue],
//                   begin: Alignment.topLeft,
//                   end: Alignment.bottomRight,
//                 ),
//                 borderRadius: BorderRadius.circular(15),
//               ),
//               child: Column(
//                 children: [
//                   // Header Section
//                   const CircleAvatar(
//                     radius: 40,
//                     backgroundColor: Colors.white,
//                     child: Icon(Icons.work, size: 40, color: Colors.blue),
//                   ),
//                   const SizedBox(height: 15),
//                   const Text(
//                     'SERVICE COMPLETION CERTIFICATE',
//                     style: TextStyle(
//                       fontSize: 20,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.white,
//                     ),
//                   ),
//                   const Divider(color: Colors.white, height: 30),

//                   // Service Details
//                   _buildDetailRow(Icons.person, 'Worker:', widget.workerName),
//                   _buildDetailRow(
//                       Icons.person_outline, 'Client:', widget.clientName),
//                   _buildDetailRow(Icons.home_repair_service, 'Service:',
//                       widget.serviceType),
//                   _buildDetailRow(
//                     Icons.calendar_today,
//                     'Completion Date:',
//                     DateFormat('dd MMM yyyy').format(widget.completionDate),
//                   ),
//                   const SizedBox(height: 20),

//                   // Verification Section
//                   Container(
//                     padding: const EdgeInsets.all(15),
//                     decoration: BoxDecoration(
//                       color: Colors.white.withOpacity(0.1),
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                     child: Column(
//                       children: [
//                         const Text(
//                           'Verification Code',
//                           style: TextStyle(
//                             color: Colors.white,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                         const SizedBox(height: 10),
//                         QrImageView(
//                           data:
//                               '${widget.workerName}-${widget.completionDate.millisecondsSinceEpoch}',
//                           version: QrVersions.auto,
//                           size: 100,
//                           backgroundColor: Colors.white,
//                         ),
//                         const SizedBox(height: 10),
//                         Text(
//                           'ID: ${DateTime.now().millisecondsSinceEpoch}',
//                           style: const TextStyle(
//                             color: Colors.white,
//                             fontStyle: FontStyle.italic,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),

//                   // Footer
//                   const Padding(
//                     padding: EdgeInsets.only(top: 20),
//                     child: Text(
//                       'This certificate verifies the successful completion\nof the mentioned service',
//                       textAlign: TextAlign.center,
//                       style: TextStyle(
//                         color: Colors.white,
//                         fontSize: 12,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildDetailRow(IconData icon, String label, String value) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 8.0),
//       child: Row(
//         children: [
//           Icon(icon, color: Colors.white),
//           const SizedBox(width: 10),
//           Text(
//             label,
//             style: const TextStyle(
//               color: Colors.white,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           const SizedBox(width: 10),
//           Expanded(
//             child: Text(
//               value,
//               style: const TextStyle(
//                 color: Colors.white,
//                 fontSize: 16,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
