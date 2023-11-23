// class SearchBar extends StatelessWidget {
//   final TextEditingController controller;
//   final VoidCallback onSearch;
//
//   SearchBar({required this.controller, required this.onSearch});
//
//   @override
//   Widget build(BuildContext context) {
//     return PreferredSize(
//       preferredSize: Size.fromHeight(50),
//       child: Padding(
//         padding: const EdgeInsets.all(8.0),
//         child: TextField(
//           controller: controller,
//           decoration: InputDecoration(
//             hintText: 'Search...',
//             prefixIcon: Icon(Icons.search),
//             border: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(25.0),
//               borderSide: BorderSide(),
//             ),
//           ),
//           onSubmitted: (_) => onSearch(),
//         ),
//       ),
//     );
//   }
// }
