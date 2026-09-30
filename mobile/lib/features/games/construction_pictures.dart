// The pictures on the Construction Engineering concept sheets.
//
// A sheet is read picture first (owner's call, 2026-09-30): the drawing the
// student just played with, with one thing happening in it, then the idea in
// short steps, then the rule. Built from the same painters the games draw
// with; see mechanics_pictures.dart for the pattern and the shared
// ConceptPicture and ConceptPair tiles.
//
// Every painter in this chapter writes its own captions along the bottom
// edge of the panel, so the drawings are stacked at full width rather than
// paired side by side: at half width those captions clip.

import 'package:flutter/material.dart';

import 'cpm_figures.dart';
import 'delivery_figures.dart';
import 'earned_value_figures.dart';
import 'mechanics_pictures.dart' show ConceptPicture;
import 'safety_figures.dart';

// ---------------------------------------------------------------------------
// The networks, matching the ones the games hand out.

/// A branch and a merge: the shape the forward pass is taught on.
const _fourTask = Network(
  tasks: [
    Task(name: 'A', days: 4),
    Task(name: 'B', days: 6, after: ['A']),
    Task(name: 'C', days: 3, after: ['A']),
    Task(name: 'D', days: 2, after: ['B', 'C']),
  ],
);

/// The same network with the short branch lengthened until it governs, so
/// the longest route moves from B to C without the drawing changing shape.
const _flipped = Network(
  tasks: [
    Task(name: 'A', days: 4),
    Task(name: 'B', days: 6, after: ['A']),
    Task(name: 'C', days: 9, after: ['A']),
    Task(name: 'D', days: 2, after: ['B', 'C']),
  ],
);

/// The five activity network the passes, float and critical path items all
/// use. C carries five days of total float; A, B and D carry none.
const _fiveTask = Network(
  tasks: [
    Task(name: 'A', days: 3),
    Task(name: 'B', days: 4, after: ['A']),
    Task(name: 'C', days: 2, after: ['A']),
    Task(name: 'D', days: 6, after: ['B']),
    Task(name: 'E', days: 3, after: ['B', 'C']),
  ],
);

/// Three routes from one start: fifteen days through B and D, twelve through
/// C and D, ten through C and E.
const _threePaths = Network(
  tasks: [
    Task(name: 'A', days: 4),
    Task(name: 'B', days: 6, after: ['A']),
    Task(name: 'C', days: 3, after: ['A']),
    Task(name: 'D', days: 5, after: ['B', 'C']),
    Task(name: 'E', days: 3, after: ['C']),
  ],
);

// ---------------------------------------------------------------------------
// Scheduling

Widget forwardPassPicture() => const ConceptPicture(
  painter: NetworkPainter(
    network: _fourTask,
    showLate: false,
    markCritical: false,
    answered: true,
  ),
  caption:
      'four jobs and what waits on what. D waits on B and C, so it starts '
      'the day the later of the two finishes',
  height: 230,
);

Widget projectDurationPicture() => const Column(
  children: [
    ConceptPicture(
      painter: NetworkPainter(network: _fourTask, showLate: false),
      caption: 'the long way round is A, B, D: twelve days',
      height: 215,
    ),
    SizedBox(height: 12),
    ConceptPicture(
      painter: NetworkPainter(network: _flipped, showLate: false),
      caption:
          'the same drawing with C stretched to nine days. now C is the long '
          'way round, and the job takes fifteen',
      height: 215,
    ),
  ],
);

Widget passesPicture() => const Column(
  children: [
    ConceptPicture(
      painter: NetworkPainter(
        network: _fiveTask,
        showLate: false,
        markCritical: false,
        answered: true,
      ),
      caption: 'going forward: the earliest each job can happen, in blue',
      height: 215,
    ),
    SizedBox(height: 12),
    ConceptPicture(
      painter: NetworkPainter(network: _fiveTask, markCritical: false),
      caption:
          'coming back: the latest it can happen without the job finishing '
          'late, in green',
      height: 215,
    ),
  ],
);

Widget floatPicture() => const ConceptPicture(
  painter: NetworkPainter(network: _fiveTask, highlight: 'C'),
  caption:
      'C is marked. it can start on day 3 or wait until day 8, so it has '
      'five days of room. the marked chain has none',
  height: 235,
);

Widget criticalPathPicture() => const ConceptPicture(
  painter: NetworkPainter(network: _threePaths, showLate: false),
  caption:
      'three ways through. the marked one is the longest, and it is the one '
      'with no room anywhere along it',
  height: 235,
);

// ---------------------------------------------------------------------------
// Earned value

/// Week ten of a job: 500k was planned by now, 420k of work is done, and
/// 480k has gone out of the door.
const _weekTen = Progress(planned: 500000, earned: 420000, actual: 480000);

/// The same job with a budget, running at eighty cents on the dollar.
const _overspending = Progress(
  planned: 700000,
  earned: 600000,
  actual: 750000,
  budget: 2000000,
);

Widget earnedValuePicture() => const ConceptPicture(
  painter: ValuePainter(progress: _weekTen, answered: true),
  caption:
      'one date, three bars: what was planned, what got done, what was '
      'spent. both gaps are measured from the middle bar',
  height: 215,
);

Widget forecastPicture() => const ConceptPicture(
  painter: ForecastPainter(progress: _overspending, answered: true),
  caption:
      'the whole budget as one bar, with what has been spent and what that '
      'money bought. the forecast runs past the end of it',
  height: 215,
);

// ---------------------------------------------------------------------------
// Safety

Widget excavationPicture() => const Column(
  children: [
    ConceptPicture(
      painter: TrenchPainter(trench: Trench(depth: 4), answered: true),
      caption: 'four feet down: the rule has not started yet',
      height: 185,
    ),
    SizedBox(height: 12),
    ConceptPicture(
      painter: TrenchPainter(trench: Trench(depth: 7), answered: true),
      caption: 'seven feet down, with nothing holding the sides back',
      height: 185,
    ),
  ],
);

Widget fallProtectionPicture() => const Column(
  children: [
    ConceptPicture(
      painter: HeightPainter(work: Working(height: 5), answered: true),
      caption: 'five feet up: under the line',
      height: 185,
    ),
    SizedBox(height: 12),
    ConceptPicture(
      painter: HeightPainter(work: Working(height: 8), answered: true),
      caption: 'eight feet up: over it, so something has to be in place',
      height: 185,
    ),
  ],
);

// ---------------------------------------------------------------------------
// Delivery

Widget deliveryFitPicture() => const Column(
  children: [
    ConceptPicture(
      painter: ScheduleShapePainter(
        method: Deliver.designBidBuild,
        answered: true,
      ),
      caption: 'drawing finishes, then bidding, then building. nothing shares',
      height: 165,
    ),
    SizedBox(height: 12),
    ConceptPicture(
      painter: ScheduleShapePainter(
        method: Deliver.designBuild,
        answered: true,
      ),
      caption: 'one firm does both, so building starts on a part drawn job',
      height: 165,
    ),
    SizedBox(height: 12),
    ConceptPicture(
      painter: ScheduleShapePainter(
        method: Deliver.managerAtRisk,
        answered: true,
      ),
      caption: 'the builder joins during drawing and names a ceiling price',
      height: 165,
    ),
  ],
);

/// Every picture on this chapter's sheets, by the contact sheet's card name.
const constructionPictures = <String, Widget Function()>{
  'forward': forwardPassPicture,
  'duration': projectDurationPicture,
  'passes': passesPicture,
  'float': floatPicture,
  'critical': criticalPathPicture,
  'variances': earnedValuePicture,
  'forecast': forecastPicture,
  'trench': excavationPicture,
  'height': fallProtectionPicture,
  'fit': deliveryFitPicture,
};
