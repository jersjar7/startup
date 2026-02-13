import React from 'react';
import { useNavigate } from 'react-router-dom';
import './problems.css';

export function Problems() {
  const navigate = useNavigate();
  const [userName, setUserName] = React.useState('');
  const [completedProblems, setCompletedProblems] = React.useState({});
  const [quote, setQuote] = React.useState('Loading...');
  const [quoteAuthor, setQuoteAuthor] = React.useState('');

  React.useEffect(() => {
    const storedUser = localStorage.getItem('userName');
    if (!storedUser) {
      navigate('/');
    } else {
      setUserName(storedUser);
    }

    // Load completed problems from localStorage
    const saved = localStorage.getItem('completedProblems');
    if (saved) {
      setCompletedProblems(JSON.parse(saved));
    }

    // Mock motivational quote (will be 3rd party API later)
    const quotes = [
      { text: "Success is the sum of small efforts repeated day in and day out.", author: "Robert Collier" },
      { text: "The expert in anything was once a beginner.", author: "Helen Hayes" },
      { text: "Don't watch the clock; do what it does. Keep going.", author: "Sam Levenson" }
    ];
    const randomQuote = quotes[Math.floor(Math.random() * quotes.length)];
    setQuote(randomQuote.text);
    setQuoteAuthor(randomQuote.author);
  }, [navigate]);

  const handleLogout = () => {
    localStorage.removeItem('userName');
    navigate('/');
  };

  const handleCheckbox = (problemId) => {
    const updated = { ...completedProblems, [problemId]: !completedProblems[problemId] };
    setCompletedProblems(updated);
    localStorage.setItem('completedProblems', JSON.stringify(updated));
  };

  const completedCount = Object.values(completedProblems).filter(Boolean).length;

  return (
    <main>
      <div className="problems-header">
        <a href="#" className="back-link" onClick={(e) => { e.preventDefault(); navigate('/study'); }}>
          ← Back to Study
        </a>
        <h1>Analytic Geometry Problems</h1>
        <button className="logout-btn" onClick={handleLogout}>Logout</button>
      </div>

      <section className="progress-section">
        <p>Progress: {completedCount}/5 Problems Completed</p>
        <p style={{ marginTop: '0.5rem', fontStyle: 'italic', color: '#666', fontWeight: 'normal' }}>
          Database placeholder: User progress will be tracked in MongoDB
        </p>
      </section>

      <section>
        {[1, 2, 3, 4, 5].map((num) => (
          <div key={num} className="problem-card">
            <h3>Problem {num}: {getProblemTitle(num)}</h3>
            <p>{getProblemText(num)}</p>
            <details>
              <summary>[Click to reveal solution]</summary>
              <div style={{ marginTop: '1rem', padding: '1rem', background: '#f5f5f5', borderLeft: '3px solid #333' }}>
                <p style={{ fontWeight: 600, marginBottom: '0.5rem' }}>Solution:</p>
                {getSolution(num)}
              </div>
            </details>
            <label>
              <input 
                type="checkbox" 
                checked={completedProblems[`problem${num}`] || false}
                onChange={() => handleCheckbox(`problem${num}`)}
              />
              <span>Mark as complete</span>
            </label>
          </div>
        ))}
      </section>

      <section className="problem-card" style={{ marginTop: '2rem' }}>
        <h3>Daily Study Motivation</h3>
        <blockquote style={{ borderLeft: '4px solid #333', paddingLeft: '1rem', fontStyle: 'italic', margin: '1rem 0' }}>
          <p>"{quote}"</p>
          <cite style={{ fontSize: '0.9rem', color: '#666' }}>- {quoteAuthor}</cite>
        </blockquote>
        <p style={{ fontStyle: 'italic', color: '#666' }}>
          3rd party API placeholder: Motivational quotes will be fetched from external API
        </p>
      </section>
    </main>
  );
}

function getProblemTitle(num) {
  const titles = [
    'Calculate the distance between two points',
    'Find the equation of a circle',
    'Determine the slope and equation of a line',
    'Find the midpoint between two coordinates',
    'Convert Cartesian to Polar coordinates'
  ];
  return titles[num - 1];
}

function getProblemText(num) {
  const problems = [
    'Find the distance between points A(2, 3) and B(5, 7).',
    'A circle has center at (3, -2) and radius 4. Write its equation in standard form.',
    'Find the slope and equation of the line passing through points (1, 2) and (4, 8).',
    'Calculate the midpoint between A(-2, 5) and B(4, -3).',
    'Convert the Cartesian point (3, 4) to polar coordinates (r, θ).'
  ];
  return problems[num - 1];
}

function getSolution(num) {
  const solutions = [
    <><p>Using the distance formula: d = √[(x₂-x₁)² + (y₂-y₁)²]</p><p>d = √[(5-2)² + (7-3)²] = √[9 + 16] = √25 = 5 units</p></>,
    <><p>Standard form: (x-h)² + (y-k)² = r²</p><p>Where (h,k) is center and r is radius</p><p>(x-3)² + (y+2)² = 16</p></>,
    <><p>Slope m = (y₂-y₁)/(x₂-x₁) = (8-2)/(4-1) = 6/3 = 2</p><p>Using point-slope form: y - y₁ = m(x - x₁)</p><p>y - 2 = 2(x - 1)</p><p>y = 2x</p></>,
    <><p>Midpoint formula: M = ((x₁+x₂)/2, (y₁+y₂)/2)</p><p>M = ((-2+4)/2, (5+(-3))/2) = (2/2, 2/2) = (1, 1)</p></>,
    <><p>r = √(x² + y²) = √(9 + 16) = √25 = 5</p><p>θ = arctan(y/x) = arctan(4/3) ≈ 53.13°</p><p>Polar coordinates: (5, 53.13°)</p></>
  ];
  return solutions[num - 1];
}