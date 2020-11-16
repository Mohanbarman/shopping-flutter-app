import 'package:ShoppingApp/models/offer.dart';
import 'package:uuid/uuid.dart';
import 'package:ShoppingApp/bloc/image_pick_bloc.dart';
import 'package:ShoppingApp/widgets/bottom_navigation_bar.dart';
import 'package:ShoppingApp/services/firebase_api.dart';
import 'package:ShoppingApp/services/localstorage.dart';
import 'package:flutter/material.dart';
import 'package:ShoppingApp/widgets/app_bar.dart';
import 'package:ShoppingApp/styles.dart';
import 'package:ShoppingApp/widgets/underlined_text.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:ShoppingApp/widgets/buttons.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:async';
import 'dart:io';

class EditOffer extends StatelessWidget {
  TextEditingController _titleController;
  TextEditingController _descriptionController;
  OfferModel model;
  String imagePath;

  EditOffer({this.model}) {
    _titleController = TextEditingController(text: model.title);
    _descriptionController = TextEditingController(text: model.description);
    imagePath = model.remoteImage;
    model = model;

    pickedImageBloc.imagePathSink.add(imagePath);
    LocalStorage.loadOfferData(model: this.model).then(
      (value) => pickedImageBloc.imageBytesSink.add(value),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(),
      bottomNavigationBar: CustomBottomNavigationBar(null),
      body: ListView(
        shrinkWrap: true,
        children: [
          Title(),
          ImagePlaceholder(pickedImageBloc),
          SizedBox(height: 30),
          UploadButton(pickedImageBloc),
          SizedBox(height: 30),
          UploadDetailsForm(
            titleController: _titleController,
            descriptionController: _descriptionController,
            model: this.model,
          ),
          SizedBox(height: 30),
        ],
      ),
    );
  }
}

class UploadDetailsForm extends StatelessWidget {
  final TextEditingController titleController;
  final TextEditingController descriptionController;

  final OfferModel model;

  UploadDetailsForm({
    this.titleController,
    this.descriptionController,
    this.model,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: ScreenPadding * 1.5),
      child: Column(
        children: [
          Row(children: [Text('Offer Title', style: AddFieldLabelStyle)]),
          SizedBox(height: 15),
          Container(
            padding: EdgeInsets.symmetric(horizontal: ScreenPadding),
            decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10)),
            child: TextField(
              controller: titleController,
              decoration: InputDecoration(
                border: InputBorder.none,
              ),
            ),
          ),
          SizedBox(height: 40),
          Row(children: [Text('Offer Description', style: AddFieldLabelStyle)]),
          SizedBox(height: 15),
          Container(
            padding: EdgeInsets.symmetric(horizontal: ScreenPadding),
            decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10)),
            child: TextField(
              controller: descriptionController,
              maxLines: 5,
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
                onPressed: () async {
                  await _save(this.model);
                },
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

  Future _save(OfferModel model) async {
    if (pickedImageBloc.cachedImageBytes != null &&
        pickedImageBloc.cachedImagePath != null) {
      print('this ran');
      var uuid = Uuid();
      var id = uuid.v1();
      print(pickedImageBloc.cachedImagePath);
      String filename =
          id.toString() + '.' + pickedImageBloc.cachedImagePath.split('.').last;
      await FirebaseStorageApi.uploadFile(
        file: File(pickedImageBloc.cachedImagePath),
        filename: filename,
      );
      await FirebaseStorageApi.updateDocument(
        model: OfferModel(
          title: titleController.value.text,
          description: descriptionController.value.text,
          image: filename,
          id: model.id,
        ),
        collection: 'offers',
      );
    } else {
      await FirebaseStorageApi.updateDocument(
        model: OfferModel(
          title: titleController.value.text,
          description: descriptionController.value.text,
          id: model.id,
          image: model.image,
        ),
        collection: 'offers',
      );
    }
  }
}

class Title extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: ScreenPadding),
        child: Center(
          child: UnderlinedText('Add a offer').noUnderline(),
        ),
      ),
    );
  }
}

class ImagePlaceholder extends StatelessWidget {
  final pickedImageBloc;
  ImagePlaceholder(this.pickedImageBloc);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: StreamBuilder(
        stream: pickedImageBloc.imageBytesStream,
        builder: (context, snapshot) {
          return Container(
            height: 250,
            width: 250,
            clipBehavior: Clip.hardEdge,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(OfferBorderRadius),
            ),
            child: snapshot.hasData == false
                ? Center(
                    child: Text('No image selected',
                        style: PlaceholderTextAddItem),
                  )
                : Image.memory(
                    snapshot.data,
                    fit: BoxFit.cover,
                  ),
          );
        },
      ),
    );
  }
}

class UploadButton extends StatelessWidget {
  final pickedImageBloc;
  UploadButton(this.pickedImageBloc);
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Center(
        child: Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: SecondaryColorDropShadow,
                offset: Offset(5, 7),
                blurRadius: 20,
              ),
            ],
          ),
          child: RaisedButton.icon(
            padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(50),
            ),
            onPressed: () {
              _pickImage().then(
                (value) async {
                  pickedImageBloc.imageBytesSink.add(await value.readAsBytes());
                  pickedImageBloc.imagePathSink.add(value.path);
                },
              );
            },
            color: SecondaryColor,
            label: Text('Select an image', style: UploadButtonTextStyle),
            icon: Icon(FeatherIcons.upload, color: Colors.white),
            elevation: 0,
          ),
        ),
      ),
    );
  }

  Future<PickedFile> _pickImage() async {
    return await ImagePicker().getImage(source: ImageSource.gallery);
  }
}
