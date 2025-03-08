import 'package:logger/logger.dart';

class LogService {
  static final Logger logger = Logger(
    printer: PrettyPrinter(
      methodCount: 4,
      errorMethodCount: 5,
      dateTimeFormat: DateTimeFormat.onlyTime,
    ),
  );

  static void d(String message) => logger.d(message);
  static void i(String message) => logger.i(message);
  static void w(String message) => logger.w(message);
  static void e(String message) => logger.e(message);
}
