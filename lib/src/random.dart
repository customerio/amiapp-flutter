import 'dart:math';

/// Random class to help generate random values conveniently
class RandomValues {
  final List<String> _emails = [
    'roll@flutter.io',
    'amiapp@flutter.io',
  ];
  final List<String> _fullNames = [
    'Flutter ready to roll',
    'Ami app on wheels',
  ];
  final List<String> _eventNames = [
    'Button Click',
    'Random Event',
    'Shopping',
    'Charity',
  ];
  final Map<String, dynamic> _attributes = {
    'type': 'random',
    'clicked': true,
    'name': 'Super Ami',
    'country': 'USA',
    'city': 'New York',
    'product': 'Clothing',
    'price': 'USD 99',
    'brand': 'Trends',
    'detail': {'color': 'Orange', 'size': 30, 'length': 34, 'isNew': true},
    'org': 'Percent Pledge',
    'amount': 'USD 500',
    'to': 'Urban Trees',
    'verified': false,
  };

  String getEmail({int? seed}) => _emails.random(seed: seed);

  String getFullName({int? seed}) => _fullNames.random(seed: seed);

  String getEventName({int? seed}) => _eventNames.random(seed: seed);

  Map<String, dynamic> getEventAttributes({int? seed}) {
    final count = _attributes.length.randomInRange(min: 0);
    final Map<String, dynamic> attributes = {};
    final keys = _attributes.keys.toList();
    for (int i = 0; i < count; i++) {
      final key = keys.random();
      attributes[key] = _attributes[key];
    }
    return attributes;
  }
}

extension _RandomRangeExtensions on int {
  int randomInRange({int min = 0, int? seed}) {
    final Random random = Random(seed);
    return min + random.nextInt(this - 1 - min);
  }
}

extension _RandomListExtensions on List<dynamic> {
  dynamic random({int? seed}) {
    return get(length.randomInRange(seed: seed));
  }

  dynamic get(int index) => this[index % length];
}
