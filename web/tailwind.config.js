/** @type {import('tailwindcss').Config} */
export default {
  content: [
    "./index.html",
    "./src/**/*.{js,ts,jsx,tsx}",
  ],
  theme: {
    extend: {
      colors: {
        // Primary vibrant colors
        'coral-pink': '#FF6B6B',
        'sunset-orange': '#FF9F45',
        'electric-purple': '#845EC2',
        'sky-blue': '#4E8397',
        'mint-green': '#4FB06D',
        'golden-yellow': '#FFC93C',
        
        // Background system
        'primary-bg': '#FFF8F3',
        'secondary-bg': '#F7F3E9',
        'accent-bg': '#FFE5E5',
        
        // Text colors
        'text-primary': '#2D3436',
        'text-secondary': '#636E72',
        'text-accent': '#FF6B6B',
        
        // Semantic colors
        'success': '#4FB06D',
        'warning': '#FFC93C',
        'error': '#FF6B6B',
        'info': '#4E8397',
        
        // Legacy colors (for transition)
        background: '#FFF8F3',
        card: '#FFFFFF',
        accent: '#FF6B6B',
        'accent-hover': '#FF5252',
        'accent-light': '#FF8787',
        border: {
          card: 'rgba(255, 107, 107, 0.15)',
          hover: 'rgba(255, 107, 107, 0.25)',
          accent: 'rgba(255, 107, 107, 0.3)',
        }
      },
      fontFamily: {
        'primary': ['Poppins', 'sans-serif'],
        'secondary': ['Space Grotesk', 'sans-serif'],
        'accent': ['Fredoka One', 'cursive'],
        'sans': ['Poppins', 'system-ui', 'sans-serif'],
      },
      fontSize: {
        'xs': ['0.75rem', { lineHeight: '1rem' }],
        'sm': ['0.875rem', { lineHeight: '1.25rem' }],
        'base': ['1rem', { lineHeight: '1.5rem' }],
        'lg': ['1.125rem', { lineHeight: '1.75rem' }],
        'xl': ['1.25rem', { lineHeight: '1.75rem' }],
        '2xl': ['1.5rem', { lineHeight: '2rem' }],
        '3xl': ['1.875rem', { lineHeight: '2.25rem' }],
        '4xl': ['2.25rem', { lineHeight: '2.5rem' }],
        '5xl': ['3rem', { lineHeight: '1' }],
        '6xl': ['3.75rem', { lineHeight: '1' }],
      },
      animation: {
        'fade-in': 'fadeIn 0.6s ease-out',
        'fade-in-up': 'fadeInUp 0.6s ease-out',
        'slide-in-right': 'slideInRight 0.5s ease-out',
        'slide-in-left': 'slideInLeft 0.5s ease-out',
        'bounce-in': 'bounceIn 0.8s cubic-bezier(0.68, -0.55, 0.265, 1.55)',
        'pulse-glow': 'pulseGlow 2s infinite',
        'float': 'float 6s ease-in-out infinite',
        'wiggle': 'wiggle 1s ease-in-out infinite',
        'gradient-shift': 'gradientShift 3s ease infinite',
        'paw-print': 'pawPrint 2s ease-in-out infinite',
        'bounce-slow': 'bounce 2s infinite',
      },
      keyframes: {
        fadeIn: {
          '0%': { opacity: '0' },
          '100%': { opacity: '1' },
        },
        fadeInUp: {
          '0%': { opacity: '0', transform: 'translateY(30px)' },
          '100%': { opacity: '1', transform: 'translateY(0)' },
        },
        slideInRight: {
          '0%': { opacity: '0', transform: 'translateX(30px)' },
          '100%': { opacity: '1', transform: 'translateX(0)' },
        },
        slideInLeft: {
          '0%': { opacity: '0', transform: 'translateX(-30px)' },
          '100%': { opacity: '1', transform: 'translateX(0)' },
        },
        bounceIn: {
          '0%': { transform: 'scale(0.3)', opacity: '0' },
          '50%': { transform: 'scale(1.05)' },
          '70%': { transform: 'scale(0.9)' },
          '100%': { transform: 'scale(1)', opacity: '1' },
        },
        pulseGlow: {
          '0%, 100%': {
            boxShadow: '0 0 20px rgba(255, 107, 107, 0.4)'
          },
          '50%': {
            boxShadow: '0 0 30px rgba(255, 107, 107, 0.8)'
          },
        },
        float: {
          '0%, 100%': { transform: 'translateY(0px)' },
          '50%': { transform: 'translateY(-10px)' },
        },
        wiggle: {
          '0%, 100%': { transform: 'rotate(-3deg)' },
          '50%': { transform: 'rotate(3deg)' },
        },
        gradientShift: {
          '0%': { backgroundPosition: '0% 50%' },
          '50%': { backgroundPosition: '100% 50%' },
          '100%': { backgroundPosition: '0% 50%' },
        },
        pawPrint: {
          '0%': { transform: 'scale(1) rotate(0deg)' },
          '25%': { transform: 'scale(1.1) rotate(5deg)' },
          '50%': { transform: 'scale(1) rotate(0deg)' },
          '75%': { transform: 'scale(1.1) rotate(-5deg)' },
          '100%': { transform: 'scale(1) rotate(0deg)' },
        },
      },
      backgroundImage: {
        'gradient-radial': 'radial-gradient(var(--tw-gradient-stops))',
        'gradient-conic': 'conic-gradient(from 180deg at 50% 50%, var(--tw-gradient-stops))',
        'gradient-vibrant': 'linear-gradient(135deg, #FF6B6B 0%, #FF9F45 25%, #FFC93C 50%, #4FB06D 75%, #4E8397 100%)',
        'gradient-coral': 'linear-gradient(135deg, #FF6B6B 0%, #FF8787 100%)',
        'gradient-sunset': 'linear-gradient(135deg, #FF9F45 0%, #FFC93C 100%)',
        'gradient-purple': 'linear-gradient(135deg, #845EC2 0%, #B39CD0 100%)',
        'gradient-mint': 'linear-gradient(135deg, #4FB06D 0%, #95E1D3 100%)',
      },
      backgroundSize: {
        '300%': '300%',
      },
      boxShadow: {
        'vibrant': '0 10px 40px rgba(255, 107, 107, 0.25)',
        'vibrant-lg': '0 20px 60px rgba(255, 107, 107, 0.35)',
        'colorful': '0 8px 32px rgba(255, 107, 107, 0.2), 0 4px 16px rgba(255, 159, 69, 0.15)',
        'playful': '0 4px 20px rgba(132, 94, 194, 0.15), 0 2px 8px rgba(255, 201, 60, 0.1)',
      },
      spacing: {
        '18': '4.5rem',
        '88': '22rem',
        '128': '32rem',
      },
      borderRadius: {
        '4xl': '2rem',
        '5xl': '2.5rem',
      },
      backdropBlur: {
        'xs': '2px',
        'sm': '4px',
        'md': '8px',
        'lg': '16px',
        'xl': '24px',
        '2xl': '32px',
      },
      transitionDuration: {
        '400': '400ms',
        '600': '600ms',
      },
      transitionTimingFunction: {
        'bounce': 'cubic-bezier(0.68, -0.55, 0.265, 1.55)',
        'smooth': 'cubic-bezier(0.25, 0.46, 0.45, 0.94)',
      },
    },
  },
  plugins: [],
}