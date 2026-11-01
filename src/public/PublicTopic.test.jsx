import React from 'react';
import { describe, it, expect } from 'vitest';
import { render, screen, fireEvent } from '@testing-library/react';
import { MemoryRouter, Routes, Route, useLocation } from 'react-router-dom';
import { PublicTopic } from './PublicTopic.jsx';

function LoginProbe() {
  const { state, search } = useLocation();
  return <p data-testid="login">{search} {JSON.stringify(state)}</p>;
}

function mount(path) {
  return render(
    <MemoryRouter initialEntries={[path]}>
      <Routes>
        <Route path="/fe-civil/:topicId" element={<PublicTopic />} />
        <Route path="/login" element={<LoginProbe />} />
      </Routes>
    </MemoryRouter>,
  );
}

describe('topic page signup buttons', () => {
  // A visitor without an account used to be bounced to the homepage by
  // /study/:id. The buttons go to signup instead, and back to this chapter.
  it('sends a visitor to signup in create mode, returning to the chapter', () => {
    mount('/fe-civil/statics');
    const links = screen.getAllByRole('link', { name: /Create your free account/ });
    expect(links.length).toBe(2);
    for (const a of links) expect(a).toHaveAttribute('href', '/login?mode=create');
    fireEvent.click(links[0]);
    const probe = screen.getByTestId('login').textContent;
    expect(probe).toContain('?mode=create');
    expect(probe).toContain('"returnTo":"/study/statics"');
    expect(probe).toContain('"mode":"create"');
  });
});
