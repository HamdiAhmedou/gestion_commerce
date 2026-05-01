import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:gestion_commerce/config/constants.dart';
import 'package:gestion_commerce/models/produit.dart';
import 'package:gestion_commerce/models/client.dart';
import 'package:gestion_commerce/models/commande.dart';
import 'package:gestion_commerce/models/commande_item.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  static Database? _db;

  Future<Database> get database async {
    _db ??= await _initDB();
    return _db!;
  }

  Future<Database> _initDB() async {
    final path = join(await getDatabasesPath(), AppConstants.dbName);
    return await openDatabase(
      path,
      version: AppConstants.dbVersion,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE ${AppConstants.tableProduits} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nom TEXT NOT NULL,
        prix REAL NOT NULL,
        stock INTEGER NOT NULL DEFAULT 0,
        categorie TEXT,
        image_url TEXT,
        description TEXT,
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE ${AppConstants.tableClients} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nom TEXT NOT NULL,
        email TEXT,
        telephone TEXT,
        adresse TEXT,
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE ${AppConstants.tableCommandes} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        client_id INTEGER NOT NULL,
        client_nom TEXT NOT NULL,
        total REAL NOT NULL DEFAULT 0,
        statut TEXT NOT NULL DEFAULT 'en_attente',
        created_at TEXT NOT NULL,
        FOREIGN KEY (client_id) REFERENCES ${AppConstants.tableClients}(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE ${AppConstants.tableCommandeItems} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        commande_id INTEGER NOT NULL,
        produit_id INTEGER NOT NULL,
        produit_nom TEXT NOT NULL,
        quantite INTEGER NOT NULL,
        prix_unitaire REAL NOT NULL,
        FOREIGN KEY (commande_id) REFERENCES ${AppConstants.tableCommandes}(id),
        FOREIGN KEY (produit_id)  REFERENCES ${AppConstants.tableProduits}(id)
      )
    ''');
  }

  // ─────────────────────────── PRODUITS ───────────────────────────

  Future<List<Produit>> getProduits() async {
    final db = await database;
    final maps = await db.query(
      AppConstants.tableProduits,
      orderBy: 'created_at DESC',
    );
    return maps.map(Produit.fromMap).toList();
  }

  Future<List<Produit>> searchProduits(String query) async {
    final db = await database;
    final maps = await db.query(
      AppConstants.tableProduits,
      where: 'nom LIKE ? OR categorie LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
      orderBy: 'created_at DESC',
    );
    return maps.map(Produit.fromMap).toList();
  }

  Future<int> insertProduit(Produit produit) async {
    final db = await database;
    return await db.insert(
      AppConstants.tableProduits,
      produit.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> updateProduit(Produit produit) async {
    final db = await database;
    return await db.update(
      AppConstants.tableProduits,
      produit.toMap(),
      where: 'id = ?',
      whereArgs: [produit.id],
    );
  }

  Future<int> deleteProduit(String id) async {
    final db = await database;
    return await db.delete(
      AppConstants.tableProduits,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> insertProduits(List<Produit> produits) async {
    final db = await database;
    final batch = db.batch();
    for (final p in produits) {
      batch.insert(
        AppConstants.tableProduits,
        p.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  // ─────────────────────────── CLIENTS ────────────────────────────

  Future<List<Client>> getClients() async {
    final db = await database;
    final maps = await db.query(
      AppConstants.tableClients,
      orderBy: 'created_at DESC',
    );
    return maps.map(Client.fromMap).toList();
  }

  Future<List<Client>> searchClients(String query) async {
    final db = await database;
    final maps = await db.query(
      AppConstants.tableClients,
      where: 'nom LIKE ? OR email LIKE ? OR telephone LIKE ?',
      whereArgs: ['%$query%', '%$query%', '%$query%'],
    );
    return maps.map(Client.fromMap).toList();
  }

  Future<int> insertClient(Client client) async {
    final db = await database;
    return await db.insert(
      AppConstants.tableClients,
      client.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> updateClient(Client client) async {
    final db = await database;
    return await db.update(
      AppConstants.tableClients,
      client.toMap(),
      where: 'id = ?',
      whereArgs: [client.id],
    );
  }

  Future<int> deleteClient(String id) async {
    final db = await database;
    return await db.delete(
      AppConstants.tableClients,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ─────────────────────────── COMMANDES ──────────────────────────

  Future<List<Commande>> getCommandes() async {
    final db = await database;
    final maps = await db.query(
      AppConstants.tableCommandes,
      orderBy: 'created_at DESC',
    );
    final commandes = <Commande>[];
    for (final map in maps) {
      final items = await getCommandeItems(map['id'].toString());
      commandes.add(Commande.fromMap(map).copyWith(items: items));
    }
    return commandes;
  }

  Future<int> insertCommande(Commande commande) async {
    final db = await database;
    final id = await db.insert(
      AppConstants.tableCommandes,
      commande.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    for (final item in commande.items) {
      await db.insert(
        AppConstants.tableCommandeItems,
       item.copyWith(commandeId: id.toString()).toMap(),
      );
    }
    return id;
  }

  Future<int> updateCommandeStatut(String id, String statut) async {
    final db = await database;
    return await db.update(
      AppConstants.tableCommandes,
      {'statut': statut},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteCommande(String id) async {
    final db = await database;
    await db.delete(
      AppConstants.tableCommandeItems,
      where: 'commande_id = ?',
      whereArgs: [id],
    );
    return await db.delete(
      AppConstants.tableCommandes,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ─────────────────────────── COMMANDE ITEMS ─────────────────────

  Future<List<CommandeItem>> getCommandeItems(String commandeId) async {
    final db = await database;
    final maps = await db.query(
      AppConstants.tableCommandeItems,
      where: 'commande_id = ?',
      whereArgs: [commandeId],
    );
    return maps.map(CommandeItem.fromMap).toList();
  }

  // ─────────────────────────── DASHBOARD ──────────────────────────

  Future<Map<String, dynamic>> getDashboardStats() async {
    final db = await database;
    final produits  = await db.rawQuery('SELECT COUNT(*) as count FROM ${AppConstants.tableProduits}');
    final clients   = await db.rawQuery('SELECT COUNT(*) as count FROM ${AppConstants.tableClients}');
    final commandes = await db.rawQuery('SELECT COUNT(*) as count FROM ${AppConstants.tableCommandes}');
    final ca        = await db.rawQuery('SELECT SUM(total) as total FROM ${AppConstants.tableCommandes}');
    return {
      'totalProduits':  produits.first['count'] ?? 0,
      'totalClients':   clients.first['count'] ?? 0,
      'totalCommandes': commandes.first['count'] ?? 0,
      'chiffreAffaires': ca.first['total'] ?? 0.0,
    };
  }
}