String removeSpecialCharacters(String input) {
  RegExp specialCharacters =
      RegExp(r'[^\w\s\p{L}.,;:?"!@#$%^&*()_+=\[\]{}|<>/]');
  return input.replaceAll(specialCharacters, '');
}
