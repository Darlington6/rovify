class Validators {
  static String? requiredField(String? value) {
    if (value == null || value.isEmpty) {
      return 'This field is required';
    }
    return null;
  }

  static String? validateUrl(String? value) {
    if (value == null || value.isEmpty) return 'Please enter a URL';
    final uri = Uri.tryParse(value);
    if (uri == null || !uri.isAbsolute) {
      return 'Please enter a valid URL';
    }
    return null;
  }
}