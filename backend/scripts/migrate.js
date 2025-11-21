const fs = require('fs');
const path = require('path');
const { query } = require('../src/utils/database');

async function runMigrations() {
  try {
    console.log('🔄 Starting database migrations...');
    
    // Create migrations table if it doesn't exist
    await query(`
      CREATE TABLE IF NOT EXISTS migrations (
        id SERIAL PRIMARY KEY,
        filename VARCHAR(255) UNIQUE NOT NULL,
        executed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    `);
    
    // Get all migration files
    const migrationsDir = path.join(__dirname, '../migrations');
    const migrationFiles = fs.readdirSync(migrationsDir)
      .filter(file => file.endsWith('.sql'))
      .sort();
    
    // Get executed migrations
    const executedMigrations = await query('SELECT filename FROM migrations');
    const executedFilenames = executedMigrations.rows.map(row => row.filename);
    
    // Run pending migrations
    for (const file of migrationFiles) {
      if (!executedFilenames.includes(file)) {
        console.log(`📄 Running migration: ${file}`);
        
        const filePath = path.join(migrationsDir, file);
        const migrationSQL = fs.readFileSync(filePath, 'utf8');
        
        // Execute migration
        await query(migrationSQL);
        
        // Record migration
        await query(
          'INSERT INTO migrations (filename) VALUES ($1)',
          [file]
        );
        
        console.log(`✅ Migration completed: ${file}`);
      } else {
        console.log(`⏭️  Skipping already executed migration: ${file}`);
      }
    }
    
    console.log('🎉 All migrations completed successfully!');
    
  } catch (error) {
    console.error('❌ Migration failed:', error);
    process.exit(1);
  }
}

// Run migrations if this script is executed directly
if (require.main === module) {
  runMigrations();
}

module.exports = { runMigrations };