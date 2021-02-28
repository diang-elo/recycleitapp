import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:qrscan/qrscan.dart' as scanner;
import 'dart:convert' as convert;
import 'package:http/http.dart' as http;
import 'dart:math';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

void main() {
  runApp(MaterialApp(
    title: 'Navigation Basics',
    home: FirstRoute(),
  ));


}
class FirstRoute extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MyApp();
  }

}

class SecondRoute extends StatelessWidget {




  GoogleMapController mapController;
  Position position;
  final LatLng _center = const LatLng(43.46893497658817, -80.51422437209672);
  var locationMessage = '';
  String latitude;
  String longitude;

  void _onMapCreated(GoogleMapController controller) async {
    mapController = controller;



  }




  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('E-waste Recycling'),
          backgroundColor: Colors.teal[300],
        ),
        body: GoogleMap(
          onMapCreated: _onMapCreated,
          initialCameraPosition: CameraPosition(

            target: _center,
            zoom: 11.0,
          ),
        ),
      ),
    );
  }
}
class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String barcodee = '';
  String imagineUrl = '';
  String price = "";
  String resell = "";
  Uint8List bytes = Uint8List(0);
  TextEditingController _inputController;
  TextEditingController _outputController;
  @override
  initState() {
    super.initState();
    this._inputController = new TextEditingController();
    this._outputController = new TextEditingController();

  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.white,
        body: Builder(

          builder: (BuildContext context) {
            return ListView(
              children: <Widget>[
                Container(
                  color: Colors.white,
                  child: Column(
                    children: <Widget>[
                      Image.asset('assets/images/logoo.png'),
                      SizedBox(height: 20),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(30.0),

                        child:Image.network(

                            imagineUrl
                        ),),
                      SizedBox(height: 10),
                      Text(
                        barcodee,
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontWeight: FontWeight.bold,color: Colors.black,fontSize: 15,),


                      ),
                      SizedBox(height: 10),
                      Text(
                        price, //CHANGE THIS VAR
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontWeight: FontWeight.bold,color: Colors.black,fontSize: 15,),


                      ),
                      SizedBox(height: 10),
                      Text(
                        resell,
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontWeight: FontWeight.bold,color: Colors.black,fontSize: 15,),


                      ),


                      SizedBox(height: 80),
                      ElevatedButton(
                        child: Text('Recycle IT'),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => SecondRoute()),
                          );
                        },
                      ),
                      this._buttonGroup(),


                    ],
                  ),
                ),
              ],
            );
          },
        ),

      ),
    );
  }



  Widget _buttonGroup() {
    return Row(
      children: <Widget>[

        Expanded(
          flex: 1,

          child: SizedBox(
            height: 60,
            child: InkWell(
              onTap: _scan,
              child: Card(
                child: Column(

                  children: <Widget>[

                    Divider(height: 20),
                    Expanded(flex: 1, child: Text("Scan")),
                    Divider(height: 15),

                  ],
                ),
              ),
            ),
          ),
        ),

      ],
    );
  }

  Future _scan() async {
    await Permission.camera.request();
    String barcode = await scanner.scan();
    if (barcode == null) {
      print('nothing return.');
    } else {
      var url = 'https://barcode-monster.p.rapidapi.com/$barcode';

      var response = await http.get(url,
          headers: {"x-rapidapi-key": "090fba85ffmsh85e95425e452236p1d8c76jsnf7cdd2e7fd50",
            "x-rapidapi-host": "barcode-monster.p.rapidapi.com"});

      if (response.statusCode == 200) {
        var jsonResponse = convert.jsonDecode(response.body);
        print(jsonResponse);
        print(jsonResponse['description']);
        print('ewewewe');
        setState(() {
          barcodee = jsonResponse['description'];
          imagineUrl = jsonResponse['image_url'];
        });
        //-------------------------------------------------------------------------------


        var other = await http.get('https://ebay-com.p.rapidapi.com/products/$barcode',
            headers: {"x-rapidapi-key": "090fba85ffmsh85e95425e452236p1d8c76jsnf7cdd2e7fd50",
              "x-rapidapi-host": "ebay-com.p.rapidapi.com"});

        if (other.statusCode == 200) {
          var otherGood = convert.jsonDecode(other.body);
          print(otherGood);
          setState(() {
            price = "Resell Price: " + "\$" +otherGood['BestPrice'].toString();
            resell = "Recycle Price: " + "\$" +((otherGood['BestPrice'] * 0.04 *100).round() /100).toString();
          });
          //------------------------------- ---------------------------
        } else {
          print('Request failed with status: ${other.statusCode}.');
        }





      } else {
        print('Request failed with status: ${response.statusCode}.');
      }

    }
  }

  Future _scanPhoto() async {
    await Permission.storage.request();
    String barcode = await scanner.scanPhoto();
    this._outputController.text = barcode;
  }

  Future _scanPath(String path) async {
    await Permission.storage.request();
    String barcode = await scanner.scanPath(path);
    this._outputController.text = barcode;
  }

  Future _scanBytes() async {
    File file = await ImagePicker.pickImage(source: ImageSource.camera);
    if (file == null) return;
    Uint8List bytes = file.readAsBytesSync();
    String barcode = await scanner.scanBytes(bytes);
    this._outputController.text = barcode;
  }

  Future _generateBarCode(String inputCode) async {
    Uint8List result = await scanner.generateBarCode(inputCode);
    this.setState(() => this.bytes = result);
  }
}