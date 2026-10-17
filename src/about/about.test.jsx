import React from 'react';
import { describe, it, expect, vi, afterEach } from 'vitest';
import { render, screen, fireEvent, waitFor } from '@testing-library/react';
import { MemoryRouter } from 'react-router-dom';
import { About } from './About.jsx';
import { Contact } from './Contact.jsx';
import { PRERENDERED_ROUTE_PATTERN } from '../../service/prerenderedRoutes.js';

// The tester's point 12: an About page and a Contact us page, public and
// prerendered so anybody (and any crawler) can read them.

afterEach(() => vi.restoreAllMocks());

describe('About', () => {
  it('tells the owner\'s story, the free access, and the name', () => {
    render(<MemoryRouter><About /></MemoryRouter>);
    expect(screen.getByRole('heading', { level: 1, name: 'Why this exists' })).toBeInTheDocument();
    expect(screen.getByText(/master's in Civil Engineering at BYU/)).toBeInTheDocument();
    for (const h of ["Why it's free", 'How it teaches', 'Why raccoons?']) {
      expect(screen.getByRole('heading', { level: 2, name: h })).toBeInTheDocument();
    }
    expect(screen.getByRole('link', { name: /write to me/i })).toHaveAttribute('href', '/contact');
  });
});

describe('Contact us', () => {
  function mount(userName = '') {
    return render(<MemoryRouter><Contact userName={userName} /></MemoryRouter>);
  }

  it('asks a signed-out visitor for an address before sending', async () => {
    const fetchSpy = vi.spyOn(global, 'fetch');
    mount();
    fireEvent.change(screen.getByLabelText('Your message'), { target: { value: 'Hello' } });
    fireEvent.click(screen.getByRole('button', { name: /send message/i }));
    expect(await screen.findByRole('alert')).toHaveTextContent(/email address/);
    expect(fetchSpy).not.toHaveBeenCalled();
  });

  it('sends a signed-in message and thanks them', async () => {
    const fetchSpy = vi.spyOn(global, 'fetch').mockResolvedValue({ ok: true, json: async () => ({ ok: true }) });
    mount('me@byu.edu');
    expect(screen.queryByLabelText('Your email')).toBeNull();
    expect(screen.getByText("We'll reply to the email on your account.")).toBeInTheDocument();
    expect(screen.queryByText(/me@byu\.edu/)).toBeNull();
    fireEvent.change(screen.getByLabelText('Your message'), { target: { value: 'Love it' } });
    fireEvent.click(screen.getByRole('button', { name: /send message/i }));
    await waitFor(() => expect(screen.getByRole('status')).toHaveTextContent('Sent. Thank you.'));
    const [url, init] = fetchSpy.mock.calls[0];
    expect(url).toBe('/api/feedback/contact');
    expect(JSON.parse(init.body)).toMatchObject({ message: 'Love it', source: 'web' });
  });

  it('shows the server\'s reason when it refuses', async () => {
    vi.spyOn(global, 'fetch').mockResolvedValue({ ok: false, json: async () => ({ msg: 'That is plenty for one hour. Thank you.' }) });
    mount('me@byu.edu');
    fireEvent.change(screen.getByLabelText('Your message'), { target: { value: 'again' } });
    fireEvent.click(screen.getByRole('button', { name: /send message/i }));
    expect(await screen.findByRole('alert')).toHaveTextContent('plenty for one hour');
  });
});

describe('both are served prerendered', () => {
  it('matches the server\'s prerendered routes', () => {
    expect(PRERENDERED_ROUTE_PATTERN.test('/about')).toBe(true);
    expect(PRERENDERED_ROUTE_PATTERN.test('/contact')).toBe(true);
  });
});
