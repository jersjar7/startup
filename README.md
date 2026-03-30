# FE for Raccoons

[My Notes](notes.md)

FE for Raccoons is a study platform for the Fundamentals of Engineering (FE) Exam. It consolidates study materials, practice problems, and video tutorials into one organized web application, eliminating the need to search through multiple textbooks and scattered online resources.

## 🚀 Specification Deliverable

For this deliverable I did the following. I checked the box `[x]` and added a description for things I completed.

- [x] Proper use of Markdown
- [x] A concise and compelling elevator pitch
- [x] Description of key features
- [x] Description of how you will use each technology
- [x] One or more rough sketches of your application. Images must be embedded in this file using Markdown image references.

### Elevator pitch

Studying for the FE (Fundamentals of Engineering) Exam is a challenge. You need to juggle textbooks, scattered YouTube videos, and practice problems from different sources. **FE for Raccoons** consolidates everything: _study materials, practice problems, and tutorials_. All into one platform so you can focus on passing instead of searching.

### Design

![Login Page](Slide1.png)
*Login/Register page with simple authentication form*

![Topics Dashboard](Slide2.png)
*Dashboard showing FE exam topics with progress tracking and live activity*

![Study View](Slide3.png)
*Study materials with key concepts and embedded YouTube tutorial*

![Practice Problems](Slide4.png)
*Practice problems interface with solutions and completion tracking*

```mermaid
sequenceDiagram
    actor Student
    actor FE for Raccoons
    Student->>FE for Raccoons: Login/Register
    FE for Raccoons->>Student: Display topic dashboard
    Student->>FE for Raccoons: Select topic (e.g., Statics)
    FE for Raccoons->>Student: Show study materials & YouTube links
    Student->>FE for Raccoons: Request practice problems
    FE for Raccoons->>Student: Display problems with solutions
    FE for Raccoons->>Student: Broadcast realtime study activity
```

### Key features

- Browse FE exam topics organized by category (Statics, Dynamics, Fluid Mechanics, etc.)
- Access study materials and concept summaries for each topic
- Complete practice problems with detailed solutions
- Curated YouTube tutorial links for visual learning
- Track personal study progress and completed topics
- View realtime activity showing what topics other users are currently studying
- Secure user authentication and personalized dashboard

### Technologies

I am going to use the required technologies in the following ways.

- **HTML** - Structured 4 pages for login, topic dashboard (list of FE exam categories to choose from), study view (study materials, YouTube embed, and button to access practice problems for selected topic), and practice problems (its own page with problems and solutions). Proper semantic HTML with navigation links between pages.

- **CSS** - Responsive styling that works on desktop and mobile. Minimalist color scheme using pale off-white and dark grey tones to avoid distracting from study content, with good contrast for readability. Clean layout for topic cards and content organization.

- **React** - Single-page application with components for topic cards, study content display, practice problem sets, and progress tracking. React Router for navigation between views. Reactive UI updates as users interact with study materials.

- **Service** - Backend service with endpoints for:
  - Retrieving topic lists and study materials
  - Fetching practice problems
  - Saving and retrieving user progress
  - User authentication (register, login, logout)
  - Third-party service call to fetch motivational quotes or additional educational content

- **Database/Login** - Store user credentials securely in MongoDB. Store user study progress, completed topics, and preferences. Authentication required to access study materials and track progress.

- **WebSocket** - Realtime display of active study sessions. Shows which topics other users are currently studying (e.g., "5 users studying Fluid Mechanics") to create a sense of community and motivation.

## 🚀 AWS deliverable

For this deliverable I did the following. I checked the box `[x]` and added a description for things I completed.

- [x] **Server deployed and accessible with custom domain name** - [My server link](https://startup.fe4raccoons.click).

## 🚀 HTML deliverable

For this deliverable I did the following. I checked the box `[x]` and added a description for things I completed.

- [x] **HTML pages** - 4 pages: index.html (login), dashboard.html (topics), study.html (study materials), problems.html (practice problems)
- [x] **Proper HTML element usage** - Used semantic elements: header, main, footer, nav, section, form, details
- [x] **Links** - Navigation between all pages, back links, logout, GitHub repo link
- [x] **Text** - All pages contain descriptive text, instructions, problem descriptions
- [x] **3rd party API placeholder** - Motivational quotes section in problems.html with placeholder text
- [x] **Images** - Placeholder for YouTube video embed in study.html
- [x] **Login placeholder** - Username/password form in index.html
- [x] **DB data placeholder** - Study materials, problems, progress tracking all marked as DB placeholders
- [x] **WebSocket placeholder** - Live Activity section in dashboard.html showing real-time user activity

## 🚀 CSS deliverable

For this deliverable I did the following. I checked the box `[x]` and added a description for things I completed.

- [x] **Visually appealing colors and layout. No overflowing elements.** - Custom color palette with cream background, charcoal text, and accent colors. Clean, professional layout with proper spacing.
- [x] **Use of a CSS framework** - Tailwind CSS imported via `@import 'tailwindcss'` in main.css
- [x] **All visual elements styled using CSS** - All buttons, inputs, cards, headers, footers, and page layouts fully styled. Modular CSS structure with main.css for shared styles and separate CSS files for each page (index.css, dashboard.css, study.css, problems.css).
- [x] **Responsive to window resizing using flexbox and/or grid display** - Grid layout for topics (.topics-grid) and page headers. Flexbox for login buttons and header layout. Media queries for mobile responsiveness at 992px and 640px breakpoints.
- [x] **Use of a imported font** - Inter font family from Google Fonts
- [x] **Use of different types of selectors including element, class, ID, and pseudo selectors** - Element selectors (body, button, input), class selectors (.topic-card, .logout-btn), ID selector (#app-title, #app-slogan), pseudo selectors (:hover, :focus, :active, :before, :last-child)

## 🚀 React part 1: Routing deliverable

For this deliverable I did the following. I checked the box `[x]` and added a description for things I completed.

- [x] **Bundled using Vite** - Application uses Vite for bundling and hot-reloading during development. Uses Tailwind CSS for styling.
- [x] **Components** - Created React components for Login, Dashboard, Study, and Problems views. All components contain converted HTML/CSS from previous deliverable
  - Login component: login form with username/password inputs, navigation to dashboard on login/register
  - Dashboard component: topic selection grid with 6 topics, live activity section, topic cards navigate to study page
  - Study component: key concepts list, video placeholder, practice button navigates to problems page
  - Problems component: 5 math problems with collapsible solutions, completion checkboxes, motivational quote section
- [x] **Router** - React Router implemented with routes for / (Login), /dashboard (Dashboard), /study (Study), /problems (Problems), and * (404 page). Navigation works via useNavigate hook in all interactive buttons.

## 🚀 React part 2: Reactivity deliverable

For this deliverable I did the following. I checked the box `[x]` and added a description for things I completed.

- [x] **All functionality implemented or mocked out** - Login authentication, progress tracking, live activity simulation, motivational quotes all working
- [x] **Hooks** - useState for state management (username, password, completedProblems, liveUsers, quote), useEffect for lifecycle events (authentication check, localStorage loading, mock WebSocket, cleanup)

## 🚀 Service deliverable

For this deliverable I did the following. I checked the box `[x]` and added a description for things I completed.

- [x] **Node.js/Express HTTP service** - Backend created in `service/index.js` using Express on port 4000. Handles JSON parsing, cookie parsing, and serves static frontend files.
- [x] **Static middleware for frontend** - `app.use(express.static('public'))` serves the bundled React frontend from the `public` directory in production.
- [x] **Calls to third party endpoints** - The Problems page fetches motivational quotes from `https://quote.cs260.click` and displays them with author attribution.
- [x] **Backend service endpoints** - API endpoints for topics (`GET /api/topics`), user progress (`GET /api/progress`, `POST /api/progress`), and authentication. All app endpoints are protected with `verifyAuth` middleware.
- [x] **Frontend calls service endpoints** - Dashboard fetches topics from `/api/topics`. Problems page loads/saves progress via `/api/progress`. Login/Register call `/api/auth/create` and `/api/auth/login`. App checks session on load via `/api/user/me`.
- [x] **Supports registration, login, logout, and restricted endpoint** - Registration (`POST /api/auth/create`), login (`POST /api/auth/login`), logout (`DELETE /api/auth/logout`), and user info (`GET /api/user/me`). Auth uses secure httpOnly cookies. Topics and progress endpoints require authentication.
- [x] **Uses BCrypt to hash passwords** - Passwords are hashed with `bcryptjs` (cost factor 10) before storing. Login compares with `bcrypt.compare`.

## 🚀 DB deliverable

For this deliverable I did the following. I checked the box `[x]` and added a description for things I completed.

- [x] **Stores data in MongoDB** - User study progress (completed problems) is stored in a `progress` collection in MongoDB Atlas. Progress persists across server restarts and is tied to the authenticated user's email.
- [x] **Stores credentials in MongoDB** - User credentials (email, bcrypt-hashed password, auth token) are stored in a `users` collection in MongoDB Atlas. Registration, login, logout, and session validation all use the database. Connection is tested on startup with a ping command.

## 🚀 WebSocket deliverable

For this deliverable I did the following. I checked the box `[x]` and added a description for things I completed.

- [x] **Backend listens for WebSocket connection** - `service/peerProxy.js` creates a WebSocketServer that upgrades HTTP connections. Uses the `ws` library with `noServer` mode, handling the upgrade event from the Express HTTP server. Includes ping/pong keep-alive every 10 seconds to detect stale connections.
- [x] **Frontend makes WebSocket connection** - Dashboard and Study components connect via `new WebSocket()` using the correct protocol (`ws://` or `wss://`). Connections are cleaned up on component unmount.
- [x] **Data sent over WebSocket connection** - When users click a topic or open the Study page, a JSON message is sent with the user's email, the topic name, and event type. The backend relays messages to all other connected clients.
- [x] **WebSocket data displayed** - The Dashboard "Live Activity" section displays real-time events showing which users are studying which topics (e.g., "user@email.com started studying Dynamics"). Events are displayed in reverse chronological order, capped at 10.
- [x] **Application is fully functional** - All features work end-to-end: authentication (register/login/logout), topic browsing, study materials, practice problems with progress tracking, third-party quote API, and real-time WebSocket activity. No mocks or placeholders remain for required functionality.
