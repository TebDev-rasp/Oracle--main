class RiskLevel {
  final String status;

  const RiskLevel({
    this.status = 'Normal conditions',
  });

  static String getStatus(double value) {
    if (value <= 79.9) {
      return 'No Risk of Heat Disorders';
    }
    if (value >= 80.0 && value <= 90.9) {
      return 'Fatigue Possible with Prolonged Exposure and Activity';
    }
    if (value >= 91.0 && value <= 102.9) {
      return 'Heat cramps and heat exhaustion possible';
    }
    if (value >= 103.0 && value <= 124.9) {
      return 'Heat Cramps and Exhaustion Likely, Heat Stroke Possible';
    }
    if (value >= 125.0) {
      return 'Heat Stroke Highly Likely';
    }
    return '';
  }
}