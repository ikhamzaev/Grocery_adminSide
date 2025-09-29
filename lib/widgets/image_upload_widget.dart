import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';

import '../core/app_export.dart';
import '../services/storage_service.dart';

class ImageUploadWidget extends StatefulWidget {
  final List<String> initialImages;
  final Function(List<String>) onImagesChanged;
  final String bucket;
  final String? customPath;
  final int maxImages;
  final bool showPreview;

  const ImageUploadWidget({
    Key? key,
    required this.initialImages,
    required this.onImagesChanged,
    required this.bucket,
    this.customPath,
    this.maxImages = 5,
    this.showPreview = true,
  }) : super(key: key);

  @override
  State<ImageUploadWidget> createState() => _ImageUploadWidgetState();
}

class _ImageUploadWidgetState extends State<ImageUploadWidget> {
  List<String> _currentImages = [];
  List<File> _pendingUploads = [];
  List<Map<String, dynamic>> _pendingWebUploads = []; // For web files
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _currentImages = List.from(widget.initialImages);
  }

  @override
  void didUpdateWidget(ImageUploadWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialImages != widget.initialImages) {
      _currentImages = List.from(widget.initialImages);
    }
  }

  Future<void> _pickImagesFromFiles() async {
    try {
      final remainingSlots = widget.maxImages - _currentImages.length - _pendingUploads.length;
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: remainingSlots > 1,
      );

      if (result != null && result.files.isNotEmpty) {
        if (kIsWeb) {
          // Handle web files using bytes
          for (final file in result.files) {
            if (file.bytes != null && file.name != null) {
              await _validateAndAddWebFile(file.name!, file.bytes!);
            }
          }
        } else {
          // Handle mobile/desktop files using path
          final files = result.files
              .where((file) => file.path != null)
              .map((file) => File(file.path!))
              .toList();

          await _validateAndAddFiles(files);
        }
      }
    } catch (e) {
      AppUtils.showSnackBar(context, 'Файл танлашда хатолик: $e');
    }
  }

  Future<void> _pickImagesFromCamera() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        final file = File(image.path);
        await _validateAndAddFiles([file]);
      }
    } catch (e) {
      AppUtils.showSnackBar(context, 'Камерадан расм олишда хатолик: $e');
    }
  }

  Future<void> _validateAndAddFiles(List<File> files) async {
    for (final file in files) {
      if (!StorageService.isValidImageFile(file)) {
        AppUtils.showSnackBar(
          context,
          'Фақат расм файллари қабул қилинади (.jpg, .jpeg, .png, .gif, .webp)',
        );
        continue;
      }

      if (!StorageService.isValidFileSize(file)) {
        AppUtils.showSnackBar(
          context,
          'Расм файли 10MB дан катта бўлмаслиги керак',
        );
        continue;
      }

      if (_pendingUploads.length + _currentImages.length >= widget.maxImages) {
        AppUtils.showSnackBar(
          context,
          'Максимум ${widget.maxImages} та расм қўшиш мумкин',
        );
        break;
      }

      setState(() {
        _pendingUploads.add(file);
      });
    }
  }

  Future<void> _validateAndAddWebFile(String fileName, Uint8List bytes) async {
    // Validate file extension
    final extension = fileName.toLowerCase().split('.').last;
    const allowedExtensions = ['jpg', 'jpeg', 'png', 'gif', 'webp'];
    
    if (!allowedExtensions.contains(extension)) {
      AppUtils.showSnackBar(
        context,
        'Фақат расм файллари қабул қилинади (.jpg, .jpeg, .png, .gif, .webp)',
      );
      return;
    }

    // Validate file size (max 10MB)
    final fileSizeMB = bytes.length / (1024 * 1024);
    if (fileSizeMB > 10.0) {
      AppUtils.showSnackBar(
        context,
        'Расм файли 10MB дан катта бўлмаслиги керак',
      );
      return;
    }

    if (_pendingWebUploads.length + _pendingUploads.length + _currentImages.length >= widget.maxImages) {
      AppUtils.showSnackBar(
        context,
        'Максимум ${widget.maxImages} та расм қўшиш мумкин',
      );
      return;
    }

    setState(() {
      _pendingWebUploads.add({
        'name': fileName,
        'bytes': bytes,
      });
    });
  }

  Future<void> _uploadPendingImages() async {
    if (_pendingUploads.isEmpty && _pendingWebUploads.isEmpty) return;

    print('DEBUG: Starting upload process...');
    print('DEBUG: Regular files: ${_pendingUploads.length}');
    print('DEBUG: Web files: ${_pendingWebUploads.length}');

    setState(() {
      _isUploading = true;
    });

    try {
      final uploadedUrls = <String>[];

      // Upload regular files (mobile/desktop)
      if (_pendingUploads.isNotEmpty) {
        print('DEBUG: Uploading regular files...');
        final regularUrls = await StorageService.uploadImages(
          imageFiles: _pendingUploads,
          bucket: widget.bucket,
          customPath: widget.customPath,
        );
        print('DEBUG: Regular upload result: $regularUrls');
        uploadedUrls.addAll(regularUrls);
      }

      // Upload web files (using bytes)
      if (_pendingWebUploads.isNotEmpty) {
        print('DEBUG: Uploading web files...');
        for (int i = 0; i < _pendingWebUploads.length; i++) {
          final webFile = _pendingWebUploads[i];
          print('DEBUG: Uploading web file $i: ${webFile['name']}');
          print('DEBUG: File size: ${(webFile['bytes'] as Uint8List).length} bytes');
          
          final url = await StorageService.uploadImageBytes(
            imageBytes: webFile['bytes'] as Uint8List,
            fileName: webFile['name'] as String,
            bucket: widget.bucket,
            customPath: widget.customPath,
          );
          
          print('DEBUG: Web file $i upload result: $url');
          if (url != null) {
            uploadedUrls.add(url);
          }
        }
      }

      print('DEBUG: Total uploaded URLs: ${uploadedUrls.length}');
      print('DEBUG: URLs: $uploadedUrls');

      setState(() {
        _currentImages.addAll(uploadedUrls);
        _pendingUploads.clear();
        _pendingWebUploads.clear();
        _isUploading = false;
      });

      widget.onImagesChanged(_currentImages);

      if (uploadedUrls.isNotEmpty) {
        AppUtils.showSnackBar(
          context,
          '${uploadedUrls.length} та расм муваффақиятли юклаб олинди',
        );
        print('DEBUG: Success message shown');
      } else {
        AppUtils.showSnackBar(
          context,
          'Хатолик: Расмлар юкланишда муаммо бўлди',
        );
        print('DEBUG: Error message shown - no URLs returned');
      }
    } catch (e) {
      print('DEBUG: Upload error: $e');
      setState(() {
        _isUploading = false;
      });
      AppUtils.showSnackBar(context, 'Расм юклашда хатолик: $e');
    }
  }

  void _removeImage(int index) {
    setState(() {
      _currentImages.removeAt(index);
    });
    widget.onImagesChanged(_currentImages);
  }

  void _removePendingImage(int index) {
    setState(() {
      if (index < _pendingUploads.length) {
        _pendingUploads.removeAt(index);
      } else {
        final webIndex = index - _pendingUploads.length;
        _pendingWebUploads.removeAt(webIndex);
      }
    });
  }

  void _showImageOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Галереядан танлаш'),
              onTap: () {
                Navigator.pop(context);
                _pickImagesFromFiles();
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Камерадан олиш'),
              onTap: () {
                Navigator.pop(context);
                _pickImagesFromCamera();
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          children: [
            Text(
              'Расмлар',
              style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '(${_currentImages.length + _pendingUploads.length + _pendingWebUploads.length}/${widget.maxImages})',
              style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurface.withAlpha(150),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Add image button
        if (_currentImages.length + _pendingUploads.length + _pendingWebUploads.length < widget.maxImages)
          InkWell(
            onTap: _showImageOptions,
            child: Container(
              width: double.infinity,
              height: 120,
              decoration: BoxDecoration(
                border: Border.all(
                  color: AppTheme.lightTheme.colorScheme.outline,
                  style: BorderStyle.solid,
                ),
                borderRadius: BorderRadius.circular(8),
                color: AppTheme.lightTheme.colorScheme.surfaceVariant.withAlpha(50),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add_photo_alternate,
                    size: 32,
                    color: AppTheme.lightTheme.colorScheme.primary,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Расм қўшиш',
                    style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    'Галерея ёки камерадан',
                    style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.onSurface.withAlpha(150),
                    ),
                  ),
                ],
              ),
            ),
          ),

        const SizedBox(height: 16),

        // Pending uploads
        if (_pendingUploads.isNotEmpty || _pendingWebUploads.isNotEmpty) ...[
          Text(
            'Юкланиши керак бўлган расмлар:',
            style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 80,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _pendingUploads.length + _pendingWebUploads.length,
              itemBuilder: (context, index) {
                Widget imageWidget;
                
                if (index < _pendingUploads.length) {
                  // Regular file
                  final file = _pendingUploads[index];
                  imageWidget = Image.file(
                    file,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(
                        Icons.broken_image,
                        color: AppTheme.lightTheme.colorScheme.error,
                      );
                    },
                  );
                } else {
                  // Web file
                  final webFile = _pendingWebUploads[index - _pendingUploads.length];
                  final bytes = webFile['bytes'] as Uint8List;
                  imageWidget = Image.memory(
                    bytes,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(
                        Icons.broken_image,
                        color: AppTheme.lightTheme.colorScheme.error,
                      );
                    },
                  );
                }

                return Container(
                  margin: const EdgeInsets.only(right: 8),
                  child: Stack(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: AppTheme.lightTheme.colorScheme.outline,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: imageWidget,
                        ),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: GestureDetector(
                          onTap: () => _removePendingImage(index),
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color: AppTheme.lightTheme.colorScheme.error,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.close,
                              size: 16,
                              color: AppTheme.lightTheme.colorScheme.onError,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isUploading ? null : _uploadPendingImages,
              child: _isUploading
                  ? const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        SizedBox(width: 8),
                        Text('Юкланиши керак бўлган расмларни юклаш...'),
                      ],
                    )
                  : Text('${_pendingUploads.length + _pendingWebUploads.length} та расмларни юклаш'),
            ),
          ),
          const SizedBox(height: 16),
        ],

        // Current images preview
        if (widget.showPreview && _currentImages.isNotEmpty) ...[
          Text(
            'Жорий расмлар:',
            style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 80,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _currentImages.length,
              itemBuilder: (context, index) {
                final imageUrl = _currentImages[index];
                return Container(
                  margin: const EdgeInsets.only(right: 8),
                  child: Stack(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: AppTheme.lightTheme.colorScheme.outline,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(
                                Icons.broken_image,
                                color: AppTheme.lightTheme.colorScheme.error,
                              );
                            },
                          ),
                        ),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: GestureDetector(
                          onTap: () => _removeImage(index),
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color: AppTheme.lightTheme.colorScheme.error,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.close,
                              size: 16,
                              color: AppTheme.lightTheme.colorScheme.onError,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ],
    );
  }
}
