import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:minhas_compras/helpers/item.dart';

class ItemPage extends StatefulWidget {
  final Item item;
  final int idCompra;

  ItemPage({this.item,this.idCompra});

  @override
  _ItemPageState createState() => _ItemPageState();
}

class _ItemPageState extends State<ItemPage> {

  ItemHelper helperItem = ItemHelper();
  List<Item> items = List();

  Item _editItem;
  bool _itemEdited = false;

  final _nameController = TextEditingController();

  final _nameFocus = FocusNode();

  @override
  void initState() {
    super.initState();

    if (widget.item == null) {
      _editItem = Item();
      _editItem.idCompra = widget.idCompra;

    } else {
      _editItem = Item.fromMap(widget.item.toMap());
      _nameController.text = _editItem.name;
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _requestPop,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.deepOrange,
          title: Text(_editItem.name ?? "Novo Item"),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            if (_editItem.name.isNotEmpty || _editItem.name != null) {
              Navigator.pop(context, _editItem);
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
                    _itemEdited = true;
                    setState(() {
                      _editItem.name = text;
                    });
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<bool> _requestPop() {
    if (_itemEdited) {
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
}
