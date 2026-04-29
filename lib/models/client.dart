class Client {
  final String? id;
  final String nom;
  final String? email;
  final String? telephone;
  final String? adresse;
  final DateTime? createdAt;

  Client({
    this.id,
    required this.nom,
    this.email,
    this.telephone,
    this.adresse,
    this.createdAt,
  });

  factory Client.fromMap(Map<String, dynamic> map) {
    return Client(
      id: map['id']?.toString(),
      nom: map['nom'] ?? '',
      email: map['email'],
      telephone: map['telephone'],
      adresse: map['adresse'],
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'])
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'nom': nom,
      'email': email,
      'telephone': telephone,
      'adresse': adresse,
      'created_at': createdAt?.toIso8601String() ?? DateTime.now().toIso8601String(),
    };
  }

  Client copyWith({
    String? id,
    String? nom,
    String? email,
    String? telephone,
    String? adresse,
  }) {
    return Client(
      id: id ?? this.id,
      nom: nom ?? this.nom,
      email: email ?? this.email,
      telephone: telephone ?? this.telephone,
      adresse: adresse ?? this.adresse,
      createdAt: createdAt,
    );
  }
}