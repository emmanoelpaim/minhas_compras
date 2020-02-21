import 'dart:io';

import 'package:minhas_compras/helpers/compra.dart';
import 'package:flutter/material.dart';
import 'package:minhas_compras/helpers/item.dart';
import 'package:minhas_compras/ui/compra_page.dart';
import 'package:intl/intl.dart';

import 'item_page.dart';

enum OrderOptions { orderaz, orderza }

class ItemListPage extends StatefulWidget {
  final Item item;
  final int idCompra;

  ItemListPage({this.item,this.idCompra});
  
  @override
  _ItemListPageState createState() => _ItemListPageState();
}

class _ItemListPageState extends State<ItemListPage> {
  ItemHelper helper = ItemHelper();

  List<Item> items = List();

  @override
  void initState() {
    super.initState();
    _getAllItemsByIdCompra(widget.idCompra);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: <Widget>[
          PopupMenuButton<OrderOptions>(
            itemBuilder: (context) => <PopupMenuEntry<OrderOptions>>[
              const PopupMenuItem(
                child: Text("Ordenar de A-Z"),
                value: OrderOptions.orderaz,
              ),
              const PopupMenuItem(
                child: Text("Ordenar de Z-A"),
                value: OrderOptions.orderza,
              ),
            ],
            onSelected: _orderList,
          )
        ],
        backgroundColor: Colors.deepOrange,
        title: Text("Meus Itens"),
        centerTitle: true,
      ),
      backgroundColor: Colors.white,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showItemPage();
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.deepOrange,
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(10.0),
        itemCount: items.length,
        itemBuilder: (context, index) {
          return _itemCard(context, index);
        },
      ),
    );
  }

  Widget _itemCard(BuildContext context, int index) {
    return GestureDetector(
      child: Card(
        child: Padding(
          padding: EdgeInsets.all(10.0),
          child: Row(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(left: 10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      items[index].name ?? "",
                      style: TextStyle(
                          fontSize: 22.0, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      onTap: () {
        _showOptions(context, index);
      },
    );
  }

  void _showOptions(BuildContext context, int index) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return BottomSheet(
          onClosing: () {},
          builder: (context) {
            return Container(
              padding: EdgeInsets.all(10.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.all(10.0),
                    child: FlatButton(
                      child: Text(
                        "Editar",
                        style:
                        TextStyle(color: Colors.deepOrange, fontSize: 20.0),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        _showItemPage(item: items[index]);
                      },
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(10.0),
                    child: FlatButton(
                      child: Text(
                        "Excluir",
                        style:
                        TextStyle(color: Colors.deepOrange, fontSize: 20.0),
                      ),
                      onPressed: () {
                        helper.deleteItem(items[index].id);
                        setState(() {
                          items.removeAt(index);
                          Navigator.pop(context);
                        });
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showItemPage({Item item}) async {
    final recItem = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ItemPage(
              item: item,
              idCompra: widget.idCompra,
            )));
    if (recItem != null) {
      if (item != null) {
        await helper.updateItem(recItem);
      } else {
        await helper.saveItem(recItem);
      }
      _getAllItemsByIdCompra(widget.idCompra);
    }
  }

  void _getAllItemsByIdCompra(int idCompra) {
    helper.getAllItemsByIdCompra(idCompra).then((list) {
      setState(() {
        items = list;
      });
    });
  }

  void _orderList(OrderOptions result) {
    switch (result) {
      case OrderOptions.orderaz:
        items.sort((a, b) {
          return a.name.toLowerCase().compareTo(b.name.toLowerCase());
        });
        break;
      case OrderOptions.orderza:
        items.sort((a, b) {
          return b.name.toLowerCase().compareTo(a.name.toLowerCase());
        });
        break;
    }
    setState(() {});
  }
}
