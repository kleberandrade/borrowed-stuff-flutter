import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../controllers/home_controller.dart';
import '../models/stuff.dart';
import '../components/loan_photo.dart';
import 'stuff_detail_page.dart';

class HomePage extends StatefulWidget {
  final HomeController controller;
  const HomePage({super.key, required this.controller});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String query = '';
  bool returned = false;
  HomeController get controller => widget.controller;
  @override
  void initState() {
    super.initState();
    controller.load();
  }

  Future<void> edit([Stuff? item]) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) =>
            StuffDetailPage(controller: controller, editedStuff: item),
      ),
    );
  }

  Future<void> remove(Stuff item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir empréstimo?'),
        content: Text(
          'O registro de ${item.description} será excluído permanentemente.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await controller.run(() => controller.dao.delete(item));
    }
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: controller,
    builder: (context, _) {
      final visible = controller.items
          .where(
            (i) =>
                i.returned == returned &&
                '${i.description} ${i.contactName}'.toLowerCase().contains(
                  query.toLowerCase(),
                ),
          )
          .toList();
      final active = controller.items.where((i) => !i.returned).length;
      return Scaffold(
        appBar: AppBar(
          title: const Text(
            'emprestei.',
            style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: -1),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 20),
              child: Chip(
                avatar: const Icon(Icons.lock_outline, size: 16),
                label: const Text('Só neste dispositivo'),
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: controller.busy ? null : () => edit(),
          icon: const Icon(Icons.add),
          label: const Text('Novo empréstimo'),
        ),
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1120),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 104),
              children: [
                const Text(
                  'SEU DIÁRIO DE EMPRÉSTIMOS',
                  style: TextStyle(
                    fontSize: 12,
                    letterSpacing: 2,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Emprestar é compartilhar.\nLembrar é cuidar.',
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    letterSpacing: -1,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Objetos, pessoas e histórias. Tudo organizado em um só lugar.',
                  style: TextStyle(fontSize: 16, color: Color(0xff52645c)),
                ),
                const SizedBox(height: 28),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _Metric(
                        value: '$active',
                        label: 'em circulação',
                        icon: Icons.swap_horiz,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _Metric(
                        value: '${controller.items.length - active}',
                        label: 'devolvidos',
                        icon: Icons.check_circle_outline,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _Metric(
                        value:
                            '${controller.items.where((i) => !i.returned).map((i) => i.contactName).toSet().length}',
                        label: 'pessoas',
                        icon: Icons.people_outline,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),
                TextField(
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.search),
                    labelText: 'Buscar objeto ou pessoa',
                  ),
                  onChanged: (value) => setState(() => query = value),
                ),
                const SizedBox(height: 18),
                Wrap(
                  spacing: 12,
                  children: [
                    ChoiceChip(
                      label: const Text('Emprestados'),
                      selected: !returned,
                      onSelected: (_) => setState(() => returned = false),
                    ),
                    ChoiceChip(
                      label: const Text('Devolvidos'),
                      selected: returned,
                      onSelected: (_) => setState(() => returned = true),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                if (controller.busy) const LinearProgressIndicator(),
                if (controller.error != null)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          Text(controller.error!),
                          TextButton(
                            onPressed: controller.load,
                            child: const Text('Tentar novamente'),
                          ),
                        ],
                      ),
                    ),
                  ),
                if (!controller.busy && visible.isEmpty) _empty(),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final columns = constraints.maxWidth > 800
                        ? 3
                        : constraints.maxWidth > 540
                        ? 2
                        : 1;
                    final width =
                        (constraints.maxWidth - (columns - 1) * 16) / columns;
                    return Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      children: visible
                          .map(
                            (item) =>
                                SizedBox(width: width, child: _card(item)),
                          )
                          .toList(),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
  Widget _empty() => Padding(
    padding: const EdgeInsets.symmetric(vertical: 40),
    child: Column(
      children: [
        const Icon(
          Icons.inventory_2_outlined,
          size: 54,
          color: Color(0xff285c4b),
        ),
        const SizedBox(height: 16),
        Text(
          query.isNotEmpty
              ? 'Nenhum resultado para essa busca'
              : returned
              ? 'As devoluções vão aparecer aqui'
              : 'Seu próximo empréstimo começa aqui',
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        const Text('Registre um objeto e para quem você emprestou.'),
        if (controller.items.isEmpty && query.isEmpty)
          TextButton.icon(
            onPressed: () => controller.run(controller.dao.addDemo),
            icon: const Icon(Icons.auto_awesome_outlined),
            label: const Text('Experimentar com exemplos locais'),
          ),
      ],
    ),
  );
  Widget _card(Stuff item) => Card(
    clipBehavior: Clip.antiAlias,
    color: Colors.white,
    child: Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              LoanPhoto(item: item, size: 64),
              const Spacer(),
              PopupMenuButton<String>(
                tooltip: 'Ações de ${item.description}',
                onSelected: (action) {
                  if (action == 'edit') {
                    edit(item);
                  } else {
                    remove(item);
                  }
                },
                itemBuilder: (_) => [
                  const PopupMenuItem(value: 'edit', child: Text('Editar')),
                  const PopupMenuItem(value: 'delete', child: Text('Excluir')),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            item.description,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text('com ${item.contactName}', style: const TextStyle(fontSize: 16)),
          if (item.phone.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: SelectableText(item.phone),
            ),
          const SizedBox(height: 16),
          Text(
            'Desde ${DateFormat('dd MMM yyyy', 'pt_BR').format(item.loanDate)}',
            style: const TextStyle(color: Color(0xff52645c)),
          ),
          const SizedBox(height: 20),
          OutlinedButton.icon(
            onPressed: controller.busy
                ? null
                : () => controller.run(() async {
                    await controller.dao.save(
                      item.withReturned(!item.returned),
                    );
                  }),
            icon: Icon(item.returned ? Icons.undo : Icons.check),
            label: Text(
              item.returned ? 'Emprestar novamente' : 'Marcar devolução',
            ),
          ),
        ],
      ),
    ),
  );
}

class _Metric extends StatelessWidget {
  final String value, label;
  final IconData icon;
  const _Metric({required this.value, required this.label, required this.icon});
  @override
  Widget build(BuildContext context) => Container(
    constraints: const BoxConstraints(minHeight: 144),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: const Color(0xffe6ede6),
      borderRadius: BorderRadius.circular(18),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: const Color(0xff285c4b)),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
        ),
        Text(label),
      ],
    ),
  );
}
