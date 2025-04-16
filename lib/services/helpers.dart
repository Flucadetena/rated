import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'dart:ui' as ui;

/// Simple function to get the type of a generic
/// and use it to make a comparison.
///
/// When using [T], comparison will not work and always return false.
/// Using [typeOf<T>()] solves this issue.
///
/// Example:
/// Assuming we use T as String.
/// `T is String` will always return false.
/// But: `typeOf<String>() is String` will return true.
Type typeOf<X>() => X;

/// Return the [String] version of the [enum]
String enumToString(Object o) => o.toString().split('.').last;

/// Returns a random [int] between the specified ranged.
/// The [min] value is inclusive and the [max] value is exclusive.
int randomRange(int min, int max) => min + Random().nextInt(max - min);

/// Checks [val] and returns it as a [Timestamp].
/// In case [val] is not supported it will return `Timestamp.now()`.
Timestamp getTimestamp(dynamic val) => switch (val) {
  Timestamp val => val,
  String time => Timestamp.fromDate(DateTime.parse(time)),
  {'_seconds': int seconds, '_nanoseconds': int nano} => Timestamp(seconds, nano),
  _ => Timestamp.now(),
};

/// Checks [val] and returns it as a [Timestamp].
/// In case [val] is null it will return `null`.
/// In case [val] is not not null but not supported it will return `Timestamp.now()`.
Timestamp? getTimestampOrNull(dynamic val) => switch (val) {
  null => null,
  _ => getTimestamp(val),
};

/// Checks [val] and returns it as a [GeoPoint].
/// In case [val] is not supported it will return `GeoPoint(0, 0)`.
GeoPoint getGeoPoint(dynamic val) => switch (val) {
  GeoPoint val => val,
  {'latitude': double lat, 'longitude': double lon} => GeoPoint(lat, lon),
  _ => const GeoPoint(0, 0),
};

/// Checks [val] and returns it as a [GeoPoint].
/// In case [val] is not supported it will return `GeoPoint(0, 0)`.
/// In case [val] is null it will return `null`.
GeoPoint? getGeoPointOrNull(dynamic val) => switch (val) {
  null => null,
  _ => getGeoPoint(val),
};

/// Returns the specified Widget as an image.
/// The [GlobalKey] is used to get the widget.
/// The Widget must already be rendered.
///
/// You can transform any [StatefulWidget] or [StatelessWidget] into an image.
/// But be aware that updates won't be reflected in the image.
Future<Uint8List> widgetAsImage(GlobalKey key) async {
  try {
    RenderRepaintBoundary boundary = key.currentContext?.findRenderObject() as RenderRepaintBoundary;

    ui.Image image = await boundary.toImage(pixelRatio: 3.0);
    ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);

    if (byteData == null) throw ErrorDescription('byteData null');

    var pngBytes = byteData.buffer.asUint8List();
    return pngBytes;
  } catch (err, stack) {
    crashError(err, 'Error transforming the widget to an image', stack: stack);
    throw Error();
  }
}

/// Simplified version of the [FirebaseCrashlytics.instance.recordError] method.
Future<void> crashError(Object error, String reason, {StackTrace? stack}) async {
  await FirebaseCrashlytics.instance.recordError(error.toString(), stack ?? StackTrace.current, reason: reason);
}

/// Returns the color to be used on top of the input color.
/// The color is either "almost black" or white, depending on the luminance of the input color.
///
/// You can set a threshold to adjust. The default is 0.5.
Color getContrastColor(Color color, {double threshold = 0.5}) {
  double luminance = color.computeLuminance();

  return luminance > threshold ? const Color(0xff0F0F0F) : const Color(0xffffffff);
}

/// Cleans a string that comes from a Gemini response.
///
/// The response needs to contain a code block with the language identifier "json" (e.g., ```json ... ```).
/// This function will remove the leading and trailing content, returning only the JSON content.
/// If the input string does not contain a code block, it will be returned as is.
///
/// You can then use the [jsonDecode] method that comes with the Dart SDK to parse the JSON.
///
/// Example:
/// ```dart
/// String jsonString = cleanPromptJson('This is the answer from gemini. ```json\n{"name": "John", "age": 30}\n```');
/// print(jsonString); // Output: '{"name": "John", "age": 30}'
/// ```
String cleanPromptJson(String response) {
  if (response.contains('```')) {
    final withoutLeading = response.split('```json').last;
    final withoutTrailing = withoutLeading.split('```').first;
    return withoutTrailing;
  }
  return response;
}

/// Calculates the 4 points of a circle given a center point (latitude, longitude) and a radius.
List<GeoPoint> getQueryGeoPoints({required double latitude, required double longitude, required double radius}) {
  // Earth's radius in meters
  const double earthRadius = 6371000;

  // Convert latitude to radians
  double latRad = latitude * pi / 180;

  // Latitude variation
  double deltaLat = (radius / earthRadius) * (180 / pi);

  // Longitude variation (adjusted for latitude)
  double deltaLon = (radius / (earthRadius * cos(latRad))) * (180 / pi);

  // Calculate the 2 points
  return [GeoPoint(latitude + deltaLat, longitude - deltaLon), GeoPoint(latitude - deltaLat, longitude + deltaLon)];
}

Uri formatUrl(String url) {
  if (!url.startsWith('http://') && !url.startsWith('https://')) {
    return Uri.parse('https://$url');
  }

  return Uri.parse(url);
}
