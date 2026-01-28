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

- [x] **HTML pages** - I did not complete this part of the deliverable.
- [x] **Proper HTML element usage** - I did not complete this part of the deliverable.
- [x] **Links** - I did not complete this part of the deliverable.
- [x] **Text** - I did not complete this part of the deliverable.
- [x] **3rd party API placeholder** - I did not complete this part of the deliverable.
- [x] **Images** - I did not complete this part of the deliverable.
- [x] **Login placeholder** - I did not complete this part of the deliverable.
- [x] **DB data placeholder** - I did not complete this part of the deliverable.
- [x] **WebSocket placeholder** - I did not complete this part of the deliverable.

## 🚀 CSS deliverable

For this deliverable I did the following. I checked the box `[x]` and added a description for things I completed.

- [ ] **Visually appealing colors and layout. No overflowing elements.** - I did not complete this part of the deliverable.
- [ ] **Use of a CSS framework** - I did not complete this part of the deliverable.
- [ ] **All visual elements styled using CSS** - I did not complete this part of the deliverable.
- [ ] **Responsive to window resizing using flexbox and/or grid display** - I did not complete this part of the deliverable.
- [ ] **Use of a imported font** - I did not complete this part of the deliverable.
- [ ] **Use of different types of selectors including element, class, ID, and pseudo selectors** - I did not complete this part of the deliverable.

## 🚀 React part 1: Routing deliverable

For this deliverable I did the following. I checked the box `[x]` and added a description for things I completed.

- [ ] **Bundled using Vite** - I did not complete this part of the deliverable.
- [ ] **Components** - I did not complete this part of the deliverable.
- [ ] **Router** - I did not complete this part of the deliverable.

## 🚀 React part 2: Reactivity deliverable

For this deliverable I did the following. I checked the box `[x]` and added a description for things I completed.

- [ ] **All functionality implemented or mocked out** - I did not complete this part of the deliverable.
- [ ] **Hooks** - I did not complete this part of the deliverable.

## 🚀 Service deliverable

For this deliverable I did the following. I checked the box `[x]` and added a description for things I completed.

- [ ] **Node.js/Express HTTP service** - I did not complete this part of the deliverable.
- [ ] **Static middleware for frontend** - I did not complete this part of the deliverable.
- [ ] **Calls to third party endpoints** - I did not complete this part of the deliverable.
- [ ] **Backend service endpoints** - I did not complete this part of the deliverable.
- [ ] **Frontend calls service endpoints** - I did not complete this part of the deliverable.
- [ ] **Supports registration, login, logout, and restricted endpoint** - I did not complete this part of the deliverable.

## 🚀 DB deliverable

For this deliverable I did the following. I checked the box `[x]` and added a description for things I completed.

- [ ] **Stores data in MongoDB** - I did not complete this part of the deliverable.
- [ ] **Stores credentials in MongoDB** - I did not complete this part of the deliverable.

## 🚀 WebSocket deliverable

For this deliverable I did the following. I checked the box `[x]` and added a description for things I completed.

- [ ] **Backend listens for WebSocket connection** - I did not complete this part of the deliverable.
- [ ] **Frontend makes WebSocket connection** - I did not complete this part of the deliverable.
- [ ] **Data sent over WebSocket connection** - I did not complete this part of the deliverable.
- [ ] **WebSocket data displayed** - I did not complete this part of the deliverable.
- [ ] **Application is fully functional** - I did not complete this part of the deliverable.
