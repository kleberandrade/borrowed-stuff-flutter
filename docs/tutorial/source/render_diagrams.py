"""Render the tutorial's original vector diagrams and PNG exports.
Run with Python 3 + Pillow. Text and arrows describe the actual Dart code.
"""
from pathlib import Path
from html import escape
import math
from PIL import Image, ImageDraw, ImageFont

OUT = Path(__file__).resolve().parents[1]
REG = '/System/Library/Fonts/Supplemental/Arial.ttf'
BOLD = '/System/Library/Fonts/Supplemental/Arial Bold.ttf'
INK, GREEN, PALE, LINE, GRAY = '#18372d', '#285c4b', '#e6ede6', '#648c7b', '#52645c'

class Figure:
    def __init__(self, height, title, subtitle):
        self.image = Image.new('RGB', (1400, height), '#ffffff')
        self.draw = ImageDraw.Draw(self.image)
        self.svg = [f'<svg xmlns="http://www.w3.org/2000/svg" width="1400" height="{height}" viewBox="0 0 1400 {height}" role="img" aria-label="{escape(title)}">', '<rect width="100%" height="100%" fill="white"/>']
        self.text(70, 62, title, 54, True)
        self.text(70, 136, subtitle, 32, color=GRAY)

    def text(self, x, y, content, size=36, bold=False, color=INK):
        font = ImageFont.truetype(BOLD if bold else REG, size)
        self.draw.text((x, y), content, font=font, fill=color, anchor='lt')
        self.svg.append(f'<text x="{x}" y="{y+size*.8}" font-family="Arial, sans-serif" font-size="{size}" font-weight="{700 if bold else 400}" fill="{color}">{escape(content)}</text>')

    def box(self, x, y, w, h, title, lines=(), fill=PALE, size=38):
        self.draw.rounded_rectangle((x, y, x+w, y+h), radius=20, fill=fill, outline=LINE, width=2)
        self.svg.append(f'<rect x="{x}" y="{y}" width="{w}" height="{h}" rx="20" fill="{fill}" stroke="{LINE}" stroke-width="2"/>')
        self.text(x+28, y+24, title, size, True)
        for i, line in enumerate(lines):
            self.text(x+28, y+72+i*39, line, 30)

    def arrow(self, points, color=GREEN):
        self.draw.line(points, fill=color, width=5, joint='curve')
        pts = ' '.join(f'{x},{y}' for x,y in points)
        self.svg.append(f'<polyline points="{pts}" fill="none" stroke="{color}" stroke-width="5"/>')
        x,y=points[-1]; px,py=points[-2]; angle=math.atan2(y-py,x-px)
        triangle=[(x,y), (x-19*math.cos(angle-.42),y-19*math.sin(angle-.42)), (x-19*math.cos(angle+.42),y-19*math.sin(angle+.42))]
        self.draw.polygon(triangle, fill=color)
        self.svg.append('<polygon points="'+' '.join(f'{a:.1f},{b:.1f}' for a,b in triangle)+f'" fill="{color}"/>')

    def save(self, name):
        self.image.save(OUT/f'{name}.png')
        (OUT/'source'/f'{name}.svg').write_text('\n'.join(self.svg+['</svg>']))

f=Figure(1360, 'Quem faz o quê no aplicativo?', 'Leia de cima para baixo: interface → coordenação → persistência.')
f.box(70,220,770,150,'Telas', ['HomePage e StuffDetailPage', 'Exibem dados e recebem ações.'])
f.box(930,220,400,195,'Stuff', ['Dados do empréstimo.', 'Valida a nova entrada.', 'models/stuff.dart'],size=38)
f.arrow([(840,290),(930,290)])
f.arrow([(455,370),(455,430)])
f.box(70,430,770,150,'HomeController', ['Controla busy, error e a lista.', 'Espera a operação e a nova leitura.'])
f.arrow([(455,580),(455,640)])
f.box(70,640,770,150,'LoanRepository → StuffDao', ['O contrato separa a aplicação do banco.', 'O DAO implementa as operações Sembast.'],size=36)
f.box(930,485,400,195,'Nos testes', ['Um repositório falso', 'pode testar a interface.', 'O DAO tem testes reais.'],fill='#f6f5f0',size=38)
f.arrow([(455,790),(455,850)])
f.box(70,850,770,140,'Sembast: store Stuff', ['Chave inteira → mapa do empréstimo'])
f.arrow([(455,990),(455,1045),(355,1045),(355,1095)])
f.arrow([(455,990),(455,1045),(1045,1045),(1045,1095)])
f.box(70,1095,570,150,'Web', ['databaseFactoryWeb', 'IndexedDB da origem do site'])
f.box(760,1095,570,150,'Nativo', ['databaseFactoryIo', 'Arquivo borrowed_stuff.db'])
f.text(70,1292,'A fábrica é escolhida na abertura. Web e nativo têm bancos separados.',30,color=GRAY)
f.save('04-architecture')

f=Figure(1420, 'O que acontece ao tocar em Salvar?', 'Fluxo real entre o formulário, o controller e o repositório.')
f.box(70,215,800,145,'1. O formulário valida', ['Form.validate() verifica os campos.', 'Stuff aplica as regras do domínio.'])
f.arrow([(470,360),(470,410)])
f.box(70,410,800,145,'2. O controller sinaliza a espera', ['busy = true; error = null', 'notifyListeners() mostra o estado atual.'],size=36)
f.arrow([(470,555),(470,605)])
f.box(70,605,800,145,'3. O DAO grava e a lista é relida', ['await operation() → dao.save(item)', 'items = await dao.readAll()'],size=36)
f.arrow([(470,750),(470,810)])
f.box(70,810,800,145,'4. O estado final é comunicado', ['finally: busy = false', 'notifyListeners() reconstrói a interface.'],size=36)
f.arrow([(470,955),(470,1015)])
f.box(70,1015,800,160,'5. A tela decide o próximo passo', ['Sucesso: volta para o diário atualizado.', 'Falha: mostra a mensagem e mantém a edição.'],size=36)
f.box(960,605,370,260,'Se houver erro', ['catch define error.', 'run retorna false.', 'A lista anterior', 'é preservada.'],fill='#f8ede5',size=34)
f.arrow([(870,670),(960,670)])
f.arrow([(1145,865),(1145,900),(870,900)])
f.text(70,1250,'await ordena o trabalho: não confirme uma gravação antes de esperá-la.',32,color=GRAY)
f.text(70,1310,'busy impede outra operação do controller enquanto a atual está em andamento.',30,color=GRAY)
f.save('05-save-flow')

f=Figure(1080, 'A chave identifica; o mapa descreve', 'Exemplo didático baseado no teste de compatibilidade do repositório.')
f.box(70,225,560,360,'Antes: registro legado', ['Chave Sembast: 4', 'id no mapa: 99 (incorreto)', 'description: Livro', 'contactName: Ana', 'photoPath: /old.jpg'],fill='#f8ede5',size=38)
f.box(770,225,560,360,'Depois: editar a mesma chave', ['Chave Sembast: 4', 'id no mapa: 4', 'description: Livro', 'photoPath: /old.jpg (preservado)', 'schemaVersion: 2'],size=36)
f.arrow([(630,400),(770,400)])
f.box(70,670,1260,185,'A leitura usa snapshot.key como identidade', ['O id antigo não é usado para localizar outro empréstimo.', 'Outra descrição “Livro” pode existir com outra chave.'],fill='#f6f5f0',size=38)
f.text(70,920,'Abertura: lê o formato antigo sem regravar todos os registros.',32,color=GRAY)
f.text(70,975,'Edição: grava os campos novos no mesmo registro e mantém a foto legada.',32,color=GRAY)
f.save('06-record-key')
