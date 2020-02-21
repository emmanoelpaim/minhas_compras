import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

final String compraTable = "compraTable";
final String idColumn = "idColumn";
final String nameColumn = "nameColumn";
final String dateColumn = "dataColumn";

class CompraHelper {
  static final CompraHelper _instance = CompraHelper.internal();

  factory CompraHelper() => _instance;

  CompraHelper.internal();

  Database _db;

  Future<Database> get db async {
    if (_db != null) {
      return _db;
    } else {
      _db = await initDb();
      return _db;
    }
  }

  Future<Database> initDb() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, "lista_compra.db");

    return await openDatabase(path, version: 1,
        onCreate: (Database db, int newerVersion) async {
          await db.execute("CREATE TABLE $compraTable("
              "$idColumn INTEGER PRIMARY KEY,"
              " $nameColumn TEXT,"
              " $dateColumn INTEGER)");
        });
  }

  Future<Compra> saveCompra(Compra compra) async {
    Database dbCompra = await db;
    compra.id = await dbCompra.insert(compraTable, compra.toMap());

    return compra;
  }

  Future<Compra> getCompra(int id) async {
    Database dbCompra = await db;
    List<Map> maps = await dbCompra.query(compraTable,
        columns: [nameColumn, dateColumn],
        where: "$idColumn = ?",
        whereArgs: [id]);
    if (maps.length > 0) {
      return Compra.fromMap(maps.first);
    } else {
      return null;
    }
  }

  Future<int> deleteCompra(int id) async {
    Database dbCompra = await db;
    return await dbCompra
        .delete(compraTable, where: "$idColumn = ?", whereArgs: [id]);
  }

  Future<int> updateCompra(Compra compra) async {
    Database dbCompra = await db;
    return await dbCompra.update(compraTable, compra.toMap(),
        where: "$idColumn = ?", whereArgs: [compra.id]);
  }

  Future<List> getAllCompras() async {
    Database dbCompra = await db;
    List listMap = await dbCompra.rawQuery("SELECT * FROM $compraTable");
    List<Compra> listCompra = List();
    for (Map m in listMap) {
      listCompra.add(Compra.fromMap(m));
    }
    print(listCompra);
    return listCompra;
  }

  Future<int> getNumber() async {
    Database dbCompra = await db;
    return Sqflite.firstIntValue(
        await dbCompra.rawQuery("SELECT COUNT(*) FROM $compraTable"));
  }

  Future close() async {
    Database dbCompra = await db;
    dbCompra.close();
  }
}

class Compra {
  int id;
  String name;
  int date;

  Compra();

  Compra.fromMap(Map map) {
    id = map[idColumn];
    name = map[nameColumn];
    date = map[dateColumn];

  }

  Map toMap() {
    Map<String, dynamic> map = {
      nameColumn: name,
      dateColumn: date,
    };
    if (id != null) {
      map[idColumn] = id;
    }
    return map;
  }

  @override
  String toString() {
    return "Compra(id: $id, name: $name, date: $date)";
  }
}