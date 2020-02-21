import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

final String itemTable = "itemTable";
final String idColumn = "idColumn";
final String nameColumn = "nameColumn";
final String idCompraColumn = "idCompraColumn";

class ItemHelper {
  static final ItemHelper _instance = ItemHelper.internal();

  factory ItemHelper() => _instance;

  ItemHelper.internal();

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
    final path = join(databasesPath, "lista_item.db");

    return await openDatabase(path, version: 1,
        onCreate: (Database db, int newerVersion) async {
          await db.execute("CREATE TABLE $itemTable("
              "$idColumn INTEGER PRIMARY KEY,"
              " $nameColumn TEXT,"
              " $idCompraColumn INTEGER)");
        });
  }

  Future<Item> saveItem(Item item) async {
    Database dbItem = await db;
    item.id = await dbItem.insert(itemTable, item.toMap());

    return item;
  }

  Future<Item> getItem(int id) async {
    Database dbItem = await db;
    List<Map> maps = await dbItem.query(itemTable,
        columns: [nameColumn, idCompraColumn],
        where: "$idColumn = ?",
        whereArgs: [id]);
    if (maps.length > 0) {
      return Item.fromMap(maps.first);
    } else {
      return null;
    }
  }

  Future<int> deleteItem(int id) async {
    Database dbItem = await db;
    return await dbItem
        .delete(itemTable, where: "$idColumn = ?", whereArgs: [id]);
  }

  Future<int> updateItem(Item item) async {
    Database dbItem = await db;
    return await dbItem.update(itemTable, item.toMap(),
        where: "$idColumn = ?", whereArgs: [item.id]);
  }

  Future<List> getAllItems() async {
    Database dbItem = await db;
    List listMap = await dbItem.rawQuery("SELECT * FROM $itemTable");
    List<Item> listItem = List();
    for (Map m in listMap) {
      listItem.add(Item.fromMap(m));
    }
    return listItem;
  }

  Future<List> getAllItemsByIdCompra(int idCompra) async {
    Database dbItem = await db;
    List listMap = await dbItem.rawQuery("SELECT * FROM $itemTable WHERE $idCompraColumn = '$idCompra'");
//    List listMap = await dbItem.rawQuery("SELECT * FROM $itemTable");
    List<Item> listItem = List();
    for (Map m in listMap) {
      listItem.add(Item.fromMap(m));
    }
    return listItem;
  }

  Future<int> getNumber() async {
    Database dbItem = await db;
    return Sqflite.firstIntValue(
        await dbItem.rawQuery("SELECT COUNT(*) FROM $itemTable"));
  }

  Future close() async {
    Database dbItem = await db;
    dbItem.close();
  }
}

class Item {
  int id;
  String name;
  int idCompra;

  Item();

  Item.fromMap(Map map) {
    id = map[idColumn];
    name = map[nameColumn];
    idCompra = map[idCompraColumn];
  }

  Map toMap() {
    Map<String, dynamic> map = {
      nameColumn: name,
      idCompraColumn: idCompra,
    };
    if (id != null) {
      map[idColumn] = id;
    }
    return map;
  }

  @override
  String toString() {
    return "Item(id: $id, name: $name, id_compra: $idCompra)";
  }
}