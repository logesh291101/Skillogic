import 'package:skillogic/model/user_model.dart';
import 'package:flutter/material.dart';

import '../pages/notification_page.dart';
import '../pages/update_profile_page.dart';

class CustomWidget {
  static AppBar getSkillogicAppBar(BuildContext context, UserModel? userModel, int refreshed) {
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
                              builder: (context) =>
                              const NotificationPage()));
                    },
                    icon: const Icon(
                      Icons.notifications,
                      color: Colors.grey,
                    )),
                if (refreshed == 1 && userModel  != null)

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
                                  builder: (context) =>
                                  const UpdateProfileScreen()));
                        },
                        child: SizedBox(
                            width: 120.0,
                            height: 120.0,
                            child: ClipRRect(
                                borderRadius: BorderRadius.circular(60.0),
                                child: Image.network(userModel.userImage, fit: BoxFit.cover,),
                                // child: FadeInImage(
                                //   placeholder: AssetImage("assets/skillogic_icon.png"),
                                //   // image: NetworkImage(userModel.userImage),
                                //   image: AssetImage("assets/skillogic_icon.png"),
                                //   fit: BoxFit.cover,
                                // )
                            ))),
                  )
              ],
            )
          ],
        ),
        elevation: 0.2,
      );
  }
}