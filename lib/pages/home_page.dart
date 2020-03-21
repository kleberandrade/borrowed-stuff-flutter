import 'package:borrowed_stuff/components/centered_circular_progress.dart';
import 'package:borrowed_stuff/components/centered_message.dart';
import 'package:borrowed_stuff/components/stuff_card.dart';
import 'package:borrowed_stuff/controllers/home_controller.dart';
import 'package:borrowed_stuff/models/stuff.dart';
import 'package:borrowed_stuff/pages/sutff_detail_page.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _controller = HomeController();
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _controller.readAll().then((value) {
      setState(() {
        _loading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Objetos Emprestados'),
      ),
      floatingActionButton: _buildFloatingActionButton(),
      body: _buildStuffList(),
    );
  }

  _buildFloatingActionButton() {
    return FloatingActionButton.extended(
      label: Text('Emprestar'),
      icon: Icon(Icons.add),
      onPressed: _addStuff,
    );
  }

  _buildStuffList() {
    if (_loading) {
      return CenteredCircularProgress();
    }

    if (_controller.stuffList.isEmpty) {
      return CenteredMessage('Vazio', icon: Icons.warning);
    }

    return ListView.builder(
      itemCount: _controller.stuffList.length,
      itemBuilder: (context, index) {
        final stuff = _controller.stuffList[index];
        return StuffCard(
          stuff: stuff,
          onDelete: () {
            _deleteStuff(stuff);
          },
          onEdit: () {
            _editStuff(index, stuff);
          },
        );
      },
    );
  }

  _addStuff() async {
    print('New stuff');
    final stuff = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => StuffDetailPage()),
    );

    if (stuff != null) {
      setState(() {
        _controller.create(stuff);
      });

      Flushbar(
        title: "Novo empréstimo",
        backgroundColor: Colors.black,
        message: "${stuff.description} emprestado para ${stuff.contactName}.",
        duration: Duration(seconds: 2),
      )..show(context);
    }
  }

  _editStuff(index, stuff) async {
    print('Edit stuff');
    final editedStuff = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => StuffDetailPage(editedStuff: stuff)),
    );

    if (editedStuff != null) {
      setState(() {
        _controller.update(index, editedStuff);
      });

      Flushbar(
        title: "Empréstimo atualizado",
        backgroundColor: Colors.black,
        message:
            "${editedStuff.description} emprestado para ${editedStuff.contactName}.",
        duration: Duration(seconds: 2),
      )..show(context);
    }
  }

  _deleteStuff(Stuff stuff) {
    print('Delete stuff');
    setState(() {
      _controller.delete(stuff);
    });

    Flushbar(
      title: "Exclusão",
      backgroundColor: Colors.red,
      message: "${stuff.description} excluido com sucesso.",
      duration: Duration(seconds: 2),
    )..show(context);
  }
}
