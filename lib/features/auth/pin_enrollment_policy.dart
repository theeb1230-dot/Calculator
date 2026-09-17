final class PinEnrollmentPolicy {
  const PinEnrollmentPolicy._();

  static const int minimumLength = 6;
  static const int maximumLength = 12;

  static bool accepts(String candidate) =>
      RegExp(r'^\d{6,12}$').hasMatch(candidate);
}
