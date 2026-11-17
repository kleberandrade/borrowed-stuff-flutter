# Illustrated classroom material

These assets support `../medium-update.pt-BR.md` and the existing Portuguese Medium story.

- `01-journal.jpg`, `02-form.jpg`, `03-validation.jpg`, `07-returned.jpg`: actual Chrome captures of the Flutter 3.50 app with fictional local data. The form captures show the real empty and validation states. No app mockup or device simulation is presented as a native device run.
- `04-architecture.png`: responsibilities and the alternative Sembast factories.
- `05-save-flow.png`: actual save/controller flow, including failure and finally.
- `06-record-key.png`: illustrative legacy key example matching the repository compatibility test.

Diagrams are original code-native figures, not AI artwork. Editable SVGs and the shared renderer are in `source/`. The renderer uses Python 3, Pillow and the standard macOS Arial fonts; run `python source/render_diagrams.py` in this directory after installing Pillow in an isolated environment. PNGs are the portable publication exports. No change to application behavior is included in this documentation revision.
