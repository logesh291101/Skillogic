
import 'package:flutter/material.dart';
import '../../../helper/user_details.dart';
import '../../../model/user_model.dart';
import '../../../widgets/CustomWidget.dart';
import '../../account_page.dart';
import '../constants.dart';
import '../widgets/filter_widget.dart';
import 'lms_home_screen.dart';
import 'my_wishlist_screen.dart';
import 'my_courses_screen.dart';

class TabsScreen extends StatefulWidget {
  static const routeName = '/lms_home_tab';
  const TabsScreen({Key? key}) : super(key: key);

  @override
  State<TabsScreen> createState() => _TabsScreenState();
}

class _TabsScreenState extends State<TabsScreen> {
  final List<Widget> _pages = [
    const HomeScreenContent(),
    const MyCoursesScreen(),
    const MyWishlistScreen(),
    const AccountScreen(),
  ];
  int refreshed = 0;
  var _selectedPageIndex = 0;

  var userDetails = UserDetails();
  UserModel? userModel;

  _getUserDetail() async {
    userModel = await userDetails.getDetail();
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _getUserDetail();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      //appBar: CustomWidget2.getDatamitesAppBar2(context, userModel, 1),
      appBar:CustomWidget.getSkillogicAppBar(context, userModel, 1),
      body: _pages[_selectedPageIndex],
      floatingActionButton: _selectedPageIndex != 3
          ? FloatingActionButton(
        onPressed: () => _showFilterModal(context),
        backgroundColor: kOrangeColor,
        child: const Icon(Icons.filter_list, color: Colors.white),
      )
          : null,
      bottomNavigationBar: BottomNavigationBar(
        onTap: _selectPage,
        items: const [
          BottomNavigationBarItem(
            backgroundColor: kBackgroundColor,
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            backgroundColor: kBackgroundColor,
            icon: Icon(Icons.school_outlined),
            activeIcon: Icon(Icons.school),
            label: 'My Course',
          ),
          BottomNavigationBarItem(
            backgroundColor: kBackgroundColor,
            icon: Icon(Icons.favorite_border),
            activeIcon: Icon(Icons.favorite),
            label: 'Wishlist',
          ),
          BottomNavigationBarItem(
            backgroundColor: kBackgroundColor,
            icon: Icon(Icons.more_vert_outlined),
            activeIcon: Icon(Icons.more_vert_rounded),
            label: 'More',
          ),
        ],
        backgroundColor: Colors.white,
        unselectedItemColor: kSecondaryColor,
        selectedItemColor: Colors.blue,
        currentIndex: _selectedPageIndex,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }

  void _selectPage(int index) {
    setState(() {
      _selectedPageIndex = index;
    });
  }

  void _showFilterModal(BuildContext ctx) {
    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      builder: (_) {
        return const FilterWidget();
      },
    );
  }
}