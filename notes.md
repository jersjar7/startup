# CS 260 Notes

[My startup - Simon](https://simon.cs260.click)

## Helpful links

- [Course instruction](https://github.com/webprogramming260)
- [Canvas](https://byu.instructure.com)
- [MDN](https://developer.mozilla.org)

## 1. Startup Specification Deliverable

### What I Learned

**Elevator Pitch Structure**
- Context: what problem exists
- Pain: why it's frustrating
- Solution: how your app fixes it
- Keep it to one paragraph

**Planning a Web App**
- Map features to required technologies before coding
- HTML pages: 3-4 pages for simple apps (login, dashboard, content views)
- React SPA: Multiple views, but only ONE actual HTML file - React swaps components
- Always include all 6 technologies: HTML, CSS, React, Service (with 3rd party API), DB/Login, WebSocket

**Git Commands**
- `git push -u origin main` - sets up tracking FIRST time
- `git push` - works after tracking is set (cloned repos already tracked)

**Design Process**
1. Create wireframes first
2. Plan color scheme that doesn't distract from content
3. Keep UI minimal and functional

**Markdown Images**
```markdown
![Alt text](filename.png)
*Optional caption*
```

**Key Insight**: Plan the technology stack early to avoid realizing you forgot a requirement halfway through.

## 2. AWS Server Setup

### My Server Details

**Server IP Address**: 50.19.107.220  
**Server URL**: http://50.19.107.220  
**Instance Name**: jerson-feforraccoons-server  
**Instance Type**: t3.micro (Free tier eligible)  
**Key Pair**: jerson-cs260-key

### SSH Command
```bash
ssh -i /Users/jerson/developer/secrets/aws/cs260_feforraccoons/jerson-cs260-key.pem ubuntu@50.19.107.220
```

### What I Learned

**AWS EC2 Basics**
- EC2 = Elastic Compute Cloud (virtual servers in the cloud)
- AMI = Amazon Machine Image (pre-configured server template)
- Used class AMI: `ami-094c4a0be0b642a24` (Web Programming 260 Server v8)
- Includes: Ubuntu, Node.js, NVM, Caddy Server, PM2

**Security Groups**
- Firewall rules that control traffic to server
- Need 3 rules for web server:
  - SSH (port 22): for remote terminal access
  - HTTP (port 80): for web traffic
  - HTTPS (port 443): for secure web traffic
- All set to "Anywhere" so website is publicly accessible

**Key Pair (.pem file)**
- Acts like a password for SSH access
- Stored at: `/Users/jerson/developer/secrets/aws/cs260_feforraccoons/`
- NEVER commit to GitHub or share publicly
- Need it every time I SSH into server

**T3 Instance Credit Specification**
- Set to "Unlimited" to prevent server from freezing if CPU maxes out
- Minimal cost (pennies per hour) vs. server dying

**Important Notes**
- Region must be US East (N. Virginia) for class AMI
- Elastic IP recommended to keep same IP address even if server restarts
- Server takes 2-3 minutes to fully boot after launching

**Elastic IP Address**
- Permanent IP: 50.19.107.220
- Allocation ID: eipalloc-071cfa12cf30b5228
- Free as long as server is running
- Will persist even if server stops/restarts

**HTTPS Configuration**
- Configured Caddy to use domain name instead of :80
- Caddy automatically requests SSL certificates from Let's Encrypt
- All traffic now uses HTTPS (secure connection)
- HTTP requests automatically redirect to HTTPS
- Certificate renewal happens automatically

**Working URLs:**
- https://fe4raccoons.click (main site - shows secure padlock)
- https://startup.fe4raccoons.click (for course project)
- https://simon.fe4raccoons.click (for Simon practice app)

**Caddyfile Location:** `~/Caddyfile` on server
- Configured to serve static files from `/usr/share/caddy`
- Configured reverse proxy for startup (port 4000) and simon (port 3000)

## 3. HTML Structure

### What I Learned

**HTML Structure Elements**
- Block elements (div, p, section, header, footer, main, aside, nav) - create distinct blocks
- Inline elements (span, a, b, img) - flow within block content without disrupting layout
- Block elements stack vertically, inline elements flow horizontally

**Common Structural Hierarchy**
```
body
├── header (page header with nav)
├── main (primary content)
│   ├── section (content blocks)
│   └── aside (supplementary content)
└── footer (page footer)
```

**Key Elements Used**
- `<a href="url">text</a>` - hyperlinks (inline)
- `<img src="url" width="200">` - images (inline)
- `<h1>` to `<h6>` - headings (block)
- `<ul>` + `<li>` - unordered lists (block)
- `<table>` + `<tr>` + `<td>`/`<th>` - tables (block)
- `<nav>` - navigation container (block)
- `<section>` - thematic content grouping (block)
- `<aside>` - tangential content (block)

**Remember**: Use semantic HTML elements (header, nav, main, footer, aside) instead of generic divs when possible - helps with SEO and accessibility.

## 4. HTML Deliverable

### What I Learned

**HTML Page Creation Strategy**
- Build pages in order of complexity: Login → Dashboard → Study → Problems
- Start simple to establish structure patterns that later pages reuse
- Follow user flow: each page naturally links to the next

**Semantic HTML vs Generic Divs**
- Use semantic elements (header, nav, main, section, footer) instead of divs
- Improves accessibility and SEO
- Makes code more readable and maintainable

**Key HTML Elements Used**
- `<details>` + `<summary>` - Collapsible content (perfect for solutions)
- `<form action="page.html">` - Simple navigation without JavaScript
- `onclick="window.location.href"` - Alternative navigation method
- `<label>` + `<input type="checkbox">` - Proper form association

**Placeholder Strategy**
- Added placeholders for all future deliverables (DB, WebSocket, API)
- Makes it clear what functionality will be added later
- Helps with planning subsequent deliverables

**Navigation Patterns**
- Consistent header structure across all pages
- Back links for easy navigation
- Logout button always in top right
- Forms can use `action` attribute to navigate on submit

**Key Insight**: Following wireframes closely during HTML creation makes CSS styling much easier later.

## 5. CSS Deliverable

### What I Learned

**Modular CSS Architecture**
- Split large CSS files into page-specific modules (main.css + page.css)
- main.css: shared styles (variables, base, header, footer, buttons)
- page.css: page-specific styles (dashboard.css, index.css, study.css, problems.css)
- Each HTML links both: `<link rel="stylesheet" href="main.css">` then `<link rel="stylesheet" href="page.css">`
- Improves maintainability and organization

**CSS Variables**
```css
:root {
  --charcoal: #2c2c2c;
  --cream: #FFF9F0;
}
/* Use with: color: var(--charcoal); */
```

**Layout Systems**
- Flexbox: `.login-buttons { display: flex; gap: 1rem; }`
- Grid: `.topics-grid { display: grid; grid-template-columns: repeat(3, 1fr); }`
- Grid items stretch by default - use `justify-self: end;` to prevent stretching

**Responsive Design**
- Media queries at breakpoints: 992px (tablet), 640px (mobile)
- Grid columns adjust: 3 columns → 2 columns → 1 column
- Flexbox direction changes: row → column

**Selector Types Used**
- Element: `button`, `input`, `body`
- Class: `.topic-card`, `.logout-btn`
- ID: `#app-title`, `#app-slogan`
- Pseudo: `:hover`, `:focus`, `:active`, `:before`, `:last-child`
- Descendant: `.login-buttons button`

**CSS Framework**
- Tailwind CSS via `@import 'tailwindcss'`
- Custom utility classes for project colors

**Key Insight**: Flexbox and Grid behave differently - flexbox auto-sizes items, grid stretches them to fill cells. Choose based on desired layout behavior.

## 5. React Part 1: Routing Deliverable

### What I Learned

**Converting from HTML to React**
- React uses a single HTML file (index.html) as entry point with a `<div id="root"></div>`
- The index.jsx file loads the top-level App component into the root div
- Each page becomes a React component (.jsx file) instead of separate HTML files
- JSX looks like HTML but has key differences: `class` becomes `className`, inline styles use objects
- Self-closing tags must have `/` (like `<input />` not `<input>`)

**Project Structure with Vite**
- Vite is the build tool that bundles React code for production
- `public/` directory holds static assets (images, icons)
- `src/` directory holds all React components and styles
- Each component gets its own folder with .jsx and .css files
- `package.json` defines dependencies and npm scripts (dev, build, preview)
- Must add `node_modules` to .gitignore (can be rebuilt with `npm install`)

**React Router**
- BrowserRouter wraps the entire app to enable routing
- Routes component defines which component to show for each path
- Route elements map paths to components: `<Route path="/" element={<Login />} />`
- NavLink or useNavigate hook handles navigation (not anchor tags)
- SPA (Single Page Application) = one HTML file, JavaScript swaps components
- URL changes without page reloads = better user experience

**Using Tailwind CSS with React**
- Tailwind integrates via `@tailwindcss/vite` plugin in vite.config.js
- Import Tailwind in app.css with `@import 'tailwindcss';`
- Must set `"type": "module"` in package.json for ES modules
- Google Fonts should go in HTML `<head>`, not CSS `@import` (to avoid Tailwind conflicts)

**React Navigation Pattern**
- Import `useNavigate` hook from 'react-router-dom'
- Call `const navigate = useNavigate();` inside component
- Use `onClick={() => navigate('/path')}` for buttons
- Use `onSubmit={(e) => { e.preventDefault(); navigate('/path'); }}` for forms
- Forms need `e.preventDefault()` to stop default HTML form submission

**Deployment Changes**
- deployReact.sh script runs `npm run build` to create production bundle
- Vite outputs optimized files to `dist/` directory
- Script copies `dist/*` to server's `services/startup/public` directory
- Production site serves the bundled React app, not original source files

**Key Differences from CSS Deliverable**
- No more separate HTML pages - everything in one index.html
- No more page reloads - React Router handles navigation
- Component-based architecture - easier to maintain and reuse code
- Build process required - can't just open HTML files directly

**Common Pitfalls**
- Forgetting to change `class` to `className` causes errors
- Inline styles need object syntax: `{{ fontSize: '1rem' }}` not `"font-size: 1rem"`
- Forms submit by default - must use `e.preventDefault()`
- Old HTML files aren't used anymore - only JSX files matter
- Browser caching can show old version - use hard refresh (Cmd+Shift+R)

**Best Practices**
- Keep component files in their own directories with related CSS
- Import component-specific CSS in each component JSX file
- Use React Router's hooks (useNavigate) instead of window.location
- Test navigation flow after converting to ensure all buttons work
- Commit frequently after completing each major step

## 6. React Part 2: Reactivity Deliverable

### What I Learned from Simon React

**useState Hook**
- `const [state, setState] = React.useState(initialValue)` - creates state variable
- State changes trigger component re-render
- Example: `const [count, setCount] = React.useState(0)`

**useEffect Hook**
- `React.useEffect(() => { /* code */ }, [dependencies])` - runs when dependencies change
- Empty `[]` = runs once on mount
- `[variable]` = runs when variable changes
- Return cleanup function for unmounting: `return () => { /* cleanup */ }`

**Safe State Updates**
- Use function form when updating based on previous state
- `setState((prev) => prev + 1)` instead of `setState(state + 1)`
- Prevents race conditions with async state updates

**Component Patterns**
- Parent/child composition: Play component contains Players and SimonGame
- Props pass data down: `<Players userName={props.userName} />`
- Lift state up when multiple components need shared state

**localStorage Persistence**
- `localStorage.setItem('key', JSON.stringify(data))` - save
- `JSON.parse(localStorage.getItem('key'))` - retrieve
- Persists across browser sessions

**Mocking Future Functionality**
- Use `setInterval` to simulate WebSocket messages
- Use hard-coded data instead of API calls
- Use localStorage instead of database

**Key Insight**: React's reactivity makes UI automatically update when state changes - no manual DOM manipulation needed.

### What I Learned from My Startup Implementation

**Login Authentication Flow**
- Check localStorage on mount to maintain login state across refreshes
- Redirect to login if no user found, redirect to dashboard if already logged in
- Store username in localStorage on login, clear on logout

**Checkbox State Persistence**
- Store checkbox state in object: `{problem1: true, problem2: false}`
- Save to localStorage as JSON on every change
- Load from localStorage on component mount

**Mock WebSocket with setInterval**
- `setInterval` updates state every 3 seconds to simulate real-time data
- Return cleanup function from useEffect to clear interval on unmount
- Update state with function form to avoid stale data: `setLiveUsers(prev => ...)`

**Dynamic Progress Tracking**
- Calculate completed count: `Object.values(completedProblems).filter(Boolean).length`
- Display updates automatically when state changes

**Random Quote Implementation**
- Create array of quotes, select random one on mount
- Use useEffect with empty dependency to run once

**Key Insight**: useEffect cleanup functions are critical for preventing memory leaks with timers and intervals.