class CommandeItem {
  final String? id;
  final String commandeId;
  final String produitId;
  final String produitNom; // denormalized for display
  final int quantite;
  final double prixUnitaire;

  CommandeItem({
    this.id,
    required this.commandeId,
    required this.produitId,
    required this.produitNom,
    required this.quantite,
    required this.prixUnitaire,
  });

  double get sousTotal => quantite * prixUnitaire;

  factory CommandeItem.fromMap(Map<String, dynamic> map) {
    return CommandeItem(
      id: map['id']?.toString(),
      commandeId: map['commande_id']?.toString() ?? '',
      produitId: map['produit_id']?.toString() ?? '',
      produitNom: map['produit_nom'] ?? '',
      quantite: map['quantite'] ?? 1,
      prixUnitaire: (map['prix_unitaire'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'commande_id': commandeId,
      'produit_id': produitId,
      'produit_nom': produitNom,
      'quantite': quantite,
      'prix_unitaire': prixUnitaire,
    };
  }
}