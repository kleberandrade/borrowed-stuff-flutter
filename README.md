# Empréstimo de Objetos

Aplicativo para lembrar dos objetos emprestados criado na disciplina de Programação Mobile, por Kleber de Oliveira Andrade.

Tutorial de criação deste app [clique aqui](https://medium.com/@kleberandrade/criando-um-aplicativo-para-lembrar-dos-objetos-emprestados-com-flutter-e-sembast-6dbf350a7a56).

<p align="center">
    <img src="https://miro.medium.com/max/720/1*trhQYyzZfIj_LsYQGOQ8Vg.png" width="250"/>
    <img src="https://miro.medium.com/max/720/1*rcw9WulfFColELibTQsA8w.png" width="250"/>
    <img src="https://miro.medium.com/max/720/1*fiP5mrr67aDnF3uPc3dRxQ.png" width="250"/>
</p>

<p align="center">
    <img src="https://miro.medium.com/max/720/1*XZIMgoUfDc_bkr-fhzWvrA.png" width="250"/>
    <img src="https://miro.medium.com/max/720/1*bRGL1qXFTrtI8NeqUEqBcQ.png" width="250"/>
    <img src="https://miro.medium.com/max/720/1*YjS4wUASqCh4TFEeEHKPpA.png" width="250"/>
</p>


## Como clonar e importar

*   Faça um fork do projeto (precisa ter uma conta no github)
*   Abra o terminal do Visual Studio Code
*   Acesse a pasta onde deseja salvar o aplicativo e digite: git clone *link_do_projeto_no_seu_github* **borrowed_stuff**
*   Clique em File -> Open e abra o projeto (pasta)
*   Não se esqueça de abrir o arquivo *pubspec.yaml* e salvar (CTRL + S) o arquivo para que os plugins sejam baixados 

## Desafio para aula

*   [ ] Adicionar um campo TextFormField parar armazenar o telefone para contato ([validação de telefone](https://stackoverflow.com/questions/55552230/flutter-validate-a-phone-number-using-regex/55552272), [RegEX](https://api.dart.dev/stable/2.0.0/dart-core/RegExp-class.html) e plugin [BrasilFields](https://pub.dev/packages/brasil_fields) para formatar os campos); Não se esqueça de modificar a classe Stuff para receber o telefone também.
*   [ ] Validar todos campos do formulário: data de empréstimo deve ser menor ou igual a data de hoje; descrição não pode ser vazio; nome não pode ser vazio; telefone não pode ser vazio e precisa ter a quantidade de números adequada;  Você pode adicionar essa validação entendendo mais sobre [TextFormField](https://flutter.dev/docs/cookbook/forms/validation);
*   [ ] Adicionar uma animação na lista de objetos ([documentação](https://flutter.dev/docs/catalog/samples/animated-list) e [vídeo tutorial](https://www.youtube.com/watch?v=i7O5T4V59HI));
*   [ ] Implementar um tema (cores) personalizadas, incluindo fontes e tamanhos (utilize o [panache](https://rxlabz.github.io/panache/#/) para facilitar a configuração das cores);
*   [ ] Adicionar um botão no StuffCard ao deslizar para esquerda, para realizar uma ligação para o número de telefone, caso ele exista; (plugin [url_launcher](https://pub.dev/packages/url_launcher) e [tutorial](https://medium.com/flutter-community/flutter-making-phone-calls-sending-sms-and-emails-with-url-launcher-56414b06f84e));

## Licença

    Copyright 2020 Kleber de Oliveira Andrade
    
    Permission is hereby granted, free of charge, to any person obtaining a copy
    of this software and associated documentation files (the "Software"), to deal
    in the Software without restriction, including without limitation the rights
    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
    copies of the Software, and to permit persons to whom the Software is
    furnished to do so, subject to the following conditions:
    
    The above copyright notice and this permission notice shall be included in all
    copies or substantial portions of the Software.
    
    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
    SOFTWARE.
