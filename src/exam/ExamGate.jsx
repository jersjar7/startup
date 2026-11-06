import React from 'react';
import { useNavigate, useSearchParams } from 'react-router-dom';
import { useDocumentTitle } from '../hooks/useDocumentTitle';
import {
  Timer,
  Exam,
  CheckCircle,
  ArrowRight,
  ArrowLeft,
  Lightning,
  ClockCountdown,
  ListChecks,
  ChartBar,
  MagnifyingGlass,
  Heart,
  GraduationCap,
  UsersThree,
} from '@phosphor-icons/react';
import './exam.css';
import { isStudentEmail, STUDENT_PRICE, STANDARD_PRICE } from '../data/pricing';
import { PROBLEM_COUNT_LABEL } from '../data/contentStats';

export function ExamGate({ userName }) {
  const navigate = useNavigate();
  const [searchParams] = useSearchParams();
  useDocumentTitle('Exam Simulation');

  const [purchased, setPurchased] = React.useState(null);
  const [purchaseDate, setPurchaseDate] = React.useState(null);
  const [attempts, setAttempts] = React.useState([]);
  const [loading, setLoading] = React.useState(true);
  const [checkoutLoading, setCheckoutLoading] = React.useState(false);
  const [error, setError] = React.useState('');
  const [pricing, setPricing] = React.useState(null);
  const [studentStep, setStudentStep] = React.useState('idle'); // idle | code | verified | unavailable
  const [eduEmail, setEduEmail] = React.useState('');
  const [code, setCode] = React.useState('');
  const [studentBusy, setStudentBusy] = React.useState(false);
  const [studentMsg, setStudentMsg] = React.useState('');
  // School site licence (ADR 0040), from /api/checkout/status:
  // access 'school' when their school gives it to them; schoolReason
  // 'unverified' (verify to get it) or 'seats_full' when it does not yet.
  const [access, setAccess] = React.useState(null);
  const [school, setSchool] = React.useState(null);
  const [schoolReason, setSchoolReason] = React.useState(null);
  const [buyInstead, setBuyInstead] = React.useState(false);

  React.useEffect(() => {
    if (!userName) {
      navigate('/login', { state: { returnTo: '/exam' } });
      return;
    }

    const sessionId = searchParams.get('session_id');
    const statusUrl = sessionId
      ? `/api/checkout/status?session_id=${sessionId}`
      : '/api/checkout/status';

    (async () => {
      let isPurchased = false;
      try {
        const r = await fetch(statusUrl);
        if (r.ok) {
          const data = await r.json();
          isPurchased = !!data.purchased;
          setPurchased(data.purchased);
          setPurchaseDate(data.purchaseDate);
          setAccess(data.access || null);
          setSchool(data.school || null);
          setSchoolReason(data.schoolReason || null);
        } else {
          setPurchased(false);
        }
      } catch {
        setPurchased(false);
      }
      // Attempts are purchase-gated (403 for free users), only fetch if owned.
      if (isPurchased) await loadAttempts();
      setLoading(false);
    })();
  }, [userName, navigate]);

  async function loadAttempts() {
    try {
      const r = await fetch('/api/exam/attempts');
      if (r.ok) setAttempts(await r.json());
    } catch { /* ignore */ }
  }

  // Re-check purchase status after Stripe redirect
  React.useEffect(() => {
    const sessionId = searchParams.get('session_id');
    if (sessionId && purchased === false) {
      const timer = setTimeout(() => {
        fetch(`/api/checkout/status?session_id=${sessionId}`)
          .then(r => r.ok ? r.json() : Promise.reject())
          .then(data => {
            if (data.purchased) {
              setPurchased(true);
              setPurchaseDate(data.purchaseDate);
            }
          })
          .catch(() => {});
      }, 1500);
      return () => clearTimeout(timer);
    }
  }, [searchParams, purchased]);

  // Load tiered pricing + this user's verified-student status.
  React.useEffect(() => {
    if (!userName) return;
    fetch('/api/checkout/pricing')
      .then((r) => (r.ok ? r.json() : null))
      .then((p) => {
        if (!p) return;
        setPricing(p);
        if (p.applies) setStudentStep('verified');
      })
      .catch(() => {});
  }, [userName]);

  // On the school gate, a student whose account address is already on the
  // school's domain should not have to type it again.
  React.useEffect(() => {
    if (schoolReason !== 'unverified' || !school || !userName) return;
    const mine = String(userName).toLowerCase();
    if ((school.domains || []).some((d) => mine.endsWith(`@${d}`))) setEduEmail((e) => e || mine);
  }, [schoolReason, school, userName]);

  const isEduInput = isStudentEmail(eduEmail);
  const studentApplies = !!pricing?.applies;
  const studentPrice = pricing?.student ?? STUDENT_PRICE;
  const standardPrice = pricing?.standard ?? STANDARD_PRICE;

  async function handleSendCode() {
    setStudentBusy(true);
    setStudentMsg('');
    try {
      const r = await fetch('/api/checkout/student/start', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ eduEmail: eduEmail.trim() }),
      });
      const body = await r.json().catch(() => ({}));
      if (r.status === 503) {
        setStudentStep('unavailable');
        setStudentMsg(body.msg || 'Student verification is being set up. Please check back soon.');
        return;
      }
      if (!r.ok) {
        setStudentMsg(body.msg || 'Could not send the code. Try again.');
        return;
      }
      setStudentStep('code');
    } catch {
      setStudentMsg('Network error. Please try again.');
    } finally {
      setStudentBusy(false);
    }
  }

  async function handleVerifyCode() {
    setStudentBusy(true);
    setStudentMsg('');
    try {
      const r = await fetch('/api/checkout/student/confirm', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ code: code.trim() }),
      });
      const body = await r.json().catch(() => ({}));
      if (!r.ok) {
        setStudentMsg(body.msg || 'Could not verify that code.');
        return;
      }
      setPricing((p) => ({ ...(p || {}), applies: true, studentVerified: true, verifiedStudentEmail: eduEmail.trim().toLowerCase() }));
      setStudentStep('verified');
      // The same code proves the address for a school licence: straight in.
      if (body.school) setSchool(body.school);
      setSchoolReason(body.schoolAccess ? null : (body.schoolReason || null));
      if (body.schoolAccess) {
        setAccess('school');
        setPurchased(true);
        await loadAttempts();
      }
    } catch {
      setStudentMsg('Network error. Please try again.');
    } finally {
      setStudentBusy(false);
    }
  }

  async function handleBuyNow() {
    setCheckoutLoading(true);
    setError('');
    try {
      const res = await fetch('/api/checkout/create-session', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({}),
      });
      if (!res.ok) {
        const body = await res.json();
        throw new Error(body.msg || 'Failed to start checkout');
      }
      const { url } = await res.json();
      window.location.href = url;
    } catch (err) {
      setError(err.message);
      setCheckoutLoading(false);
    }
  }

  // The emailed-code step, shared by the price gate and the school gate: the
  // one verification flow (a typed address never counts, ADR 0040).
  function renderStudentVerify({ label, placeholder = 'you@university.edu', sendLabel = 'Send my code' }) {
    return (
      <div className="exam-student-verify">
        {studentStep === 'unavailable' ? (
          <p className="exam-student-unavailable">
            {studentMsg || 'Student verification is being set up. Please check back soon.'}
          </p>
        ) : studentStep === 'code' ? (
          <>
            <label htmlFor="student-code">
              Enter the 6-digit code sent to <strong>{eduEmail.trim().toLowerCase()}</strong>:
            </label>
            <div className="exam-student-row">
              <input
                id="student-code"
                className="exam-code-input"
                inputMode="numeric"
                autoComplete="one-time-code"
                maxLength={6}
                placeholder="123456"
                value={code}
                onChange={(e) => setCode(e.target.value.replace(/\D/g, ''))}
              />
              <button
                type="button"
                className="btn-secondary exam-student-btn"
                onClick={handleVerifyCode}
                disabled={studentBusy || code.trim().length !== 6}
              >
                {studentBusy ? 'Verifying…' : 'Verify'}
              </button>
            </div>
            <button type="button" className="exam-link-btn"
              onClick={() => { setStudentStep('idle'); setCode(''); setStudentMsg(''); }}>
              Use a different email
            </button>
          </>
        ) : (
          <>
            <label htmlFor="student-email">{label}</label>
            <div className="exam-student-row">
              <input
                id="student-email"
                type="email"
                placeholder={placeholder}
                value={eduEmail}
                onChange={(e) => setEduEmail(e.target.value)}
              />
              <button
                type="button"
                className="btn-secondary exam-student-btn"
                onClick={handleSendCode}
                disabled={studentBusy || !isEduInput}
              >
                {studentBusy ? 'Sending…' : sendLabel}
              </button>
            </div>
          </>
        )}
        {studentMsg && studentStep !== 'unavailable' && (
          <p className="exam-student-msg" role="alert">{studentMsg}</p>
        )}
      </div>
    );
  }

  if (loading) {
    return (
      <main className="exam-main">
        <div className="exam-loading">Loading...</div>
      </main>
    );
  }

  // What you get, the same list whichever way in.
  const features = (
        <div className="exam-gate-features">
          <div className="exam-gate-feature">
            <Exam weight="bold" size={20} className="egf-icon egf-icon--ember" />
            <div>
              <span className="egf-label">110 questions</span>
              <span className="egf-desc">Weighted by the official NCEES topic distribution</span>
            </div>
          </div>
          <div className="exam-gate-feature">
            <ClockCountdown weight="bold" size={20} className="egf-icon egf-icon--sunbeam" />
            <div>
              <span className="egf-label">5 hours 20 minutes</span>
              <span className="egf-desc">Same time limit as the real exam</span>
            </div>
          </div>
          <div className="exam-gate-feature">
            <ChartBar weight="bold" size={20} className="egf-icon egf-icon--forest" />
            <div>
              <span className="egf-label">Per-chapter score breakdown</span>
              <span className="egf-desc">See exactly where you're strong and where to focus</span>
            </div>
          </div>
          <div className="exam-gate-feature">
            <MagnifyingGlass weight="bold" size={20} className="egf-icon egf-icon--sunbeam" />
            <div>
              <span className="egf-label">Review every answer</span>
              <span className="egf-desc">Afterward, see every question you got right and wrong, each with a step-by-step explanation</span>
            </div>
          </div>
          <div className="exam-gate-feature">
            <ListChecks weight="bold" size={20} className="egf-icon egf-icon--ember" />
            <div>
              <span className="egf-label">Unlimited retakes</span>
              <span className="egf-desc">Take it as many times as you want, with a different, randomly drawn exam each time</span>
            </div>
          </div>
        </div>
  );

  // ═══ SCHOOL GATE: their school covers them, they only need to verify ═══
  // ADR 0040. A licence covers the domain of their account address or of the
  // school on their profile, and no address on it is verified yet. The
  // emailed code is the one proof we take; once it lands they are in.
  if (!purchased && schoolReason === 'unverified' && school && !buyInstead) {
    const domain = (school.domains || [])[0] || 'your school';
    return (
      <main className="exam-main">
        <div className="exam-gate">
          <div className="exam-gate-card exam-gate-card--school">
            <button className="exam-gate-back" onClick={() => navigate('/dashboard')}>
              <ArrowLeft size={16} weight="bold" />
              Dashboard
            </button>

            <span className="exam-gate-overline">{school.name}</span>
            <h1 className="exam-gate-title">Your school gives you the exam simulation</h1>
            <p className="exam-gate-subtitle">
              {school.name} pays for its students, so there is nothing for you to buy.
              Confirm your @{domain} email and the full 110-question simulation is yours.
            </p>

            {renderStudentVerify({
              label: (
                <>
                  Your <strong>@{domain}</strong> email. We will send a 6-digit code to it.
                </>
              ),
              placeholder: `you@${domain}`,
              sendLabel: 'Send my code',
            })}

            {features}

            <button type="button" className="exam-link-btn exam-gate-not-mine" onClick={() => setBuyInstead(true)}>
              Not a student there? See the price instead
            </button>
          </div>
        </div>
      </main>
    );
  }


  // ═══ NOT PURCHASED ═══
  if (!purchased) {
    return (
      <main className="exam-main">
        <div className="exam-gate">
          <div className="exam-gate-card">
            <button className="exam-gate-back" onClick={() => navigate('/dashboard')}>
              <ArrowLeft size={16} weight="bold" />
              Dashboard
            </button>

            <h1 className="exam-gate-title">110-Question Exam Simulation</h1>
            <p className="exam-gate-subtitle">
              The closest thing to sitting for the real FE Civil exam.
            </p>

            {schoolReason === 'seats_full' && school && (
              <div className="exam-gate-seats-full" role="status">
                <UsersThree weight="bold" size={20} className="exam-gate-seats-full-icon" />
                <div>
                  <p className="exam-gate-seats-full-title">Every seat at {school.name} is taken</p>
                  <p className="exam-gate-seats-full-text">
                    Your school gives the simulation to its students, and all of its seats are in use.
                    Ask your department to add seats; you get in the moment they do. You can also buy it yourself below.
                  </p>
                </div>
              </div>
            )}

            {/* Price and the buy button first, what you get under them */}
            <div className="exam-gate-price">
              <span className="exam-gate-amount">${studentApplies ? studentPrice : standardPrice}</span>
              <span className="exam-gate-period">one-time &middot; no subscription</span>
            </div>

            {error && <div className="exam-error" role="alert">{error}</div>}

            <button
              className="btn-primary exam-buy-btn"
              onClick={handleBuyNow}
              disabled={checkoutLoading}
            >
              {checkoutLoading ? 'Redirecting to checkout...' : `Buy the Exam Simulation for $${studentApplies ? studentPrice : standardPrice}`}
            </button>

            <p className="exam-gate-guarantee">
              14-day money-back guarantee, and if you don't pass, we'll extend your access free.
            </p>

            {studentApplies ? (
              <p className="exam-gate-student-note">
                <CheckCircle weight="fill" size={15} />
                {' '}Student price applied{pricing?.verifiedStudentEmail ? ` (verified ${pricing.verifiedStudentEmail})` : ''}.
              </p>
            ) : renderStudentVerify({
              label: (
                <>
                  Students pay ${studentPrice}, and nothing if their school has a licence with us.
                  Enter your <strong>.edu</strong> email and we will send you a 6-digit code.
                </>
              ),
            })}

            <button className="exam-gate-preview-btn" onClick={() => navigate('/exam/preview')}>
              Try 10 questions free first
            </button>


            {features}

            {/* Why we charge: the genuine message */}
            <div className="exam-gate-why">
              <Heart weight="bold" size={18} className="exam-gate-why-icon" />
              <div>
                <p className="exam-gate-why-title">Why this is the only thing that costs money</p>
                <p className="exam-gate-why-text">
                  Unlike other FE prep platforms that charge $200+ for access, we give you
                  all 15 chapters, {PROBLEM_COUNT_LABEL} practice problems, step-by-step solutions, and the
                  diagnostic exam completely free. We built this to help students get their
                  EIT certification without breaking the bank.
                </p>
                <p className="exam-gate-why-text">
                  This one-time purchase helps us cover server costs and keep
                  everything else free for the next student who finds us.
                </p>
              </div>
            </div>

          </div>
        </div>
      </main>
    );
  }

  // ═══ PURCHASED ═══
  const completedAttempts = attempts.filter(a => a.status === 'completed');
  const bestScore = completedAttempts.length > 0
    ? Math.max(...completedAttempts.map(a => a.overallPercentage || 0))
    : null;

  return (
    <main className="exam-main">
      <div className="exam-hub">
        <div className="exam-hub-header">
          <button className="btn-secondary exam-back-link" onClick={() => navigate('/dashboard')}>
            <ArrowLeft size={16} weight="bold" />
            Dashboard
          </button>
          <h1 className="exam-hub-title">Exam Simulation</h1>
          <p className="exam-hub-subtitle">
            110 questions, 5h 20min, weighted by NCEES distribution.
          </p>
          {access === 'school' && school && (
            <p className="exam-hub-school">
              <GraduationCap weight="bold" size={16} />
              Given to you by {school.name}
            </p>
          )}
        </div>

        <div className="exam-hub-body">
          {/* Start exam card */}
          <div className="exam-start-card">
            <div className="exam-start-card-inner">
              <div className="exam-start-info">
                <div className="exam-start-rule">
                  <Timer weight="bold" size={18} />
                  <span>5 hours 20 minutes</span>
                </div>
                <div className="exam-start-rule">
                  <Exam weight="bold" size={18} />
                  <span>110 questions across 15 chapters</span>
                </div>
                {bestScore !== null && (
                  <div className="exam-start-rule">
                    <Lightning weight="bold" size={18} />
                    <span>Best score: {bestScore}%</span>
                  </div>
                )}
              </div>
              <button className="btn-primary exam-start-btn" onClick={() => navigate('/exam/session')}>
                Start New Exam
                <ArrowRight size={16} weight="bold" />
              </button>
            </div>
          </div>

          {/* Past attempts */}
          {completedAttempts.length > 0 && (
            <div className="exam-attempts-section">
              <h3 className="exam-attempts-title">Past Attempts</h3>
              <div className="exam-attempts-list">
                {completedAttempts.map(a => (
                  <button
                    key={a.attemptId}
                    className="exam-attempt-row"
                    onClick={() => navigate(`/exam/results/${a.attemptId}`)}
                  >
                    <span className="ea-num">#{a.attemptNumber}</span>
                    <span className="ea-score">{a.totalCorrect}/{a.totalQuestions}</span>
                    <span className="ea-pct" style={{ color: a.overallPercentage >= 50 ? 'var(--forest)' : 'var(--error)' }}>
                      {a.overallPercentage}%
                    </span>
                    <span className="ea-date">
                      {a.completedAt ? new Date(a.completedAt).toLocaleDateString() : ''}
                    </span>
                    <ArrowRight size={14} weight="bold" className="ea-arrow" />
                  </button>
                ))}
              </div>
            </div>
          )}
        </div>
      </div>
    </main>
  );
}
