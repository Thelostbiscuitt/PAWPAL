import React from 'react';

const LoadingSpinner = ({ size = 'md' }) => {
  const sizeClasses = {
    sm: 'w-4 h-4',
    md: 'w-8 h-8',
    lg: 'w-12 h-12',
    xl: 'w-16 h-16'
  };

  return (
    <div className="flex items-center justify-center space-x-2">
      <div className={`${sizeClasses[size]} bg-gradient-coral rounded-full animate-pulse`} />
      <div className={`${sizeClasses[size]} bg-gradient-sunset rounded-full animate-pulse`} style={{ animationDelay: '0.2s' }} />
      <div className={`${sizeClasses[size]} bg-gradient-mint rounded-full animate-pulse`} style={{ animationDelay: '0.4s' }} />
    </div>
  );
};

export default LoadingSpinner;