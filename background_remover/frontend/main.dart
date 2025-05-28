import 'dart:html' as html;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() => runApp(BackgroundRemoverApp());

class BackgroundRemoverApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Background Remover',
      theme: ThemeData(
        fontFamily: 'Arial',
        primarySwatch: Colors.deepPurple,
        scaffoldBackgroundColor: Color(0xFFF6F2FF),
      ),
      home: HomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Uint8List? originalImage;
  Uint8List? processedImage;

  void pickImage() async {
    final uploadInput = html.FileUploadInputElement()..accept = 'image/*';
    uploadInput.click();

    uploadInput.onChange.listen((e) {
      final file = uploadInput.files!.first;
      final reader = html.FileReader();
      reader.readAsArrayBuffer(file);
      reader.onLoadEnd.listen((e) async {
        final data = reader.result as Uint8List;
        setState(() => originalImage = data);
        await uploadToBackend(file, data);
      });
    });
  }

  Future<void> uploadToBackend(html.File file, Uint8List bytes) async {
    final uri = Uri.parse('http://127.0.0.1:8000/remove-background/');
    final request = http.MultipartRequest('POST', uri);
    final multipartFile = http.MultipartFile.fromBytes(
      'file',
      bytes,
      filename: file.name,
    );

    request.files.add(multipartFile);

    try {
      final response = await request.send();
      if (response.statusCode == 200) {
        final responseData = await response.stream.toBytes();
        setState(() => processedImage = responseData);
      } else {
        print('Failed: ${response.statusCode}');
      }
    } catch (e) {
      print('Error uploading image: $e');
    }
  }

  Widget buildImageCard(Uint8List image, String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          title,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.memory(image, height: 200),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24),
          child: Container(
            width: 500,
            padding: EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.deepPurple.withOpacity(0.2),
                  blurRadius: 12,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              children: [
                Text(
                  '✨ Background Remover',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: pickImage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Text(
                    'Pick Image',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
                SizedBox(height: 30),
                if (originalImage != null)
                  buildImageCard(originalImage!, "Original Image:"),
                SizedBox(height: 30),
                if (processedImage != null) ...[
                  buildImageCard(
                    processedImage!,
                    "Processed Image (Background Removed):",
                  ),
                  SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: () {
                      final blob = html.Blob([processedImage]);
                      final url = html.Url.createObjectUrlFromBlob(blob);
                      final anchor =
                          html.AnchorElement(href: url)
                            ..setAttribute("download", "background_removed.png")
                            ..click();
                      html.Url.revokeObjectUrl(url); // Clean up
                    },
                    icon: Icon(Icons.download),
                    label: Text("Download Image"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
