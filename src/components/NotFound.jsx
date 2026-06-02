import React from 'react';
import { MapTrifold, House, ArrowLeft } from '@phosphor-icons/react';

export function NotFound() {
  return (
    <main style={{
      display: 'flex',
      alignItems: 'center',
      justifyContent: 'center',
      minHeight: '60vh',
      padding: '2rem',
    }}>
      <div style={{
        background: '#FFFFFF',
        borderRadius: '16px',
        boxShadow: '0 1px 3px rgba(44,44,44,0.04), 0 4px 16px rgba(44,44,44,0.06)',
        padding: '3rem 2.5rem',
        maxWidth: '480px',
        width: '100%',
        textAlign: 'center',
      }}>
        <MapTrifold size={48} weight="regular" style={{ color: '#A09C93', marginBottom: '1rem' }} />
        <h1 style={{
          fontFamily: "'DM Sans', system-ui, sans-serif",
          fontSize: '2rem',
          fontWeight: 700,
          color: '#2C2C2C',
          letterSpacing: '-0.04em',
          marginBottom: '0.25rem',
        }}>
          404
        </h1>
        <h2 style={{
          fontFamily: "'DM Sans', system-ui, sans-serif",
          fontSize: '1.125rem',
          fontWeight: 600,
          color: '#2C2C2C',
          letterSpacing: '-0.02em',
          marginBottom: '0.5rem',
        }}>
          Page not found
        </h2>
        <p style={{
          fontFamily: "'Inter', system-ui, sans-serif",
          fontSize: '0.9rem',
          color: '#7A766D',
          lineHeight: 1.6,
          marginBottom: '1.5rem',
          textAlign: 'left',
        }}>
          The page you're looking for doesn't exist or may have been moved.
        </p>
        <div style={{ display: 'flex', gap: '0.75rem', justifyContent: 'center', flexWrap: 'wrap' }}>
          <a href="/dashboard" className="btn-primary" style={{ textDecoration: 'none' }}>
            <House size={16} weight="bold" />
            Dashboard
          </a>
          <a href="/" className="btn-secondary" style={{ textDecoration: 'none' }}>
            <ArrowLeft size={16} weight="bold" />
            Home
          </a>
        </div>
      </div>
    </main>
  );
}
