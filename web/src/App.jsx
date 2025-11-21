import React, { useState, useEffect } from 'react'
import {
  Heart,
  MessageCircle,
  MapPin,
  AlertTriangle,
  Calendar,
  Menu,
  X,
  Home,
  Phone,
  Mail,
  Settings,
  User,
  Plus,
  Search,
  Filter,
  ChevronRight,
  Star,
  Clock,
  TrendingUp,
  Activity,
  Shield,
  Zap
} from 'lucide-react'
import AnimatedBackground from './components/AnimatedBackground'
import LoadingSpinner from './components/LoadingSpinner'
import AnimatedIcon from './components/AnimatedIcon'
import ResponsiveWrapper from './components/ResponsiveWrapper'
import AccessibilityTester from './components/AccessibilityTester'

function App() {
  const [activeTab, setActiveTab] = useState('overview')
  const [mobileMenuOpen, setMobileMenuOpen] = useState(false)

  const tabs = [
    { id: 'overview', label: 'Overview', icon: Home },
    { id: 'health', label: 'Health Tracking', icon: Heart },
    { id: 'chat', label: 'AI Assistant', icon: MessageCircle },
  ]

  const navigationItems = [
    { icon: Phone, label: 'Emergency', href: '#emergency' },
    { icon: MapPin, label: 'Find Vets', href: '#resources' },
    { icon: Calendar, label: 'Appointments', href: '#appointments' },
    { icon: Mail, label: 'Messages', href: '#messages' },
    { icon: Settings, label: 'Settings', href: '#settings' },
  ]

  const statsCards = [
    {
      title: 'Health Score',
      value: '92%',
      change: '+3%',
      icon: Heart,
      color: 'text-emerald-400'
    },
    {
      title: 'Active Alerts',
      value: '2',
      change: '1 new',
      icon: AlertTriangle,
      color: 'text-amber-400'
    },
    {
      title: 'Appointments',
      value: '3',
      change: 'Next: Tomorrow',
      icon: Calendar,
      color: 'text-blue-400'
    },
    {
      title: 'Weight Trend',
      value: 'Stable',
      change: '+0.2kg',
      icon: TrendingUp,
      color: 'text-purple-400'
    }
  ]

  const recentActivities = [
    {
      id: 1,
      type: 'health',
      title: 'Weight Updated',
      description: 'Buddy gained 0.2kg this week',
      time: '2 hours ago',
      icon: Activity,
      color: 'bg-emerald-500/20 text-emerald-400'
    },
    {
      id: 2,
      type: 'appointment',
      title: 'Vet Visit Scheduled',
      description: 'Annual checkup for Max',
      time: '1 day ago',
      icon: Calendar,
      color: 'bg-blue-500/20 text-blue-400'
    },
    {
      id: 3,
      type: 'alert',
      title: 'Medication Reminder',
      description: 'Flea treatment due in 3 days',
      time: '2 days ago',
      icon: AlertTriangle,
      color: 'bg-amber-500/20 text-amber-400'
    }
  ]

  const quickActions = [
    {
      title: 'AI Health Check',
      description: 'Get instant AI analysis',
      icon: Zap,
      color: 'bg-gradient-to-br from-emerald-500 to-emerald-600',
      href: '#ai-check'
    },
    {
      title: 'Emergency Triage',
      description: 'Assess urgent symptoms',
      icon: Shield,
      color: 'bg-gradient-to-br from-red-500 to-red-600',
      href: '#emergency'
    },
    {
      title: 'Find Local Help',
      description: 'Locate vets & services',
      icon: MapPin,
      color: 'bg-gradient-to-br from-blue-500 to-blue-600',
      href: '#resources'
    }
  ]

  useEffect(() => {
    // Close mobile menu when switching tabs
    setMobileMenuOpen(false)
  }, [activeTab])

  return (
    <AccessibilityTester>
      <div className="min-h-screen bg-primary-bg relative overflow-hidden">
        {/* Animated Background */}
        <AnimatedBackground />
      
      {/* Mobile Menu Overlay */}
      {mobileMenuOpen && (
        <div 
          className="fixed inset-0 bg-black/50 backdrop-blur-sm z-40 lg:hidden"
          onClick={() => setMobileMenuOpen(false)}
        />
      )}
      
      {/* Sidebar */}
      <aside className={`
        fixed left-0 top-0 h-full w-72 glass-vibrant z-50
        transform transition-transform duration-300 ease-in-out
        ${mobileMenuOpen ? 'translate-x-0' : '-translate-x-full lg:translate-x-0'}
      `}>
        {/* Logo */}
        <div className="p-6 border-b border-coral-pink/20">
          <div className="flex items-center space-x-3">
            <div className="w-10 h-10 bg-gradient-coral rounded-xl flex items-center justify-center shadow-vibrant">
              <Heart className="w-6 h-6 text-white" />
            </div>
            <div>
              <h1 className="text-xl font-bold text-text-primary font-accent">Pet Support</h1>
              <p className="text-sm text-text-secondary font-secondary">Your Pet Care Companion</p>
            </div>
          </div>
        </div>
        
        {/* Navigation */}
        <nav className="p-4 space-y-2">
          {navigationItems.map((item) => (
            <a
              key={item.label}
              href={item.href}
              className="nav-item"
            >
              <item.icon className="w-5 h-5" />
              <span>{item.label}</span>
            </a>
          ))}
        </nav>
        
        {/* User Profile */}
        <div className="absolute bottom-0 left-0 right-0 p-4 border-t border-coral-pink/20">
          <div className="flex items-center space-x-3">
            <div className="w-10 h-10 bg-gradient-coral rounded-full flex items-center justify-center shadow-vibrant">
              <User className="w-5 h-5 text-white" />
            </div>
            <div className="flex-1">
              <p className="font-semibold text-text-primary font-primary">John Doe</p>
              <p className="text-sm text-text-secondary font-secondary">Premium Member</p>
            </div>
          </div>
        </div>
      </aside>
      
      {/* Main Content */}
      <div className="lg:ml-72 min-h-screen">
        {/* Header */}
        <header className="bg-white/90 backdrop-blur-lg border-b border-coral-pink/20 sticky top-0 z-30 shadow-playful">
          <div className="flex items-center justify-between px-6 py-4">
            <div className="flex items-center space-x-4">
              {/* Mobile Menu Toggle */}
              <button
                onClick={() => setMobileMenuOpen(!mobileMenuOpen)}
                className="lg:hidden p-2 rounded-xl hover:bg-coral-pink/10 transition-colors"
                aria-label="Toggle mobile menu"
              >
                {mobileMenuOpen ? (
                  <X className="w-5 h-5 text-coral-pink" />
                ) : (
                  <Menu className="w-5 h-5 text-coral-pink" />
                )}
              </button>
              
              {/* Search */}
              <div className="relative">
                <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-5 h-5 text-text-secondary" />
                <input
                  type="text"
                  placeholder="Search pets, symptoms, resources..."
                  className="input-playful pl-10 w-64 md:w-96"
                />
              </div>
            </div>
            
            <div className="flex items-center space-x-3">
              {/* Notifications */}
              <button className="relative p-2 rounded-xl hover:bg-coral-pink/10 transition-colors">
                <AlertTriangle className="w-5 h-5 text-sunset-orange" />
                <span className="absolute top-1 right-1 w-2 h-2 bg-coral-pink rounded-full animate-pulse-glow" />
              </button>
              
              {/* User Menu */}
              <button className="flex items-center space-x-2 p-2 rounded-xl hover:bg-coral-pink/10 transition-colors">
                <div className="w-8 h-8 bg-gradient-coral rounded-full flex items-center justify-center shadow-vibrant">
                  <User className="w-4 h-4 text-white" />
                </div>
                <ChevronRight className="w-4 h-4 text-text-secondary" />
              </button>
            </div>
          </div>
        </header>
        
        {/* Tab Navigation */}
        <div className="bg-white/80 backdrop-blur-md border-b border-coral-pink/20">
          <div className="flex space-x-1 px-6">
            {tabs.map((tab) => (
              <button
                key={tab.id}
                onClick={() => setActiveTab(tab.id)}
                className={`
                  tab-playful relative
                  ${activeTab === tab.id ? 'active' : ''}
                `}
              >
                <tab.icon className="w-5 h-5" />
                <span>{tab.label}</span>
              </button>
            ))}
          </div>
        </div>
        
        {/* Tab Content */}
        <main className="p-6">
          {activeTab === 'overview' && <OverviewTab statsCards={statsCards} activities={recentActivities} quickActions={quickActions} />}
          {activeTab === 'health' && <HealthTab />}
          {activeTab === 'chat' && <ChatTab />}
        </main>
        </div>
      </div>
    </AccessibilityTester>
  )
}

// Overview Tab Component
function OverviewTab({ statsCards, activities, quickActions }) {
  return (
    <div className="space-y-8 animate-fade-in stagger-animation">
      {/* Stats Grid */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
        {statsCards.map((stat, index) => (
          <div key={stat.title} className="stat-card animate-fade-in-up" style={{ animationDelay: `${index * 0.1}s` }}>
            <div className="flex items-center justify-between">
              <div>
                <p className="text-text-secondary text-sm font-semibold font-secondary">{stat.title}</p>
                <p className="text-3xl font-bold text-text-primary mt-1 font-primary">{stat.value}</p>
                <p className="text-sm text-text-secondary mt-1 font-secondary">{stat.change}</p>
              </div>
              <div className="icon-playful stat-icon">
                <stat.icon className="w-6 h-6" />
              </div>
            </div>
          </div>
        ))}
      </div>
      
      {/* Quick Actions */}
      <div>
        <h2 className="text-3xl font-bold text-text-primary mb-6 font-accent text-gradient-coral">Quick Actions</h2>
        <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
          {quickActions.map((action, index) => (
            <a
              key={action.title}
              href={action.href}
              className="card-gradient group hover:scale-105 transition-all duration-300 animate-fade-in-up hover-lift"
              style={{ animationDelay: `${(index + 4) * 0.1}s` }}
            >
              <div className="icon-secondary mb-4">
                <action.icon className="w-6 h-6 text-white" />
              </div>
              <h3 className="text-lg font-bold text-text-primary mb-2 font-primary">{action.title}</h3>
              <p className="text-text-secondary font-secondary">{action.description}</p>
              <ChevronRight className="w-5 h-5 text-coral-pink group-hover:text-sunset-orange transition-colors mt-4" />
            </a>
          ))}
        </div>
      </div>
      
      {/* Recent Activities */}
      <div>
        <h2 className="text-3xl font-bold text-text-primary mb-6 font-accent text-gradient-coral">Recent Activities</h2>
        <div className="space-y-4">
          {activities.map((activity, index) => (
            <div key={activity.id} className="card-playful flex items-center space-x-4 animate-fade-in-up hover-lift" style={{ animationDelay: `${(index + 7) * 0.1}s` }}>
              <div className="icon-playful">
                <activity.icon className="w-5 h-5 text-white" />
              </div>
              <div className="flex-1">
                <h4 className="font-semibold text-text-primary font-primary">{activity.title}</h4>
                <p className="text-text-secondary font-secondary">{activity.description}</p>
              </div>
              <div className="text-text-secondary text-sm font-secondary">
                <Clock className="w-4 h-4 inline mr-1" />
                {activity.time}
              </div>
            </div>
          ))}
        </div>
      </div>
    </div>
  )
}

// Health Tab Component
function HealthTab() {
  return (
    <div className="space-y-8 animate-fade-in">
      <div className="text-center animate-fade-in-up">
        <h2 className="text-4xl font-bold text-text-primary mb-4 font-accent text-gradient-coral">Health Tracking</h2>
        <p className="text-text-secondary max-w-2xl mx-auto font-secondary text-lg">
          Monitor your pet's health with comprehensive tracking tools and AI-powered insights.
        </p>
      </div>
      
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-8">
        {/* Weight Tracking */}
        <div className="card-playful animate-fade-in-up" style={{ animationDelay: '0.2s' }}>
          <h3 className="text-xl font-bold text-text-primary mb-4 font-primary">Weight Tracking</h3>
          <div className="space-y-4">
            <div className="flex items-center justify-between">
              <span className="text-text-secondary font-secondary">Current Weight</span>
              <span className="text-2xl font-bold text-text-primary font-primary">25.5 kg</span>
            </div>
            <div className="h-32 bg-gradient-to-r from-coral-pink/20 to-sunset-orange/40 rounded-xl flex items-end justify-center p-4 border-2 border-coral-pink/20">
              <div className="text-xs text-text-secondary font-secondary">Weight trend chart here</div>
            </div>
            <button className="btn-vibrant w-full">
              <Plus className="w-4 h-4 mr-2" />
              Log Weight
            </button>
          </div>
        </div>
        
        {/* Health Records */}
        <div className="card-playful animate-fade-in-up" style={{ animationDelay: '0.4s' }}>
          <h3 className="text-xl font-bold text-text-primary mb-4 font-primary">Health Records</h3>
          <div className="space-y-3">
            {['Vaccination', 'Check-up', 'Medication'].map((record, index) => (
              <div key={record} className="flex items-center justify-between p-3 rounded-xl bg-coral-pink/5 hover:bg-coral-pink/10 transition-colors animate-fade-in-up" style={{ animationDelay: `${0.6 + index * 0.1}s` }}>
                <span className="text-text-primary font-secondary">{record}</span>
                <ChevronRight className="w-4 h-4 text-coral-pink" />
              </div>
            ))}
          </div>
          <button className="btn-outline-vibrant w-full mt-4">
            <Plus className="w-4 h-4 mr-2" />
            Add Record
          </button>
        </div>
      </div>
    </div>
  )
}

// Chat Tab Component
function ChatTab() {
  return (
    <div className="animate-fade-in">
      <div className="max-w-4xl mx-auto">
        <div className="card-playful">
          <div className="flex items-center space-x-3 mb-6">
            <MessageCircle className="w-6 h-6 text-coral-pink" />
            <h2 className="text-2xl font-bold text-text-primary font-accent text-gradient-coral">AI Pet Assistant</h2>
            <div className="w-3 h-3 bg-coral-pink rounded-full animate-pulse-glow" />
          </div>
          
          <div className="h-96 flex flex-col">
            {/* Chat Messages */}
            <div className="flex-1 space-y-4 overflow-y-auto p-4">
              <div className="flex items-start space-x-3 animate-fade-in-up">
                <div className="w-8 h-8 bg-gradient-coral rounded-full flex items-center justify-center shadow-vibrant">
                  <User className="w-4 h-4 text-white" />
                </div>
                <div className="card-glass max-w-md">
                  <p className="text-text-primary font-secondary">My dog seems lethargic today. Should I be concerned?</p>
                  <span className="text-xs text-text-secondary font-secondary">2:30 PM</span>
                </div>
              </div>
              
              <div className="flex items-start space-x-3 animate-fade-in-up" style={{ animationDelay: '0.2s' }}>
                <div className="w-8 h-8 bg-gradient-mint rounded-full flex items-center justify-center shadow-vibrant">
                  <MessageCircle className="w-4 h-4 text-white" />
                </div>
                <div className="card-gradient max-w-md">
                  <p className="text-text-primary font-secondary">
                    Lethargy can be concerning. Here are some things to check:
                  </p>
                  <ul className="mt-2 space-y-1 text-sm text-text-secondary font-secondary">
                    <li>• Check for fever (normal: 101-102.5°F)</li>
                    <li>• Monitor water intake</li>
                    <li>• Observe appetite changes</li>
                    <li>• Check for other symptoms</li>
                  </ul>
                  <p className="mt-3 text-sm text-coral-pink font-semibold">
                    If symptoms persist or worsen, contact your vet.
                  </p>
                  <span className="text-xs text-text-secondary font-secondary">2:32 PM</span>
                </div>
              </div>
            </div>
            
            {/* Chat Input */}
            <div className="border-t border-coral-pink/20 p-4">
              <div className="flex items-center space-x-3">
                <button className="p-2 rounded-xl hover:bg-coral-pink/10 transition-colors">
                  <Plus className="w-5 h-5 text-coral-pink" />
                </button>
                <input
                  type="text"
                  placeholder="Ask about your pet's health..."
                  className="input-playful flex-1"
                />
                <button className="btn-vibrant">
                  Send
                </button>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  )
}

export default App