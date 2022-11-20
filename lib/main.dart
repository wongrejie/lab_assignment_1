import 'dart:async';
import 'dart:convert';
import 'package:rounded_loading_button/rounded_loading_button.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:ndialog/ndialog.dart';
import 'package:fluttertoast/fluttertoast.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(primarySwatch: Colors.purple),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Movies City'),
        ),
        body: const HomePage(),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TextEditingController textSearch = TextEditingController();
  //variables initialization
  var movieTitle = "",
      year = "",
      genre = "",
      imageUrl = "https://via.placeholder.com/250x300.png?text=No+Record",
      desc = "";
  final RoundedLoadingButtonController _btnController =
      RoundedLoadingButtonController();

  @override
  Widget build(BuildContext context) {
    return Center(
        child: SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Padding(padding: EdgeInsets.all(8)),
          const Text("Movie Search",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const Padding(padding: EdgeInsets.all(8)),
          SizedBox(
            width: 300,
            child: TextField(
              controller: textSearch,
              decoration: InputDecoration(
                  hintText: 'Movie Title',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0))),
            ),
          ),
          const Padding(padding: EdgeInsets.all(8)),
          SizedBox(
            width: 180,
            child: RoundedLoadingButton(
              color: Colors.purple,
              controller: _btnController,
              onPressed: () {
                showAlertDialog(context);
              },
              child: const Text('Search',
                  style: TextStyle(color: Colors.white, fontSize: 16)),
            ),
          ),
          const Padding(padding: EdgeInsets.all(8)),
          Text(desc,
              style:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Image.network(imageUrl),
        ],
      ),
    ));
  }

  showAlertDialog(BuildContext context) {
    // set up the cancel and confirm buttons
    Widget cancelButton = TextButton(
      child: const Text("Cancel"),
      onPressed: () {
        _btnController.reset();
        Navigator.pop(context);
      },
    );
    Widget confirmButton = TextButton(
      child: const Text("Confirm"),
      onPressed: () {
        Navigator.pop(context);
        _getMovie();
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: const Text("Confirmation Alert"),
      content: const Text("Do you confirm to search the movie?"),
      actions: [
        cancelButton,
        confirmButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  Future<void> _getMovie() async {
    _btnController.start();
    ProgressDialog progressDialog = ProgressDialog(context,
        message: const Text("Progress"),
        title: const Text("Searching for your movie..."));
    progressDialog.show();
    String search = textSearch.text;
    var apikey = "b51cd3c0";
    var url = Uri.parse('https://www.omdbapi.com/?t=$search&apikey=$apikey');
    var response = await http.get(url);
    var rescode = response.statusCode;
    if (rescode == 200) {
      var jsonData = response.body;
      var parsedJson = json.decode(jsonData);

      movieTitle = parsedJson['Title'];
      year = parsedJson['Year'];
      genre = parsedJson['Genre'];
      imageUrl = parsedJson['Poster'];
      setState(() {
        desc =
            "Movie Title:  $movieTitle\n\n Year:  $year\n\n Genre:  $genre \n";
        _btnController.success();
      });
      Fluttertoast.showToast(
          msg: "Movie Found!",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          fontSize: 16,
          timeInSecForIosWeb: 2);
    } else {
      setState(() {
        desc = "No record was found.";
      });
    }
    _btnController.reset();
    progressDialog.dismiss();
  }
}
