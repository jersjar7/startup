// Screen nodes, written the way the games' own widgets are (see the pack's
// screen_nodes.dart for what each one is).

typedef Node = Map<String, Object?>;

Node box({
  Node? child,
  List<Node>? c,
  List<num>? pad,
  Object? w,
  num? h,
  Object? fill,
  Object? border,
  Object? stroke,
  num? radius,
  String? align,
  bool clip = false,
  String? cross,
  String? edge,
  String? when,
  num? minW,
  num? minH,
}) => {
  'k': 'box',
  'minw': ?minW,
  'minh': ?minH,
  'child': ?child,
  'c': ?c,
  'pad': ?pad,
  'w': ?w,
  'h': ?h,
  'fill': ?fill,
  'border': ?border,
  'stroke': ?stroke,
  'radius': ?radius,
  'align': ?align,
  if (clip) 'clip': true,
  'cross': ?cross,
  'edge': ?edge,
  'when': ?when,
};

Node row(
  List<Node> c, {
  String? main,
  String? cross,
  String? when,
  bool min = false,
}) => {
  'k': 'row',
  'c': c,
  if (min) 'size': 'min',
  'main': ?main,
  'cross': ?cross,
  'when': ?when,
};

Node col(List<Node> c, {String? main, String? cross, String? when}) => {
  'k': 'col',
  'c': c,
  'main': ?main,
  'cross': ?cross,
  'when': ?when,
};

Node gapW(num w) => {'k': 'gap', 'w': w};

Node gapH(num h, {String? when}) => {'k': 'gap', 'h': h, 'when': ?when};

Node flex(Node child, [int f = 1, bool loose = false]) => {
  'k': 'flex',
  'child': child,
  if (f != 1) 'f': f,
  if (loose) 'loose': true,
};

Node rule({num h = 1, Object? color}) => {'k': 'rule', 'h': h, 'color': ?color};

Node center(Node child, {num? wf}) => {
  'k': 'center',
  'child': child,
  'wf': ?wf,
};

Node t(
  Object v, {
  String? font,
  num? size,
  Object? color,
  bool bold = false,
  num? line,
  String? align,
  bool one = false,
  bool bar = false,
  int? weight,
  String? when,
}) => {
  'k': 't',
  'v': v,
  'font': ?font,
  'size': ?size,
  'color': ?color,
  if (bold) 'bold': true,
  'line': ?line,
  'align': ?align,
  if (one) 'one': true,
  if (bar) 'bar': true,
  'weight': ?weight,
  'when': ?when,
};

Node tex(Object v, num size, {String? when, String? align, bool fit = true}) =>
    {
      'k': 'tex',
      'v': v,
      'size': size,
      'align': ?align,
      if (!fit) 'fit': false,
      'when': ?when,
    };

Node draw(Object d) => {'k': 'draw', 'd': d};

Node clip(Node child, num radius, {String? when}) => {
  'k': 'clip',
  'radius': radius,
  'child': child,
  'when': ?when,
};

Node grid(Node child, {num? minor, num? major}) => {
  'k': 'grid',
  'child': child,
  'minor': ?minor,
  'major': ?major,
};

/// A formula in a line of text, as the games write one inside a box.
Node math(String v, num size, {Object? color}) => {
  'k': 'math',
  'v': v,
  'size': size,
  'color': ?color,
};

/// Answer [i], tapped anywhere on [child]: inked, or with [plain] a bare
/// tap area (no ink, no fill) as games on a bare tap handler are.
Node answer(
  int i,
  Node child, {
  num radius = 12,
  Object? fill,
  String? key,
  bool plain = false,
}) => {
  'k': 'answer',
  'i': i,
  if (plain) 'plain': true,
  'key': ?key,
  'child': child,
  if (radius != 12) 'radius': radius,
  'fill': ?fill,
};

/// A value that follows the state of the answer it sits in.
Map<String, Object?> tone(
  Object? idle,
  Object? picked,
  Object? right,
  Object? wrong, {
  int? of,
}) => {
  'idle': idle,
  'picked': picked,
  'right': right,
  'wrong': wrong,
  'of': ?of,
};

/// What is picked in slot [k]: [of] has one value per answer.
Map<String, Object?> slot(int k, List<Object?> of, {Object? empty}) => {
  'slot': k,
  'of': of,
  'empty': empty,
};

/// Which place the answer it sits in was picked in: [places] has one value
/// per place.
Map<String, Object?> place(List<Object?> places, {Object? none}) => {
  'place': places,
  'none': none,
};

/// A value before the answer and after it.
Map<String, Object?> askDone(Object? ask, Object? done) => {
  'ask': ask,
  'done': done,
};

/// The games' usual answer button: white, ember once picked, then forest
/// or red, its border a pixel thicker once it is anything but idle.
Node tinted(
  int i,
  Node child, {
  num radius = 12,
  num? h,
  List<num>? pad,
  String? align,
  Object? w = 'max',
}) => answer(
  i,
  box(
    w: w,
    h: h,
    pad: pad,
    align: align,
    radius: radius,
    border: tone('line', 'ember', 'forest', 'error'),
    stroke: tone(1, 2, 2, 2),
    child: child,
  ),
  radius: radius,
  fill: tone('white', 'emberBg', 'forestBg', 'errorBg'),
);

/// Answers side by side, each taking an equal share, [space] apart.
Node answerRow(List<Node> answers, {num space = 8}) => row([
  for (final (i, a) in answers.indexed) ...[if (i > 0) gapW(space), flex(a)],
]);

/// A drawing on the grid, clipped to the games' 16 pixel corner.
Node pictured(Object d, num h, {num radius = 16, String? when}) => clip(
  box(w: 'max', h: h, child: grid(draw(d))),
  radius,
  when: when,
);

Node icon(String name, {num? size, Object? color}) => {
  'k': 'icon',
  'v': name,
  'size': ?size,
  'color': ?color,
};

/// Its child at [v] opacity (a value that may follow the round).
Node fade(Object v, Node child) => {'k': 'fade', 'o': v, 'child': child};

/// Children laid out in runs, [space] apart and [run] between runs.
Node wrap(List<Node> c, {num space = 0, num run = 0, bool center = false}) => {
  'k': 'wrap',
  'c': c,
  if (space != 0) 'spacing': space,
  if (run != 0) 'run': run,
  if (center) 'align': 'center',
  if (center) 'cross': 'center',
};

/// A button that moves the pick by [by] (see the pack's `step` node).
Node stepper(int by, Node child, {Object? fill, num radius = 12}) => {
  'k': 'step',
  'by': by,
  'child': child,
  'fill': ?fill,
  if (radius != 12) 'radius': radius,
};

/// Slot [k], tapped to empty it once filled.
Node unslot(int k, Node child) => {'k': 'slot', 's': k, 'child': child};

/// A value by whether answer [i] is picked.
Map<String, Object?> has(int i, Object? yes, Object? no) => {
  'of': i,
  'on': yes,
  'off': no,
};

/// A value per step of a run of moves.
Map<String, Object?> perStep(List<Object?> each) => {'step': each};

/// A value while the round is open, and once answered right or wrong.
Map<String, Object?> outcome(Object? open, Object? right, Object? wrong) => {
  'open': open,
  'won': right,
  'lost': wrong,
};

/// A value by how slot [k] of a fill stands.
Map<String, Object?> fillState(
  int k, {
  required Object? right,
  required Object? wrong,
  required Object? next,
  required Object? full,
  required Object? empty,
}) => {
  'fill': k,
  'right': right,
  'wrong': wrong,
  'next': next,
  'full': full,
  'empty': empty,
};
