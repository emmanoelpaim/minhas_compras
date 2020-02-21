import 'package:flutter/cupertino.dart';
import 'package:minhas_compras/helpers/compra.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:minhas_compras/helpers/item.dart';
import 'package:minhas_compras/ui/item_list_page.dart';

import 'item_page.dart';

class CompraPage extends StatefulWidget {
  final Compra compra;

  CompraPage({this.compra});

  @override
  _CompraPageState createState() => _CompraPageState();
}

class _CompraPageState extends State<CompraPage> {
  ItemHelper helperItem = ItemHelper();
  List<Item> items = List();

  Compra _editCompra;
  bool _compraEdited = false;

  DateTime selectedDate = DateTime.now();
  DateTime _dateTime;

  Future<Null> _selectDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime(2015, 8),
        lastDate: DateTime(2101));
    if (picked != null && picked != selectedDate)
      setState(() {
        selectedDate = picked;
      });
  }

  final _nameController = TextEditingController();

  final _nameFocus = FocusNode();

  @override
  void initState() {
    super.initState();

    if (widget.compra == null) {
      _editCompra = Compra();
    } else {
      _editCompra = Compra.fromMap(widget.compra.toMap());
      _nameController.text = _editCompra.name;
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _requestPop,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.deepOrange,
          title: Text(_editCompra.name ?? "Nova Compra"),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            if (_editCompra.name.isNotEmpty || _editCompra.name != null) {
              Navigator.pop(context, _editCompra);
            } else {
              FocusScope.of(context).requestFocus(_nameFocus);
            }
          },
          child: Icon(Icons.save),
          backgroundColor: Colors.deepOrange,
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: <Widget>[
                TextField(
                  controller: _nameController,
                  focusNode: _nameFocus,
                  decoration: InputDecoration(labelText: "Name"),
                  onChanged: (text) {
                    _compraEdited = true;
                    setState(() {
                      _editCompra.name = text;
                    });
                  },
                ),
                Container(
                  child: Padding(
                    padding: EdgeInsets.all(10.0),
                    child: Column(
                      children: <Widget>[
                        Row(children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              children: <Widget>[
                                Text(_editCompra.date == null
                                    ? 'Escolha uma data'
                                    : DateFormat('dd/MM/yyyy')
                                    .format(
                                    DateTime.fromMillisecondsSinceEpoch(
                                        _editCompra.date))
                                    .toString()),
                                RaisedButton(
                                  child: Icon(Icons.calendar_today),
                                  onPressed: () {
                                    showDatePicker(
                                            context: context,
                                            initialDate: _editCompra.date !=
                                                    null
                                                ? DateTime
                                                    .fromMillisecondsSinceEpoch(
                                                        _editCompra.date)
                                                : DateTime.now(),
                                            firstDate: DateTime(2001),
                                            lastDate: DateTime(2021))
                                        .then((date) {
                                      setState(() {
                                        _compraEdited = true;
                                        _editCompra.date =
                                            date.millisecondsSinceEpoch;
                                      });
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Padding(
                              padding: const EdgeInsets.only(top:10.0),
                              child: RaisedButton(
                                  child: Icon(Icons.add_shopping_cart),
                                  onPressed: () {
                                    if(_editCompra.id!=null){
                                      _showItemListPage();
                                    }else{
                                      showDialog(
                                          context: context,
                                          builder: (context) {
                                            return AlertDialog(
                                              title: Text("Alerta"),
                                              content: Text("Você precisa salvar um compra antes"),
                                              actions: <Widget>[
                                                FlatButton(
                                                  child: Text("Ok"),
                                                  onPressed: () {
                                                    Navigator.pop(context);
                                                  },
                                                ),
                                              ],
                                            );
                                          });
                                    }

                                  }),
                            ),
                          ),
                        ]),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<bool> _requestPop() {
    if (_compraEdited) {
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text("Descartar Alterações?"),
              content: Text("Se sair as alterações serão perdidas."),
              actions: <Widget>[
                FlatButton(
                  child: Text("Cancelar"),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                FlatButton(
                  child: Text("Sim"),
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                ),
              ],
            );
          });
      return Future.value(false);
    } else {
      return Future.value(true);
    }
  }

  void _getAllItemsByIdCompra(int idCompra) {
    helperItem.getAllItemsByIdCompra(idCompra).then((list) {
      setState(() {
        items = list;
      });
    });
  }

  void _showItemListPage({Item item}) async {
    final recItem = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ItemListPage(
                  item: item,
                  idCompra: _editCompra.id,
                )));
    if (recItem != null) {
      if (item != null) {
        await helperItem.updateItem(recItem);
      } else {
        await helperItem.saveItem(recItem);
      }
      _getAllItemsByIdCompra(_editCompra.id);
    }
  }
}
