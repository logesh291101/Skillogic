import 'package:flutter_svg/svg.dart';
import 'package:skillogic/model/user_model.dart';
import 'package:flutter/material.dart';
import 'package:skillogic/pages/profile_screen.dart';
import '../pages/notification_page.dart';
import '../pages/update_profile_page.dart';

class CustomWidget {
  static AppBar getSkillogicAppBar(
    BuildContext context,
    UserModel? userModel,
    int refreshed,
  ) {
    return AppBar(
      backgroundColor: Colors.white,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Image.network(
            "https://firebasestorage.googleapis.com/v0/b/skillogic-a5248.appspot.com/o/skillogic.png?alt=media&token=ca907448-3e21-4583-8bf2-3c0dd53a72c4",
            height: 24,
            fit: BoxFit.contain,
          ),
          // Text(userModel?.userImage??""),
          Row(
            children: [
              IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const NotificationPage(),
                    ),
                  );
                },
                icon: const Icon(Icons.notifications, color: Colors.grey),
              ),
              SizedBox(width: 5),
              if (refreshed == 1 && userModel != null)
                SizedBox(
                  width: 40,
                  height: 40,
                  child: MaterialButton(
                    height: 40,
                    padding: EdgeInsets.zero,
                    shape: const CircleBorder(),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ProfileScreen(),
                        ),
                      );
                    },
                    child: SizedBox(
                      width: 120.0,
                      height: 120.0,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(60.0),
                        child: Image.network(
                          userModel.userImage,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      elevation: 0.2,
    );
  }

  static void showInternetDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible:true,
      builder: (context) {
        return Dialog(
          child: Container(
            height: MediaQuery.of(context).size.height * 0.3,
            //width: MediaQuery.of(context).size.width * 0.4,
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        height: MediaQuery.of(context).size.height * 0.30,
                        width: MediaQuery.of(context).size.width * 0.30,
                        child: SvgPicture.asset("assets/lost-connection.svg"),
                      ),
                      SizedBox(width: 10),
                      Text(
                        "You’re offline",
                        style: TextStyle(
                          fontSize: MediaQuery.of(context).size.width * 0.05,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                // const SizedBox(height:7),
                Text(
                  //"${remoteConfigModel.update_reason}",
                  "Please connect to the internet to \ncontinue your learning.",
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w400),
                ),
                const SizedBox(height: 16),
                MaterialButton(
                  onPressed: () async {
                    Navigator.pop(context as BuildContext);
                  },
                  child: const Text("Okay"),
                  color: Colors.redAccent,textColor:Colors.white,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class CustomWidget2 {
  static AppBar getSkillogicAppBar(
    BuildContext context,
    UserModel? userModel,
    int refreshed,
  ) {
    return AppBar(
      backgroundColor: Colors.white,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Image.network(
            "https://firebasestorage.googleapis.com/v0/b/skillogic-a5248.appspot.com/o/skillogic.png?alt=media&token=ca907448-3e21-4583-8bf2-3c0dd53a72c4",
            height: 24,
            fit: BoxFit.contain,
          ),
          // Text(userModel?.userImage??""),
          Row(
            children: [
              IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const NotificationPage(),
                    ),
                  );
                },
                icon: const Icon(Icons.notifications, color: Colors.grey),
              ),
              SizedBox(width: 5),
              if (refreshed == 1 && userModel != null)
                SizedBox(
                  width: 40,
                  height: 40,
                  child: MaterialButton(
                    height: 40,
                    padding: EdgeInsets.zero,
                    shape: const CircleBorder(),
                    onPressed: () {
                      // Navigator.push(
                      //     context,
                      //     MaterialPageRoute(
                      //         builder: (context) =>
                      //         const UpdateProfileScreen()));
                    },
                    child: SizedBox(
                      width: 120.0,
                      height: 120.0,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(60.0),
                        child: Image.network(
                          userModel.userImage,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      elevation: 0.2,
    );
  }
}
