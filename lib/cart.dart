import 'dart:async';
import 'dart:convert';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:toast/toast.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:random_string/random_string.dart';
import 'paymentscreen.dart';
import 'package:intl/intl.dart';
import 'user.dart';
import 'homescreen.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoder/geocoder.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class CartScreen extends StatefulWidget {
  final User user;

  const CartScreen({Key key, this.user}) : super(key: key);

  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  GlobalKey<RefreshIndicatorState> refreshKey;
  String server = "https://saujanaeclipse.com/bungabunga";
  List cartData;
  double screenHeight, screenWidth;
  bool _donation = true;
  bool _homeDelivery = false;
  double _totalprice = 0.0;
  Position _currentPosition;
  String curaddress;
  Completer<GoogleMapController> _controller = Completer();
  GoogleMapController gmcontroller;
  CameraPosition _home;
  MarkerId markerId1 = MarkerId("12");
  Set<Marker> markers = Set();

  double latitude, longitude;
  String label;
  CameraPosition _userpos;
  double deliverycharge;
  double amountpayable;
  String titlecenter = "Loading your cart";

  @override
  void initState() {
    super.initState();
    _getLocation();
    Future.delayed(Duration.zero, () {
      this._loadCart();
    });
    refreshKey = GlobalKey<RefreshIndicatorState>();
  }

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
            backgroundColor: Colors.purple[200],
            title: Text(
              'Cart',
              style: TextStyle(
                color: Colors.black12,
              ),
            ),
            iconTheme: new IconThemeData(color: Colors.black),
            actions: <Widget>[
              IconButton(
                icon: Icon(MdiIcons.deleteEmpty),
                onPressed: () {
                  deleteAll();
                },
              ),
            ]),
        body: RefreshIndicator(
            key: refreshKey,
            color: Color.fromRGBO(101, 255, 218, 50),
            onRefresh: () async {
              await refreshList();
            },
            child: Container(
                child: Column(
              children: <Widget>[
                Text(
                  "Content of your Cart",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),
                cartData == null
                    ? Flexible(
                        child: Container(
                            child: Center(
                                child: Text(
                        titlecenter,
                        style: TextStyle(
                            color: Color.fromRGBO(101, 255, 218, 50),
                            fontSize: 22,
                            fontWeight: FontWeight.bold),
                      ))))
                    : Expanded(
                        child: ListView.builder(
                            itemCount: cartData.length + 2,
                            itemBuilder: (context, index) {
                              if (index == cartData.length) {
                                return Container(
                                    height: screenHeight / 3,
                                    width: screenWidth / 2.5,
                                    child: InkWell(
                                      onLongPress: () {
                                        print("Delete");
                                      },
                                      child: Card(
                                        elevation: 5,
                                        child: Column(
                                          children: <Widget>[
                                            SizedBox(
                                              height: 10,
                                            ),
                                            Text("Delivery Option",
                                                style: TextStyle(
                                                    fontSize: 18.0,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.black)),
                                            Expanded(
                                                child: Row(
                                              children: <Widget>[
                                                Container(
                                                  width: screenWidth / 2,
                                                  child: Column(
                                                    children: <Widget>[
                                                      Row(
                                                        children: <Widget>[
                                                          Checkbox(
                                                            value: _donation,
                                                            onChanged:
                                                                (bool value) {
                                                              _onDonation(
                                                                  value);
                                                            },
                                                          ),
                                                          Text(
                                                            "Donation",
                                                            style: TextStyle(
                                                              color:
                                                                  Colors.black,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Padding(
                                                    padding:
                                                        EdgeInsets.fromLTRB(
                                                            2, 1, 2, 1),
                                                    child: SizedBox(
                                                        width: 2,
                                                        child: Container(
                                                          color: Colors.grey,
                                                        ))),
                                                Expanded(
                                                    child: Container(
                                                  width: screenWidth / 2,
                                                  child: Column(
                                                    children: <Widget>[
                                                      Row(
                                                        children: <Widget>[
                                                          Checkbox(
                                                            value:
                                                                _homeDelivery,
                                                            onChanged:
                                                                (bool value) {
                                                              _onHomeDelivery(
                                                                  value);
                                                            },
                                                          ),
                                                          Text(
                                                            "Home Delivery",
                                                            style: TextStyle(
                                                              color:
                                                                  Colors.black,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      FlatButton(
                                                        color: Colors.blue[200],
                                                        onPressed: () {
                                                          _loadMapDialog();
                                                        },
                                                        child: Icon(
                                                          MdiIcons
                                                              .locationEnter,
                                                          color: Colors.black,
                                                        ),
                                                      ),
                                                      Text("Current Address:",
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              color: Colors
                                                                  .black)),
                                                      Row(
                                                        children: <Widget>[
                                                          Text("  "),
                                                          Flexible(
                                                            child: Text(
                                                              curaddress ??
                                                                  "Address not set",
                                                              maxLines: 3,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                              style: TextStyle(
                                                                color: Colors
                                                                    .black,
                                                              ),
                                                            ),
                                                          )
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                )),
                                              ],
                                            ))
                                          ],
                                        ),
                                      ),
                                    ));
                              }

                              if (index == cartData.length + 1) {
                                return Container(
                                    child: Card(
                                  elevation: 5,
                                  child: Column(
                                    children: <Widget>[
                                      SizedBox(
                                        height: 10,
                                      ),
                                      Text("Payment",
                                          style: TextStyle(
                                              fontSize: 20.0,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black)),
                                      SizedBox(height: 10),
                                      Container(
                                          padding:
                                              EdgeInsets.fromLTRB(50, 0, 50, 0),
                                          child: Table(
                                              defaultColumnWidth:
                                                  FlexColumnWidth(1.0),
                                              columnWidths: {
                                                0: FlexColumnWidth(7),
                                                1: FlexColumnWidth(3),
                                              },
                                              children: [
                                                TableRow(children: [
                                                  TableCell(
                                                    child: Container(
                                                        alignment: Alignment
                                                            .centerLeft,
                                                        height: 20,
                                                        child: Text(
                                                            "Total Item Price ",
                                                            style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                color: Colors
                                                                    .black))),
                                                  ),
                                                  TableCell(
                                                    child: Container(
                                                      alignment:
                                                          Alignment.centerLeft,
                                                      height: 20,
                                                      child: Text(
                                                          "RM" +
                                                                  _totalprice
                                                                      .toStringAsFixed(
                                                                          2) ??
                                                              "0.0",
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontSize: 14,
                                                              color: Colors
                                                                  .black)),
                                                    ),
                                                  ),
                                                ]),
                                                TableRow(children: [
                                                  TableCell(
                                                    child: Container(
                                                        alignment: Alignment
                                                            .centerLeft,
                                                        height: 20,
                                                        child: Text(
                                                            "Delivery Charge ",
                                                            style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                color: Colors
                                                                    .black))),
                                                  ),
                                                  TableCell(
                                                    child: Container(
                                                      alignment:
                                                          Alignment.centerLeft,
                                                      height: 20,
                                                      child: Text(
                                                          "RM" +
                                                                  deliverycharge
                                                                      .toStringAsFixed(
                                                                          2) ??
                                                              "0.0",
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontSize: 14,
                                                              color: Colors
                                                                  .black)),
                                                    ),
                                                  ),
                                                ]),
                                                TableRow(children: [
                                                  TableCell(
                                                    child: Container(
                                                        alignment: Alignment
                                                            .centerLeft,
                                                        height: 20,
                                                        child: Text(
                                                            "Total Amount ",
                                                            style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                color: Colors
                                                                    .black))),
                                                  ),
                                                  TableCell(
                                                    child: Container(
                                                      alignment:
                                                          Alignment.centerLeft,
                                                      height: 20,
                                                      child: Text(
                                                          "RM" +
                                                                  amountpayable
                                                                      .toStringAsFixed(
                                                                          2) ??
                                                              "0.0",
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              color: Colors
                                                                  .black)),
                                                    ),
                                                  ),
                                                ]),
                                              ])),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      MaterialButton(
                                        shape: RoundedRectangleBorder(),
                                        minWidth: 200,
                                        height: 40,
                                        child: Text('Make Payment',
                                            style: TextStyle(fontSize: 16)),
                                        color: Colors.blue[200],
                                        textColor: Colors.black,
                                        elevation: 10,
                                        onPressed: makePayment,
                                      ),
                                    ],
                                  ),
                                ));
                              }
                              index -= 0;

                              return Card(
                                  elevation: 10,
                                  child: Padding(
                                      padding: EdgeInsets.all(5),
                                      child: Row(children: <Widget>[
                                        Column(
                                          children: <Widget>[
                                            Container(
                                              height: screenHeight / 8,
                                              width: screenWidth / 5,
                                              child: ClipOval(
                                                  child: CachedNetworkImage(
                                                fit: BoxFit.scaleDown,
                                                imageUrl: server +
                                                    "/productimage/${cartData[index]['id']}.jpg",
                                                placeholder: (context, url) =>
                                                    new CircularProgressIndicator(),
                                                errorWidget:
                                                    (context, url, error) =>
                                                        new Icon(Icons.error),
                                              )),
                                            ),
                                            Text(
                                              "RM" + cartData[index]['price'],
                                              style: TextStyle(
                                                color: Colors.black,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Padding(
                                            padding: EdgeInsets.fromLTRB(
                                                5, 1, 10, 1),
                                            child: SizedBox(
                                                width: 2,
                                                child: Container(
                                                  height: screenWidth / 3.5,
                                                  color: Colors.grey,
                                                ))),
                                        Container(
                                            width: screenWidth / 1.45,
                                            child: Row(
                                              children: <Widget>[
                                                Flexible(
                                                  child: Column(
                                                    children: <Widget>[
                                                      Text(
                                                        cartData[index]['name'],
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 16,
                                                            color:
                                                                Colors.black),
                                                        maxLines: 1,
                                                      ),
                                                      Text(
                                                        "Available " +
                                                            cartData[index]
                                                                ['quantity'] +
                                                            " unit",
                                                        style: TextStyle(
                                                          color: Colors.black,
                                                        ),
                                                      ),
                                                      Text(
                                                        "Quantity " +
                                                            cartData[index]
                                                                ['cquantity'],
                                                        style: TextStyle(
                                                          color: Colors.black,
                                                        ),
                                                      ),
                                                      Container(
                                                          height: 20,
                                                          child: Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .center,
                                                            children: <Widget>[
                                                              FlatButton(
                                                                onPressed: () {
                                                                  _updateCart(
                                                                      index,
                                                                      "add");
                                                                },
                                                                child: Icon(
                                                                  MdiIcons.plus,
                                                                  color: Colors
                                                                          .blue[
                                                                      200],
                                                                ),
                                                              ),
                                                              Text(
                                                                cartData[index][
                                                                    'cquantity'],
                                                                style:
                                                                    TextStyle(
                                                                  color: Colors
                                                                      .black,
                                                                ),
                                                              ),
                                                              FlatButton(
                                                                onPressed: () {
                                                                  _updateCart(
                                                                      index,
                                                                      "remove");
                                                                },
                                                                child: Icon(
                                                                  MdiIcons
                                                                      .minus,
                                                                  color: Colors
                                                                          .blue[
                                                                      200],
                                                                ),
                                                              ),
                                                            ],
                                                          )),
                                                      Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: <Widget>[
                                                          Text(
                                                              "Total RM" +
                                                                  cartData[index]
                                                                      [
                                                                      'yourprice'],
                                                              style: TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  color: Colors
                                                                      .black)),
                                                          FlatButton(
                                                            onPressed: () {
                                                              _deleteCart(
                                                                  index);
                                                            },
                                                            child: Icon(
                                                              MdiIcons.delete,
                                                              color: Colors
                                                                  .blue[200],
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                )
                                              ],
                                            )),
                                      ])));
                            })),
              ],
            ))));
  }

  void _loadCart() {
    _totalprice = 0.0;
    amountpayable = 0.0;
    deliverycharge = 0.0;
    ProgressDialog pr = new ProgressDialog(context,
        type: ProgressDialogType.Normal, isDismissible: false);
    pr.style(message: "Updating cart...");
    pr.show();
    String urlLoadJobs = server + "/php/load_cart.php";
    http.post(urlLoadJobs, body: {
      "email": widget.user.email,
    }).then((res) {
      print(res.body);
      pr.hide().then((isHidden) {
        print(isHidden);
      });
      if (res.body == "Cart Empty") {
        widget.user.quantity = "0";
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (BuildContext context) => MainScreen(
                      user: widget.user,
                    )));
      }

      setState(() {
        var extractdata = json.decode(res.body);
        cartData = extractdata["cart"];
        for (int i = 0; i < cartData.length; i++) {
          _totalprice = cartData[i]['yourprice'] + _totalprice;
        }
        amountpayable = _totalprice;
        print(_totalprice);
      });
    }).catchError((err) {
      print(err);
      pr.hide().then((isHidden) {
        print(isHidden);
      });
    });
    pr.hide().then((isHidden) {
      print(isHidden);
    });
  }

  _deleteCart(int index) {
    showDialog(
      context: context,
      builder: (context) => new AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(20.0))),
        title: new Text(
          'Delete item?',
          style: TextStyle(
            color: Colors.black,
          ),
        ),
        actions: <Widget>[
          MaterialButton(
              onPressed: () {
                Navigator.of(context).pop(false);
                http.post(server + "/php/delete_cart.php", body: {
                  "email": widget.user.email,
                  "prodid": cartData[index]['id'],
                }).then((res) {
                  print(res.body);

                  if (res.body == "success") {
                    _loadCart();
                  } else {
                    Toast.show("Failed", context,
                        duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
                  }
                }).catchError((err) {
                  print(err);
                });
              },
              child: Text(
                "Yes",
                style: TextStyle(
                  color: Colors.black,
                ),
              )),
          MaterialButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: Text(
                "Cancel",
                style: TextStyle(
                  color: Colors.black,
                ),
              )),
        ],
      ),
    );
  }

  void _onDonation(bool newValue) => setState(() {
        _donation= newValue;
        if (_donation) {
          _homeDelivery = false;
          _updatePayment();
        } else {
          _updatePayment();
        }
      });

  void _onHomeDelivery(bool newValue) {
    _getLocation();
    setState(() {
      _homeDelivery = newValue;
      if (_homeDelivery) {
        _updatePayment();
        _donation = false;
      } else {
        _updatePayment();
      }
    });
  }

  void _updatePayment() {
    _totalprice = 0.0;
    amountpayable = 0.0;
    setState(() {
      for (int i = 0; i < cartData.length; i++) {
        _totalprice = double.parse(cartData[i]['yourprice']) + _totalprice;
      }
      print(_donation);
      if (_donation) {
        deliverycharge = 0.0;
      }

      if (_homeDelivery) {
        if (_totalprice > 100) {
          deliverycharge = 5.00;
        } else {
          deliverycharge = 0.0;
        }
      }
      amountpayable = deliverycharge + _totalprice;
      print("Dev Charge:" + deliverycharge.toStringAsFixed(3));
      print(_totalprice);
    });
  }

  void makePaymentDialog() {
    showDialog(
      context: context,
      builder: (context) => new AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(20.0))),
        title: new Text(
          'Proceed with payment?',
          style: TextStyle(
            color: Colors.black,
          ),
        ),
        content: new Text(
          'Are you sure?',
          style: TextStyle(
            color: Colors.black,
          ),
        ),
        actions: <Widget>[
          MaterialButton(
              onPressed: () {
                Navigator.of(context).pop(false);
                makePayment();
              },
              child: Text(
                "Ok",
                style: TextStyle(
                  color: Color.fromRGBO(101, 255, 218, 50),
                ),
              )),
          MaterialButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: Text(
                "Cancel",
                style: TextStyle(
                  color: Color.fromRGBO(101, 255, 218, 50),
                ),
              )),
        ],
      ),
    );
  }

  Future<void> makePayment() async {
    if (_donation) {
      print("DONATION");
      Toast.show("Self Pickup", context,
          duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
    } else if (_homeDelivery) {
      print("HOME DELIVERY");
      Toast.show("Home Delivery", context,
          duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
    } else {
      Toast.show("Please select delivery option", context,
          duration: Toast.LENGTH_LONG,
          gravity: Toast.BOTTOM,
          textColor: Colors.white);
    }
    var now = new DateTime.now();
    var formatter = new DateFormat('ddMMyyyy-');
    String orderid = widget.user.email.substring(1, 4) +
        "-" +
        formatter.format(now) +
        randomAlphaNumeric(6);
    print(orderid);
    await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (BuildContext context) => PaymentScreen(
                  user: widget.user,
                  val: _totalprice.toStringAsFixed(2),
                  orderid: orderid,
                )));
    _loadCart();
  }

  void deleteAll() {
    showDialog(
      context: context,
      builder: (context) => new AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(20.0))),
        title: new Text(
          'Delete all items?',
          style: TextStyle(
            color: Colors.black,
          ),
        ),
        actions: <Widget>[
          MaterialButton(
              onPressed: () {
                Navigator.of(context).pop(false);
                http.post(server + "/php/delete_cart.php", body: {
                  "email": widget.user.email,
                }).then((res) {
                  print(res.body);

                  if (res.body == "success") {
                    _loadCart();
                  } else {
                    Toast.show("Failed", context,
                        duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
                  }
                }).catchError((err) {
                  print(err);
                });
              },
              child: Text(
                "Yes",
                style: TextStyle(
                  color: Colors.black,
                ),
              )),
          MaterialButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: Text(
                "Cancel",
                style: TextStyle(
                  color: Colors.black,
                ),
              )),
        ],
      ),
    );
  }

  _getLocation() async {
    final Geolocator geolocator = Geolocator()..forceAndroidLocationManager;
    _currentPosition = await geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    final coordinates =
        new Coordinates(_currentPosition.latitude, _currentPosition.longitude);
    var addresses =
        await Geocoder.local.findAddressesFromCoordinates(coordinates);
    var first = addresses.first;
    setState(() {
      curaddress = first.addressLine;
      if (curaddress != null) {
        latitude = _currentPosition.latitude;
        longitude = _currentPosition.longitude;
        return;
      }
    });

    print("${first.featureName} : ${first.addressLine}");
  }

  _loadMapDialog() {
    try {
      if (_currentPosition.latitude == null) {
        Toast.show("Location not available. Please wait...", context,
            duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
        _getLocation();
        return;
      }
      _controller = Completer();
      _userpos = CameraPosition(
        target: LatLng(latitude, longitude),
        zoom: 14.4746,
      );

      markers.add(Marker(
          markerId: markerId1,
          position: LatLng(latitude, longitude),
          infoWindow: InfoWindow(
            title: 'Current Location',
            snippet: 'Delivery Location',
          )));

      showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(
            builder: (context, newSetState) {
              return AlertDialog(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20.0))),
                title: Text(
                  "Select New Delivery Location",
                  style: TextStyle(
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.center,
                ),
                titlePadding: EdgeInsets.all(5),
                actions: <Widget>[
                  Text(
                    curaddress,
                    style: TextStyle(
                      color: Colors.black,
                    ),
                  ),
                  Container(
                    height: screenHeight / 2 ?? 600,
                    width: screenWidth ?? 360,
                    child: GoogleMap(
                        mapType: MapType.normal,
                        initialCameraPosition: _userpos,
                        markers: markers.toSet(),
                        onMapCreated: (controller) {
                          _controller.complete(controller);
                        },
                        onTap: (newLatLng) {
                          _loadLoc(newLatLng, newSetState);
                        }),
                  ),
                  MaterialButton(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0)),
                    height: 30,
                    child: Text('Close'),
                    color: Color.fromRGBO(101, 255, 218, 50),
                    textColor: Colors.black,
                    elevation: 10,
                    onPressed: () {
                      markers.clear();
                      Navigator.of(context).pop(false);
                    },
                  ),
                ],
              );
            },
          );
        },
      );
    } catch (e) {
      print(e);
      return;
    }
  }

  void _loadLoc(LatLng loc, newSetState) async {
    newSetState(() {
      print("insetstate");
      markers.clear();
      latitude = loc.latitude;
      longitude = loc.longitude;
      _getLocationfromlatlng(latitude, longitude, newSetState);
      _home = CameraPosition(
        target: loc,
        zoom: 14,
      );
      markers.add(Marker(
          markerId: markerId1,
          position: LatLng(latitude, longitude),
          infoWindow: InfoWindow(
            title: 'New Location',
            snippet: 'New Delivery Location',
          )));
    });
    _userpos = CameraPosition(
      target: LatLng(latitude, longitude),
      zoom: 14.4746,
    );
    _newhomeLocation();
  }

  _getLocationfromlatlng(double lat, double lng, newSetState) async {
    final Geolocator geolocator = Geolocator()
      ..placemarkFromCoordinates(lat, lng);
    _currentPosition = await geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    final coordinates = new Coordinates(lat, lng);
    var addresses =
        await Geocoder.local.findAddressesFromCoordinates(coordinates);
    var first = addresses.first;
    newSetState(() {
      curaddress = first.addressLine;
      if (curaddress != null) {
        latitude = _currentPosition.latitude;
        longitude = _currentPosition.longitude;
        return;
      }
    });
    setState(() {
      curaddress = first.addressLine;
      if (curaddress != null) {
        latitude = _currentPosition.latitude;
        longitude = _currentPosition.longitude;
        return;
      }
    });

    print("${first.featureName} : ${first.addressLine}");
  }

  Future<void> _newhomeLocation() async {
    gmcontroller = await _controller.future;
    gmcontroller.animateCamera(CameraUpdate.newCameraPosition(_home));
  }

  _updateCart(int index, String op) {
    int quantity = int.parse(cartData[index]['quantity']);
    int curquantity = int.parse(cartData[index]['cquantity']);

    if (op == "add") {
      curquantity++;
      if (quantity < (curquantity - 2)) {
        Toast.show("Quantity not available", context,
            duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
        return;
      }
    }
    if (op == "remove") {
      curquantity--;
      if (curquantity == 0) {
        _deleteCart(index);
        return;
      }
    }

    String urlLoadJobs = server + "/php/update_cart.php";
    http.post(urlLoadJobs, body: {
      "email": widget.user.email,
      "prodid": cartData[index]['id'],
      "quantity": curquantity.toString()
    }).then((res) {
      print(res.body);
      if (res.body == "failed") {
        Toast.show("Failed", context,
            duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
        Toast.show("Cart Updated", context,
            duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
        _loadCart();
      } else {
        print(res.body);
        Toast.show("Cart Updated", context,
            duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
      }
    }).catchError((err) {
      print(err);
    });
  }

  Future<Null> refreshList() async {
    await Future.delayed(Duration(seconds: 2));
    _loadCart();
    return null;
  }
}
