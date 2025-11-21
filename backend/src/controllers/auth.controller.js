const bcrypt = require('bcryptjs');
const { validationResult } = require('express-validator');
const { v4: uuidv4 } = require('uuid');
const { query, transaction } = require('../utils/database');
const { generateTokens, verifyRefreshToken } = require('../middleware/auth.middleware');
const { 
  ValidationError, 
  UnauthorizedError, 
  NotFoundError, 
  ConflictError,
  asyncHandler 
} = require('../middleware/error.middleware');

// User registration
const register = asyncHandler(async (req, res) => {
  // Validate input
  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    throw new ValidationError('Validation failed', errors.array());
  }

  const { email, password, firstName, lastName, phone } = req.body;

  // Check if user already exists
  const existingUser = await query(
    'SELECT id FROM users WHERE email = $1',
    [email]
  );

  if (existingUser.rows.length > 0) {
    throw new ConflictError('User with this email already exists');
  }

  // Hash password
  const saltRounds = 12;
  const passwordHash = await bcrypt.hash(password, saltRounds);

  // Generate email verification token
  const verificationToken = uuidv4();

  // Create user
  const result = await query(
    `INSERT INTO users (email, password_hash, first_name, last_name, phone, email_verification_token) 
     VALUES ($1, $2, $3, $4, $5, $6) 
     RETURNING id, email, first_name, last_name, phone, is_verified, created_at`,
    [email, passwordHash, firstName, lastName, phone, verificationToken]
  );

  const user = result.rows[0];

  // Generate tokens
  const { accessToken, refreshToken } = generateTokens(user.id, user.email);

  // TODO: Send verification email (implement email service)

  res.status(201).json({
    message: 'User registered successfully. Please check your email for verification.',
    user: {
      id: user.id,
      email: user.email,
      firstName: user.first_name,
      lastName: user.last_name,
      phone: user.phone,
      isVerified: user.is_verified,
      createdAt: user.created_at
    },
    tokens: {
      accessToken,
      refreshToken
    }
  });
});

// User login
const login = asyncHandler(async (req, res) => {
  // Validate input
  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    throw new ValidationError('Validation failed', errors.array());
  }

  const { email, password } = req.body;

  // Find user
  const result = await query(
    'SELECT id, email, password_hash, first_name, last_name, phone, is_verified FROM users WHERE email = $1',
    [email]
  );

  if (result.rows.length === 0) {
    throw new UnauthorizedError('Invalid email or password');
  }

  const user = result.rows[0];

  // Verify password
  const isPasswordValid = await bcrypt.compare(password, user.password_hash);
  if (!isPasswordValid) {
    throw new UnauthorizedError('Invalid email or password');
  }

  // Generate tokens
  const { accessToken, refreshToken } = generateTokens(user.id, user.email);

  res.json({
    message: 'Login successful',
    user: {
      id: user.id,
      email: user.email,
      firstName: user.first_name,
      lastName: user.last_name,
      phone: user.phone,
      isVerified: user.is_verified
    },
    tokens: {
      accessToken,
      refreshToken
    }
  });
});

// Refresh access token
const refreshToken = asyncHandler(async (req, res) => {
  // Validate input
  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    throw new ValidationError('Validation failed', errors.array());
  }

  const { refreshToken } = req.body;

  try {
    // Verify refresh token
    const decoded = verifyRefreshToken(refreshToken);
    
    // Check if user still exists
    const result = await query(
      'SELECT id, email FROM users WHERE id = $1',
      [decoded.userId]
    );

    if (result.rows.length === 0) {
      throw new UnauthorizedError('Invalid refresh token');
    }

    const user = result.rows[0];

    // Generate new tokens
    const tokens = generateTokens(user.id, user.email);

    res.json({
      message: 'Token refreshed successfully',
      tokens
    });
  } catch (error) {
    throw new UnauthorizedError('Invalid refresh token');
  }
});

// User logout
const logout = asyncHandler(async (req, res) => {
  // TODO: Implement token blacklist or refresh token invalidation
  res.json({
    message: 'Logout successful'
  });
});

// Send email verification
const sendEmailVerification = asyncHandler(async (req, res) => {
  const userId = req.user.id;
  
  // Generate new verification token
  const verificationToken = uuidv4();
  
  // Update user with new token
  await query(
    'UPDATE users SET email_verification_token = $1 WHERE id = $2',
    [verificationToken, userId]
  );

  // TODO: Send verification email

  res.json({
    message: 'Verification email sent successfully'
  });
});

// Verify email
const verifyEmail = asyncHandler(async (req, res) => {
  // Validate input
  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    throw new ValidationError('Validation failed', errors.array());
  }

  const { token } = req.body;

  // Find user with verification token
  const result = await query(
    'SELECT id FROM users WHERE email_verification_token = $1',
    [token]
  );

  if (result.rows.length === 0) {
    throw new NotFoundError('Invalid or expired verification token');
  }

  // Verify user and clear token
  await query(
    'UPDATE users SET is_verified = true, email_verification_token = NULL WHERE id = $1',
    [result.rows[0].id]
  );

  res.json({
    message: 'Email verified successfully'
  });
});

// Forgot password
const forgotPassword = asyncHandler(async (req, res) => {
  // Validate input
  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    throw new ValidationError('Validation failed', errors.array());
  }

  const { email } = req.body;

  // Check if user exists
  const result = await query(
    'SELECT id FROM users WHERE email = $1',
    [email]
  );

  if (result.rows.length === 0) {
    // Don't reveal if user exists or not
    res.json({
      message: 'If an account with this email exists, a password reset link has been sent'
    });
    return;
  }

  // Generate reset token
  const resetToken = uuidv4();
  const resetExpires = new Date(Date.now() + 3600000); // 1 hour from now

  // Update user with reset token
  await query(
    'UPDATE users SET password_reset_token = $1, password_reset_expires = $2 WHERE id = $3',
    [resetToken, resetExpires, result.rows[0].id]
  );

  // TODO: Send password reset email

  res.json({
    message: 'If an account with this email exists, a password reset link has been sent'
  });
});

// Reset password
const resetPassword = asyncHandler(async (req, res) => {
  // Validate input
  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    throw new ValidationError('Validation failed', errors.array());
  }

  const { token, password } = req.body;

  // Find user with valid reset token
  const result = await query(
    'SELECT id FROM users WHERE password_reset_token = $1 AND password_reset_expires > NOW()',
    [token]
  );

  if (result.rows.length === 0) {
    throw new NotFoundError('Invalid or expired reset token');
  }

  // Hash new password
  const saltRounds = 12;
  const passwordHash = await bcrypt.hash(password, saltRounds);

  // Update password and clear reset token
  await query(
    'UPDATE users SET password_hash = $1, password_reset_token = NULL, password_reset_expires = NULL WHERE id = $2',
    [passwordHash, result.rows[0].id]
  );

  res.json({
    message: 'Password reset successfully'
  });
});

// Change password
const changePassword = asyncHandler(async (req, res) => {
  // Validate input
  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    throw new ValidationError('Validation failed', errors.array());
  }

  const { currentPassword, newPassword } = req.body;
  const userId = req.user.id;

  // Get current password hash
  const result = await query(
    'SELECT password_hash FROM users WHERE id = $1',
    [userId]
  );

  if (result.rows.length === 0) {
    throw new NotFoundError('User not found');
  }

  // Verify current password
  const isCurrentPasswordValid = await bcrypt.compare(currentPassword, result.rows[0].password_hash);
  if (!isCurrentPasswordValid) {
    throw new UnauthorizedError('Current password is incorrect');
  }

  // Hash new password
  const saltRounds = 12;
  const newPasswordHash = await bcrypt.hash(newPassword, saltRounds);

  // Update password
  await query(
    'UPDATE users SET password_hash = $1 WHERE id = $2',
    [newPasswordHash, userId]
  );

  res.json({
    message: 'Password changed successfully'
  });
});

// Get user profile
const getProfile = asyncHandler(async (req, res) => {
  const userId = req.user.id;

  const result = await query(
    `SELECT id, email, first_name, last_name, phone, location_lat, location_lng, 
            city, country, is_verified, created_at, updated_at 
     FROM users WHERE id = $1`,
    [userId]
  );

  if (result.rows.length === 0) {
    throw new NotFoundError('User not found');
  }

  const user = result.rows[0];

  res.json({
    user: {
      id: user.id,
      email: user.email,
      firstName: user.first_name,
      lastName: user.last_name,
      phone: user.phone,
      location: user.location_lat && user.location_lng ? {
        lat: user.location_lat,
        lng: user.location_lng
      } : null,
      city: user.city,
      country: user.country,
      isVerified: user.is_verified,
      createdAt: user.created_at,
      updatedAt: user.updated_at
    }
  });
});

// Update user profile
const updateProfile = asyncHandler(async (req, res) => {
  // Validate input
  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    throw new ValidationError('Validation failed', errors.array());
  }

  const { firstName, lastName, phone, city, country, location } = req.body;
  const userId = req.user.id;

  // Build update query dynamically
  const updates = [];
  const values = [];
  let paramIndex = 1;

  if (firstName !== undefined) {
    updates.push(`first_name = $${paramIndex++}`);
    values.push(firstName);
  }
  if (lastName !== undefined) {
    updates.push(`last_name = $${paramIndex++}`);
    values.push(lastName);
  }
  if (phone !== undefined) {
    updates.push(`phone = $${paramIndex++}`);
    values.push(phone);
  }
  if (city !== undefined) {
    updates.push(`city = $${paramIndex++}`);
    values.push(city);
  }
  if (country !== undefined) {
    updates.push(`country = $${paramIndex++}`);
    values.push(country);
  }
  if (location !== undefined) {
    updates.push(`location_lat = $${paramIndex++}`);
    values.push(location.lat);
    updates.push(`location_lng = $${paramIndex++}`);
    values.push(location.lng);
  }

  if (updates.length === 0) {
    throw new ValidationError('No fields to update');
  }

  // Add user ID to values
  values.push(userId);

  const result = await query(
    `UPDATE users SET ${updates.join(', ')} WHERE id = $${paramIndex} RETURNING *`,
    values
  );

  if (result.rows.length === 0) {
    throw new NotFoundError('User not found');
  }

  const user = result.rows[0];

  res.json({
    message: 'Profile updated successfully',
    user: {
      id: user.id,
      email: user.email,
      firstName: user.first_name,
      lastName: user.last_name,
      phone: user.phone,
      location: user.location_lat && user.location_lng ? {
        lat: user.location_lat,
        lng: user.location_lng
      } : null,
      city: user.city,
      country: user.country,
      isVerified: user.is_verified,
      createdAt: user.created_at,
      updatedAt: user.updated_at
    }
  });
});

module.exports = {
  register,
  login,
  refreshToken,
  logout,
  sendEmailVerification,
  verifyEmail,
  forgotPassword,
  resetPassword,
  changePassword,
  getProfile,
  updateProfile
};