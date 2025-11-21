import React from 'react';

const ResponsiveWrapper = ({ 
  children, 
  className = '',
  mobileClassName = '',
  tabletClassName = '',
  desktopClassName = ''
}) => {
  return (
    <div className={`
      ${className}
      ${mobileClassName} // Mobile-first approach
      md:${tabletClassName} // Tablet styles
      lg:${desktopClassName} // Desktop styles
    `}>
      {children}
    </div>
  );
};

export default ResponsiveWrapper;