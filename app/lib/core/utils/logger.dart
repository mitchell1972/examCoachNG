import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';

enum LogLevel { verbose, debug, info, warning, error }

class Logger {
  static const String _tag = 'ExamCoach';
  
  static void verbose(String message, {Object? error, StackTrace? stackTrace}) {
    _log(LogLevel.verbose, message, error: error, stackTrace: stackTrace);
  }
  
  static void debug(String message, {Object? error, StackTrace? stackTrace}) {
    _log(LogLevel.debug, message, error: error, stackTrace: stackTrace);
  }
  
  static void info(String message, {Object? error, StackTrace? stackTrace}) {
    _log(LogLevel.info, message, error: error, stackTrace: stackTrace);
  }
  
  static void warning(String message, {Object? error, StackTrace? stackTrace}) {
    _log(LogLevel.warning, message, error: error, stackTrace: stackTrace);
  }
  
  static void error(String message, {Object? error, StackTrace? stackTrace}) {
    _log(LogLevel.error, message, error: error, stackTrace: stackTrace);
  }
  
  static void _log(
    LogLevel level,
    String message, {
    Object? error,
    StackTrace? stackTrace,
  }) {
    if (!kDebugMode && level == LogLevel.verbose || level == LogLevel.debug) {
      return;
    }
    
    final levelString = level.name.toUpperCase();
    final timestamp = DateTime.now().toIso8601String();
    final logMessage = '[$_tag] [$levelString] [$timestamp] $message';
    
    if (error != null) {
      developer.log(
        logMessage,
        error: error,
        stackTrace: stackTrace,
        level: _getLevelValue(level),
      );
    } else {
      developer.log(
        logMessage,
        level: _getLevelValue(level),
      );
    }
    
    // In debug mode, also print to console for easier debugging
    if (kDebugMode) {
      print(logMessage);
      if (error != null) {
        print('Error: $error');
      }
      if (stackTrace != null) {
        print('StackTrace: $stackTrace');
      }
    }
  }
  
  static int _getLevelValue(LogLevel level) {
    switch (level) {
      case LogLevel.verbose:
        return 500;
      case LogLevel.debug:
        return 700;
      case LogLevel.info:
        return 800;
      case LogLevel.warning:
        return 900;
      case LogLevel.error:
        return 1000;
    }
  }
}
