enum DnsRegion { iran, global }

class DnsServer {
  final String id;
  final String name;
  final String primary;
  final String secondary;
  final String? primaryV6;
  final String? secondaryV6;
  final DnsRegion region;
  final String description;
  final bool userAdded;

  const DnsServer({
    required this.id,
    required this.name,
    required this.primary,
    required this.secondary,
    this.primaryV6,
    this.secondaryV6,
    required this.region,
    required this.description,
    this.userAdded = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'primary': primary,
        'secondary': secondary,
        'primaryV6': primaryV6,
        'secondaryV6': secondaryV6,
        'region': region.name,
        'description': description,
        'userAdded': userAdded,
      };

  factory DnsServer.fromJson(Map<String, dynamic> json) {
    return DnsServer(
      id: '${json['id']}',
      name: '${json['name']}',
      primary: '${json['primary']}',
      secondary: '${json['secondary']}',
      primaryV6: json['primaryV6']?.toString(),
      secondaryV6: json['secondaryV6']?.toString(),
      region: json['region'] == 'iran' ? DnsRegion.iran : DnsRegion.global,
      description: '${json['description'] ?? ''}',
      userAdded: json['userAdded'] == true,
    );
  }
}
