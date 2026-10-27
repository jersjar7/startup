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
}) => {
  'k': 'box',
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

Node row(List<Node> c, {String? main, String? cross, String? when}) => {
  'k': 'row',
  'c': c,
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
  'when': ?when,
};

Node tex(Object v, num size, {String? when}) => {
  'k': 'tex',
  'v': v,
  'size': size,
  'when': ?when,
};

Node draw(Object d) => {'k': 'draw', 'd': d};

Node clip(Node child, num radius, {String? when}) => {
  'k': 'clip',
  'radius': radius,
  'child': child,
  'when': ?when,
};

Node grid(Node child) => {'k': 'grid', 'child': child};

Node answer(int i, Node child, {num radius = 12, Object? fill}) => {
  'k': 'answer',
  'i': i,
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
