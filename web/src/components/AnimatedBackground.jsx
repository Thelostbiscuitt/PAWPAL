import React from 'react';

const AnimatedBackground = () => {
  return (
    <div className="fixed inset-0 pointer-events-none overflow-hidden">
      {/* Floating paw prints */}
      <div className="absolute top-20 left-10 text-coral-pink/10 text-6xl animate-float" style={{ animationDelay: '0s' }}>🐾</div>
      <div className="absolute top-40 right-20 text-sunset-orange/10 text-4xl animate-float" style={{ animationDelay: '1s' }}>🦴</div>
      <div className="absolute bottom-30 left-30 text-mint-green/10 text-5xl animate-float" style={{ animationDelay: '2s' }}>🐾</div>
      <div className="absolute bottom-20 right-10 text-golden-yellow/10 text-3xl animate-float" style={{ animationDelay: '3s' }}>⚽</div>
      
      {/* Gradient orbs */}
      <div className="absolute top-0 left-0 w-96 h-96 bg-gradient-coral/20 rounded-full filter blur-3xl animate-pulse" />
      <div className="absolute bottom-0 right-0 w-96 h-96 bg-gradient-sunset/20 rounded-full filter blur-3xl animate-pulse" style={{ animationDelay: '1s' }} />
      <div className="absolute top-1/2 left-1/2 transform -translate-x-1/2 -translate-y-1/2 w-96 h-96 bg-gradient-mint/10 rounded-full filter blur-3xl animate-pulse" style={{ animationDelay: '2s' }} />
    </div>
  );
};

export default AnimatedBackground;