import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:ndialog/ndialog.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue, //primary theme color
      ),
      home: FileDownload(), //call to homepage class
    );
  }
}

class FileDownload extends StatefulWidget {
  @override
  _FileDownloadState createState() => _FileDownloadState();
}

class _FileDownloadState extends State<FileDownload> {
  late bool isLoading;
  bool _allowWriteFile = false;

  List<Course> courseContent = [];

  String progress = "";
  late Dio dio;

  @override
  void initState() {
    super.initState();
    dio = Dio();
    courseContent.add(Course(
        title: "Sample 1",
        path: "http://www.africau.edu/images/default/sample.pdf"));
    courseContent.add(Course(
        title: "Sample 2",
        path: "https://www.clickdimensions.com/links/TestPDFfile.pdf"));
    courseContent.add(Course(
        title: "Icarus ",
        path: "https://www.clickdimensions.com/links/TestPDFfile.pdf"));
    courseContent.add(Course(
        title: "Vaishnav",
        path: "https://www.clickdimensions.com/links/TestPDFfile.pdf"));
    courseContent.add(Course(
        title: "blabla",
        path: "https://www.clickdimensions.com/links/TestPDFfile.pdf"));
  }

  requestWritePermission() async {
    if (await Permission.storage.request().isGranted) {
      setState(() {
        _allowWriteFile = true;
      });
    } else {
      Map<Permission, PermissionStatus> statuses = await [
        Permission.storage,
      ].request();
    }
  }

  Future<String> getDirectoryPath() async {
    Directory appDocDirectory = await getApplicationDocumentsDirectory();

    Directory directory =
        await new Directory(appDocDirectory.path + '/' + 'dir')
            .create(recursive: true);

    return directory.path;
  }

  Future downloadFile(String url, path) async {
    if (!_allowWriteFile) {
      requestWritePermission();
    }
    try {
      ProgressDialog progressDialog = ProgressDialog(context,
          dialogTransitionType: DialogTransitionType.Bubble,
          title: Text("Downloading File"));

      progressDialog.show();

      await dio.download(url, path, onReceiveProgress: (rec, total) {
        setState(() {
          isLoading = true;
          progress = ((rec / total) * 100).toStringAsFixed(0) + "%";
          progressDialog.setMessage(Text("Dowloading $progress"));
        });
      });
      progressDialog.dismiss();
    } catch (e) {
      print(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      backgroundColor: Colors.white70,
      appBar: AppBar(
        title: Text("FIle Download"),
        backgroundColor: Colors.red,
      ),
      body: Container(
        child: ListView.builder(
          itemBuilder: (context, index) {
            String url = courseContent[index].path;
            String title = courseContent[index].title;
            String extension = url.substring(url.lastIndexOf("/"));
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Card(
                elevation: 10,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        "$title",
                        style: TextStyle(
                            fontSize: 26,
                            color: Colors.purpleAccent,
                            fontWeight: FontWeight.bold),
                      ),
                      RaisedButton(
                        color: Colors.green,
                        onPressed: () {
                          getDirectoryPath().then((path) {
                            File f = File(path + "$extension");
                            if (f.existsSync()) {
                              Navigator.push(context,
                                  MaterialPageRoute(builder: (context) {
                                return PDFScreen(f.path);
                              }));
                              return;
                            }

                            downloadFile(url, "$path/$extension");
                          });
                        },
                        child: Text(
                          "View",
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
          itemCount: courseContent.length,
        ),
      ),
    );
  }
}

class PDFScreen extends StatelessWidget {
  String pathPDF = "";
  PDFScreen(this.pathPDF);
  final GlobalKey<SfPdfViewerState> _pdfViewerKey = GlobalKey();
  @override
  Widget build(BuildContext context) {
    return SfPdfViewer.file(
      File(pathPDF),
      key: _pdfViewerKey,
    );
  }
}

class Course {
  String title;
  String path;
  Course({required this.title, required this.path});
}
