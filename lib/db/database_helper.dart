import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/usuario.dart';
import '../models/produto.dart';
import '../models/compra.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'calculista.db');

    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE usuario (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nome_completo TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        senha TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE produto (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nome_do_produto TEXT NOT NULL,
        marca_do_produto TEXT,
        preco_do_produto REAL NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE compra (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        usuario_id INTEGER NOT NULL,
        produto_id INTEGER NOT NULL,
        nome_do_supermercado TEXT NOT NULL,
        quantidade INTEGER NOT NULL,
        preco_unitario REAL NOT NULL,
        preco_total_produto REAL NOT NULL,
        preco_total_compra REAL NOT NULL,
        data TEXT NOT NULL,
        FOREIGN KEY (usuario_id) REFERENCES usuario(id),
        FOREIGN KEY (produto_id) REFERENCES produto(id)
      )
    ''');
  }

  // ───── USUÁRIO ─────────────────────
  Future<int> insertUsuario(Usuario usuario) async {
    final db = await database;
    return await db.insert('usuario', usuario.toMap());
  }

  Future<Usuario?> loginUsuario(String email, String senhaCriptografada) async {
    final db = await database;
    final result = await db.query(
      'usuario',
      where: 'email = ? AND senha = ?',
      whereArgs: [email, senhaCriptografada],
    );
    if (result.isNotEmpty) {
      return Usuario.fromMap(result.first);
    }
    return null;
  }

  // ───── LOGIN POR ID ─────────────────────
  Future<Usuario?> loginUsuarioPorId(int id) async {
    final db = await database;
    final result = await db.query('usuario', where: 'id = ?', whereArgs: [id]);
    if (result.isNotEmpty) {
      return Usuario.fromMap(result.first);
    }
    return null;
  }

  // ───── PRODUTO ─────────────────────
  Future<int> insertProduto(Produto produto) async {
    final db = await database;
    return await db.insert('produto', produto.toMap());
  }

  Future<List<Produto>> getTodosProdutos() async {
    final db = await database;
    final result = await db.query('produto');
    return result.map((map) => Produto.fromMap(map)).toList();
  }

  // ───── COMPRA ─────────────────────
  Future<int> insertCompra(Compra compra) async {
    final db = await database;
    return await db.insert('compra', compra.toMap());
  }

  Future<List<Compra>> getComprasPorUsuario(int usuarioId) async {
    final db = await database;
    final result = await db.query(
      'compra',
      where: 'usuario_id = ?',
      whereArgs: [usuarioId],
    );
    return result.map((map) => Compra.fromMap(map)).toList();
  }

  Future<int> updateCompra(Compra compra) async {
    final db = await database;
    return await db.update(
      'compra',
      compra.toMap(),
      where: 'id = ?',
      whereArgs: [compra.id],
    );
  }

  Future<int> deleteCompra(int id) async {
    final db = await database;
    return await db.delete('compra', where: 'id = ?', whereArgs: [id]);
  }
}
