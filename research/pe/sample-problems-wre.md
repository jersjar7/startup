# Sample PE Civil WRE problems (DRAFT, for Jerson's review)

Six original problems in the FE for Raccoons format, one per heavy topic, to
show what a PE product would look like and to double as study material. Every
answer and every wrong choice was computed in Python, and each wrong choice is
a real mistake a candidate makes. Handbook section numbers are left as
**TO CHECK**: they need the current NCEES PE Civil Reference Handbook open,
and we only point to the handbook. We never copy from it.

These are easier than real PE depth questions on purpose: they are format
samples. Real product questions need more steps and a licensed PE's review
(see product-proposal.md).

---

## 1. Hydrology: rational method with a composite C

A 12-acre site is 40% paved (C = 0.90) and 60% lawn (C = 0.25). The design
rainfall intensity for the time of concentration is 3.2 in/hr. Using the
rational method, the peak runoff is most nearly:

- A. 9.6 cfs
- **B. 19.6 cfs**
- C. 22.1 cfs
- D. 34.6 cfs

**Solution.** Weight C by area: C = 0.40(0.90) + 0.60(0.25) = 0.51.
Q = CiA = 0.51 x 3.2 x 12 = 19.6 cfs (1 acre-in/hr is about 1 cfs).

**Why the wrong answers are tempting.** A uses only the lawn C. C averages the
two C values without weighting by area. D uses only the paved C.

Handbook: Hydrology, rational method (section TO CHECK).

---

## 2. Open channel: Manning's equation

A rectangular concrete channel (n = 0.013) is 6 ft wide on a slope of 0.002
ft/ft and flows 2 ft deep at uniform flow. The flow is most nearly:

- A. 46.6 cfs
- **B. 69.5 cfs**
- C. 73.8 cfs
- D. 80.6 cfs

**Solution.** A = 6 x 2 = 12 ft2. Wetted perimeter P = 6 + 2(2) = 10 ft.
R = A/P = 1.2 ft. Q = (1.49/n) A R^(2/3) S^(1/2) = (1.49/0.013)(12)(1.2)^(2/3)(0.002)^(1/2) = 69.5 cfs.

**Why the wrong answers are tempting.** A uses the SI constant 1.0 instead of
1.49. C forgets the 2/3 power on R. D counts only one wall in the wetted
perimeter (P = b + y).

Handbook: Hydraulics, open channel, Manning's equation (section TO CHECK).

---

## 3. Closed conduit: Hazen-Williams head loss

Water flows at 3.0 cfs through 2,000 ft of 12-in pipe with a Hazen-Williams C
of 120. The friction head loss is most nearly:

- A. 5.1 ft
- B. 5.9 ft
- **C. 10.2 ft**
- D. 14.3 ft

**Solution.** In US units, h_f = 4.73 L Q^1.852 / (C^1.852 D^4.87), with Q in
cfs and D in ft. h_f = 4.73(2000)(3.0)^1.852 / ((120)^1.852 (1.0)^4.87) = 10.2 ft.

**Why the wrong answers are tempting.** A computes the loss per 1,000 ft and
stops. B squares Q and C, as in Darcy-Weisbach. D uses C = 100, the value for
older cast iron.

Handbook: Hydraulics, closed conduit, Hazen-Williams (section TO CHECK).

---

## 4. Groundwater: Thiem equation, confined aquifer

A well pumps 500 gpm at steady state from a confined aquifer with a
transmissivity of 1,500 ft2/day. The difference in drawdown between observation
wells 50 ft and 500 ft from the pumping well is most nearly:

- A. 10.2 ft
- **B. 23.5 ft**
- C. 47.0 ft
- D. 148 ft

**Solution.** Q = 500 gpm x 0.13368 ft3/gal x 1,440 min/day = 96,250 ft3/day.
s1 - s2 = Q/(2 pi T) x ln(r2/r1) = 96,250 / (2 pi x 1,500) x ln(10) = 23.5 ft.

**Why the wrong answers are tempting.** A uses log base 10 instead of the
natural log. C drops the 2 from 2 pi. D drops the 2 pi altogether.

Handbook: Groundwater and wells, Thiem equation (section TO CHECK).

---

## 5. Water quality: mixing a discharge into a stream

A stream carrying 20 cfs with an ultimate BOD of 2 mg/L receives 3 cfs of
treated effluent with an ultimate BOD of 30 mg/L. Assuming complete mixing, the
BOD just downstream is most nearly:

- A. 3.9 mg/L
- **B. 5.7 mg/L**
- C. 6.5 mg/L
- D. 16 mg/L

**Solution.** By mass balance, C = (Q1 C1 + Q2 C2)/(Q1 + Q2) =
(20 x 2 + 3 x 30)/23 = 5.7 mg/L.

**Why the wrong answers are tempting.** C divides by the stream flow alone and
forgets the effluent adds water. D averages the two concentrations without
weighting by flow. A leaves out the BOD the stream already carried.

Handbook: Environmental, mass balance and mixing (section TO CHECK).

---

## 6. Wastewater: primary clarifier sizing

A circular primary clarifier must treat an average flow of 4.0 MGD at a
surface overflow rate of 1,000 gpd/ft2. The required diameter is most nearly:

- A. 36 ft
- **B. 71 ft**
- C. 80 ft
- D. 113 ft

**Solution.** Area = Q / SOR = 4,000,000 / 1,000 = 4,000 ft2.
D = sqrt(4A/pi) = sqrt(4 x 4,000 / pi) = 71.4 ft.

**Why the wrong answers are tempting.** A solves for the radius and stops. C
uses 800 gpd/ft2, a common design value for a different case. D sizes for a
2.5x peak flow when the problem gives the average-flow rate.

Handbook: Wastewater treatment, sedimentation (section TO CHECK). Design
overflow rates also appear in the Ten States Standards (Wastewater), one of the
supplied documents.

---

## What these show

- The FE for Raccoons format carries over: one problem, choices whose wrong
  answers teach something, a short worked solution, a pointer to the handbook.
- Real PE depth questions need more steps than these (pump plus system curve,
  multi-stage treatment, hydrograph routing). Writing them costs more than
  writing FE problems, and they need a licensed PE's review before anyone pays
  for them.
