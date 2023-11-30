// import 'package:flutter/material.dart';
//
// class CustomControls extends StatefulWidget {
//   final VoidCallback onPlayPause;
//   final bool isPlaying;
//
//   const CustomControls({
//     Key? key,
//     required this.onPlayPause,
//     required this.isPlaying,
//   }) : super(key: key);
//
//   @override
//   _CustomControlsState createState() => _CustomControlsState();
// }
//
// class _CustomControlsState extends State<CustomControls> {
//   bool _showIcon = true;
//
//   @override
//   void didUpdateWidget(covariant CustomControls oldWidget) {
//     super.didUpdateWidget(oldWidget);
//
//     // When isPlaying changes, show the icon and set a delayed task to hide it
//     if (widget.isPlaying) {
//       setState(() {
//         _showIcon = true;
//       });
//
//       // Delayed task to hide the icon after 1 second
//       Future.delayed(Duration(seconds: 1), () {
//         if (mounted) {
//           setState(() {
//             _showIcon = false;
//           });
//         }
//       });
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: widget.onPlayPause,
//       child: Center(
//         child: Visibility(
//           visible: _showIcon,
//           child: Icon(
//             widget.isPlaying ? Icons.pause_circle : Icons.play_circle,
//             size: 48.0,
//             color: Colors.white,
//           ),
//         ),
//       ),
//     );
//   }
// }
