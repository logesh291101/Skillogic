
//
// class CustomBottomNavBar extends StatelessWidget {
//   final int selectedIndex;
//   final Function(int) onItemTapped;
//
//   const CustomBottomNavBar({
//     Key? key,
//     required this.selectedIndex,
//     required this.onItemTapped,
//   }) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: const BorderRadius.only(
//           topLeft: Radius.circular(16.0),
//           topRight: Radius.circular(16.0),
//         ),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.grey.shade300,
//             offset: const Offset(0, -2),
//             blurRadius: 6.0,
//           ),
//         ],
//       ),
//       child: BottomNavigationBar(
//         type: BottomNavigationBarType.fixed,
//         selectedFontSize: 12,
//         unselectedFontSize: 12,
//         currentIndex: selectedIndex >= 2 ? selectedIndex + 1 : selectedIndex,
//         selectedItemColor: Colors.blue,
//         unselectedItemColor: Colors.grey,
//         onTap: (index) {
//           if (index == 2) return; // Skip FAB space
//           onItemTapped(index > 2 ? index - 1 : index); // Adjust index
//         },
//         items: [
//           BottomNavigationBarItem(
//             icon: Icon(
//               selectedIndex == 0 ? Icons.home : Icons.home_outlined,
//             ),
//             label: 'Home',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(
//               selectedIndex == 1 ? Icons.school : Icons.school_outlined,
//             ),
//             label: 'Classroom',
//           ),
//           BottomNavigationBarItem(
//             icon: const SizedBox.shrink(), // Placeholder for FAB
//             label: '',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(
//               selectedIndex == 2 ? Icons.groups_rounded : Icons.groups_outlined,
//             ),
//             label: 'Referral',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(
//               selectedIndex == 3
//                   ? Icons.more_vert_rounded
//                   : Icons.more_vert_outlined,
//             ),
//             label: 'More',
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;
  final int refreshed; // Pass the refreshed value

  const CustomBottomNavBar({
    Key? key,
    required this.selectedIndex,
    required this.onItemTapped,
    required this.refreshed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final navigationItems = refreshed == 0
        ? [
      BottomNavigationBarItem(
        icon: Icon(
          selectedIndex == 0 ? Icons.home : Icons.home_outlined,
        ),
        label: 'Home',
      ),
      BottomNavigationBarItem(
        icon: Icon(
          selectedIndex == 1 ? Icons.school : Icons.school_outlined,
        ),
        label: 'Classroom',
      ),
    ]
        : [
      BottomNavigationBarItem(
        icon: Icon(
          selectedIndex == 0 ? Icons.home : Icons.home_outlined,
        ),
        label: 'Home',
      ),
      BottomNavigationBarItem(
        icon: Icon(
          selectedIndex == 1 ? Icons.school : Icons.school_outlined,
        ),
        label: 'Classroom',
      ),
      BottomNavigationBarItem(
        icon: const SizedBox.shrink(), // Placeholder for FAB
        label: '',
      ),
      BottomNavigationBarItem(
        icon: Icon(
          selectedIndex == 2 ? Icons.groups_rounded : Icons.groups_outlined,
        ),
        label: 'Referral',
      ),
      BottomNavigationBarItem(
        icon: Icon(
          selectedIndex == 3
              ? Icons.more_vert_rounded
              : Icons.more_vert_outlined,
        ),
        label: 'More',
      ),
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16.0),
          topRight: Radius.circular(16.0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            offset: const Offset(0, -2),
            blurRadius: 6.0,
          ),
        ],
      ),
      child: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        currentIndex: selectedIndex >= 2 && refreshed != 0
            ? selectedIndex + 1
            : selectedIndex,
        selectedItemColor: Colors.purple,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          if (refreshed != 0 && index == 2) return; // Skip FAB space
          onItemTapped(
              refreshed != 0 && index > 2 ? index - 1 : index); // Adjust index
        },
        items: navigationItems,
      ),
    );
  }
}

