import 'package:flutter/widgets.dart';
import 'package:photoprism/api/api.dart';
import 'package:photoprism/api/db_api.dart';
import 'package:photoprism/common/db.dart';
import 'package:photoprism/model/photoprism_model.dart';
import 'package:provider/provider.dart';

class PhotoManager {
  const PhotoManager();

  static Future<void> archivePhotos(
      BuildContext context, List<String> photoUUIDs) async {
    final PhotoprismModel model =
        Provider.of<PhotoprismModel>(context, listen: false);

    model.photoprismLoadingScreen.showLoadingScreen('Archive photos..');
    final int status = await apiArchivePhotos(photoUUIDs, model);
    if (status == 0) {
      model.gridController.clear();
      await apiUpdateDb(model);
      model.photoprismLoadingScreen.hideLoadingScreen();
    } else {
      model.photoprismLoadingScreen.hideLoadingScreen();
      model.photoprismMessage.showMessage('Archiving photos failed.');
    }
  }

  static String getPhotoThumbnailUrl(
      BuildContext context, PhotoWithFile photo) {
    final PhotoprismModel model = Provider.of<PhotoprismModel>(context);
    if (model.config == null) {
      return null;
    }
    final String filehash = photo.file.hash;
    return model.photoprismUrl +
        '/api/v1/t/' +
        filehash +
        '/' +
        model.config.previewToken +
        '/tile_224';
  }

  static int getPhotoIndexInScrollView(BuildContext context) {
    final PhotoprismModel model = Provider.of<PhotoprismModel>(context);
    try {
      final double currentPhoto = (model.photos.length - 1) *
          model.scrollController.offset /
          (model.scrollController.position.maxScrollExtent -
              model.scrollController.position.minScrollExtent);
      if (currentPhoto.isNaN || currentPhoto.isInfinite) {
        return 0;
      }
      return currentPhoto.floor();
    } catch (_) {
      return 0;
    }
  }
}
