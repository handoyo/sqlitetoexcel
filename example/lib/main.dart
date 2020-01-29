import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:sqlitetoexcel/sqlitetoexcel.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  static Database _db;
  final scaffoldKey = GlobalKey<ScaffoldState>();
  var dbName = "sample.db";
  var path, dbPath, dir;

  @override
  void initState() {
    super.initState();
    db.then((result) {});
    getPermission();
  }

  getPermission() async {
    await PermissionHandler()
        .checkPermissionStatus(PermissionGroup.storage)
        .then((status) {
      if (status == PermissionStatus.denied) {
        requestPermission();
      }
    });
  }

  requestPermission() async {
    await PermissionHandler().requestPermissions([PermissionGroup.storage]);
  }

  Future<Database> get db async {
    if (_db != null) return _db;
    _db = await initDb();
    return _db;
  }

  initDb() async {
    final directory = await getExternalStorageDirectory();
    String path = join(directory.path, dbName);
    var theDb = await openDatabase(path, version: 1, onCreate: _onCreate);
    return theDb;
  }

  void _onCreate(Database db, int version) async {
    // When creating the db, create the table
    await db.execute(
        "CREATE TABLE `customer` (customer_id INTEGER PRIMARY KEY, first_name INTEGER, last_name TEXT);");
    await db.rawInsert(
        'INSERT INTO `customer` (customer_id, first_name, last_name) VALUES (1, "Becky", "Toad"),(2, "Teddy", "Bear"),(3, "Ducky", "Donald")');
    await db.execute(
        "CREATE TABLE `product` (product_id INTEGER PRIMARY KEY, product_name TEXT, price REAL, description TEXT);");
    await db.rawInsert(
        'INSERT INTO `product` (product_id, product_name, price, description) VALUES (1, "Skinsheen" , 10.000 , "This a dummy product for testing"),(2, "Scar removal" , 15.000 , "This a dummy product for testing"),(3, "Face cleanser" , 20.000 , "This a dummy product for testing")');
    await db.execute(
        "CREATE TABLE `order_products` (order_products_id, product_id INTEGER PRIMARY KEY, qty INT, unit_price REAL, subtotal REAL, shipping_cost REAL, total REAL);");
    await db.rawInsert(
        'INSERT INTO `order_products` (order_products_id, product_id, qty, unit_price, subtotal,shipping_cost,total) VALUES (1, 1 , 2, 10.000, 20.000, 9.000, 29.000),(2, 2 , 3, 15.000, 45.000, 18.000, 63.000),(3, 4 , 2, 20.000, 40.000, 9.000, 49.000)');
  }

  // Export All tables
  Future<String> _exportAll() async {
    var excludes = new List<dynamic>();
    var prettify = new Map<dynamic, dynamic>();
    var finalpath = "";

    // Exclude column(s) from being exported
    excludes.add("order_id");

    // Prettifies columns name
    prettify["customer_id"] = "Customer ID";
    prettify["first_name"] = "First Name";
    prettify["last_name"] = "Last Name";
    prettify["product_id"] = "Product ID";
    prettify["product_name"] = "Product Name";
    prettify["price"] = "Price";
    prettify["description"] = "Description";
    prettify["qty"] = "Quantity";
    prettify["subtotal"] = "Sub Total";
    prettify["shipping_fee"] = "Shipping Fee";
    prettify["total"] = "Total";

    final directory = await getExternalStorageDirectory();
    path = directory.path;
    dbPath = join(directory.path, dbName);
    try {
      finalpath = await Sqlitetoexcel.exportAll(
          dbPath, "documents", "", "Export All.xls", excludes, prettify);
      return finalpath;
    } on PlatformException catch (e) {
      print("exception" + e.message.toString());
    }
    return finalpath;
  }

  // Export specific tables only
  Future<String> _exportSpecificTables() async {
    var excludes = new List();
    var prettify = new Map<dynamic, dynamic>();
    var tables = new List();
    var finalpath = "";

    // Exclude column(s) from being exported
    excludes.add("order_id");
    excludes.add("customer_id");

    //Tables name that will be exported
    tables.add("customer");
    tables.add("product");

    // Prettifies columns name
    prettify["first_name"] = "First Name";
    prettify["last_name"] = "Last Name";
    prettify["product_id"] = "Product ID";
    prettify["product_name"] = "Product Name";
    prettify["price"] = "Price";
    prettify["description"] = "Description";
    prettify["qty"] = "Quantity";

    final directory = await getExternalStorageDirectory();

    var path = directory.path;
    path = directory.path;
    dbPath = join(directory.path, dbName);
    dir = path + "/";
    try {
      finalpath = await Sqlitetoexcel.exportSpecificTables(dbPath, "documents",
          "", "Export Specifics Table.xls", tables, excludes, prettify);
      return finalpath;
    } on PlatformException catch (e) {
      print(e.message.toString());
    }
    return finalpath;
  }

  Future<String> _exportSingleTable() async {
    var excludes = new List();
    var prettify = new Map<dynamic, dynamic>();
    var finalpath = "";

    // Exclude column(s) from being exported
    excludes.add("customer_id");

    // Prettifies columns name
    prettify["first_name"] = "First Name";
    prettify["last_name"] = "Last Name";

    // Table name that will be exported
    var tableName = "customer";

    final directory = await getExternalStorageDirectory();
    var path = directory.path;
    path = directory.path;
    dbPath = join(directory.path, dbName);
    dir = path + "/";

    try {
      finalpath = await Sqlitetoexcel.exportSingleTable(dbPath, "documents", "",
          "Export Single Table.xls", tableName, excludes, prettify);
    } on PlatformException catch (e) {
      print(e.message.toString());
    }
    return finalpath;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        key: scaffoldKey,
        body: SingleChildScrollView(
          child: Center(
              child: Column(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(top: 40),
                child: Container(
                  child: RaisedButton(
                    onPressed: () {
                      _exportAll().then((path) {
                        showSnackBar(path.toString());
                      });
                    },
                    child: Text("Export All"),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 60),
                child: Container(
                  child: RaisedButton(
                    onPressed: () {
                      _exportSpecificTables().then((path) {
                        showSnackBar(path.toString());
                      });
                    },
                    child: Text("Export Specific Tables"),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 80),
                child: Container(
                  child: RaisedButton(
                    onPressed: () {
                      _exportSingleTable().then((path) {
                        showSnackBar(path.toString());
                      });
                    },
                    child: Text("Export Single table"),
                  ),
                ),
              ),
            ],
          )),
        ),
      ),
    );
  }

  void showSnackBar(String message) {
    scaffoldKey.currentState.showSnackBar(SnackBar(
      content: Text('Your excel file is saved in ' + message),
      duration: Duration(seconds: 2),
      action: SnackBarAction(
        label: 'Close',
        textColor: Colors.white,
        onPressed: scaffoldKey.currentState.hideCurrentSnackBar,
      ),
    ));
  }
}
