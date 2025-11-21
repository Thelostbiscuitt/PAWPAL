import React from 'react';

const AnimatedIcon = ({ 
  icon: Icon, 
  size = 'md', 
  color = 'coral-pink', 
  animation = 'wiggle',
  className = '' 
}) => {
  const sizeClasses = {
    sm: 'w-4 h-4',
    md: 'w-6 h-6',
    lg: 'w-8 h-8',
    xl: 'w-10 h-10'
  };

  const colorClasses = {
    'coral-pink': 'text-coral-pink',
    'sunset-orange': 'text-sunset-orange',
    'mint-green': 'text-mint-green',
    'electric-purple': 'text-electric-purple',
    'sky-blue': 'text-sky-blue',
    'golden-yellow': 'text-golden-yellow'
  };

  const animationClasses = {
    wiggle: 'animate-wiggle',
    bounce: 'animate-bounce-slow',
    pulse: 'animate-pulse',
    float: 'animate-float',
    'paw-print': 'animate-paw-print'
  };

  return (
    <div className={`inline-flex items-center justify-center ${className}`}>
      <Icon 
        className={`${sizeClasses[size]} ${colorClasses[color]} ${animationClasses[animation]}`}
      />
    </div>
  );
};

export default AnimatedIcon;