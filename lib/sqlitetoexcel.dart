import 'dart:async';

import 'package:flutter/services.dart';

class Sqlitetoexcel {
  static const MethodChannel _channel =
      const MethodChannel('sqlitetoexcel');

  // Export all tables to Excel
  static Future<String> exportAll(String dbName, String exportFolder,String customPath, String filename, List excludes, Map<dynamic,dynamic> prettify) async {
    Map argsMap = <String, dynamic>{
      'db': dbName,
      'exportFolder' : exportFolder,
      'customPath': customPath,
      'filename': filename,
      'excludes' : excludes,
      'prettify' : prettify,
    };
    
    final String result = await _channel.invokeMethod('exportAll',argsMap);
    return result;
  }

  // Export specific tables to Excel
  static Future<String> exportSpecificTables(String dbName, String exportFolder,String customPath, String filename, List tables, List excludes, Map<dynamic,dynamic> prettify) async {
    Map argsMap = <String, dynamic>{
      'db': dbName,
      'exportFolder' : exportFolder,
      'customPath': customPath,
      'filename': filename,
      'tables' : tables,
      'excludes' : excludes,
      'prettify' : prettify
    };
    final String result = await _channel.invokeMethod('exportSpecificTables',argsMap);
    return result;
  }

  // Export single table to Excel
  static Future<String> exportSingleTable(String dbName, String exportFolder,String customPath, String filename, String tableName, List excludes, Map<dynamic,dynamic> prettify) async {
    Map argsMap = <String, dynamic>{
      'db': dbName,
      'exportFolder' : exportFolder,
      'customPath': customPath,
      'filename': filename,
      'tableName' : tableName,
      'excludes' : excludes,
      'prettify' : prettify
    };
    final String result = await _channel.invokeMethod('exportSingleTable',argsMap);
    return result;
  }
}
