import React from 'react';
import { describe, it, expect } from 'vitest';
import { render, screen } from '@testing-library/react';
import { MemoryRouter } from 'react-router-dom';
import { Header } from './Header';

describe('Header', () => {
  it('takes the logo home, signed in or not', () => {
    for (const userName of [null, 'raccoon@uwf.edu']) {
      const { unmount } = render(<MemoryRouter><Header userName={userName} /></MemoryRouter>);
      expect(screen.getByRole('link', { name: 'FE for Raccoons home' }).getAttribute('href')).toBe('/');
      unmount();
    }
  });
});
