import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class ImageService {
  static final ImageService instance = ImageService._init();
  final ImagePicker _picker = ImagePicker();

  ImageService._init();

  // التقاط صورة من الكاميرا
  Future<String?> captureImage() async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (photo != null) {
        return await _saveImage(photo.path);
      }
      return null;
    } catch (e) {
      print('خطأ في التقاط الصورة: $e');
      return null;
    }
  }

  // اختيار صورة من المعرض
  Future<String?> pickImageFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        return await _saveImage(image.path);
      }
      return null;
    } catch (e) {
      print('خطأ في اختيار الصورة: $e');
      return null;
    }
  }

  // حفظ الصورة في مجلد التطبيق
  Future<String> _saveImage(String sourcePath) async {
    try {
      final Directory appDir = await getApplicationDocumentsDirectory();
      final String exerciseImagesDir = path.join(appDir.path, 'exercise_images');
      
      // إنشاء المجلد إذا لم يكن موجوداً
      final Directory directory = Directory(exerciseImagesDir);
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }

      // إنشاء اسم فريد للصورة
      final String fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      final String savedPath = path.join(exerciseImagesDir, fileName);

      // نسخ الصورة
      final File sourceFile = File(sourcePath);
      await sourceFile.copy(savedPath);

      return savedPath;
    } catch (e) {
      print('خطأ في حفظ الصورة: $e');
      rethrow;
    }
  }

  // حذف صورة
  Future<bool> deleteImage(String imagePath) async {
    try {
      final File file = File(imagePath);
      if (await file.exists()) {
        await file.delete();
        return true;
      }
      return false;
    } catch (e) {
      print('خطأ في حذف الصورة: $e');
      return false;
    }
  }

  // التحقق من وجود الصورة
  Future<bool> imageExists(String imagePath) async {
    try {
      final File file = File(imagePath);
      return await file.exists();
    } catch (e) {
      return false;
    }
  }

  // الحصول على حجم الصورة
  Future<int?> getImageSize(String imagePath) async {
    try {
      final File file = File(imagePath);
      if (await file.exists()) {
        return await file.length();
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
