class Country {
  final String name;
  final String flagUrl;

  Country({required this.name, required this.flagUrl});

  factory Country.fromJson(Map<String, dynamic> json) {
    final nameMap = json['name'] as Map<dynamic, dynamic>?;
    final flagsMap = json['flags'] as Map<dynamic, dynamic>?;
    return Country(
      name: (nameMap?['common'] as String?) ?? 'Unknown',
      flagUrl: (flagsMap?['png'] as String?) ?? '',
    );
  }
}

