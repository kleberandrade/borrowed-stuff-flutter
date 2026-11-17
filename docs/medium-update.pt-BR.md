# Criando um aplicativo para lembrar dos objetos emprestados com Flutter e Sembast

## Notas de aula do professor Kleber de Oliveira Andrade

Atualização de 17/11/2026: esta edição acompanha a modernização do projeto para Flutter 3.41.9 e Dart 3.11.5, com null safety, Material 3 e execução Web. O objetivo da aula continua o mesmo: lembrar o que emprestamos, para quem e em qual data, mantendo os dados localmente. A URL e a autoria do artigo são preservadas.

Vamos criar um diário de empréstimos que permite cadastrar e editar objetos, guardar a pessoa e uma foto opcional, marcar devoluções e excluir registros com confirmação. Na tela inicial podemos buscar pelo objeto ou pela pessoa e alternar entre emprestados e devolvidos.

### Preparando e executando o projeto

Para acompanhar a versão atual, instale Flutter 3.41.9, que inclui Dart 3.11.5, e tenha o Chrome disponível. Confira a versão e o diagnóstico da instalação com os comandos abaixo. Não use o antigo requisito de Dart 2 desta aula. O aplicativo não precisa de Firebase, servidor ou chave de API.

```sh
flutter --version
flutter doctor
git clone https://github.com/kleberandrade/borrowed-stuff-flutter.git
cd borrowed-stuff-flutter
flutter pub get
flutter run -d chrome --web-port 8767
```

Mantenha o mesmo endereço e porta para encontrar o mesmo banco no navegador. O armazenamento Web pertence à origem do site. Na primeira execução, o botão “Experimentar com exemplos locais” cria três registros fictícios. A operação só insere exemplos quando a coleção está vazia e não substitui dados existentes.

### Dependências atuais

O pubspec.yaml do repositório é a referência. Estas são as dependências da edição atual; o pubspec.lock registra as versões resolvidas e deve ser mantido no aplicativo.

```yaml
name: borrowed_stuff
description: An offline lending journal for objects, people and returns.
publish_to: none
version: 2.0.0+2

environment:
  sdk: '>=3.11.0 <4.0.0'
  flutter: '>=3.41.0'

dependencies:
  flutter:
    sdk: flutter
  flutter_localizations:
    sdk: flutter
  intl: ^0.20.2
  image_picker: ^1.2.4
  path: ^1.9.1
  path_provider: ^2.1.5
  sembast: ^3.8.5
  sembast_web: 2.4.4+1
  cupertino_icons: ^1.0.8

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^6.0.0

flutter:
  uses-material-design: true

```

O Sembast Web está fixado em 2.4.4+1: versões mais novas exigem Dart 3.12. Não é necessário trocar o SDK compartilhado para executar esta edição. Flushbar, flutter_slidable e datetime_picker_formfield foram removidos. Usamos os componentes atuais do Flutter: botões, menus, showDatePicker, indicadores de progresso e diálogos Material.

### Separando responsabilidades

Continuamos com modelo, acesso a dados, controller e telas, mas as dependências agora são explícitas. Stuff representa um empréstimo; StuffDao implementa LoanRepository; HomeController recebe esse repositório, espera a gravação terminar e só então atualiza a lista. HomePage apresenta o diário e StuffDetailPage apresenta o formulário.

A estrutura atual está em lib/models, lib/database, lib/controllers, lib/pages e lib/components. O arquivo do formulário chama-se lib/pages/stuff_detail_page.dart, corrigindo a grafia antiga. O código completo de cada etapa está no repositório, em vez de depender dos antigos Gists da versão Dart 2.

Referência conceitual preservada da aula original: vídeo “MVC // Dicionário do Programador”, do Código Fonte TV: https://www.youtube.com/watch?v=jyTNhT67ZyY. O vídeo é de terceiros e não foi modificado.

### Modelo, validação e datas

A classe Stuff tem campos finais: id opcional, description, contactName, loanDate, phone opcional, photoPath legado, photoBase64 e returned. Um registro novo exige descrição e pessoa com conteúdo após trim; sua data não pode estar no futuro. O telefone é opcional, mas, quando preenchido, deve ter de 8 a 15 dígitos e apenas a pontuação permitida. A interface valida antes de salvar e o modelo também protege a entrada.

```dart
final item = Stuff(
  description: 'O Hobbit',
  contactName: 'Marina Costa',
  loanDate: DateTime(2026, 11, 17),
  phone: '(11) 99999-1234',
);
```

No exemplo, escolha uma data igual ou anterior ao dia em que você executar o código. loanDate é uma data de calendário local. A serialização mantém o campo loanDate em milissegundos por compatibilidade e acrescenta calendarDate no formato YYYY-MM-DD. Assim, as novas gravações não mudam de dia quando lidas em outro fuso horário.

O formato antigo só contém um instante em milissegundos; ele é interpretado no fuso do dispositivo, como antes. Não há informação suficiente para reconstruir o fuso original de um registro antigo. Registros legados com campos vazios ou datas futuras continuam legíveis; ao editar, corrija os dados para atender às validações atuais.

Código completo do modelo: https://github.com/kleberandrade/borrowed-stuff-flutter/blob/master/lib/models/stuff.dart

### Abrindo o Sembast no dispositivo e na Web

Mantemos borrowed_stuff.db no diretório de documentos do aplicativo nas plataformas nativas. No navegador usamos databaseFactoryWeb, que persiste em IndexedDB. Não tente abrir um caminho de arquivo nativo no Chrome. A função atual de abertura é:

```dart
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sembast/sembast_io.dart';
import 'package:sembast_web/sembast_web.dart';

Future<Database> openAppDatabase() async {
  if (kIsWeb) return databaseFactoryWeb.openDatabase('borrowed_stuff.db');
  final dir = await getApplicationDocumentsDirectory();
  return databaseFactoryIo.openDatabase(p.join(dir.path, 'borrowed_stuff.db'));
}
```

A abertura acontece no início do app. A conexão é injetada no DAO e o controller é entregue às telas. Isso substitui o Completer global da primeira edição e permite testar o repositório com um banco separado. Se a abertura falhar, a interface oferece uma nova tentativa em vez de deixar um indicador girando indefinidamente.

### Identidade dos registros e CRUD

A coleção continua chamada Stuff e usa chaves inteiras. O identificador confiável é snapshot.key, não o campo id contido no mapa. A primeira edição fazia uma atualização filtrada pela descrição após inserir: dois objetos com a mesma descrição podiam receber o mesmo id no conteúdo. Agora cada registro mantém sua própria chave.

```dart
final dao = StuffDao(database);
final saved = await dao.save(item);
final loans = await dao.readAll();
await dao.save(saved.withReturned(true));
// Para excluir um registro, depois da confirmação na interface:
await dao.delete(saved);
```

As chamadas acima são um exemplo sequencial dentro de uma função async; database deve ser a conexão obtida com openAppDatabase. save devolve o objeto com sua chave após a inserção. A devolução atualiza a mesma chave; não apaga o empréstimo. O filtro Devolvidos permite consultar o histórico e emprestar novamente. A exclusão definitiva só acontece após confirmação.

Código completo: https://github.com/kleberandrade/borrowed-stuff-flutter/blob/master/lib/database/stuff_dao.dart

### Compatibilidade com o aplicativo antigo

Faça uma cópia do arquivo borrowed_stuff.db e das fotos referenciadas antes de atualizar uma instalação antiga. Preserve o identificador do app e não desinstale a versão anterior primeiro. O projeto preserva o identificador, o nome do arquivo, a coleção e as chaves.

A leitura dos mapas antigos não regrava os dados ao iniciar. Ao editar, o registro recebe schemaVersion 2 e os campos adicionais; photoPath é mantido se a pessoa não remover ou substituir a foto. A chave real do banco prevalece sobre um id antigo incorreto. Campos novos ausentes assumem valores vazios ou false. Há teste que cria dados no formato antigo, fecha o arquivo, abre, atualiza e abre novamente, conferindo chave, data, foto e devolução.

Os dados nativos não são importados automaticamente para a Web. Cada navegador/origem tem seu diário. Limpar os dados do site apaga esse diário. Não há sincronização, exportação ou criptografia adicionada nesta edição.

### Fotos com a API atual

Usamos ImagePicker().pickImage com ImageSource.gallery, retornando XFile. A seleção é opcional. O formulário lê readAsBytes, verifica o limite de 5 MB e grava base64 junto ao registro. Isso evita depender de caminhos temporários ou URLs blob que deixam de funcionar depois de recarregar a página. O app solicita redimensionamento para até 1200 × 1200 e qualidade 80 onde a plataforma permite.

```dart
final file = await ImagePicker().pickImage(
  source: ImageSource.gallery,
  maxWidth: 1200,
  maxHeight: 1200,
  imageQuality: 80,
  requestFullMetadata: false,
);
if (file != null) {
  final bytes = await file.readAsBytes();
  if (bytes.length > 5 * 1024 * 1024) {
    throw ArgumentError('Escolha uma imagem de até 5 MB.');
  }
  final photoBase64 = base64Encode(bytes);
  // O formulário entrega photoBase64 ao novo Stuff ao salvar.
}
```

Esse trecho ilustra a seleção; veja o tratamento completo de cancelamento, erros e estado no formulário. Importe dart:convert e package:image_picker/image_picker.dart para usar essas APIs. O app atual escolhe uma imagem da galeria/arquivo, não tira fotos com a câmera. As antigas permissões Android CAMERA, WRITE_EXTERNAL_STORAGE e READ_EXTERNAL_STORAGE não fazem parte dessa implementação. No iOS, Info.plist informa o motivo de acesso à fototeca. A configuração atual usa Android API 24 ou superior e iOS 15 ou superior.

Fotos antigas continuam usando photoPath apenas nas plataformas nativas, quando o arquivo ainda existe. Se ele não existir ou não puder ser exibido, mostramos um ícone sem apagar o caminho salvo. A Web mostra um marcador para caminhos de arquivo nativos. Payloads de foto têm teste de persistência; a seleção visual automatizada ficou limitada pela configuração de acesso a arquivos da extensão do navegador, portanto não foi apresentada como teste manual concluído.

### Controller e telas

HomeController.run espera a operação e uma nova leitura do banco. Enquanto ela executa, busy impede gravações concorrentes pela interface. Se houver falha, a lista anterior permanece visível, aparece uma mensagem e é possível tentar novamente. O diário usa ListenableBuilder para refletir essas mudanças.

Na HomePage há resumo, busca por nome/objeto, cartões em uma, duas ou três colunas conforme a largura, filtros e ações visíveis. O formulário usa Form e TextFormField, showDatePicker limitado ao dia atual, controles Material 3 e confirmação antes de descartar alterações. Os controllers de texto são liberados em dispose. Há estados vazios, de carregamento e de erro; a navegação por teclado usa os controles padrão do Flutter.

Arquivos completos:
https://github.com/kleberandrade/borrowed-stuff-flutter/blob/master/lib/main.dart
https://github.com/kleberandrade/borrowed-stuff-flutter/blob/master/lib/controllers/home_controller.dart
https://github.com/kleberandrade/borrowed-stuff-flutter/blob/master/lib/pages/home_page.dart
https://github.com/kleberandrade/borrowed-stuff-flutter/blob/master/lib/pages/stuff_detail_page.dart

### Testando antes de experimentar

```sh
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test --coverage
flutter build web
```

A suíte verifica entradas inválidas, datas/fotos antigas, descrições repetidas, ids antigos incorretos, migração ao atualizar, exclusão, reabertura de arquivo, exemplos idempotentes, persistência de fotos, recuperação do controller após falha e o fluxo de validação/cadastro/devolução em largura de celular. O workflow do GitHub repete formatação, análise, testes e build Web com Flutter 3.41.9. Consulte o resultado real na aba Actions; nenhum percentual de cobertura ou resultado de mutação foi inventado.

Na validação em Chrome, foram carregados exemplos, marcada uma devolução e recarregada a página para conferir a persistência. Screenshots reais ficam em docs/screenshots. Não confunda build ou viewport móvel com execução em telefone físico. Os resultados e limites dos builds nativos ficam em docs/WORK_LOG.md.

### Desafios para continuar a aula

Adicione exportação/restauração com teste de compatibilidade; experimente uma data prevista de devolução; implemente animações respeitando movimento reduzido; ou estude uma ação explícita de telefone com url_launcher. O telefone já é opcional e validado nesta versão; não é necessário instalar BrasilFields para executar o projeto.

Referência de terceiros preservada para a extensão de chamadas, SMS e e-mail: https://medium.com/flutter-community/flutter-making-phone-calls-sending-sms-and-emails-with-url-launcher-56414b06f84e . Esse artigo é somente referência e não foi alterado. Câmera, chamadas e mensagens não são funcionalidades implementadas nesta edição.

### Código, créditos e licença

Projeto completo: https://github.com/kleberandrade/borrowed-stuff-flutter . O README em inglês documenta requisitos e comandos verificados. O material original de 2020, incluindo screenshots, exercícios e créditos, está preservado em docs/legacy-readme.pt-BR.md e deve ser lido como histórico de Dart 2.

Aplicativo e notas de aula de Kleber de Oliveira Andrade, disciplina de Programação Mobile. Código sob MIT, copyright 2020 Kleber de Oliveira Andrade; bibliotecas e conteúdos de terceiros mantêm suas próprias licenças e créditos.
