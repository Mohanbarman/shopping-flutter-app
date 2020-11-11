import 'package:ShoppingApp/components/bottom_navigation_bar.dart';
import 'package:ShoppingApp/components/shimmer_placeholders.dart';
import 'package:ShoppingApp/models/brand.dart';
import 'package:ShoppingApp/models/category.dart';
import 'package:ShoppingApp/services/firebase_api.dart';
import 'package:ShoppingApp/shared/localstorage.dart';
import 'package:flutter_multiselect/flutter_multiselect.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:ShoppingApp/components/underlined_text.dart';
import 'package:ShoppingApp/components/app_bar.dart';
import 'package:ShoppingApp/components/buttons.dart';
import 'package:ShoppingApp/styles.dart';
import 'package:flutter/material.dart';

class AddProduct extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(),
      bottomNavigationBar: CustomBottomNavigationBar(null),
      body: ListView(
        shrinkWrap: true,
        children: [
          Title(),
          Padding(
            padding: const EdgeInsets.all(ScreenPadding),
            child: Text('Product Image', style: AddFieldLabelStyle),
          ),
          ImageRow(),
          SizedBox(height: 30),
          UploadDetailsForm(),
          SizedBox(height: 30),
        ],
      ),
    );
  }
}

class UploadDetailsForm extends StatefulWidget {
  @override
  _UploadDetailsFormState createState() => _UploadDetailsFormState();
}

class _UploadDetailsFormState extends State<UploadDetailsForm> {
  String dropdownValue = 'fan';

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: ScreenPadding * 1.5),
      child: Column(
        children: [
          StreamBuilder(
            stream: FirebaseStorageApi.streamOfCollection(
              collection: 'brands',
            ),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return TextInputShimmer();
              return DropdownButton(
                value: dropdownValue,
                items: snapshot.data.docs
                    .toList()
                    .map(
                      (e) {
                        print(e.id);
                        return DropdownMenuItem<String>(
                          child: Text(e['name']),
                          value: e['name'],
                        );
                      },
                    )
                    .toList()
                    .cast<DropdownMenuItem<String>>(),
                onChanged: (String value) {
                  setState(() {
                    dropdownValue = value;
                  });
                },
              );
            },
          ),
          StreamBuilder(
              stream: FirebaseStorageApi.streamOfCollection(
                collection: 'categories',
              ),
              builder: (context, snapshot) {
                return MultiSelect(
                  autovalidate: true,
                  titleText: 'title',
                  validator: (value) {
                    if (value == null) {
                      return 'Please select one or more option(s)';
                    }
                    return null;
                  },
                  errorText: 'Please select one or more option(s)',
                  dataSource: snapshot.data.docs
                      .toList()
                      .map(
                        (e) => {
                          'value': e.id,
                          'display': e['name'],
                        },
                      )
                      .toList(),
                  textField: 'display',
                  valueField: 'value',
                  filterable: true,
                  required: true,
                  onSaved: (value) {
                    print('value saved');
                    print('The value is $value');
                  },
                );
              }),
          SizedBox(height: 15),
          Row(children: [Text('Product Title', style: AddFieldLabelStyle)]),
          SizedBox(height: 15),
          Container(
            padding: EdgeInsets.symmetric(horizontal: ScreenPadding),
            decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10)),
            child: TextField(
              decoration: InputDecoration(
                border: InputBorder.none,
              ),
            ),
          ),
          SizedBox(height: 40),
          Row(children: [
            Text('Product Description', style: AddFieldLabelStyle)
          ]),
          SizedBox(height: 15),
          Container(
            padding: EdgeInsets.symmetric(horizontal: ScreenPadding),
            decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10)),
            child: TextField(
              maxLines: 8,
              decoration: InputDecoration(
                border: InputBorder.none,
              ),
            ),
          ),
          SizedBox(height: 40),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              HighlightedShadowButton(
                title: 'Save',
                fgColor: DefaultGreenColor,
                shadowColor: DefaultShadowGreenColor,
                onPressed: () {},
              ),
              HighlightedShadowButton(
                title: 'Cancel',
                fgColor: DefaultRedColor,
                shadowColor: DefaultShadowRedColor,
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class Title extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Padding(
        padding: EdgeInsets.all(ScreenPadding),
        child: UnderlinedText('Add product').noUnderline(),
      ),
    );
  }
}

class ImageRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: ListView(
        scrollDirection: Axis.horizontal,
        shrinkWrap: true,
        physics: ClampingScrollPhysics(),
        children: [
          SizedBox(width: ScreenPadding),
          GestureDetector(
            onTap: () {},
            child: Container(
              height: 50,
              width: 200,
              clipBehavior: Clip.hardEdge,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Stack(
                children: [
                  Center(
                    child: Icon(
                      FeatherIcons.upload,
                      size: 70,
                      color: DefaultGreenColor,
                    ),
                  ),
                  Positioned(
                    bottom: 15,
                    child: Container(
                      width: 200,
                      child: Center(
                          child:
                              Text('900x900', style: PlaceholderTextAddItem)),
                    ),
                  )
                ],
              ),
            ),
          ),
          SizedBox(width: ScreenPadding),
        ],
      ),
    );
  }
}
