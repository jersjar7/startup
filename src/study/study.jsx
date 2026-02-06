import React from 'react';
import './study.css';

export function Study() {
  return (
    <main>
      <section className="key-concepts">
        <h2>Key Concepts</h2>
        <p>Study Materials and concept summaries go here.</p>
        <ul>
          <li>Coordinate Systems (Cartesian, Polar)</li>
          <li>Distance and Midpoint Formulas</li>
          <li>Circle Equations</li>
          <li>Line Equations and Slopes</li>
          <li>Conic Sections (Parabolas, Ellipses, Hyperbolas)</li>
          <li>Vector Operations</li>
        </ul>
        <p style={{ marginTop: '1rem', fontStyle: 'italic', color: '#666' }}>Database placeholder: Study materials will be loaded from MongoDB</p>
      </section>

      <section className="video-section">
        <h3>YouTube Video Tutorial</h3>
        <p style={{ color: '#666' }}>(Embedded Video Player)</p>
        <p style={{ marginTop: '1rem', fontStyle: 'italic', color: '#666' }}>Placeholder for YouTube embed from Raccoon Engineering channel</p>
      </section>

      <section style={{ textAlign: 'center' }}>
        <button className="practice-btn">
          Practice Problems →
        </button>
      </section>
    </main>
  );
}