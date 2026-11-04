// Writes mobile/rive/lesson_node/scene.rml: the lesson node as an isometric
// platform (mobile/design/road/ROAD.md). The scene is generated so the
// curves of the rise and the bounce are sampled from the same formulas as
// AppRoad in lib/core/theme/road.dart. Run from mobile/:
//
//   node rive/build_lesson_node.mjs && rive rive/lesson_node --once
import { writeFileSync } from 'node:fs';

const out = new URL('./lesson_node/scene.rml', import.meta.url);
const f = (v) => +v.toFixed(4);

// Geometry, artboard units: the face is 100 across.
const K = 0.5;
const W = 124, H = 100;
const CX = 62, FY = 39; // the face centre
const D0 = 100 / 6; // the plinth at the default depth (size / 6)
const O = D0 / 2; // scale origin below the face centre: the middle of the side
const P = 8; // how far a press sinks the face
const T = 11; // ring thickness: 0.22 of the face radius (road.mjs)
const RING = 100 - T; // ring centre-line diameter
const SQ = 72, SQR = 20.16; // the not-built square and its corners
const LIFT = 4 * 100 / 84; // 4 pt at the phone's 84 pt face
const FRAMES = 18; // 300 ms at 60 fps

// The exact curves of AppRoad in road.dart.
const riseScale = (t) => { const c = 1.7, u = t - 1; return 0.95 + 0.05 * (1 + (c + 1) * u ** 3 + c * u * u); };
const riseLift = (t) => 4 * Math.sin(Math.PI * t);
const arriveBounce = (t) => 1 + 0.05 * Math.sin(Math.PI * t) * (1 - t * 0.3) / 0.855304; // peaks at 1.05 (road.dart)

const kf = (obj, key, frames) => `            <KeyedObject objectId="${obj}">
                <KeyedProperty propertyKey="${key}">
${frames.map(([fr, v, ease]) => ease
    ? `                    <KeyFrameDouble value="${f(v)}" frame="${fr}" interpolationType="cubic">
                        <CubicEaseInterpolator x1="${ease[0]}" y1="${ease[1]}" x2="${ease[2]}" y2="${ease[3]}"/>
                    </KeyFrameDouble>`
    : `                    <KeyFrameDouble value="${f(v)}" frame="${fr}"/>`).join('\n')}
                </KeyedProperty>
            </KeyedObject>`;
const hold = (obj, key, v) => kf(obj, key, [[0, v]]);
const anim = (id, name, duration, body, extra = '') =>
  `        <LinearAnimation ${extra}duration="${duration}" name="${name}" id="${id}">\n${body.join('\n')}\n        </LinearAnimation>`;

// Object ids.
const id = {
  ahead: '0:15', arrive: '0:16', breath: '0:17', platform: '0:18',
  press: '0:20', pop: '0:24', tilt: '0:26', haloTilt: '0:27', halo: '0:22',
  check: '0:46', dots: '0:48', wedgeGroup: '0:38', rim: '0:34', rimPath: '0:35',
  face: '0:30', facePath: '0:31',
  sideTop: '0:50', sideTopPath: '0:51', foot: '0:52', sideBottom: '0:54', sideBottomPath: '0:55',
  footTilt: '0:56', footShape: '0:57', footPath: '0:58',
};
const vm = {
  state: '0:102', progress: '0:103', pressed: '0:104', celebrate: '0:105', face: '0:106', plinth: '0:107',
  rim: '0:108', wedge: '0:109', ink: '0:110', halo: '0:111', current: '0:112', ahead: '0:113', arrive: '0:114', depth: '0:115',
};
const bind = (p, key, conv) => `<DataBindContext sourcePathIds="0:100-${p}" propertyKey="${key}"${conv ? ` converterId="${conv}"` : ''}/>`;
const plinthFill = `<Fill name="Fill">
                        <SolidColor colorValue="FFCDBFA8" name="Plinth">
                            ${bind(vm.plinth, 37)}
                        </SolidColor>
                    </Fill>`;

// One hold pose per state: face size and corners, the ring, the glyphs.
const pose = (w, r, { rim = 0, check = 0, dots = 0, wedge = 0 }) => {
  const s = w / 100;
  return [
    hold(id.facePath, 20, w), hold(id.facePath, 21, w), hold(id.facePath, 31, r),
    hold(id.footPath, 20, w), hold(id.footPath, 21, w), hold(id.footPath, 31, r),
    hold(id.sideTopPath, 20, w), hold(id.sideBottomPath, 20, w),
    hold(id.rimPath, 20, RING * s), hold(id.rimPath, 21, RING * s), hold(id.rimPath, 31, r * RING / 100),
    hold(id.rim, 18, rim), hold(id.check, 18, check), hold(id.dots, 18, dots), hold(id.wedgeGroup, 18, wedge),
  ];
};

const ease = [0.42, 0, 0.58, 1];
const sampled = (fn) => Array.from({ length: FRAMES + 1 }, (_, i) => [i, fn(i / FRAMES)]);

const animations = [
  anim('0:60', 'NotBuilt', 1, pose(SQ, SQR, { dots: 1 })),
  anim('0:61', 'NotStarted', 1, pose(100, 50, {})),
  anim('0:62', 'InProgress', 1, pose(100, 50, { rim: 1, wedge: 1 })),
  anim('0:63', 'Cleared', 1, pose(100, 50, { check: 1 })),
  anim('0:64', 'PressUp', 1, [hold(id.press, 14, 0)]),
  anim('0:65', 'PressDown', 1, [hold(id.press, 14, P)]),
  anim('0:68', 'Still', 1, [hold(id.breath, 16, 1), hold(id.breath, 17, 1)]),
  anim('0:69', 'Breathing', 78, [
    kf(id.breath, 16, [[0, 1, ease], [78, 1.035]]),
    kf(id.breath, 17, [[0, 1, ease], [78, 1.035]]),
  ], 'loopValue="pingPong" '),
  anim('0:66', 'Idle', 1, [hold(id.pop, 16, 1), hold(id.pop, 17, 1), hold(id.halo, 16, 1), hold(id.halo, 17, 1), hold(id.halo, 18, 0)]),
  anim('0:67', 'Celebrate', 40, [
    kf(id.pop, 16, [[0, 1, [0, 0, 0.58, 1]], [9, 1.09, ease], [22, 0.985, ease], [40, 1]]),
    kf(id.pop, 17, [[0, 1, [0, 0, 0.58, 1]], [9, 1.09, ease], [22, 0.985, ease], [40, 1]]),
    kf(id.halo, 16, [[0, 1, [0, 0, 0.58, 1]], [40, 1.42]]),
    kf(id.halo, 17, [[0, 1, [0, 0, 0.58, 1]], [40, 1.42]]),
    kf(id.halo, 18, [[0, 0.55, [0, 0, 0.58, 1]], [40, 0]]),
  ]),
  // ahead: rests at 95%; rises to 100% with a lift, easing out past it.
  anim('0:90', 'Up', 1, [hold(id.ahead, 16, 1), hold(id.ahead, 17, 1), hold(id.ahead, 14, FY + O)]),
  anim('0:91', 'Ahead', 1, [hold(id.ahead, 16, 0.95), hold(id.ahead, 17, 0.95), hold(id.ahead, 14, FY + O)]),
  anim('0:92', 'Rise', FRAMES, [
    kf(id.ahead, 16, sampled(riseScale)),
    kf(id.ahead, 17, sampled(riseScale)),
    kf(id.ahead, 14, sampled((t) => FY + O - riseLift(t) * 100 / 84)),
  ]),
  // arrive: one bounce to 105% and back.
  anim('0:93', 'Rest', 1, [hold(id.arrive, 16, 1), hold(id.arrive, 17, 1)]),
  anim('0:94', 'Bounce', FRAMES, [kf(id.arrive, 16, sampled(arriveBounce)), kf(id.arrive, 17, sampled(arriveBounce))]),
];

const cond = (prop, kind, value) => {
  const comp = {
    enum: [`BindablePropertyEnum`, 637, `<TransitionValueEnumComparator value="${value}"/>`],
    bool: [`BindablePropertyBoolean`, 634, `<TransitionValueBooleanComparator value="${value}"/>`],
    trigger: [`BindablePropertyTrigger`, 686, `<TransitionValueTriggerComparator/>`],
  }[kind];
  return `                    <TransitionViewModelCondition opValue="equal">
                        <TransitionPropertyViewModelComparator>
                            <${comp[0]}>
                                ${bind(prop, comp[1])}
                            </${comp[0]}>
                        </TransitionPropertyViewModelComparator>
                        ${comp[2]}
                    </TransitionViewModelCondition>`;
};
const tr = (to, ms, c, interp = true) => `                <StateTransition stateToId="${to}" duration="${ms}"${interp && ms ? ' interpolationType="cubic"' : ''}>
${interp && ms ? '                    <CubicEaseInterpolator x1="0" y1="0" x2="0.58" y2="1"/>\n' : ''}${c}
                </StateTransition>`;
const exitTr = (to) => `                <StateTransition stateToId="${to}" duration="0" enableExitTime="true" exitTimeIsPercetange="true" exitTime="100"/>`;
const st = (animId, x, sid, body, reset = false) => `                <AnimationState animationId="${animId}"${reset ? ' reset="true"' : ''} x="${x}" y="0" id="${sid}">
${body.join('\n')}
                </AnimationState>`;
const layer = (name, lid, entry, states) => `            <StateMachineLayer name="${name}" id="${lid}">
                <AnyState x="640" y="-120"/>
                <ExitState x="760" y="-120"/>
                <EntryState x="0" y="16">
                    <StateTransition stateToId="${entry}"/>
                </EntryState>
${states.join('\n')}
            </StateMachineLayer>`;

const states = [['0:80', '0:60', '0:121'], ['0:81', '0:61', '0:122'], ['0:82', '0:62', '0:123'], ['0:83', '0:63', '0:124']];
const stateLayer = layer('State', '0:71', '0:81', states.map(([sid, aid], i) => st(aid, 160 * (i + 1), sid,
  states.filter(([o]) => o !== sid).map(([o, , ev]) => tr(o, 0, cond(vm.state, 'enum', ev))))));
const pressLayer = layer('Press', '0:72', '0:84', [
  st('0:64', 160, '0:84', [tr('0:85', 90, cond(vm.pressed, 'bool', 'true'))]),
  st('0:65', 320, '0:85', [tr('0:84', 90, cond(vm.pressed, 'bool', 'false'))]),
]);
const breatheLayer = layer('Breathe', '0:74', '0:88', [
  st('0:68', 160, '0:88', [tr('0:89', 300, cond(vm.current, 'bool', 'true'))]),
  st('0:69', 320, '0:89', [tr('0:88', 300, cond(vm.current, 'bool', 'false'))], true),
]);
const clearLayer = layer('Clear', '0:73', '0:86', [
  st('0:66', 160, '0:86', [tr('0:87', 0, cond(vm.celebrate, 'trigger'))]),
  st('0:67', 320, '0:87', [exitTr('0:86')], true),
]);
// Ahead: a platform the road has not reached waits at 95%. Arriving at it
// (ahead turns false) plays the rise once; turning ahead on is immediate,
// so a map opened with platforms ahead never animates them on arrival.
const aheadLayer = layer('Ahead', '0:75', '0:95', [
  st('0:90', 160, '0:95', [tr('0:96', 0, cond(vm.ahead, 'bool', 'true'), false)]),
  st('0:91', 320, '0:96', [tr('0:97', 0, cond(vm.ahead, 'bool', 'false'), false)]),
  st('0:92', 480, '0:97', [tr('0:96', 0, cond(vm.ahead, 'bool', 'true'), false), exitTr('0:95')], true),
]);
const arriveLayer = layer('Arrive', '0:76', '0:98', [
  st('0:93', 160, '0:98', [tr('0:99', 0, cond(vm.arrive, 'trigger'))]),
  st('0:94', 320, '0:99', [exitTr('0:98')], true),
]);

const rml = `<Rive version="1" kind="fragment">
    <!--
        One lesson node on the chapter path, drawn as an isometric platform
        (mobile/design/road/ROAD.md, owner 2026-11-03). Generated: the
        numbers below come from road.mjs and road.dart, so edit those first.

        The app owns every decision: which of the four states the node is in,
        how far the arc has filled, whether a finger is on it, whether the
        walked road has reached it yet, and when the finished moment and the
        arrival fire. This file only decides how each of those looks and
        moves. The contract is the LessonNode view model at the bottom;
        docs/mobile/lesson-node-rive.md explains it.

        Geometry, in units where the face is 100 across: the face is the
        node circle squashed to half height (K = 0.5), 100 by 50, centred at
        (${CX}, ${FY}). It stands on a plinth \`depth\` tall (default 100/6, so a
        84 pt node has the phone's 14 pt plinth); the foot is the face's
        ellipse moved straight down by the depth. Everything on the face is
        drawn in a node squashed to half height, so the ring and the check
        are foreshortened the way the face is.

        Nesting, outermost first: Ahead (the 95% rest and the rise) > Arrive
        (the bounce) > Breath (the current lesson) > the platform. All three
        scale about the middle of the side, ${f(O)} below the face centre.
        First child draws on top.
    -->
    <Artboard defaultStateMachineId="0:70" viewModelId="0:100" viewModelInstanceId="0:101"
              width="${W}" height="${H}" styleId="0:3" name="LessonNode" id="0:2">
        <LayoutComponentStyle name="Artboard Style" id="0:3"/>

        <Node x="${CX}" y="${f(FY + O)}" name="Ahead" id="${id.ahead}">
            <Node x="0" y="0" name="Arrive" id="${id.arrive}">
                <Node x="0" y="0" name="Breath" id="${id.breath}">
                    <!-- The platform, with its origin on the face centre. -->
                    <Node x="0" y="${f(-O)}" name="Platform" id="${id.platform}">

                        <!-- Everything that sinks when pressed: the face and the top of the side. -->
                        <Node x="0" y="0" name="Press" id="${id.press}">

                            <!-- Everything that pops when the lesson is finished. -->
                            <Node x="0" y="0" name="Pop" id="${id.pop}">
                                <!-- The face's plane: the circle squashed to half height. -->
                                <Node x="0" y="0" scaleY="${K}" name="Tilt" id="${id.tilt}">

                                    <!-- The finished check, road.mjs's path at this face's size. -->
                                    <Shape x="0" y="0" opacity="0" name="Check" id="${id.check}">
                                        <PointsPath isClosed="false" name="Path">
                                            <StraightVertex x="${f(-15 * 50 / 42)}" y="${f(1 * 50 / 42)}"/>
                                            <StraightVertex x="${f(-6 * 50 / 42)}" y="${f(10 * 50 / 42)}"/>
                                            <StraightVertex x="${f(14 * 50 / 42)}" y="${f(-10 * 50 / 42)}"/>
                                        </PointsPath>
                                        <Stroke thickness="${f(6.5 * 50 / 42)}" cap="round" join="round" name="Stroke">
                                            <SolidColor colorValue="FF63F0A8" name="Ink" id="0:47">
                                                ${bind(vm.ink, 37)}
                                            </SolidColor>
                                        </Stroke>
                                    </Shape>

                                    <!-- The "not written yet" ellipsis. -->
                                    <Shape x="0" y="0" opacity="0" name="Dots" id="${id.dots}">
                                        <Ellipse x="-6.1" y="0" width="4.1" height="4.1" name="L"/>
                                        <Ellipse x="0" y="0" width="4.1" height="4.1" name="M"/>
                                        <Ellipse x="6.1" y="0" width="4.1" height="4.1" name="R"/>
                                        <Fill name="Fill">
                                            <SolidColor colorValue="FFA79B87" name="Ink" id="0:49">
                                                ${bind(vm.ink, 37)}
                                            </SolidColor>
                                        </Fill>
                                    </Shape>

                                    <!--
                                        The progress arc: ${T} thick on a ${RING} circle, so its
                                        outer edge is the face's edge, trimmed from the top
                                        and drawn over the track below it. Butt ends, as in
                                        the approved R02.
                                    -->
                                    <Node x="0" y="0" opacity="0" name="WedgeGroup" id="${id.wedgeGroup}">
                                        <Shape x="0" y="0" name="Wedge" id="0:40">
                                            ${bind(vm.progress, 18, '0:131')}
                                            <Ellipse width="${RING}" height="${RING}" name="Path" id="0:41"/>
                                            <Stroke thickness="${T}" cap="butt" name="Stroke" id="0:42">
                                                <SolidColor colorValue="FF2C2C2C" name="Wedge" id="0:43">
                                                    ${bind(vm.wedge, 37)}
                                                </SolidColor>
                                                <TrimPath start="0" end="0.15" name="Sweep" id="0:44">
                                                    ${bind(vm.progress, 115, '0:130')}
                                                </TrimPath>
                                            </Stroke>
                                        </Shape>
                                    </Node>

                                    <!-- The spring track under the arc, shown while a lesson is underway. -->
                                    <Shape x="0" y="0" opacity="0" name="Rim" id="${id.rim}">
                                        <Rectangle width="${RING}" height="${RING}" cornerRadiusTL="${RING / 2}" name="Path" id="${id.rimPath}"/>
                                        <Stroke thickness="${T}" name="Stroke">
                                            <SolidColor colorValue="FF63F0A8" name="Rim" id="0:36">
                                                ${bind(vm.rim, 37)}
                                            </SolidColor>
                                        </Stroke>
                                    </Shape>

                                    <!-- The face. Circle or rounded square, decided by the state. -->
                                    <Shape x="0" y="0" name="Face" id="${id.face}">
                                        <Rectangle width="100" height="100" cornerRadiusTL="50" name="Path" id="${id.facePath}"/>
                                        <Fill name="Fill">
                                            <SolidColor colorValue="FFFFF9F0" name="Face" id="0:32">
                                                ${bind(vm.face, 37)}
                                            </SolidColor>
                                        </Fill>
                                    </Shape>
                                </Node>
                            </Node>

                            <!-- The top ${P} of the side, which goes down with the face. -->
                            <Shape x="0" y="0" name="SideTop" id="${id.sideTop}">
                                <Rectangle width="100" height="${P}" originY="0" name="Path" id="${id.sideTopPath}"/>
                                ${plinthFill}
                            </Shape>
                        </Node>

                        <!-- The rest of the side, ${P} down to the foot, and the foot: the face's outline \`depth\` lower. -->
                        <Shape x="0" y="${P}" name="SideBottom" id="${id.sideBottom}">
                            <Rectangle width="100" height="${f(D0 - P)}" originY="0" name="Path" id="${id.sideBottomPath}">
                                ${bind(vm.depth, 21, '0:132')}
                            </Rectangle>
                            ${plinthFill}
                        </Shape>
                        <Node x="0" y="${f(D0)}" name="Foot" id="${id.foot}">
                            ${bind(vm.depth, 14)}
                            <Node x="0" y="0" scaleY="${K}" name="FootTilt" id="${id.footTilt}">
                                <Shape x="0" y="0" name="FootShape" id="${id.footShape}">
                                    <Rectangle width="100" height="100" cornerRadiusTL="50" name="Path" id="${id.footPath}"/>
                                    ${plinthFill}
                                </Shape>
                            </Node>
                        </Node>

                            <!-- The halo that leaves the face at the finished moment, on the face's plane. Drawn under the platform, so it never crosses the plinth. -->
                            <Node x="0" y="0" scaleY="${K}" name="HaloTilt" id="${id.haloTilt}">
                                <Shape x="0" y="0" opacity="0" name="Halo" id="${id.halo}">
                                    <Ellipse width="100" height="100" name="Path" id="0:23"/>
                                    <Stroke thickness="3" name="Stroke">
                                        <SolidColor colorValue="FF63F0A8" name="Halo" id="0:25">
                                            ${bind(vm.halo, 37)}
                                        </SolidColor>
                                    </Stroke>
                                </Shape>
                            </Node>
                    </Node>
                </Node>
            </Node>
        </Node>

        <!-- ================= Animations ================= -->
${animations.join('\n')}

        <!-- ================= State machine ================= -->
        <StateMachine name="Node" id="0:70">
${[stateLayer, pressLayer, breatheLayer, clearLayer, aheadLayer, arriveLayer].join('\n')}
        </StateMachine>
    </Artboard>

    <!--
        progress 0..1 -> trim end, as a fraction of the circle. Equal input and
        output ranges make this a clamp, not a remap: a tenth stays a tenth,
        but the arc is never a sliver (54 degrees), so "barely started" is
        readable. It does close at 1: the app holds the closed circle for a
        beat before turning the node over, and that is the finishing moment.
    -->
    <DataConverterRangeMapper minInput="0.15" maxInput="1" minOutput="0.15" maxOutput="1"
                              clampLower="true" clampUpper="true" name="ToSweep" id="0:130"/>
    <!-- progress 0 hides the arc entirely; anything past a whisker shows it. -->
    <DataConverterRangeMapper minInput="0" maxInput="0.02" minOutput="0" maxOutput="1"
                              clampLower="true" clampUpper="true" name="ToVisible" id="0:131"/>
    <!-- depth -> the height of the side below the part that sinks with a press. -->
    <DataConverterOperationValue operationType="subtract" operationValue="${P}" name="BelowPress" id="0:132"/>

    <DataEnumCustom name="NodeState" id="0:120">
        <DataEnumValue key="notBuilt" value="Not built" id="0:121"/>
        <DataEnumValue key="notStarted" value="Not started" id="0:122"/>
        <DataEnumValue key="inProgress" value="In progress" id="0:123"/>
        <DataEnumValue key="cleared" value="Cleared" id="0:124"/>
    </DataEnumCustom>

    <!--
        The contract with the app. Names are the public surface; the app sets
        these by name and nothing else in this file is reachable from outside.
    -->
    <ViewModel defaultInstanceId="0:101" name="LessonNode" id="0:100">
        <ViewModelPropertyEnumCustom enumId="0:120" name="state" id="${vm.state}"/>
        <ViewModelPropertyNumber name="progress" id="${vm.progress}"/>
        <ViewModelPropertyBoolean name="pressed" id="${vm.pressed}"/>
        <ViewModelPropertyTrigger name="celebrate" id="${vm.celebrate}"/>
        <ViewModelPropertyColor name="face" id="${vm.face}"/>
        <ViewModelPropertyColor name="plinth" id="${vm.plinth}"/>
        <ViewModelPropertyColor name="rim" id="${vm.rim}"/>
        <ViewModelPropertyColor name="wedge" id="${vm.wedge}"/>
        <ViewModelPropertyColor name="ink" id="${vm.ink}"/>
        <ViewModelPropertyColor name="halo" id="${vm.halo}"/>
        <ViewModelPropertyBoolean name="current" id="${vm.current}"/>
        <ViewModelPropertyBoolean name="ahead" id="${vm.ahead}"/>
        <ViewModelPropertyTrigger name="arrive" id="${vm.arrive}"/>
        <ViewModelPropertyNumber name="depth" id="${vm.depth}"/>
        <ViewModelInstance exports="true" name="Default" id="0:101">
            <ViewModelInstanceEnum propertyValue="0:122" viewModelPropertyId="${vm.state}"/>
            <ViewModelInstanceNumber propertyValue="0" viewModelPropertyId="${vm.progress}"/>
            <ViewModelInstanceBoolean propertyValue="false" viewModelPropertyId="${vm.pressed}"/>
            <ViewModelInstanceTrigger viewModelPropertyId="${vm.celebrate}"/>
            <ViewModelInstanceColor propertyValue="FFFFF9F0" viewModelPropertyId="${vm.face}"/>
            <ViewModelInstanceColor propertyValue="FFCDBFA8" viewModelPropertyId="${vm.plinth}"/>
            <ViewModelInstanceColor propertyValue="FF63F0A8" viewModelPropertyId="${vm.rim}"/>
            <ViewModelInstanceColor propertyValue="FF2C2C2C" viewModelPropertyId="${vm.wedge}"/>
            <ViewModelInstanceColor propertyValue="FF63F0A8" viewModelPropertyId="${vm.ink}"/>
            <ViewModelInstanceColor propertyValue="FF63F0A8" viewModelPropertyId="${vm.halo}"/>
            <ViewModelInstanceBoolean propertyValue="false" viewModelPropertyId="${vm.current}"/>
            <ViewModelInstanceBoolean propertyValue="false" viewModelPropertyId="${vm.ahead}"/>
            <ViewModelInstanceTrigger viewModelPropertyId="${vm.arrive}"/>
            <ViewModelInstanceNumber propertyValue="${f(D0)}" viewModelPropertyId="${vm.depth}"/>
        </ViewModelInstance>
    </ViewModel>
</Rive>
`;
writeFileSync(out, rml);
console.log('wrote', out.pathname);
