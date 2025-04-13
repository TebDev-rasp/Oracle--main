class ComfortLevel {
  final String status;

  const ComfortLevel({
    this.status = 'Comfortable',
  });

  static String getStatus(double value) {
    if (value <= 79.9) {
      return 'Comfortable';
    }
    if (value >= 80.0 && value <= 90.9) {
      return 'Caution';
    }
    if (value >= 91.0 && value <= 102.9) {
      return 'Extreme Caution';
    }
    if (value >= 103.0 && value <= 124.9) {
      return 'Danger';
    }
    if (value >= 125.0) {
      return 'Extreme Danger';
    }
    return '';
  }
}