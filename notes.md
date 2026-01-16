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
ssh -i /Users/jerson/secrets/aws/cs260_feforraccoons/jerson-cs260-key.pem ubuntu@50.19.107.220
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