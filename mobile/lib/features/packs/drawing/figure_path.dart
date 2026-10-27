import 'dart:ui' as ui;

/// The path the figures use: Flutter's own, plus a note of how it was
/// built, so a recorded drawing can rebuild its curves exactly.
///
/// An extension type, so at run time it IS Flutter's path and draws on a
/// real canvas at no cost. Only while the pack builder records
/// ([recordPaths]) does each path keep its list of moves. A built path
/// cannot say how it was built, and tracing it afterwards turns curves into
/// near-misses (phase 0, the coupon check).
extension type Path._(ui.Path _path) implements ui.Path {
  Path() : this._(_start(ui.Path()));

  static ui.Path _start(ui.Path p) {
    if (recordPaths) _moves[p] = <List<Object?>>[];
    return p;
  }

  void _note(List<Object?> move) => _moves[_path]?.add(move);

  set fillType(ui.PathFillType value) {
    _note(['F', value.index]);
    _path.fillType = value;
  }

  void moveTo(double x, double y) {
    _note(['M', x, y]);
    _path.moveTo(x, y);
  }

  void relativeMoveTo(double dx, double dy) {
    _note(['m', dx, dy]);
    _path.relativeMoveTo(dx, dy);
  }

  void lineTo(double x, double y) {
    _note(['L', x, y]);
    _path.lineTo(x, y);
  }

  void relativeLineTo(double dx, double dy) {
    _note(['l', dx, dy]);
    _path.relativeLineTo(dx, dy);
  }

  void quadraticBezierTo(double x1, double y1, double x2, double y2) {
    _note(['Q', x1, y1, x2, y2]);
    _path.quadraticBezierTo(x1, y1, x2, y2);
  }

  void relativeQuadraticBezierTo(double x1, double y1, double x2, double y2) {
    _note(['q', x1, y1, x2, y2]);
    _path.relativeQuadraticBezierTo(x1, y1, x2, y2);
  }

  void cubicTo(
    double x1,
    double y1,
    double x2,
    double y2,
    double x3,
    double y3,
  ) {
    _note(['C', x1, y1, x2, y2, x3, y3]);
    _path.cubicTo(x1, y1, x2, y2, x3, y3);
  }

  void relativeCubicTo(
    double x1,
    double y1,
    double x2,
    double y2,
    double x3,
    double y3,
  ) {
    _note(['c', x1, y1, x2, y2, x3, y3]);
    _path.relativeCubicTo(x1, y1, x2, y2, x3, y3);
  }

  void conicTo(double x1, double y1, double x2, double y2, double w) {
    _note(['K', x1, y1, x2, y2, w]);
    _path.conicTo(x1, y1, x2, y2, w);
  }

  void arcTo(
    ui.Rect rect,
    double startAngle,
    double sweepAngle,
    bool forceMoveTo,
  ) {
    _note([
      'A',
      rect.left,
      rect.top,
      rect.right,
      rect.bottom,
      startAngle,
      sweepAngle,
      forceMoveTo ? 1 : 0,
    ]);
    _path.arcTo(rect, startAngle, sweepAngle, forceMoveTo);
  }

  void arcToPoint(
    ui.Offset arcEnd, {
    ui.Radius radius = ui.Radius.zero,
    double rotation = 0.0,
    bool largeArc = false,
    bool clockwise = true,
  }) {
    _note([
      'AP',
      arcEnd.dx,
      arcEnd.dy,
      radius.x,
      radius.y,
      rotation,
      largeArc ? 1 : 0,
      clockwise ? 1 : 0,
    ]);
    _path.arcToPoint(
      arcEnd,
      radius: radius,
      rotation: rotation,
      largeArc: largeArc,
      clockwise: clockwise,
    );
  }

  void addRect(ui.Rect rect) {
    _note(['R', rect.left, rect.top, rect.right, rect.bottom]);
    _path.addRect(rect);
  }

  void addOval(ui.Rect oval) {
    _note(['O', oval.left, oval.top, oval.right, oval.bottom]);
    _path.addOval(oval);
  }

  void addArc(ui.Rect oval, double startAngle, double sweepAngle) {
    _note([
      'AA',
      oval.left,
      oval.top,
      oval.right,
      oval.bottom,
      startAngle,
      sweepAngle,
    ]);
    _path.addArc(oval, startAngle, sweepAngle);
  }

  void addPolygon(List<ui.Offset> points, bool close) {
    _note([
      'PG',
      close ? 1 : 0,
      [
        for (final p in points) ...[p.dx, p.dy],
      ],
    ]);
    _path.addPolygon(points, close);
  }

  void addRRect(ui.RRect r) {
    _note([
      'RR',
      r.left,
      r.top,
      r.right,
      r.bottom,
      r.tlRadiusX,
      r.tlRadiusY,
      r.trRadiusX,
      r.trRadiusY,
      r.brRadiusX,
      r.brRadiusY,
      r.blRadiusX,
      r.blRadiusY,
    ]);
    _path.addRRect(r);
  }

  void close() {
    _note(['Z']);
    _path.close();
  }

  void reset() {
    _moves[_path]?.clear();
    _path.reset();
  }
}

/// Set by the pack builder while it records.
bool recordPaths = false;

final Expando<List<List<Object?>>> _moves = Expando();

/// How [path] was built, if it was built by a figure while recording.
List<List<Object?>>? pathMoves(ui.Path path) => _moves[path];
