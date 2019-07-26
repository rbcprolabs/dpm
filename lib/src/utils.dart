/// Like [String.split], but only splits on the first occurrence of the pattern.
///
/// This always returns an array of two elements or fewer.
List<String> split1(String toSplit, String pattern) {
  if (toSplit.isEmpty) {
    return <String>[];
  }

  final index = toSplit.indexOf(pattern);
  if (index == -1) {
    return [toSplit];
  }
  return [
    toSplit.substring(0, index),
    toSplit.substring(index + pattern.length)
  ];
}
