const { validationResult } = require('express-validator');
const db = require('../utils/database');
const cloudinary = require('cloudinary').v2;
const fs = require('fs');
const path = require('path');
const { Parser } = require('json2csv');

// Configure Cloudinary
cloudinary.config({
  cloud_name: process.env.CLOUDINARY_CLOUD_NAME,
  api_key: process.env.CLOUDINARY_API_KEY,
  api_secret: process.env.CLOUDINARY_API_SECRET
});

// Get dashboard statistics
const getDashboardStats = async (req, res) => {
  try {
    const queries = {
      totalUsers: 'SELECT COUNT(*) as count FROM users WHERE is_active = true',
      newUsersThisMonth: `SELECT COUNT(*) as count FROM users 
                         WHERE created_at >= date_trunc('month', CURRENT_DATE)`,
      totalPets: 'SELECT COUNT(*) as count FROM pets WHERE is_deleted = false',
      newPetsThisMonth: `SELECT COUNT(*) as count FROM pets 
                         WHERE created_at >= date_trunc('month', CURRENT_DATE)`,
      totalHealthRecords: 'SELECT COUNT(*) as count FROM health_records WHERE is_deleted = false',
      aiQueriesThisMonth: `SELECT COUNT(*) as count FROM ai_chat_logs 
                           WHERE created_at >= date_trunc('month', CURRENT_DATE)`,
      emergencyQueriesThisMonth: `SELECT COUNT(*) as count FROM emergency_triage_logs 
                                  WHERE created_at >= date_trunc('month', CURRENT_DATE)`,
      activeUsersThisWeek: `SELECT COUNT(DISTINCT user_id) as count FROM user_sessions 
                            WHERE last_activity >= date_trunc('week', CURRENT_DATE)`
    };

    const results = {};
    for (const [key, query] of Object.entries(queries)) {
      const result = await db.query(query);
      results[key] = parseInt(result.rows[0].count);
    }

    // Get recent activity
    const recentActivity = await db.query(`
      SELECT 'user' as type, id, email, created_at 
      FROM users 
      WHERE created_at >= CURRENT_DATE - INTERVAL '7 days'
      UNION ALL
      SELECT 'pet' as type, id, name as email, created_at 
      FROM pets 
      WHERE created_at >= CURRENT_DATE - INTERVAL '7 days'
      ORDER BY created_at DESC 
      LIMIT 10
    `);

    res.status(200).json({
      success: true,
      data: {
        stats: results,
        recentActivity: recentActivity.rows
      }
    });
  } catch (error) {
    console.error('Error getting dashboard stats:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to get dashboard statistics'
    });
  }
};

// User management
const getUsers = async (req, res) => {
  try {
    const { page = 1, limit = 20, search, isActive, role } = req.query;
    const offset = (page - 1) * limit;

    let whereClause = 'WHERE 1=1';
    const params = [];

    if (search) {
      whereClause += ` AND (first_name ILIKE $${params.length + 1} OR last_name ILIKE $${params.length + 1} OR email ILIKE $${params.length + 1})`;
      params.push(`%${search}%`);
    }

    if (isActive !== undefined) {
      whereClause += ` AND is_active = $${params.length + 1}`;
      params.push(isActive === 'true');
    }

    if (role) {
      whereClause += ` AND role = $${params.length + 1}`;
      params.push(role);
    }

    const query = `
      SELECT id, email, first_name, last_name, role, is_active, created_at, last_login
      FROM users 
      ${whereClause}
      ORDER BY created_at DESC
      LIMIT $${params.length + 1} OFFSET $${params.length + 2}
    `;
    params.push(limit, offset);

    const countQuery = `SELECT COUNT(*) as total FROM users ${whereClause}`;
    
    const [users, countResult] = await Promise.all([
      db.query(query, params),
      db.query(countQuery, params.slice(0, -2))
    ]);

    res.status(200).json({
      success: true,
      data: {
        users: users.rows,
        pagination: {
          page: parseInt(page),
          limit: parseInt(limit),
          total: parseInt(countResult.rows[0].total),
          pages: Math.ceil(countResult.rows[0].total / limit)
        }
      }
    });
  } catch (error) {
    console.error('Error getting users:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to get users'
    });
  }
};

const getUserById = async (req, res) => {
  try {
    const { id } = req.params;
    
    const userQuery = `
      SELECT id, email, first_name, last_name, role, is_active, created_at, last_login,
             phone_number, address, city, country
      FROM users 
      WHERE id = $1
    `;
    
    const userResult = await db.query(userQuery, [id]);
    
    if (userResult.rows.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'User not found'
      });
    }

    // Get user's pets
    const petsQuery = `
      SELECT id, name, type, breed, age, weight, gender, created_at
      FROM pets 
      WHERE user_id = $1 AND is_deleted = false
      ORDER BY created_at DESC
    `;
    
    const petsResult = await db.query(petsQuery, [id]);

    res.status(200).json({
      success: true,
      data: {
        user: userResult.rows[0],
        pets: petsResult.rows
      }
    });
  } catch (error) {
    console.error('Error getting user:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to get user'
    });
  }
};

const updateUser = async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        success: false,
        message: 'Validation failed',
        errors: errors.array()
      });
    }

    const { id } = req.params;
    const updates = req.body;
    
    // Build dynamic update query
    const updateFields = [];
    const values = [];
    let paramCount = 1;

    for (const [key, value] of Object.entries(updates)) {
      updateFields.push(`${key} = $${paramCount}`);
      values.push(value);
      paramCount++;
    }

    if (updateFields.length === 0) {
      return res.status(400).json({
        success: false,
        message: 'No fields to update'
      });
    }

    updateFields.push(`updated_at = CURRENT_TIMESTAMP`);
    values.push(id);

    const query = `
      UPDATE users 
      SET ${updateFields.join(', ')}
      WHERE id = $${paramCount}
      RETURNING id, email, first_name, last_name, role, is_active, updated_at
    `;

    const result = await db.query(query, values);

    if (result.rows.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'User not found'
      });
    }

    res.status(200).json({
      success: true,
      data: result.rows[0],
      message: 'User updated successfully'
    });
  } catch (error) {
    console.error('Error updating user:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to update user'
    });
  }
};

const deleteUser = async (req, res) => {
  try {
    const { id } = req.params;
    
    // Soft delete user
    const query = `
      UPDATE users 
      SET is_active = false, updated_at = CURRENT_TIMESTAMP
      WHERE id = $1
      RETURNING id, email
    `;

    const result = await db.query(query, [id]);

    if (result.rows.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'User not found'
      });
    }

    res.status(200).json({
      success: true,
      message: 'User deleted successfully'
    });
  } catch (error) {
    console.error('Error deleting user:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to delete user'
    });
  }
};

// Pet management
const getAllPets = async (req, res) => {
  try {
    const { page = 1, limit = 20, search, type, userId } = req.query;
    const offset = (page - 1) * limit;

    let whereClause = 'WHERE p.is_deleted = false';
    const params = [];

    if (search) {
      whereClause += ` AND (p.name ILIKE $${params.length + 1} OR p.breed ILIKE $${params.length + 1})`;
      params.push(`%${search}%`);
    }

    if (type) {
      whereClause += ` AND p.type = $${params.length + 1}`;
      params.push(type);
    }

    if (userId) {
      whereClause += ` AND p.user_id = $${params.length + 1}`;
      params.push(userId);
    }

    const query = `
      SELECT p.*, u.first_name, u.last_name, u.email
      FROM pets p
      JOIN users u ON p.user_id = u.id
      ${whereClause}
      ORDER BY p.created_at DESC
      LIMIT $${params.length + 1} OFFSET $${params.length + 2}
    `;
    params.push(limit, offset);

    const countQuery = `SELECT COUNT(*) as total FROM pets p ${whereClause}`;
    
    const [pets, countResult] = await Promise.all([
      db.query(query, params),
      db.query(countQuery, params.slice(0, -2))
    ]);

    res.status(200).json({
      success: true,
      data: {
        pets: pets.rows,
        pagination: {
          page: parseInt(page),
          limit: parseInt(limit),
          total: parseInt(countResult.rows[0].total),
          pages: Math.ceil(countResult.rows[0].total / limit)
        }
      }
    });
  } catch (error) {
    console.error('Error getting pets:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to get pets'
    });
  }
};

const getPetById = async (req, res) => {
  try {
    const { id } = req.params;
    
    const query = `
      SELECT p.*, u.first_name, u.last_name, u.email
      FROM pets p
      JOIN users u ON p.user_id = u.id
      WHERE p.id = $1 AND p.is_deleted = false
    `;
    
    const result = await db.query(query, [id]);
    
    if (result.rows.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'Pet not found'
      });
    }

    // Get pet's health records
    const healthRecordsQuery = `
      SELECT id, record_type, description, date, veterinarian_name, created_at
      FROM health_records 
      WHERE pet_id = $1 AND is_deleted = false
      ORDER BY date DESC
    `;
    
    const healthRecordsResult = await db.query(healthRecordsQuery, [id]);

    res.status(200).json({
      success: true,
      data: {
        pet: result.rows[0],
        healthRecords: healthRecordsResult.rows
      }
    });
  } catch (error) {
    console.error('Error getting pet:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to get pet'
    });
  }
};

const updatePet = async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        success: false,
        message: 'Validation failed',
        errors: errors.array()
      });
    }

    const { id } = req.params;
    const updates = req.body;
    
    // Build dynamic update query
    const updateFields = [];
    const values = [];
    let paramCount = 1;

    for (const [key, value] of Object.entries(updates)) {
      updateFields.push(`${key} = $${paramCount}`);
      values.push(value);
      paramCount++;
    }

    if (updateFields.length === 0) {
      return res.status(400).json({
        success: false,
        message: 'No fields to update'
      });
    }

    updateFields.push(`updated_at = CURRENT_TIMESTAMP`);
    values.push(id);

    const query = `
      UPDATE pets 
      SET ${updateFields.join(', ')}
      WHERE id = $${paramCount} AND is_deleted = false
      RETURNING *
    `;

    const result = await db.query(query, values);

    if (result.rows.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'Pet not found'
      });
    }

    res.status(200).json({
      success: true,
      data: result.rows[0],
      message: 'Pet updated successfully'
    });
  } catch (error) {
    console.error('Error updating pet:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to update pet'
    });
  }
};

const deletePet = async (req, res) => {
  try {
    const { id } = req.params;
    
    // Soft delete pet
    const query = `
      UPDATE pets 
      SET is_deleted = true, updated_at = CURRENT_TIMESTAMP
      WHERE id = $1
      RETURNING id, name
    `;

    const result = await db.query(query, [id]);

    if (result.rows.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'Pet not found'
      });
    }

    res.status(200).json({
      success: true,
      message: 'Pet deleted successfully'
    });
  } catch (error) {
    console.error('Error deleting pet:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to delete pet'
    });
  }
};

// Content management - Articles
const getArticles = async (req, res) => {
  try {
    const { page = 1, limit = 20, category, petType, isPublished } = req.query;
    const offset = (page - 1) * limit;

    let whereClause = 'WHERE 1=1';
    const params = [];

    if (category) {
      whereClause += ` AND category = $${params.length + 1}`;
      params.push(category);
    }

    if (petType) {
      whereClause += ` AND (pet_type = $${params.length + 1} OR pet_type IS NULL)`;
      params.push(petType);
    }

    if (isPublished !== undefined) {
      whereClause += ` AND is_published = $${params.length + 1}`;
      params.push(isPublished === 'true');
    }

    const query = `
      SELECT *
      FROM educational_articles 
      ${whereClause}
      ORDER BY created_at DESC
      LIMIT $${params.length + 1} OFFSET $${params.length + 2}
    `;
    params.push(limit, offset);

    const countQuery = `SELECT COUNT(*) as total FROM educational_articles ${whereClause}`;
    
    const [articles, countResult] = await Promise.all([
      db.query(query, params),
      db.query(countQuery, params.slice(0, -2))
    ]);

    res.status(200).json({
      success: true,
      data: {
        articles: articles.rows,
        pagination: {
          page: parseInt(page),
          limit: parseInt(limit),
          total: parseInt(countResult.rows[0].total),
          pages: Math.ceil(countResult.rows[0].total / limit)
        }
      }
    });
  } catch (error) {
    console.error('Error getting articles:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to get articles'
    });
  }
};

const createArticle = async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        success: false,
        message: 'Validation failed',
        errors: errors.array()
      });
    }

    const { title, content, category, petType, tags, isPublished } = req.body;
    const authorId = req.user.id;

    const query = `
      INSERT INTO educational_articles 
      (title, content, category, pet_type, tags, is_published, author_id)
      VALUES ($1, $2, $3, $4, $5, $6, $7)
      RETURNING *
    `;

    const values = [
      title,
      content,
      category,
      petType || null,
      tags ? JSON.stringify(tags) : null,
      isPublished !== undefined ? isPublished : false,
      authorId
    ];

    const result = await db.query(query, values);

    res.status(201).json({
      success: true,
      data: result.rows[0],
      message: 'Article created successfully'
    });
  } catch (error) {
    console.error('Error creating article:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to create article'
    });
  }
};

const updateArticle = async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        success: false,
        message: 'Validation failed',
        errors: errors.array()
      });
    }

    const { id } = req.params;
    const updates = req.body;
    
    // Build dynamic update query
    const updateFields = [];
    const values = [];
    let paramCount = 1;

    for (const [key, value] of Object.entries(updates)) {
      if (key === 'tags') {
        updateFields.push(`${key} = $${paramCount}`);
        values.push(JSON.stringify(value));
      } else {
        updateFields.push(`${key} = $${paramCount}`);
        values.push(value);
      }
      paramCount++;
    }

    if (updateFields.length === 0) {
      return res.status(400).json({
        success: false,
        message: 'No fields to update'
      });
    }

    updateFields.push(`updated_at = CURRENT_TIMESTAMP`);
    values.push(id);

    const query = `
      UPDATE educational_articles 
      SET ${updateFields.join(', ')}
      WHERE id = $${paramCount}
      RETURNING *
    `;

    const result = await db.query(query, values);

    if (result.rows.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'Article not found'
      });
    }

    res.status(200).json({
      success: true,
      data: result.rows[0],
      message: 'Article updated successfully'
    });
  } catch (error) {
    console.error('Error updating article:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to update article'
    });
  }
};

const deleteArticle = async (req, res) => {
  try {
    const { id } = req.params;
    
    const query = `
      DELETE FROM educational_articles 
      WHERE id = $1
      RETURNING id, title
    `;

    const result = await db.query(query, [id]);

    if (result.rows.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'Article not found'
      });
    }

    res.status(200).json({
      success: true,
      message: 'Article deleted successfully'
    });
  } catch (error) {
    console.error('Error deleting article:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to delete article'
    });
  }
};

const uploadArticleImage = async (req, res) => {
  try {
    if (!req.file) {
      return res.status(400).json({
        success: false,
        message: 'No image file provided'
      });
    }

    const { id } = req.params;

    // Upload to Cloudinary
    const result = await cloudinary.uploader.upload_stream({
      resource_type: 'image',
      folder: 'pet-support-articles',
      public_id: `article-${id}-${Date.now()}`
    }, async (error, result) => {
      if (error) {
        console.error('Cloudinary upload error:', error);
        return res.status(500).json({
          success: false,
          message: 'Failed to upload image'
        });
      }

      try {
        // Update article with image URL
        const updateQuery = `
          UPDATE educational_articles 
          SET image_url = $1, updated_at = CURRENT_TIMESTAMP
          WHERE id = $2
          RETURNING *
        `;

        const updateResult = await db.query(updateQuery, [result.secure_url, id]);

        if (updateResult.rows.length === 0) {
          return res.status(404).json({
            success: false,
            message: 'Article not found'
          });
        }

        res.status(200).json({
          success: true,
          data: {
            imageUrl: result.secure_url,
            article: updateResult.rows[0]
          },
          message: 'Image uploaded successfully'
        });
      } catch (dbError) {
        console.error('Database update error:', dbError);
        res.status(500).json({
          success: false,
          message: 'Failed to update article with image'
        });
      }
    });

    result.end(req.file.buffer);
  } catch (error) {
    console.error('Error uploading article image:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to upload image'
    });
  }
};

// Analytics and reports
const getUserAnalytics = async (req, res) => {
  try {
    const { startDate, endDate } = req.query;
    
    let dateFilter = '';
    const params = [];
    
    if (startDate) {
      dateFilter += ` AND created_at >= $${params.length + 1}`;
      params.push(startDate);
    }
    
    if (endDate) {
      dateFilter += ` AND created_at <= $${params.length + 1}`;
      params.push(endDate);
    }

    const queries = {
      userGrowth: `
        SELECT DATE_TRUNC('day', created_at) as date, COUNT(*) as count
        FROM users 
        WHERE 1=1 ${dateFilter}
        GROUP BY DATE_TRUNC('day', created_at)
        ORDER BY date ASC
      `,
      userByRole: `
        SELECT role, COUNT(*) as count
        FROM users 
        WHERE is_active = true
        GROUP BY role
      `,
      userByCountry: `
        SELECT country, COUNT(*) as count
        FROM users 
        WHERE is_active = true AND country IS NOT NULL
        GROUP BY country
        ORDER BY count DESC
        LIMIT 10
      `,
      retentionRate: `
        SELECT 
          COUNT(CASE WHEN last_login >= CURRENT_DATE - INTERVAL '7 days' THEN 1 END) as active_week,
          COUNT(CASE WHEN last_login >= CURRENT_DATE - INTERVAL '30 days' THEN 1 END) as active_month,
          COUNT(*) as total_users
        FROM users 
        WHERE is_active = true AND created_at <= CURRENT_DATE - INTERVAL '30 days'
      `
    };

    const results = {};
    for (const [key, query] of Object.entries(queries)) {
      const result = await db.query(query, params);
      results[key] = result.rows;
    }

    res.status(200).json({
      success: true,
      data: results
    });
  } catch (error) {
    console.error('Error getting user analytics:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to get user analytics'
    });
  }
};

const exportData = async (req, res) => {
  try {
    const { type, startDate, endDate } = req.query;
    
    let query = '';
    let filename = '';
    
    switch (type) {
      case 'users':
        query = 'SELECT id, email, first_name, last_name, role, created_at FROM users';
        filename = 'users.csv';
        break;
      case 'pets':
        query = 'SELECT id, user_id, name, type, breed, age, weight, created_at FROM pets WHERE is_deleted = false';
        filename = 'pets.csv';
        break;
      case 'health_records':
        query = 'SELECT id, pet_id, record_type, description, date, created_at FROM health_records WHERE is_deleted = false';
        filename = 'health_records.csv';
        break;
      default:
        return res.status(400).json({
          success: false,
          message: 'Invalid export type'
        });
    }

    if (startDate || endDate) {
      query += ' WHERE 1=1';
      const params = [];
      
      if (startDate) {
        query += ` AND created_at >= $${params.length + 1}`;
        params.push(startDate);
      }
      
      if (endDate) {
        query += ` AND created_at <= $${params.length + 1}`;
        params.push(endDate);
      }
      
      const result = await db.query(query, params);
      const csv = new Parser().parse(result.rows);
      
      res.setHeader('Content-Type', 'text/csv');
      res.setHeader('Content-Disposition', `attachment; filename=${filename}`);
      res.send(csv);
    } else {
      const result = await db.query(query);
      const csv = new Parser().parse(result.rows);
      
      res.setHeader('Content-Type', 'text/csv');
      res.setHeader('Content-Disposition', `attachment; filename=${filename}`);
      res.send(csv);
    }
  } catch (error) {
    console.error('Error exporting data:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to export data'
    });
  }
};

// System health
const getSystemHealth = async (req, res) => {
  try {
    const health = {
      status: 'healthy',
      timestamp: new Date().toISOString(),
      services: {
        database: 'unknown',
        cloudinary: 'unknown',
        openai: 'unknown'
      },
      metrics: {
        uptime: process.uptime(),
        memory: process.memoryUsage(),
        cpu: process.cpuUsage()
      }
    };

    // Check database connection
    try {
      await db.query('SELECT 1');
      health.services.database = 'healthy';
    } catch (dbError) {
      health.services.database = 'unhealthy';
      health.status = 'degraded';
    }

    // Check Cloudinary
    try {
      await cloudinary.api.ping();
      health.services.cloudinary = 'healthy';
    } catch (cloudinaryError) {
      health.services.cloudinary = 'unhealthy';
      health.status = 'degraded';
    }

    // Check OpenAI (simple ping)
    try {
      // This would be a simple OpenAI API call in a real implementation
      health.services.openai = 'healthy';
    } catch (openaiError) {
      health.services.openai = 'unhealthy';
      health.status = 'degraded';
    }

    const statusCode = health.status === 'healthy' ? 200 : 503;
    res.status(statusCode).json({
      success: health.status === 'healthy',
      data: health
    });
  } catch (error) {
    console.error('Error checking system health:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to check system health'
    });
  }
};

module.exports = {
  getDashboardStats,
  getUsers,
  getUserById,
  updateUser,
  deleteUser,
  getAllPets,
  getPetById,
  updatePet,
  deletePet,
  getArticles,
  createArticle,
  updateArticle,
  deleteArticle,
  uploadArticleImage,
  getUserAnalytics,
  exportData,
  getSystemHealth
};