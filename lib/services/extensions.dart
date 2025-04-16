import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:jiffy/jiffy.dart';
import 'package:labhouse/services/helpers.dart';

extension FirestoreSnapshot on DocumentSnapshot {
  /// Simple method to avoid casting [data()] every time.
  /// #syntacticSugar
  Map<String, Object?> get dataAsMap => data() as Map<String, Object?>? ?? {};
}

/// Extension method that allows casting a value to a specified type.
/// Intended facilitate the casting of Firestore data and minimize errors.
/// It can cast single values and Lists.
///
/// Example:
/// ```dart
///
/// class User {
///   final String name;
///
///   User({required this.name});
///
///   User fromMap(Map<String, Object?> data) => User(name: data['name'].as<String>());
///
/// }
/// ```
extension FirestoreMapping on Object? {
  /// This method allows casting a value to a specified Type [T].
  /// The supported Types for [T] are: `String, int, double, bool, Timestamp, Color`.
  ///
  /// Number values will be casted to the specified type.
  /// So if the [Object] is of Type `int` and [T] is of Type `double`,
  /// the value will be converted to `double`.
  ///
  /// If [defaultVal] is provided, it will be returned in case the value is null.
  /// If not, the default value for the specified type will be returned.
  /// The default value pair is: {String: '', int: 0, double: 0.0, bool: false, Timestamp: Timestamp.now(), Color: Colors.transparent, GeoPoint: GeoPoint(0,0)}.
  ///
  /// If the value is not supported, an Exception will be thrown.
  ///
  /// Example:
  /// ```dart
  /// final name = data['name'].as<String>();
  /// final age = data['age'].as<int>();
  /// final height = data['height'].as<double>();
  /// final isAdult = data['isAdult'].as<bool>();
  /// final date = data['date'].as<Timestamp>();
  /// final color = data['color'].as<Color>();
  /// final point = data['point'].as<GeoPoint>();
  /// ```
  T as<T>({T? defaultVal}) {
    final type = typeOf<T>();

    final res = switch (this) {
      T val => val,
      num val when type == int => val.toInt() as T,
      num val when type == double => val.toDouble() as T,
      String val when type == Color => Color(int.parse('0x$val')) as T,
      dynamic val when type == Timestamp => getTimestamp(val) as T,
      dynamic val when type == GeoPoint => getGeoPoint(val) as T,
      _ when defaultVal != null => defaultVal,
      _ when type == String => '' as T,
      _ when type == int => 0 as T,
      _ when type == double => 0.0 as T,
      _ when type == bool => false as T,
      _ when type == Color => Colors.transparent as T,
      _ => throw Exception('Type not supported'),
    };
    return res;
  }

  /// This method allows casting a value to a specified Type [T].
  /// It uses the method [as] to cast the value.
  /// If the [Object] is null, null will be returned.
  T? asOrNull<T>() => switch (this) {
    null => null,
    _ => as<T>(),
  };

  /// This method allows casting a List of values to a specified Type [T].
  /// It uses the method [as] to cast each value in the List.
  /// If the [Object] is not a List, the [defaultVal] will be returned
  /// or empty List if [defaultVal] is `null`.
  List<T> asList<T>({List<T>? defaultVal}) {
    if (this case List<Object?> val) {
      return val.map((v) => v.as<T>()).toList();
    }

    return defaultVal ?? List<T>.empty(growable: true);
  }

  /// This method allows casting a List of values to a specified Type [T].
  /// It uses the method [as] to cast each value in the List.
  /// If the [Object] is not a List, null will be returned.
  List<T>? asListOrNull<T>() {
    if (this == null) return null;
    return asList<T>();
  }
}

/// Extension for all things [String].
/// Includes methods to ease the use of common operations with [String] across the app.
extension StringExtension on String {
  /// Returns the [String] in camelCase format.
  /// It also treats compound words separated by hyphens the same. So 'first-second' will return 'First-Second'.
  String get camelCase {
    List<String> res = [];
    res = split(' ');
    res = res.where((str) => str != '').map((str) => str.firstUppercase).toList();
    String resString = res.join(' ');
    res = resString.split('-');
    res = res.where((str) => str != '').map((str) => str.firstUppercase).toList();
    return res.join('-');
  }

  /// Capitalizes only the first letter of the [String]
  String get firstUppercase => this != '' ? this[0].toUpperCase() + substring(1) : '';

  /// Returns a subset of the [String] of the specified [size].
  /// If the [String] is smaller than the [size], the original [String] is returned.
  String sub(int size) => length <= size ? this : substring(0, size);

  static const _diacritics = 'ÀÁÂÃÄÅàáâãäåÒÓÔÕÕÖØòóôõöøÈÉÊËèéêëðÇçÐÌÍÎÏìíîïÙÚÛÜùúûüÑñŠšŸÿýŽž';
  static const _nonDiacritics = 'AAAAAAaaaaaaOOOOOOOooooooEEEEeeeeeCcDIIIIiiiiUUUUuuuuNnSsYyyZz';

  /// Returns the [String] without diacritical marks.
  /// Use it for searches, sorting, or comparison purposes.
  ///
  /// E.x: 'Álvaro' -> 'Alvaro'
  String get withoutDiacriticalMarks => splitMapJoin(
    '',
    onNonMatch:
        (char) => char.isNotEmpty && _diacritics.contains(char) ? _nonDiacritics[_diacritics.indexOf(char)] : char,
  );

  /// Returns the [String] in lowercase without diacritical marks and trimmed.
  /// Use it for searches, sorting, or comparison purposes.
  ///
  /// E.x: ' Álvaro Garrido ' -> 'alvaro garrido'
  String get clean => withoutDiacriticalMarks.toLowerCase().trim();
}

/// Extension for all things [Color].
extension ColorExtension on Color {
  //! Until the color change has been resolved we use this method. Issues:
  //! https://github.com/flutter/flutter/issues/160184
  //! https://github.com/flutter/flutter/issues/159686
  //! Old version - toString().replaceFirst('Color(0x', '').replaceFirst(')', '');
  /// Returns the [Color] in a hex format including the alpha channel. E.x: 'FF000000'.
  String get toMap => value.toRadixString(16);

  /// Returns a lighter version of the [Color] by using the opacity [opacity] and adding a white overlay.
  /// Use this to get the same result as with the `withOpacity` method but without the transparency.
  Color lighterByOpacity(double opacity) {
    assert(opacity >= 0 && opacity <= 1, 'Opacity must be between 0 and 1');
    return Color.lerp(this, Colors.white, 1 - opacity)!;
  }

  /// Return a darker or lighter version of the color based on the [backgroundColor]
  /// This can be use to ensure the right contrast between the content and the background.
  Color betterContrastOverColor(Color backgroundColor, {double threshold = 0.5, double blendLevel = 0.5}) {
    double luminance = computeLuminance();
    Color blendColor = luminance > threshold ? Colors.black : Colors.white;

    return Color.lerp(this, blendColor, 1 - blendLevel)!;
  }
}

/// Extension for all things [List].
extension Lists<T> on List<T> {
  /// Returns a subset of the [List] of the specified [size].
  /// If the [List] is smaller than the [size], the original [List] is returned.
  ///
  /// If [start] is provided, the subset will start from that index.
  /// If [start] is greater than the [size] or the `List.length`, an empty [List] is returned.
  /// If [size] is greater or equal to the `List.length`, the `List.length` value is used.
  List<T> sub(int size, {int start = 0}) {
    final totalSize = length <= size ? length : size;

    return start >= totalSize ? [] : sublist(start, totalSize);
  }

  /// Returns a subset a [List] without the first [number] of elements.
  /// If the [number] is negative, the last [number] elements will be returned.
  /// If the [number] is greater or equal to the `List.length`, an empty [List] is returned.
  List<T> pop(int number) {
    if ((number).abs() >= length) return number > 0 ? [] : this;
    if (number < 0) return sublist(length + number);
    if (number == 0) return [];
    return sublist(number, length);
  }
}

/// Extension for all things [num].
extension NumExtension on num {
  /// Converts the [num] from hours to milliseconds.
  /// Useful to store time in firestore without using [Timestamp].
  ///
  /// E.x: 1.hoursToMilliseconds -> 3600000
  int get hoursToMilliseconds => (this * 60 * 60 * 1000).toInt();

  /// Converts the [num] from minutes to milliseconds.
  /// Useful to store time in firestore without using [Timestamp].
  ///
  /// E.x: 1.minutesToMilliseconds -> 60000
  int get minutesToMilliseconds => (this * 60 * 1000).toInt();

  /// Converts the [num] from milliseconds to hours.
  /// Useful to convert time stored in firestore without using [Timestamp].
  ///
  /// E.x: 3600000.millisecondsToHours -> 1
  int get millToHours => Duration(milliseconds: toInt()).inHours;

  /// Converts the [num] from milliseconds to minutes.
  /// Useful to convert time stored in firestore without using [Timestamp].
  ///
  /// E.x: 60000.millisecondsToMinutes -> 1
  int get millToMinutes => Duration(milliseconds: toInt()).inMinutes.remainder(60);

  /// Converts the [num] from seconds to minutes.
  int get secToMinutes => Duration(seconds: toInt()).inMinutes;

  /// Converts the [num] from seconds to hours.
  int get secToHours => Duration(seconds: toInt()).inHours;

  /// Converts the [num] from minutes to hours.
  int get minToHours => Duration(minutes: toInt()).inHours;

  /// Converts the [num] from minutes to seconds.
  int get minToSeconds => Duration(minutes: toInt()).inSeconds;

  /// Converts the [num] from hours to minutes.
  int get hoursToMinutes => Duration(hours: toInt()).inMinutes;

  /// Converts the [num] from hours to seconds.
  int get hoursToSeconds => Duration(hours: toInt()).inSeconds;

  /// Formats big numbers to a compact form to display in the UI.
  /// E.x: 1500 -> 1.5K
  /// E.x: 1000000 -> 1M
  String get compactNum => NumberFormat.compact().format(this);
}

/// Extension for all things [Timestamp].
extension ExtendTimeStamp on Timestamp {
  /// Adds or removes minutes from a Timestamp.
  /// If [minutes] is negative, the time will be removed.
  ///
  /// The addition or subtraction will affect the date.
  /// Adjusting the: hours, days, months,..
  Timestamp addRmvMinutes(int minutes) {
    Jiffy date = Jiffy.parseFromDateTime(toDate());
    date = minutes > 0 ? date.add(minutes: minutes) : date.subtract(minutes: minutes.abs());
    return Timestamp.fromDate(date.dateTime);
  }

  /// Adds or removes hours from a Timestamp.
  /// If [hours] is negative, the time will be removed.
  ///
  /// The addition or subtraction will affect the date.
  /// Adjusting the: days, months, years,..
  Timestamp addRmvHours(int hours) {
    Jiffy date = Jiffy.parseFromDateTime(toDate());
    date = hours > 0 ? date.add(hours: hours) : date.subtract(hours: hours.abs());
    return Timestamp.fromDate(date.dateTime);
  }

  /// Adds or removes days from a Timestamp.
  /// If [days] is negative, the time will be removed.
  ///
  /// The addition or subtraction will affect the date.
  /// Adjusting the: months, years,..
  Timestamp addRmvDays(int days) {
    Jiffy date = Jiffy.parseFromDateTime(toDate());
    date = days > 0 ? date.add(days: days) : date.subtract(days: days.abs());
    return Timestamp.fromDate(date.dateTime);
  }

  /// Adds or removes months from a Timestamp.
  /// If [months] is negative, the time will be removed.
  ///
  /// The addition or subtraction will affect the date.
  /// Adjusting the: years,..
  Timestamp addRmvMonths(int months) {
    Jiffy date = Jiffy.parseFromDateTime(toDate());
    date = months > 0 ? date.add(months: months) : date.subtract(months: months.abs());
    return Timestamp.fromDate(date.dateTime);
  }

  /// Adds or removes years from a Timestamp.
  /// If [years] is negative, the time will be removed.
  Timestamp addRmvYears(int years) {
    Jiffy date = Jiffy.parseFromDateTime(toDate());
    date = years > 0 ? date.add(years: years) : date.subtract(years: years.abs());
    return Timestamp.fromDate(date.dateTime);
  }

  /// Returns the [Timestamp] with the time set to the start of the day (00:00:00).
  Timestamp get startOfDay {
    DateTime date = toDate().startOfDay;
    return Timestamp.fromDate(date);
  }

  /// Returns the [Timestamp] with the time set to the end of the day (23:59:59).
  Timestamp get endOfDay {
    DateTime date = toDate().endOfDay;
    return Timestamp.fromDate(date);
  }

  /// Returns the [Timestamp] with the time set to the start of the week (00:00:00).
  Timestamp get startOfWeek {
    DateTime date = toDate().startOfWeek;
    return Timestamp.fromDate(date);
  }

  /// Returns the [Timestamp] with the time set to the end of the week (23:59:59).
  Timestamp get endOfWeek {
    DateTime date = toDate().endOfWeek;
    return Timestamp.fromDate(date);
  }

  /// Returns the [Timestamp] with the time set to the start of the month (00:00:00).
  Timestamp get startOfMonth {
    DateTime date = toDate().startOfMonth;
    return Timestamp.fromDate(date);
  }

  /// Returns the [Timestamp] with the time set to the end of the month (23:59:59).
  Timestamp get endOfMonth {
    DateTime date = toDate().endOfMonth;
    return Timestamp.fromDate(date);
  }

  /// Changes the only the day of the [Timestamp], keeping all other values.
  Timestamp setDay(int day) {
    DateTime date = toDate();
    date = DateTime(date.year, date.month, day, date.hour, date.minute, date.second);
    return Timestamp.fromDate(date);
  }

  // Returns `true` if the [Timestamp] is a date before the start of the day (00:00:00).
  bool get isBeforeToday {
    return compareTo(Timestamp.now().startOfDay) < 0;
  }

  // Returns `true` if the [Timestamp] is a date after the end of the day (23:59:59).
  bool get isAfterToday {
    return compareTo(Timestamp.now().endOfDay) > 0;
  }

  // Returns `true` if the [Timestamp] is a date before or the same as the start of the day (00:00:00).
  bool get isBeforeOrToday {
    return compareTo(Timestamp.now().startOfDay) <= 0;
  }

  // Returns `true` if the [Timestamp] is a date after or the same as the end of the day (23:59:59).
  bool get isAfterOrToday {
    return compareTo(Timestamp.now().endOfDay) >= 0;
  }

  // Returns `true` if the [Timestamp] is a date before `Timestamp.now()`.
  bool get isBeforeNow {
    return compareTo(Timestamp.now()) < 0;
  }

  // Returns `true` if the [Timestamp] is a date after `Timestamp.now()`.
  bool get isAfterNow {
    return compareTo(Timestamp.now()) > 0;
  }

  // Returns `true` if the [Timestamp] is a date before or the same as `Timestamp.now()`.
  bool get isBeforeOrNow {
    return compareTo(Timestamp.now()) <= 0;
  }

  // Returns `true` if the [Timestamp] is a date after or the same as `Timestamp.now()`.
  bool get isAfterOrNow {
    return compareTo(Timestamp.now()) >= 0;
  }

  // Returns `true` if the [Timestamp] is a date before [date].
  bool isBefore(Timestamp date) {
    return compareTo(date) < 0;
  }

  // Returns `true` if the [Timestamp] is a date after [date].
  bool isAfter(Timestamp date) {
    return compareTo(date) > 0;
  }

  // Returns `true` if the [Timestamp] is a date before or the same as [date].
  bool isBeforeOrEqual(Timestamp date) {
    return compareTo(date) <= 0;
  }

  // Returns `true` if the [Timestamp] is a date after or the same as [date].
  bool isAfterOrEqual(Timestamp date) {
    return compareTo(date) >= 0;
  }
}

/// Extension for all things [DateTime].
extension ExtendDateTime on DateTime {
  /// Returns the [DateTime] with the time set to the start of the day (00:00:00).
  DateTime get startOfDay => DateTime(year, month, day);

  /// Returns the [DateTime] with the time set to the end of the day (23:59:59).
  DateTime get endOfDay => DateTime(year, month, day, 23, 59, 59);

  /// Returns the [DateTime] with the time set to the start of the week (00:00:00).
  DateTime get startOfWeek => subtract(Duration(days: weekday - 1)).startOfDay;

  /// Returns the [DateTime] with the time set to the end of the week (23:59:59).
  DateTime get endOfWeek => add(Duration(days: DateTime.daysPerWeek - weekday)).endOfDay;

  /// Returns the [DateTime] with the time set to the start of the month (00:00:00).
  DateTime get startOfMonth => DateTime(year, month, 1);

  /// Returns the [DateTime] with the time set to the end of the month (23:59:59).
  DateTime get endOfMonth => DateTime(year, month + 1, 0, 23, 59, 59);

  /// Returns whether the Date is before now or not.
  bool get isBeforeNow => isBefore(DateTime.now());

  /// Returns whether the Date is after now or not.
  bool get isAfterNow => isAfter(DateTime.now());

  /// Allows to set any value of the [DateTime] without changing the others.
  DateTime setDate({int? newYear, int? newMonth, int? newDay, int? newHour, int? newMinute, int? newSecond}) {
    return DateTime(
      newYear ?? year,
      newMonth ?? month,
      newDay ?? day,
      newHour ?? hour,
      newMinute ?? minute,
      newSecond ?? second,
    );
  }

  /// Return the minutes and the seconds
  /// E.x: '24:53'
  // ignore: non_constant_identifier_names
  String get mmss => DateFormat('mm:ss').format(this);

  /// Return the name of the day of the week
  /// E.x: 'Monday'
  // ignore: non_constant_identifier_names
  String get EEEE => DateFormat('EEEE').format(this);

  /// Return hour and minutes with 24 hr format
  /// E.x: '14:00'
  // ignore: non_constant_identifier_names
  String get HHmm => DateFormat('HH:mm').format(this);

  /// Return hour and minutes with 24 hr format
  /// E.x: '2:00 pm'
  // ignore: non_constant_identifier_names
  String get hhmmAmPm => DateFormat('hh:mm a').format(this).toLowerCase();

  /// Return day and month in numbers
  /// E.x; '26/10'
  String get dM => DateFormat('d/M').format(this);

  /// Return day number/month number/last 2 numbers of year
  /// E.x: '26/10/23'
  String get ddMMyy => DateFormat('dd/MM/yy').format(this);

  /// Return day number/month number/year number
  /// E.x: '26/10/2023'
  String get ddMMyyyy => DateFormat('dd/MM/yyyy').format(this);

  /// Return the day name of week, number and month
  /// E.x: 'Thu 26/10'
  // ignore: non_constant_identifier_names
  String get EddMM => DateFormat('E dd/MM').format(this);

  /// Return the day number and first 3 letters of month
  /// E.x: '26 Oct'
  String get ddMMM => DateFormat('dd MMM').format(this);

  /// Return the month name and day number.
  /// E.x: 'October 26'
  // ignore: non_constant_identifier_names
  String get MMMMdd => DateFormat('MMMM dd').format(this);

  /// Return day name, day number and month.
  /// E.x; 'Thu, 26 October'
  // ignore: non_constant_identifier_names
  String get EdMMMM => DateFormat('E, d MMMM').format(this);

  /// Return day name, day number and month name.
  /// E.x: 'Thursday 26 October'
  // ignore: non_constant_identifier_names
  String get EEEEdMMMM => DateFormat('EEEE d MMMM').format(this);

  /// Return only the hour 24 format.
  /// E.x: '14'
  String get H => DateFormat('H').format(this);

  /// Return day name, day number and month name. Hour, minutes with h.
  /// E.x: 'Thursday, 26 October • 15:30h'
  String get dateAndHour => '${DateFormat('EEEE, dd MMMM • HH:mm').format(this)}h';

  /// Return day name, day number and month name and year.
  /// E.x: 'Thursday, 26 October 2025'
  String get dateWithDay => DateFormat('EEEE, dd MMMM yyyy').format(this);

  /// Return day name, day number and month name. Hour, minutes with h.
  /// E.x: 'Thursday, 26 October • 15:30h'
  String get dateHour => '${DateFormat('EEEE dd • HH:mm').format(this)}h';

  /// Return day number, month name - Hour, minutes with h.
  /// E.x: '26 Oct - 15:30h'
  // ignore: non_constant_identifier_names
  String get ddMMM_HHmm => '${DateFormat('dd MMM - HH:mm').format(this)}h';

  /// Return month name, day number, year number.
  /// E.x: 'December 1,2023'
  // ignore: non_constant_identifier_names
  String get MMdd_yy => DateFormat('yMMMMd').format(this);

  /// Return month name.
  /// E.x: 'December'
  /// ignore: non_constant_identifier_names
  String get MMMM => DateFormat('MMMM').format(this);

  /// Return month name abbreviated.
  /// E.x: 'Dec'
  /// ignore: non_constant_identifier_names
  String get MMM => DateFormat('MMM').format(this);

  /// Return day(num) month(name abr.), year(num).
  /// E.x: '1 dec 2023'
  // ignore: non_constant_identifier_names
  String get MMM_d_y => DateFormat('MMMM d, y').format(this);

  /// Return first 3 letters of month, the day(number) and last 2 numbers of year
  /// E.x: 'Jun 12/23'
  // ignore: non_constant_identifier_names
  String get MMM_dyy => DateFormat('MMM d/yy').format(this);

  /// Return day, month • hour, minutes.
  /// E.x: '24 April • 11:00'
  String get dMHm => DateFormat('d MMMM • HH:mm').format(this);
}

extension DurationExtension on Duration {
  String get HHMM => toString().split('.').first.split(':').pop(2).join(':');
  String get MMSS => toString().split('.').first.split(':').pop(-2).join(':');
  String get HHMMSS => toString().split('.').first;
  String get HHMMSS_NoZero {
    final sections = toString().split('.').first.split(':');
    if (int.tryParse(sections.first) != null && int.parse(sections.first) > 0) {
      return sections.join(':');
    } else if (int.tryParse(sections[1]) != null && int.parse(sections[1]) > 0) {
      return sections.pop(-2).join(':');
    } else {
      return sections.pop(-1).first;
    }
  }
}
