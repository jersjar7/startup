import React from 'react';
import { BrowserRouter, NavLink, Route, Routes } from 'react-router-dom';
import { Login } from './login/login';
import { Dashboard } from './dashboard/dashboard';
import { Study } from './study/study';
import { Problems } from './problems/problems';
import './app.css';

export default function App() {
  return (
    <BrowserRouter>
      <div className="body">
        <header>
          <h1 id="app-title">FE for Raccoons</h1>
          <h4 id="app-slogan">All you need to pass the Fundamentals of Engineering exam in one place!</h4>
        </header>

        <Routes>
          <Route path="/" element={<Login />} exact />
          <Route path="/dashboard" element={<Dashboard />} />
          <Route path="/study" element={<Study />} />
          <Route path="/problems" element={<Problems />} />
          <Route path="*" element={<NotFound />} />
        </Routes>

        <footer>
          <p>Created by Jerson J. Garcia</p>
          <p>
            <a href="https://github.com/jersjar7/startup" target="_blank">GitHub Repository</a>
          </p>
        </footer>
      </div>
    </BrowserRouter>
  );
}

function NotFound() {
  return <main>404: Page not found</main>;
}