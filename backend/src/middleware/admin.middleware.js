const db = require('../utils/database');

/**
 * Middleware to check if user has admin privileges
 * This middleware should be used after auth middleware
 */
const adminMiddleware = async (req, res, next) => {
  try {
    // User should already be attached to req by auth middleware
    if (!req.user) {
      return res.status(401).json({
        success: false,
        message: 'Authentication required'
      });
    }

    // Check if user is admin
    if (req.user.role !== 'admin') {
      return res.status(403).json({
        success: false,
        message: 'Admin privileges required'
      });
    }

    // Optional: Check if admin account is still active
    const adminCheckQuery = `
      SELECT id, email, role, is_active 
      FROM users 
      WHERE id = $1 AND role = 'admin' AND is_active = true
    `;
    
    const result = await db.query(adminCheckQuery, [req.user.id]);
    
    if (result.rows.length === 0) {
      return res.status(403).json({
        success: false,
        message: 'Admin account not found or inactive'
      });
    }

    // Attach admin user info to request
    req.admin = result.rows[0];
    
    next();
  } catch (error) {
    console.error('Admin middleware error:', error);
    res.status(500).json({
      success: false,
      message: 'Internal server error during admin verification'
    });
  }
};

/**
 * Middleware to check specific admin permissions
 * Can be extended for role-based permissions within admin
 */
const checkAdminPermission = (permission) => {
  return async (req, res, next) => {
    try {
      // For now, all admins have all permissions
      // In a more complex system, you might have different admin roles
      if (req.user.role !== 'admin') {
        return res.status(403).json({
          success: false,
          message: 'Admin privileges required'
        });
      }

      // Log admin action for audit trail
      await logAdminAction(req.user.id, req.method, req.originalUrl, permission);
      
      next();
    } catch (error) {
      console.error('Permission check error:', error);
      res.status(500).json({
        success: false,
        message: 'Internal server error during permission check'
      });
    }
  };
};

/**
 * Log admin actions for audit trail
 */
const logAdminAction = async (adminId, method, url, permission) => {
  try {
    const logQuery = `
      INSERT INTO admin_action_logs 
      (admin_id, action_type, endpoint, permission, ip_address, user_agent, timestamp)
      VALUES ($1, $2, $3, $4, $5, $6, CURRENT_TIMESTAMP)
    `;
    
    // In a real implementation, you'd get IP and user agent from req
    await db.query(logQuery, [
      adminId,
      method,
      url,
      permission || 'general',
      '127.0.0.1', // Would be req.ip in production
      'Pet Support Admin' // Would be req.get('User-Agent') in production
    ]);
  } catch (error) {
    console.error('Failed to log admin action:', error);
    // Don't throw error here, just log it
  }
};

module.exports = {
  adminMiddleware,
  checkAdminPermission
};