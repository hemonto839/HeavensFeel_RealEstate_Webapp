import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:realestate/accessories/navigation_container.dart';
import 'package:realestate/pages/chat_home_page.dart';
import 'package:realestate/pages/property_details/property_page_show.dart';
import 'package:realestate/pages/user_profile/user_profile_setting.dart';

class AccountSetting extends StatelessWidget {
  const AccountSetting({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Account setting Page"),
      ),
      body: ListView(
        children: [
          const SizedBox(height: 7),          
          NavigationContainer(
            title: "Profile Setting",
            onTap: (){
              Navigator.push(
                context, 
                MaterialPageRoute(
                  builder: (_) => UserProfileSetting()
                )  
              );
            },
            subtitle: "Change your account details and password", 
          ),
          const SizedBox(height: 7),          

          NavigationContainer(
            title: "Messaging",
            onTap: (){
              Navigator.push(
                context, 
                MaterialPageRoute(
                  builder: (_) => ChatHomePage()
                )  
              );
            },
            subtitle: "Communicate with other users", 
          ),
          const SizedBox(height: 7),  

          NavigationContainer(
            title: "Notification Setting",
            onTap: (){

            },
            subtitle: "Change your account --- and ---", 
     
          ),
          const SizedBox(height: 7),          

          NavigationContainer(
            title: "All My Properties",
            onTap: (){
              Navigator.push(
                context, 
                MaterialPageRoute(
                  builder: (_) => PropertyPageShow(pageType: PropertyPageType.myProperties)
                )
              );
            },
            subtitle: "Check all your properties", 
          ),
          const SizedBox(height: 7),        

          NavigationContainer(
            title: "Favourite Properties",
            onTap: (){
              Navigator.push(
                context, 
                MaterialPageRoute(
                  builder: (_) => PropertyPageShow(pageType: PropertyPageType.saved)
                )
              );
            },
            subtitle: "Check all your favourite properties", 
          ),
          const SizedBox(height: 7),

          NavigationContainer(
            title: "Sign Out",
            onTap: () async {
              await FirebaseAuth.instance.signOut();
              // ignore: use_build_context_synchronously
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
          ),
          const SizedBox(height: 7),

        ],
      ),
      
    );
  }
}