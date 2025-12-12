import 'dart:async';
import 'package:flutter/material.dart';

class SleepTimerHelper {
  static Timer? _sleepTimer;
  static int? _remainingSeconds;

  /// Bắt đầu sleep timer
  static void startSleepTimer(int minutes, VoidCallback onTimerEnd) {
    // Hủy timer cũ nếu có
    _sleepTimer?.cancel();

    _remainingSeconds = minutes * 60;

    _sleepTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _remainingSeconds = _remainingSeconds! - 1;

      if (_remainingSeconds! <= 0) {
        timer.cancel();
        onTimerEnd();
      }
    });
  }

  /// Lấy thời gian còn lại (giây)
  static int? getRemainingSeconds() => _remainingSeconds;

  /// Định dạng thời gian hiển thị
  static String formatRemainingTime() {
    if (_remainingSeconds == null) return '00:00';

    int minutes = _remainingSeconds! ~/ 60;
    int seconds = _remainingSeconds! % 60;

    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  /// Hủy timer
  static void cancelSleepTimer() {
    _sleepTimer?.cancel();
    _remainingSeconds = null;
  }

  /// Kiểm tra timer có hoạt động không
  static bool isTimerActive() => _sleepTimer != null && _sleepTimer!.isActive;
}
