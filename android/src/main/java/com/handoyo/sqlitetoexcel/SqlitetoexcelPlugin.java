package com.handoyo.sqlitetoexcel;

import androidx.annotation.NonNull;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;
import com.ajts.androidmads.library.SQLiteToExcel;
import java.util.ArrayList;
import java.util.List;
import java.util.HashMap;
import java.util.Map;
import android.app.Activity;
import android.content.Context;
import android.os.Bundle;
import android.os.Environment;

/** SqlitetoexcelPlugin */
public class SqlitetoexcelPlugin implements FlutterPlugin, MethodCallHandler {
  SQLiteToExcel sqliteToExcel;
  public String filename;
  public String path;

  private static Context context;

  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
    final MethodChannel channel = new MethodChannel(flutterPluginBinding.getFlutterEngine().getDartExecutor(), "sqlitetoexcel");
    channel.setMethodCallHandler(new SqlitetoexcelPlugin());
  }

  // This static function is optional and equivalent to onAttachedToEngine. It supports the old
  // pre-Flutter-1.12 Android projects. You are encouraged to continue supporting
  // plugin registration via this function while apps migrate to use the new Android APIs
  // post-flutter-1.12 via https://flutter.dev/go/android-project-migration.
  //
  // It is encouraged to share logic between onAttachedToEngine and registerWith to keep
  // them functionally equivalent. Only one of onAttachedToEngine or registerWith will be called
  // depending on the user's project. onAttachedToEngine or registerWith must both be defined
  // in the same class.
  public static void registerWith(Registrar registrar) {
    final MethodChannel channel = new MethodChannel(registrar.messenger(), "sqlitetoexcel");
    channel.setMethodCallHandler(new SqlitetoexcelPlugin());
    context=registrar.activity().getApplication();
  }

  @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
  
        if (call.method.equals("exportAll")) {
         
          path = getPath( call.argument("exportFolder"),  call.argument("customPath"));
          sqliteToExcel = new SQLiteToExcel(context, call.argument("db"), path);
  
          // Excluded Columns 
          List<String> excludeColumns = new ArrayList<>();
          List<String> excludes = call.argument("excludes");
          if (excludes.size() > 0) {
            for (String item : excludes) {
              excludeColumns.add(item);
            }
            sqliteToExcel.setExcludeColumns(excludeColumns);
          }
  
          // Prettify or Naming Columns
          HashMap<String, String> prettyNames = new HashMap<>();
          HashMap<String, String> prettify = call.argument("prettify");
          if (prettify.size() > 0) {
            prettify.forEach((k, v) -> {
              prettyNames.put(k, v);
            });
            sqliteToExcel.setPrettyNameMapping(prettyNames);
          }
  
          sqliteToExcel.exportAllTables(call.argument("filename"), new SQLiteToExcel.ExportListener() {
            @Override
            public void onStart() {
               //result.success("Start export"); 
            }

            @Override
            public void onCompleted(String filePath) {
              result.success(filePath);
            }

            @Override
            public void onError(Exception e) {
                result.success(e);
            }
          });
        } else if (call.method.equals("exportSpecificTables")) {
          path = getPath( call.argument("exportFolder"),  call.argument("customPath"));
          sqliteToExcel = new SQLiteToExcel(context, call.argument("db"), path);
  
          // Excluded Columns 
          List<String> excludeColumns = new ArrayList<>();
          List<String> excludes = call.argument("excludes");
          if (excludes.size() > 0) {
            for (String item : excludes) {
              excludeColumns.add(item);
            }
            sqliteToExcel.setExcludeColumns(excludeColumns);
          }
  
          // Prettify or Naming Columns
          HashMap<String, String> prettyNames = new HashMap<>();
          HashMap<String, String> prettify = call.argument("prettify");
          if (prettify.size() > 0) {
            prettify.forEach((k, v) -> {
              prettyNames.put(k, v);
            });
            sqliteToExcel.setPrettyNameMapping(prettyNames);
          }

          sqliteToExcel.exportSpecificTables(call.argument("tables"), call.argument("filename"),
              new SQLiteToExcel.ExportListener() {
                @Override
                public void onStart() {

                }

                @Override
                public void onCompleted(String filePath) {
                  result.success(filePath);
                }

                @Override
                public void onError(Exception e) {

                }
              });
        } else if (call.method.equals("exportSingleTable")) {
          path = getPath( call.argument("exportFolder"),  call.argument("customPath"));
          sqliteToExcel = new SQLiteToExcel(context, call.argument("db"), path);
  
          // Excluded Columns 
          List<String> excludeColumns = new ArrayList<>();
          List<String> excludes = call.argument("excludes");
          if (excludes.size() > 0) {
            for (String item : excludes) {
              excludeColumns.add(item);
            }
            sqliteToExcel.setExcludeColumns(excludeColumns);
          }
  
          // Prettify or Naming Columns
          HashMap<String, String> prettyNames = new HashMap<>();
          HashMap<String, String> prettify = call.argument("prettify");
          if (prettify.size() > 0) {
            prettify.forEach((k, v) -> {
              prettyNames.put(k, v);
            });
            sqliteToExcel.setPrettyNameMapping(prettyNames);
          }

          sqliteToExcel.exportSingleTable(call.argument("tableName"), call.argument("filename"),
              new SQLiteToExcel.ExportListener() {
                @Override
                public void onStart() {

                }

                @Override
                public void onCompleted(String filePath) {
                  result.success(filePath);
                }

                @Override
                public void onError(Exception e) {

                }
              });
    } else {
      result.notImplemented();
    }
  }

  public String getPath(String exportFolder,String customPath) {
    if (exportFolder != "" && customPath !="" ) {
      switch (exportFolder.toString()) {
         case "downloads" :
           path = Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_DOWNLOADS).toString() + "/";
           break;
         case "documents" : 
           path = Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_DOCUMENTS).toString() + "/";
           break;
         case "custom" : 
           path = customPath;
           break;
      }
    } else {
      switch (exportFolder.toString()) {
        case "downloads" :
          path = Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_DOWNLOADS).toString() + "/";
          break;
        case "documents" : 
          path = Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_DOCUMENTS).toString() + "/";
          break;
      }
    }
    return path;
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
  }
}
