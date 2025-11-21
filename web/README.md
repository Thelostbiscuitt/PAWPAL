# Pet Support App - Web Application

A modern, responsive web application for pet care management with AI-powered assistance, built with React and Tailwind CSS.

## 🎨 Design System

### Color Palette
- **Background**: `#0a0a0a` (Dark theme)
- **Cards**: `#1a1a1a` (Glassmorphism effect)
- **Accent**: `#10b981` (Green for CTAs)
- **Text**: White and muted grays for hierarchy

### Visual Features
- **Glassmorphism**: Subtle borders with backdrop blur
- **Gradient Orbs**: Orange/amber background ambiance
- **Smooth Transitions**: Hover states and animations
- **Mobile-First**: Responsive design approach

## 🚀 Quick Start

### Prerequisites
- Node.js 18+ 
- npm or yarn package manager

### Installation

```bash
# Clone the repository
git clone <repository-url>
cd pet-support-app/web

# Install dependencies
npm install

# Start development server
npm run dev
```

### Development

```bash
# Start development server with hot reload
npm run dev

# Build for production
npm run build

# Preview production build
npm run preview

# Lint code
npm run lint

# Fix linting issues
npm run lint:fix
```

## 🏗️ Project Structure

```
web/
├── src/
│   ├── components/          # Reusable UI components
│   ├── pages/             # Page components
│   ├── hooks/              # Custom React hooks
│   ├── utils/              # Utility functions
│   ├── styles/             # Global styles
│   ├── assets/             # Static assets
│   ├── App.jsx             # Main app component
│   ├── main.jsx            # App entry point
│   └── index.css           # Global styles
├── public/                  # Public assets
├── package.json             # Dependencies and scripts
├── tailwind.config.js       # Tailwind configuration
├── vite.config.js           # Vite build configuration
└── index.html              # HTML template
```

## 🎯 Features

### Core Functionality
- **Tab Navigation**: Switch between Overview, Health Tracking, and AI Chat
- **Dashboard**: Health scores, alerts, appointments, and weight trends
- **Health Tracking**: Weight monitoring, health records, and medication tracking
- **AI Assistant**: Conversational AI for pet care questions
- **Emergency Triage**: Quick symptom assessment and urgency classification
- **Resource Finder**: Locate local vets, pet stores, and services

### Interactive Elements
- **Hover States**: All interactive elements have smooth hover transitions
- **Glassmorphism Cards**: Modern card design with backdrop blur
- **Gradient Backgrounds**: Dynamic orange/amber orb gradients
- **Responsive Layout**: Mobile-first design that scales to desktop
- **Smooth Animations**: Fade-in, slide-up, and pulse effects

## 🛠️ Technical Implementation

### React Components
- **Functional Components**: Using React hooks for state management
- **Modular Structure**: Reusable components with clear separation of concerns
- **No External Dependencies**: Only Tailwind CSS and Lucide React icons

### Styling
- **Tailwind CSS**: Utility-first CSS framework
- **Custom Theme**: Extended color palette and animations
- **Responsive Design**: Mobile-first breakpoints
- **Accessibility**: ARIA labels and keyboard navigation

### Performance
- **Code Splitting**: Lazy loading for optimal performance
- **Optimized Builds**: Vite for fast development and production builds
- **Tree Shaking**: Unused code elimination
- **Asset Optimization**: Efficient image and asset loading

## 📱 Responsive Design

### Breakpoints
- **Mobile**: < 640px
- **Tablet**: 640px - 1024px
- **Desktop**: > 1024px

### Layout Adaptation
- **Mobile**: Collapsible sidebar, stacked content
- **Tablet**: Partial sidebar, grid layouts
- **Desktop**: Full sidebar, multi-column layouts

## 🎨 UI Components

### Glassmorphism Cards
```jsx
<div className="glass">
  <h3>Card Title</h3>
  <p>Card content with backdrop blur</p>
</div>
```

### Accent Buttons
```jsx
<button className="btn-accent">
  Primary Action
</button>

<button className="btn-accent-outline">
  Secondary Action
</button>
```

### Tab Navigation
```jsx
<div className="tab-button active">
  <Icon />
  <span>Tab Label</span>
</div>
```

## 🔄 State Management

### Local State
- **useState**: Component-level state
- **useEffect**: Side effects and lifecycle
- **useContext**: Global state sharing

### Data Flow
- **Props Down**: Parent to child data flow
- **Events Up**: Child to parent communication
- **Custom Hooks**: Reusable state logic

## 🎭 Animations

### CSS Animations
- **fade-in**: Smooth opacity transition
- **slide-up**: Vertical slide with fade
- **pulse-glow**: Pulsing shadow effect
- **float**: Gentle floating animation

### Transitions
- **Hover States**: Color and scale changes
- **Tab Switching**: Smooth content transitions
- **Mobile Menu**: Slide-in/out effects

## 🔧 Development Workflow

### Code Quality
- **ESLint**: JavaScript/React linting
- **Prettier**: Code formatting (recommended)
- **Git Hooks**: Pre-commit quality checks

### Testing Strategy
- **Unit Tests**: Component testing with Jest
- **Integration Tests**: User flow testing
- **E2E Tests**: End-to-end scenario testing

## 🚀 Deployment

### Build Process
```bash
# Development build
npm run build

# Production optimization
npm run build --mode production
```

### Deployment Options
- **Static Hosting**: Vercel, Netlify, GitHub Pages
- **CDN**: CloudFront, Cloudflare
- **Server**: Node.js server with static files

## 🌐 Browser Support

### Modern Browsers
- ✅ Chrome 90+
- ✅ Firefox 88+
- ✅ Safari 14+
- ✅ Edge 90+

### Features Required
- ES6+ JavaScript
- CSS Grid and Flexbox
- CSS Custom Properties
- Backdrop Filter (for glassmorphism)

## 📊 Performance Metrics

### Core Web Vitals
- **LCP**: < 2.5s (Largest Contentful Paint)
- **FID**: < 100ms (First Input Delay)
- **CLS**: < 0.1 (Cumulative Layout Shift)

### Optimization Techniques
- **Code Splitting**: Reduce initial bundle size
- **Image Optimization**: WebP format, lazy loading
- **CSS Optimization**: Purge unused styles
- **Caching**: Proper cache headers

## 🔒 Security Considerations

### Content Security
- **CSP Headers**: Content Security Policy
- **XSS Prevention**: Input sanitization
- **HTTPS Only**: Secure communication
- **Authentication**: Secure session management

### Best Practices
- **Input Validation**: Client and server-side
- **Secure Headers**: HSTS, XSS Protection
- **Dependency Updates**: Regular security patches
- **Code Review**: Security-focused reviews

## 🎯 Future Enhancements

### Planned Features
- **PWA Support**: Offline functionality
- **Real-time Updates**: WebSocket integration
- **Advanced Analytics**: User behavior tracking
- **A/B Testing**: Feature experimentation

### Technical Improvements
- **TypeScript Migration**: Type safety
- **State Management**: Redux/Zustand integration
- **Component Library**: Storybook documentation
- **Testing Coverage**: 90%+ coverage goal

## 🤝 Contributing Guidelines

### Development Standards
- **Code Style**: ESLint configuration
- **Commit Messages**: Conventional commits
- **Pull Requests**: Template requirements
- **Documentation**: JSDoc comments

### Git Workflow
```bash
# Create feature branch
git checkout -b feature/new-feature

# Make changes and commit
git add .
git commit -m "feat: add new feature"

# Push and create PR
git push origin feature/new-feature
```

## 📞 Support and Troubleshooting

### Common Issues
- **Build Failures**: Check Node.js version and dependencies
- **Styling Issues**: Verify Tailwind CSS configuration
- **Performance**: Check bundle size and loading times
- **Browser Compatibility**: Test in target browsers

### Getting Help
- **Documentation**: Check inline comments and README
- **Issues**: Create GitHub issue with details
- **Community**: Join Discord/Slack for support
- **Debugging**: Use browser dev tools and React DevTools

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

Built with ❤️ for pet owners everywhere.