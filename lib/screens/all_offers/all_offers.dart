import 'package:ShoppingApp/models/offer.dart';
import 'package:ShoppingApp/services/firebase_api.dart';
import 'package:ShoppingApp/services/localstorage.dart';
import 'package:ShoppingApp/styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:ShoppingApp/widgets/app_bar.dart';
import 'package:ShoppingApp/widgets/bottom_navigation_bar.dart';
import 'package:ShoppingApp/widgets/underlined_text.dart';
import 'package:ShoppingApp/widgets/offer_dialog.dart';
import 'package:ShoppingApp/widgets/shimmer_placeholders.dart';

class Offers extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BackgroundColor,
      appBar: CustomAppBar(),
      bottomNavigationBar: CustomBottomNavigationBar(2),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            child: UnderlinedText('All offers'),
            padding: EdgeInsets.only(
              left: ScreenPadding,
              bottom: ScreenPadding,
              top: ScreenPadding,
            ),
          ),
          StreamBuilder(
            stream: FirebaseStorageApi.streamOfCollection(collection: 'offers'),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return CircularProgressIndicator();
            },
          )
        ],
      ),
    );
  }
}
