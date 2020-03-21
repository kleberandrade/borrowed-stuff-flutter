import 'package:borrowed_stuff/helpers/validator.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:borrowed_stuff/components/back_dialog.dart';
import 'package:borrowed_stuff/components/photo_container.dart';
import 'package:borrowed_stuff/models/stuff.dart';

class StuffDetailPage extends StatefulWidget {
  final Stuff editedStuff;

  StuffDetailPage({
    Key key,
    this.editedStuff,
  }) : super(key: key);

  @override
  _StuffDetailPageState createState() => _StuffDetailPageState();
}

class _StuffDetailPageState extends State<StuffDetailPage> {
  final _formKey = GlobalKey<FormState>();
  final _dateController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _nameController = TextEditingController();
  final _dateFormat = DateFormat('dd/MM/yyyy');

  var _currentStuff = Stuff();

  @override
  void initState() {
    super.initState();
    if (widget.editedStuff != null) {
      _currentStuff = Stuff.fromMap(widget.editedStuff.toMap());
      _dateController.text = _dateFormat.format(_currentStuff.loanDate);
      _descriptionController.text = _currentStuff.description;
      _nameController.text = _currentStuff.contactName;
    }
  }

  @override
  void dispose() {
    _dateController.clear();
    _descriptionController.clear();
    _nameController.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onBackPressed,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.editedStuff == null
              ? "Novo Empréstimo"
              : "Editar Empréstimo"),
        ),
        body: _buildForm(),
      ),
    );
  }

  Future<bool> _onBackPressed() {
    return showDialog(
          context: context,
          builder: (context) {
            return BackDialog(
              onConfirm: () => Navigator.of(context).pop(false),
              onCancel: () => Navigator.of(context).pop(true),
            );
          },
        ) ??
        false;
  }

  _buildForm() {
    return Form(
      key: _formKey,
      child: ListView(
        padding: EdgeInsets.all(16.0),
        children: <Widget>[
          PhotoContainer(
            initialPhotoPath: _currentStuff.photoPath,
            onChanged: (path) {
              _currentStuff.photoPath = path;
            },
          ),
          _buildDateInputField(),
          _buildDescriptionInputField(),
          _buildNameInputField(),
          _buildConfirmButton(),
        ],
      ),
    );
  }

  _buildDateInputField() {
    return DateTimeField(
      decoration: InputDecoration(
        icon: Icon(Icons.date_range),
        labelText: 'Data do empréstimo',
      ),
      format: _dateFormat,
      initialValue: _currentStuff.loanDate,
      onShowPicker: (context, currentValue) {
        return showDatePicker(
          context: context,
          firstDate: DateTime(1900),
          initialDate: currentValue ?? DateTime.now(),
          lastDate: DateTime(2100),
        );
      },
      controller: _dateController,
      onChanged: (date) {
        _currentStuff.loanDate = date;
      },
      validator: (date) {
        return Validator.isEmptyDate(date);
      },
    );
  }

  _buildDescriptionInputField({Function(String) onSaved}) {
    return TextFormField(
      decoration: InputDecoration(
        icon: Icon(Icons.description),
        labelText: 'Descrição do objeto emprestado',
      ),
      onSaved: (value) {
        setState(() {
          _currentStuff.description = value;
        });
      },
      controller: _descriptionController,
      validator: (value) {
        return Validator.isEmptyText(value);
      },
    );
  }

  _buildNameInputField({Function(String) onSaved}) {
    return TextFormField(
      decoration: InputDecoration(
        icon: Icon(Icons.person),
        labelText: 'Nome do contato',
      ),
      onSaved: (value) {
        setState(() {
          _currentStuff.contactName = value;
        });
      },
      controller: _nameController,
      validator: (value) {
        return Validator.isEmptyText(value);
      },
    );
  }

  _buildConfirmButton() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 32.0),
      child: InkWell(
        child: Container(
          color: Theme.of(context).accentColor,
          height: 50.0,
          child: Center(
            child: Text(
              widget.editedStuff == null ? 'REGISTRAR' : 'ATUALIZAR',
              style: TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
        onTap: () {
          final form = _formKey.currentState;
          if (form.validate()) {
            form.save();
            Navigator.of(context).pop(_currentStuff);
          }
        },
      ),
    );
  }
}