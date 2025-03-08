import 'package:flutter/material.dart';

class SnackBarUtil {
  static void showSnackBar({
    required BuildContext context,
    required String message,
    SnackBarType type = SnackBarType.info,
    Duration duration = const Duration(seconds: 3),
    SnackBarAction? action,
  }) {
    final messenger = ScaffoldMessenger.of(context);

    messenger.clearSnackBars();

    final snackBar = SnackBar(
      content: Row(
        children: [
          _getIcon(type),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
            ),
          ),
        ],
      ),
      backgroundColor: _getBackgroundColor(type),
      behavior: SnackBarBehavior.floating,
      duration: duration,
      action: action,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      margin: const EdgeInsets.all(16),
      dismissDirection: DismissDirection.horizontal,
    );

    messenger.showSnackBar(snackBar);
  }

  static Color _getBackgroundColor(SnackBarType type) {
    switch (type) {
      case SnackBarType.success:
        return Colors.green;
      case SnackBarType.error:
        return Colors.red;
      case SnackBarType.warning:
        return Colors.orange;
      case SnackBarType.info:
        return Colors.blue;
      case SnackBarType.noInternet:
        return Colors.grey;
    }
  }

  static Widget _getIcon(SnackBarType type) {
    IconData iconData;
    switch (type) {
      case SnackBarType.success:
        iconData = Icons.check_circle_outline;
        break;
      case SnackBarType.error:
        iconData = Icons.error_outline;
        break;
      case SnackBarType.warning:
        iconData = Icons.warning_amber;
        break;
      case SnackBarType.info:
        iconData = Icons.info_outline;
        break;
      case SnackBarType.noInternet:
        iconData = Icons.wifi_off;
        break;
    }

    return Icon(
      iconData,
      color: Colors.white,
      size: 24,
    );
  }
}

enum SnackBarType {
  success,
  error,
  warning,
  info,
  noInternet,
}
