import 'dart:convert';

import 'package:material_ui/material_ui.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../controllers/home_controller.dart';
import '../models/stuff.dart';
import '../components/loan_photo.dart';

class StuffDetailPage extends StatefulWidget {
  final HomeController controller;
  final Stuff? editedStuff;
  const StuffDetailPage({
    super.key,
    required this.controller,
    this.editedStuff,
  });
  @override
  State<StuffDetailPage> createState() => _StuffDetailPageState();
}

class _StuffDetailPageState extends State<StuffDetailPage> {
  final form = GlobalKey<FormState>();
  late final TextEditingController description, person, phone;
  late DateTime date;
  String? photo, photoPath, error;
  bool saving = false, dirty = false, picking = false;
  @override
  void initState() {
    super.initState();
    final item = widget.editedStuff;
    description = TextEditingController(text: item?.description);
    person = TextEditingController(text: item?.contactName);
    phone = TextEditingController(text: item?.phone);
    date = item?.loanDate ?? DateUtils.dateOnly(DateTime.now());
    photo = item?.photoBase64;
    photoPath = item?.photoPath;
  }

  @override
  void dispose() {
    description.dispose();
    person.dispose();
    phone.dispose();
    super.dispose();
  }

  Future<void> pickPhoto() async {
    setState(() {
      picking = true;
      error = null;
    });
    try {
      final file = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 80,
        requestFullMetadata: false,
      );
      if (file == null) return;
      final bytes = await file.readAsBytes();
      if (bytes.length > 5 * 1024 * 1024) {
        throw ArgumentError('Escolha uma imagem de até 5 MB.');
      }
      if (!mounted) return;
      setState(() {
        photo = base64Encode(bytes);
        photoPath = null;
        dirty = true;
      });
    } catch (_) {
      if (mounted) {
        setState(
          () => error =
              'Não foi possível abrir a foto. Escolha uma imagem de até 5 MB.',
        );
      }
    } finally {
      if (mounted) setState(() => picking = false);
    }
  }

  Future<void> save() async {
    if (!form.currentState!.validate()) return;
    setState(() {
      saving = true;
      error = null;
    });
    try {
      final item = Stuff(
        id: widget.editedStuff?.id,
        description: description.text,
        contactName: person.text,
        phone: phone.text.trim(),
        loanDate: date,
        photoBase64: photo,
        photoPath: photoPath,
        returned: widget.editedStuff?.returned ?? false,
      );
      final ok = await widget.controller.run(() async {
        await widget.controller.dao.save(item);
      });
      if (!mounted) return;
      if (ok) {
        setState(() {
          dirty = false;
        });
        Navigator.pop(context);
      } else {
        setState(() => error = widget.controller.error);
      }
    } on ArgumentError catch (e) {
      setState(() => error = e.message.toString());
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  Future<void> leave() async {
    if (saving || picking) return;
    if (!dirty) {
      Navigator.pop(context);
      return;
    }
    final discard = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Descartar alterações?'),
        content: const Text('As alterações ainda não foram salvas.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Continuar editando'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Descartar'),
          ),
        ],
      ),
    );
    if (discard == true && mounted) {
      setState(() => dirty = false);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: !dirty && !saving && !picking,
    onPopInvokedWithResult: (didPop, _) {
      if (!didPop) leave();
    },
    child: Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: leave,
          tooltip: 'Voltar',
          icon: const Icon(Icons.arrow_back),
        ),
        title: Text(
          widget.editedStuff == null ? 'Novo empréstimo' : 'Editar empréstimo',
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 620),
          child: Form(
            key: form,
            onChanged: () {
              if (!dirty) setState(() => dirty = true);
            },
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                Text(
                  'O que vai circular?',
                  style: Theme.of(context).textTheme.headlineMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text('Guarde os detalhes para lembrar depois.'),
                const SizedBox(height: 24),
                Row(
                  children: [
                    LoanPhoto(
                      item: Stuff(
                        description: 'objeto',
                        contactName: 'pessoa',
                        loanDate: date,
                        photoBase64: photo,
                        photoPath: photoPath,
                        validate: false,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          OutlinedButton.icon(
                            onPressed: picking || saving ? null : pickPhoto,
                            icon: const Icon(
                              Icons.add_photo_alternate_outlined,
                            ),
                            label: Text(picking ? 'Abrindo…' : 'Escolher foto'),
                          ),
                          const Text('Opcional · até 5 MB'),
                          if (photo != null || photoPath != null)
                            TextButton(
                              onPressed: saving
                                  ? null
                                  : () => setState(() {
                                      photo = null;
                                      photoPath = null;
                                      dirty = true;
                                    }),
                              child: const Text('Remover foto'),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),
                TextFormField(
                  controller: description,
                  enabled: !saving,
                  maxLength: 120,
                  textCapitalization: TextCapitalization.sentences,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Objeto',
                    hintText: 'Ex.: livro O Hobbit',
                    prefixIcon: Icon(Icons.inventory_2_outlined),
                  ),
                  validator: requiredText,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: person,
                  enabled: !saving,
                  maxLength: 100,
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Nome da pessoa',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  validator: requiredText,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: phone,
                  enabled: !saving,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Telefone (opcional)',
                    prefixIcon: Icon(Icons.phone_outlined),
                  ),
                  validator: (value) =>
                      value!.trim().isNotEmpty &&
                          !Stuff.validPhone(value.trim())
                      ? 'Informe um telefone válido'
                      : null,
                ),
                const SizedBox(height: 20),
                OutlinedButton.icon(
                  onPressed: saving
                      ? null
                      : () async {
                          final today = DateUtils.dateOnly(DateTime.now());
                          final selected = await showDatePicker(
                            context: context,
                            initialDate: date.isAfter(today) ? today : date,
                            firstDate: date.isBefore(DateTime(1900))
                                ? date
                                : DateTime(1900),
                            lastDate: today,
                          );
                          if (selected != null && mounted) {
                            setState(() {
                              date = selected;
                              dirty = true;
                            });
                          }
                        },
                  icon: const Icon(Icons.calendar_today_outlined),
                  label: Text(
                    'Emprestado em ${DateFormat('dd/MM/yyyy').format(date)}',
                  ),
                ),
                if (error != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Text(
                      error!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ),
                const SizedBox(height: 28),
                FilledButton.icon(
                  onPressed: saving || picking ? null : save,
                  icon: const Icon(Icons.check),
                  label: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Text(saving ? 'Salvando…' : 'Salvar empréstimo'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
  String? requiredText(String? value) =>
      value == null || value.trim().isEmpty ? 'Campo obrigatório' : null;
}
