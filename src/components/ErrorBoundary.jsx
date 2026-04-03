import React from 'react';
import { SmileySad, House, ArrowClockwise } from '@phosphor-icons/react';

export class ErrorBoundary extends React.Component {
  constructor(props) {
    super(props);
    this.state = { hasError: false };
  }

  static getDerivedStateFromError() {
    return { hasError: true };
  }

  componentDidCatch(error, errorInfo) {
    console.error('ErrorBoundary caught:', error, errorInfo);
  }

  handleReset = () => {
    this.setState({ hasError: false });
  };

  render() {
    if (this.state.hasError) {
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
            <SmileySad size={48} weight="regular" style={{ color: '#A09C93', marginBottom: '1rem' }} />
            <h2 style={{
              fontFamily: "'DM Sans', system-ui, sans-serif",
              fontSize: '1.25rem',
              fontWeight: 700,
              color: '#2C2C2C',
              marginBottom: '0.5rem',
              letterSpacing: '-0.02em',
            }}>
              Something went wrong
            </h2>
            <p style={{
              fontFamily: "'Inter', system-ui, sans-serif",
              fontSize: '0.9rem',
              color: '#7A766D',
              lineHeight: 1.6,
              marginBottom: '1.5rem',
              textAlign: 'left',
            }}>
              An unexpected error occurred. You can try again or head back to the dashboard.
            </p>
            <div style={{ display: 'flex', gap: '0.75rem', justifyContent: 'center', flexWrap: 'wrap' }}>
              <button className="btn-primary" onClick={this.handleReset}>
                <ArrowClockwise size={16} weight="bold" />
                Try Again
              </button>
              <a href="/dashboard" className="btn-secondary" style={{ textDecoration: 'none' }}>
                <House size={16} weight="bold" />
                Dashboard
              </a>
            </div>
          </div>
        </main>
      );
    }

    return this.props.children;
  }
}
