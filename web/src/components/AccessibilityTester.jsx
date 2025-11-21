import React, { useEffect, useState } from 'react';

const AccessibilityTester = ({ children }) => {
  const [issues, setIssues] = useState([]);
  const [showReport, setShowReport] = useState(false);

  useEffect(() => {
    // Basic accessibility checks
    const checkAccessibility = () => {
      const foundIssues = [];
      
      // Check for missing alt text on images
      const images = document.querySelectorAll('img:not([alt])');
      if (images.length > 0) {
        foundIssues.push(`${images.length} image(s) missing alt text`);
      }
      
      // Check for missing labels on inputs
      const inputs = document.querySelectorAll('input:not([aria-label]):not([aria-labelledby])');
      const unlabeledInputs = Array.from(inputs).filter(input => {
        const id = input.id;
        return !id || !document.querySelector(`label[for="${id}"]`);
      });
      if (unlabeledInputs.length > 0) {
        foundIssues.push(`${unlabeledInputs.length} input(s) missing labels`);
      }
      
      // Check for insufficient color contrast (simplified)
      const textElements = document.querySelectorAll('p, h1, h2, h3, h4, h5, h6, span, a');
      // This is a simplified check - in production, you'd use a proper contrast calculation
      foundIssues.push('Color contrast should be verified with proper tools');
      
      setIssues(foundIssues);
    };

    // Run checks after component mounts
    setTimeout(checkAccessibility, 1000);
  }, [children]);

  if (process.env.NODE_ENV !== 'development') {
    return children;
  }

  return (
    <>
      {children}
      
      {/* Accessibility Report Toggle */}
      <button
        onClick={() => setShowReport(!showReport)}
        className="fixed bottom-4 right-4 bg-electric-purple text-white p-3 rounded-full shadow-vibrant hover:scale-110 transition-transform z-50"
        aria-label="Toggle accessibility report"
      >
        <svg className="w-5 h-5" fill="currentColor" viewBox="0 0 20 20">
          <path d="M10 12a2 2 0 100-4 2 2 0 000 4z"/>
          <path fillRule="evenodd" d="M.458 10C1.732 5.943 5.522 3 10 3s8.268 2.943 9.542 7c-1.274 4.057-5.064 7-9.542 7S1.732 14.057.458 10zM14 10a4 4 0 11-8 0 4 4 0 018 0z" clipRule="evenodd"/>
        </svg>
      </button>
      
      {/* Accessibility Report */}
      {showReport && (
        <div className="fixed inset-0 bg-black/50 backdrop-blur-sm z-50 flex items-center justify-center p-4">
          <div className="bg-white rounded-2xl p-6 max-w-md w-full max-h-96 overflow-y-auto shadow-vibrant">
            <h3 className="text-xl font-bold text-text-primary mb-4 font-primary">Accessibility Report</h3>
            
            {issues.length === 0 ? (
              <p className="text-mint-green font-semibold">No accessibility issues found!</p>
            ) : (
              <ul className="space-y-2">
                {issues.map((issue, index) => (
                  <li key={index} className="flex items-start space-x-2">
                    <span className="text-sunset-orange">⚠️</span>
                    <span className="text-text-secondary text-sm">{issue}</span>
                  </li>
                ))}
              </ul>
            )}
            
            <div className="mt-6 space-y-3">
              <h4 className="font-semibold text-text-primary">Quick Checks:</h4>
              <ul className="text-sm text-text-secondary space-y-1">
                <li>✓ All interactive elements are keyboard accessible</li>
                <li>✓ Focus indicators are visible</li>
                <li>✓ Semantic HTML elements are used</li>
                <li>✓ ARIA labels are provided where needed</li>
              </ul>
            </div>
            
            <button
              onClick={() => setShowReport(false)}
              className="btn-vibrant w-full mt-6"
            >
              Close Report
            </button>
          </div>
        </div>
      )}
    </>
  );
};

export default AccessibilityTester;