import 'dart:io';

import 'package:minhas_compras/helpers/compra.dart';
import 'package:flutter/material.dart';
import 'package:minhas_compras/ui/compra_page.dart';
import 'package:intl/intl.dart';

enum OrderOptions { orderaz, orderza }

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  CompraHelper helper = CompraHelper();

  List<Compra> compras = List();

  @override
  void initState() {
    super.initState();
    _getAllCompras();
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
        title: Text("Minhas Compras"),
        centerTitle: true,
      ),
      backgroundColor: Colors.white,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showCompraPage();
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.deepOrange,
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(10.0),
        itemCount: compras.length,
        itemBuilder: (context, index) {
          return _compraCard(context, index);
        },
      ),
    );
  }

  Widget _compraCard(BuildContext context, int index) {
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
                      compras[index].name ?? "",
                      style: TextStyle(
                          fontSize: 22.0, fontWeight: FontWeight.bold),
                    ),
                    Text(
                        compras[index].date != null ? DateFormat('dd/MM/yyyy')
                            .format(DateTime.fromMillisecondsSinceEpoch(
                            compras[index].date))
                            .toString():""
                       ,
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
                        _showCompraPage(compra: compras[index]);
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
                        helper.deleteCompra(compras[index].id);
                        setState(() {
                          compras.removeAt(index);
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

  void _showCompraPage({Compra compra}) async {
    final recCompra = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => CompraPage(
                  compra: compra,
                )));
    if (recCompra != null) {
      if (compra != null) {
        await helper.updateCompra(recCompra);
      } else {
        await helper.saveCompra(recCompra);
      }
      _getAllCompras();
    }
  }

  void _getAllCompras() {
    helper.getAllCompras().then((list) {
      setState(() {
        compras = list;
      });
    });
  }

  void _orderList(OrderOptions result) {
    switch (result) {
      case OrderOptions.orderaz:
        compras.sort((a, b) {
          return a.name.toLowerCase().compareTo(b.name.toLowerCase());
        });
        break;
      case OrderOptions.orderza:
        compras.sort((a, b) {
          return b.name.toLowerCase().compareTo(a.name.toLowerCase());
        });
        break;
    }
    setState(() {});
  }
}
