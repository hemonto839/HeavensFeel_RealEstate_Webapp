import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:file_picker/file_picker.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:io' show File; // only used on non-web platforms

// uploading file to cloudinary
Future<String?> uploadToCloudinary(FilePickerResult? filePickerResult) async {
  if (filePickerResult == null || filePickerResult.files.isEmpty) {
    print("No file selected");
    return null;
  }

  final fileData = filePickerResult.files.single;

  // Debug: Check if dotenv is loaded
  print("Dotenv loaded: ${dotenv.isEveryDefined(['CLOUDINARY_CLOUD_NAME', 'CLOUDINARY_UPLOAD_PRESET'])}");
  
  final String cloudName = dotenv.env['CLOUDINARY_CLOUD_NAME'] ?? '';
  final String uploadPreset = dotenv.env['CLOUDINARY_UPLOAD_PRESET'] ?? '';

  // Debug: Print the values (remove in production)
  print("Cloud Name: '$cloudName'");
  print("Upload Preset: '$uploadPreset'");

  // Check if environment variables are properly set
  if (cloudName.isEmpty) {
    print("ERROR: CLOUDINARY_CLOUD_NAME is not set or empty");
    return null;
  }
  
  if (uploadPreset.isEmpty) {
    print("ERROR: CLOUDINARY_UPLOAD_PRESET is not set or empty");
    return null;
  }

  // multipart request used for file upload in http
  final Uri uri = Uri.parse("https://api.cloudinary.com/v1_1/$cloudName/image/upload");
  print("Upload URL: $uri");

  var request = http.MultipartRequest("POST", uri);

  try {
    if (kIsWeb) {
      // Web: use bytes because no file path is available
      if (fileData.bytes == null) {
        print("ERROR: File bytes are null on web platform");
        return null;
      }
      
      Uint8List bytes = fileData.bytes!;
      var multipartFile = http.MultipartFile.fromBytes(
        'file',
        bytes,
        filename: fileData.name,
      );
      // add the files part to the request
      request.files.add(multipartFile);
      print("Web: Added file from bytes, size: ${bytes.length}");
    } else {
      // Mobile/Desktop: use file path
      if (fileData.path == null) {
        print("ERROR: File path is null on mobile/desktop platform");
        return null;
      }
      
      File file = File(fileData.path!);
      
      // Check if file exists
      if (!await file.exists()) {
        print("ERROR: File does not exist at path: ${fileData.path}");
        return null;
      }
      
      // Attach the file using its path
      var multipartFile = await http.MultipartFile.fromPath('file', file.path);
      request.files.add(multipartFile);
      print("Mobile: Added file from path: ${file.path}");
    }

    // Add the upload preset (needed for Cloudinary unsigned uploads)
    request.fields['upload_preset'] = uploadPreset;
    
    print("Sending request to Cloudinary...");
    
    // send the request
    final response = await request.send();
    // accept the respond in text
    final responseBody = await response.stream.bytesToString();

    print("Response status: ${response.statusCode}");
    
    if (response.statusCode == 200) {
      final jsonRes = jsonDecode(responseBody);
      String url = jsonRes['secure_url'];
      print("Upload success: $url");
      return url;
    } else {
      print("Upload failed: ${response.statusCode}");
      print("Response body: $responseBody");
      return null;
    }
  } catch (e) {
    print("Exception during upload: $e");
    return null;
  }
}

// remove from cloudinary (only for profile image )
Future<bool> deleteFromCloudinary(String imageUrl) async {
  try {
    // Extract public_id from URL
    final uri = Uri.parse(imageUrl);
    final pathSegments = uri.pathSegments;
    final publicIdWithExtension = pathSegments.last;
    final publicId = publicIdWithExtension.split('.').first;
    
    final String cloudName = dotenv.env['CLOUDINARY_CLOUD_NAME'] ?? '';
    final String apiKey = dotenv.env['CLOUDINARY_API_KEY'] ?? '';
    final String apiSecret = dotenv.env['CLOUDINARY_API_SECRET'] ?? '';
    
    if (cloudName.isEmpty || apiKey.isEmpty || apiSecret.isEmpty) {
      print("ERROR: Cloudinary credentials not set for deletion");
      return false;
    }
    
    final deleteUri = Uri.parse("https://api.cloudinary.com/v1_1/$cloudName/image/destroy");
    
    final response = await http.post(
      deleteUri,
      body: {
        'public_id': publicId,
        'api_key': apiKey,
        'api_secret': apiSecret,
      },
    );
    
    if (response.statusCode == 200) {
      final jsonRes = jsonDecode(response.body);
      print("Delete response: $jsonRes");
      return jsonRes['result'] == 'ok';
    } else {
      print("Delete failed: ${response.statusCode}");
      return false;
    }
  } catch (e) {
    print("Exception during delete: $e");
    return false;
  }
}