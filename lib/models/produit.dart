class Produit {
  final String? id;
  final String nom;
  final double prix;
  final int stock;
  final String? categorie;
  final String? imageUrl;
  final String? description;
  final DateTime? createdAt;

  Produit({
    this.id,
    required this.nom,
    required this.prix,
    required this.stock,
    this.categorie,
    this.imageUrl,
    this.description,
    this.createdAt,
  });

  // SQLite → Produit
  factory Produit.fromMap(Map<String, dynamic> map) {
    return Produit(
      id: map['id']?.toString(),
      nom: map['nom'] ?? '',
      prix: (map['prix'] as num).toDouble(),
      stock: map['stock'] ?? 0,
      categorie: map['categorie'],
      imageUrl: map['image_url'],
      description: map['description'],
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'])
          : null,
    );
  }

  // Produit → SQLite
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'nom': nom,
      'prix': prix,
      'stock': stock,
      'categorie': categorie,
      'image_url': imageUrl,
      'description': description,
      'created_at': createdAt?.toIso8601String() ?? DateTime.now().toIso8601String(),
    };
  }

  // DummyJSON API → Produit
  factory Produit.fromJson(Map<String, dynamic> json) {
    return Produit(
      nom: json['title'] ?? '',
      prix: (json['price'] as num).toDouble(),
      stock: json['stock'] ?? 0,
      categorie: json['category'],
      imageUrl: (json['images'] as List?)?.first?.toString(),
      description: json['description'],
      createdAt: DateTime.now(),
    );
  }

  Produit copyWith({
    String? id,
    String? nom,
    double? prix,
    int? stock,
    String? categorie,
    String? imageUrl,
    String? description,
  }) {
    return Produit(
      id: id ?? this.id,
      nom: nom ?? this.nom,
      prix: prix ?? this.prix,
      stock: stock ?? this.stock,
      categorie: categorie ?? this.categorie,
      imageUrl: imageUrl ?? this.imageUrl,
      description: description ?? this.description,
      createdAt: createdAt,
    );
  }
}