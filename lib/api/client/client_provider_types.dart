part of '../client.dart';

class ProviderInfo {
  final List<ProviderEntry> all;
  final Map<String, String> defaults;
  final List<String> connected;
  const ProviderInfo({
    required this.all,
    required this.defaults,
    required this.connected,
  });

  factory ProviderInfo.fromJson(Map<String, dynamic> j) {
    final def = <String, String>{};
    asMap(j['default']).forEach((k, v) => def[k] = v.toString());
    return ProviderInfo(
      all: asList(j['all'])
          .map((e) => ProviderEntry.fromJson(asMap(e)))
          .toList(),
      defaults: def,
      connected: asList(j['connected']).map((e) => e.toString()).toList(),
    );
  }

  bool get isConnected => connected.isNotEmpty;

  /// Every model grouped by provider, connected providers first.
  List<ProviderEntry> get ordered {
    final set = connected.toSet();
    final list = [...all]
      ..sort((a, b) {
        final ac = set.contains(a.id) ? 0 : 1;
        final bc = set.contains(b.id) ? 0 : 1;
        if (ac != bc) return ac - bc;
        return a.id.compareTo(b.id);
      });
    return list.where((p) => p.models.isNotEmpty).toList();
  }
}

class ProviderEntry {
  final String id, name, source;
  final List<String> env;
  final List<ModelInfo> models;
  ProviderEntry({
    required this.id,
    required this.name,
    required this.source,
    required this.env,
    required this.models,
  });

  factory ProviderEntry.fromJson(Map<String, dynamic> j) {
    final out = <ModelInfo>[];
    asMap(j['models']).forEach((mid, mv) {
      final m = asMap(mv);
      final merged = {...m, 'providerID': asStr(j['id'])};
      out.add(ModelInfo.fromJson(asStr(j['id']), mid, merged));
    });
    return ProviderEntry(
      id: asStr(j['id']),
      name: asStr(j['name'], asStr(j['id'])),
      source: asStr(j['source']),
      env: asList(j['env']).map((e) => e.toString()).toList(),
      models: out,
    );
  }

  bool get needsKey => env.isNotEmpty && models.isNotEmpty;
}

class AuthMethod {
  final String provider, type, label;
  final String? link;
  const AuthMethod({
    required this.provider,
    required this.type,
    required this.label,
    this.link,
  });

  factory AuthMethod.from(String provider, Map<String, dynamic> j) =>
      AuthMethod(
        provider: provider,
        type: asStr(j['type']),
        label: asStr(j['label'], asStr(j['type'])),
        link: j['link']?.toString(),
      );
}
