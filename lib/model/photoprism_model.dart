import 'dart:async';

import 'package:drag_select_grid_view/drag_select_grid_view.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photoprism/api/albums.dart';
import 'package:photoprism/api/photos.dart';
import 'package:photoprism/common/photoprism_album_manager.dart';
import 'package:photoprism/common/photoprism_remote_config_loader.dart';
import 'package:photoprism/common/photoprism_loading_screen.dart';
import 'package:photoprism/common/photoprism_message.dart';
import 'package:photoprism/common/photoprism_photo_manager.dart';
import 'package:photoprism/common/photoprism_settings_manager.dart';
import 'package:photoprism/common/photoprism_uploader.dart';
import 'package:photoprism/model/album.dart';
import 'package:photoprism/model/photo.dart';

class PhotoprismModel extends ChangeNotifier {
  // general
  String photoprismUrl = "https://demo.photoprism.org";
  List<Photo> photoList;
  Map<String, Album> albums;

  // theming
  String applicationColor = "#424242";

  // photoprism uploader
  bool autoUploadEnabled = false;
  String autoUploadFolder = "/storage/emulated/0/DCIM/Camera";
  String autoUploadLastTimeActive = "Never";

  // runtime data
  bool isLoading = false;
  int selectedPageIndex = 0;
  DragSelectGridViewController gridController = DragSelectGridViewController();
  PhotoViewScaleState photoViewScaleState = PhotoViewScaleState.initial;
  BuildContext context;

  // helpers
  PhotoprismUploader photoprismUploader;
  PhotoprismRemoteConfigLoader photoprismRemoteConfigLoader;
  PhotoprismSettingsManager photoprismSettingsManager;
  PhotoprismPhotoManager photoprismPhotoManager;
  PhotoprismAlbumManager photoprismAlbumManager;
  PhotoprismLoadingScreen photoprismLoadingScreen;
  PhotoprismMessage photoprismMessage;

  PhotoprismModel() {
    initialize();
  }

  DragSelectGridViewController getGridController() {
    try {
      gridController.hasListeners;
    } catch (_) {
      gridController = DragSelectGridViewController();
      gridController.addListener(notifyListeners);
    }
    return gridController;
  }

  initialize() async {
    photoprismUploader = new PhotoprismUploader(this);
    photoprismRemoteConfigLoader = new PhotoprismRemoteConfigLoader(this);
    photoprismSettingsManager = new PhotoprismSettingsManager(this);
    photoprismPhotoManager = new PhotoprismPhotoManager(this);
    photoprismAlbumManager = new PhotoprismAlbumManager(this);
    photoprismLoadingScreen = new PhotoprismLoadingScreen(this);
    photoprismMessage = new PhotoprismMessage(this);

    await photoprismSettingsManager.loadPhotoprismUrl();
    photoprismRemoteConfigLoader.loadApplicationColor();
    Photos.loadPhotosFromNetworkOrCache(this, photoprismUrl, "");
    Albums.loadAlbumsFromNetworkOrCache(this, photoprismUrl);
    gridController.addListener(notifyListeners);
  }

  void setSelectedPageIndex(int index) {
    selectedPageIndex = index;
    notifyListeners();
  }

  Future<void> setPhotoprismUrl(url) async {
    await photoprismSettingsManager.savePhotoprismUrlToPrefs(url);
    this.photoprismUrl = url;
    notifyListeners();
  }

  void setPhotoViewScaleState(PhotoViewScaleState scaleState) {
    photoViewScaleState = scaleState;
    notifyListeners();
  }
}
