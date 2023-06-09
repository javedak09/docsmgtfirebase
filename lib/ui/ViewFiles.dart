import 'dart:convert';
import 'dart:io';
import 'package:docsmgtfirebase/ui/SampleEntry.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:docsmgtfirebase/ui/InnerFolder.dart';
import 'dart:async';
import 'package:http/http.dart' as http;

class ViewFiles extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String message = "";

  Future<String> createFolderInAppDocDir(String folderName) async {
    //Get this App Document Directory

    final Directory _appDocDir = await getApplicationDocumentsDirectory();
    //App Document Directory + folder name
    final Directory _appDocDirFolder =
        Directory('${_appDocDir.path}/$folderName/');

    if (await _appDocDirFolder.exists()) {
      //if folder already exists return path
      return _appDocDirFolder.path;
    } else {
      //if folder not exists create folder and then return its path
      final Directory _appDocDirNewFolder =
      await _appDocDirFolder.create(recursive: true);
      return _appDocDirNewFolder.path;
    }
  }

  callFolderCreationMethod(String folderInAppDocDir) async {
    // ignore: unused_local_variable
    String actualFileName = await createFolderInAppDocDir(folderInAppDocDir);
    print(actualFileName);
    setState(() {});
  }

  final folderController = TextEditingController();
  late final String url;
  late String nameOfFolder;

  /*Future<void> _showMyDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Column(
            children: [
              Text(
                'ADD FOLDER',
                textAlign: TextAlign.left,
              ),
              Text(
                'Type a folder name to add',
                style: TextStyle(
                  fontSize: 14,
                ),
              )
            ],
          ),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return TextField(
                controller: folderController,
                autofocus: true,
                decoration: InputDecoration(hintText: 'Enter folder name'),
                onChanged: (val) {
                  setState(() {
                    nameOfFolder = folderController.text;
                    print(nameOfFolder);
                  });
                },
              );
            },
          ),
          actions: <Widget>[
            ElevatedButton(
              child: Text(
                'Add',
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () async {
                if (nameOfFolder != null) {
                  await callFolderCreationMethod(nameOfFolder);
                  getDir();
                  setState(() {
                    folderController.clear();
                    nameOfFolder = "";
                  });
                  Navigator.of(context).pop();
                }
              },
            ),
            ElevatedButton(
              child: Text(
                'No',
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }*/

  late List<FileSystemEntity> _folders;

  Future<void> getDir() async {
    //final directory = await getApplicationDocumentsDirectory();
    //final dir = directory.path;

    final directory = await getExternalStorageDirectory();
    var arr_dir = directory!.path.split('/');

    var appDocDir = new Directory(arr_dir[0] +
        "/" +
        arr_dir[1] +
        "/" +
        arr_dir[2] +
        "/" +
        arr_dir[3] +
        "/Download/docsmgtsys/");

    //String pdfDirectory = '$dir/';
    //final myDir = new Directory(pdfDirectory);

    print(appDocDir.path);

    var files = appDocDir.listSync(recursive: false);
    files.length;

    setState(() {
      //_folders = myDir.listSync(recursive: true, followLinks: false);
      _folders = appDocDir.listSync(recursive: false, followLinks: false);
    });
    //print(_folders);
  }

  _uploadFiles1(String filename, String url) async {
    final directory = await getExternalStorageDirectory();
    var arr_dir = directory!.path.split('/');

    var appDocDir = new Directory(arr_dir[0] +
        "/" +
        arr_dir[1] +
        "/" +
        arr_dir[2] +
        "/" +
        arr_dir[3] +
        "/Download/docsmgtsys/");

    var request = http.MultipartRequest('POST', Uri.parse(url));

    Map<String, String> str = {};
    request.headers.addAll(str);

    /*request.files.add(await http.MultipartFile.fromPath(
        'imgurl', appDocDir.path + "sero/sero_a78.xlsx"));*/

    var res = await request.send();
    print("response code = >  " + res.statusCode.toString());
    return res.reasonPhrase;
  }

  _uploadFiles(String str1, String str2) async {
    var url = Uri.parse(
        'http://cls-pae-fp59408:7777/docsmgtsys/test.php'); // Url of the website where we get the data from.
    var request = http.Request('POST', url); // Set to GET
    http.StreamedResponse response = await request.send(); // Send request.
    // Check if response is okay
    if (response.statusCode == 200) {
      dynamic data =
          await response.stream.bytesToString(); // Turn bytes to readable data.
      var json = jsonDecode("hello");
      setState(() => message = json["imgurl"]);
    } else {
      print("${response.statusCode} - Something went wrong..");
    }
  }

  Future<void> _showDeleteDialog(int index) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Are you sure to delete this folder?',
          ),
          actions: <Widget>[
            ElevatedButton(
              child: Text('Yes'),
              onPressed: () async {
                await _folders[index].delete();
                getDir();
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: Text('No'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    _folders = [];
    getDir();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("View Files"),
        backgroundColor: Colors.purple,
        actions: [
          IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => SampleEntry()));
            },
          ),
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              _uploadFiles(
                  "", "http://cls-pae-fp59408:7777/docsmgtsys/test.php");
            },
          ),
        ],
      ),
      body: GridView.builder(
        padding: EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 25,
        ),
        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 180,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
        ),
        itemBuilder: (context, index) {
          return Material(
            elevation: 6.0,
            child: Stack(
              children: [
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(10),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      FutureBuilder(
                          future: getFileType(_folders[index]),
                          builder: (ctx, snapshot) {
                            if (snapshot.hasData) {
                              FileStat f = snapshot.data as FileStat;

                              print("file.stat() ${f.type} - size ${f.size}");
                              ;
                              if (f.type.toString().contains("file")) {
                                return Icon(
                                  Icons.file_copy_outlined,
                                  size: 100,
                                  color: Colors.orange,
                                );
                              } else {
                                return InkWell(
                                    onTap: () {
                                      Navigator.push(context,
                                          new MaterialPageRoute(
                                              builder: (builder) {
                                                return InnerFolder(
                                                    filespath: _folders[index].path);
                                              }));
                                      /* final myDir = new Directory(_folders[index].path);

                                          var    _folders_list = myDir.listSync(recursive: true, followLinks: false);

                                          for(int k=0;k<_folders_list.length;k++)
                                          {
                                            var config = File(_folders_list[k].path);
                                            print("IsFile ${config is File}");
                                          }
                                          print(_folders_list);*/
                                    },
                                    child: Icon(Icons.folder,
                                        size: 100, color: Colors.orange));
                              }
                            }
                            return Icon(
                              Icons.file_copy_outlined,
                              size: 100,
                              color: Colors.orange,
                            );
                          }),
                      Text(
                        '${_folders[index].path.split('/').last}',
                      ),
                    ],
                  ),
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: GestureDetector(
                    onTap: () {
                      _showDeleteDialog(index);
                      getDir();
                    },
                    child: Icon(
                      Icons.delete,
                      color: Colors.grey,
                    ),
                  ),
                )
              ],
            ),
          );
        },
        itemCount: _folders.length,
      ),
    );
  }

  Future getFileType(file) {
    return file.stat();
  }
}
