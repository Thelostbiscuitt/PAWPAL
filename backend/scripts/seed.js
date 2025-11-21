const { query } = require('../src/utils/database');

async function seedDatabase() {
  try {
    console.log('🌱 Starting database seeding...');
    
    // Clear existing data (in development)
    if (process.env.NODE_ENV === 'development') {
      console.log('🗑️  Clearing existing data...');
      await query('DELETE FROM resource_reviews');
      await query('DELETE FROM local_resources');
      await query('DELETE FROM emergency_triage');
      await query('DELETE FROM chat_messages');
      await query('DELETE FROM chat_conversations');
      await query('DELETE FROM reminders');
      await query('DELETE FROM care_plan_tasks');
      await query('DELETE FROM care_plans');
      await query('DELETE FROM health_records');
      await query('DELETE FROM pets');
      await query('DELETE FROM user_preferences');
      await query('DELETE FROM users');
    }
    
    // Create sample users
    console.log('👤 Creating sample users...');
    const bcrypt = require('bcryptjs');
    const passwordHash = await bcrypt.hash('password123', 12);
    
    const userResult = await query(`
      INSERT INTO users (email, password_hash, first_name, last_name, phone, city, country, location_lat, location_lng, is_verified)
      VALUES 
        ('john.doe@example.com', $1, 'John', 'Doe', '+2348012345678', 'Lagos', 'Nigeria', 6.5244, 3.3792, true),
        ('jane.smith@example.com', $1, 'Jane', 'Smith', '+2348023456789', 'Abuja', 'Nigeria', 9.0579, 7.4951, true),
        ('pet.lover@example.com', $1, 'Pet', 'Lover', '+2348034567890', 'Port Harcourt', 'Nigeria', 4.8156, 7.0498, true)
      RETURNING id, email, first_name, last_name
    `, [passwordHash]);
    
    const users = userResult.rows;
    console.log(`✅ Created ${users.length} users`);
    
    // Create sample pets
    console.log('🐕 Creating sample pets...');
    const petResult = await query(`
      INSERT INTO pets (user_id, name, species, breed, birth_date, weight, gender, profile_image_url)
      VALUES 
        ($1, 'Buddy', 'dog', 'Golden Retriever', '2022-03-15', 25.5, 'male', 'https://example.com/buddy.jpg'),
        ($1, 'Luna', 'cat', 'Persian', '2021-07-22', 4.2, 'female', 'https://example.com/luna.jpg'),
        ($2, 'Max', 'dog', 'German Shepherd', '2020-11-10', 30.0, 'male', 'https://example.com/max.jpg'),
        ($2, 'Bella', 'cat', 'Siamese', '2022-01-05', 3.8, 'female', 'https://example.com/bella.jpg'),
        ($3, 'Charlie', 'dog', 'Labrador', '2021-09-18', 28.5, 'male', 'https://example.com/charlie.jpg')
      RETURNING id, name, species, breed
    `, [users[0].id, users[1].id, users[2].id]);
    
    const pets = petResult.rows;
    console.log(`✅ Created ${pets.length} pets`);
    
    // Create sample health records
    console.log('🏥 Creating sample health records...');
    await query(`
      INSERT INTO health_records (pet_id, record_type, title, value, unit, notes, veterinarian_name, clinic_name)
      VALUES 
        ($1, 'weight', 'Monthly Weight Check', 25.8, 'kg', 'Healthy weight gain', 'Dr. Johnson', 'Pet Care Clinic'),
        ($1, 'vaccination', 'Annual Vaccination', NULL, NULL, 'DHPP vaccine administered', 'Dr. Johnson', 'Pet Care Clinic'),
        ($2, 'checkup', 'Regular Health Check', NULL, NULL, 'Overall health is good', 'Dr. Smith', 'Animal Hospital'),
        ($3, 'weight', 'Monthly Weight Check', 30.2, 'kg', 'Stable weight', 'Dr. Brown', 'Vet Center'),
        ($4, 'grooming', 'Regular Grooming', NULL, NULL, 'Full grooming session', 'Groomer Pro', 'Pet Spa')
    `, [pets[0].id, pets[1].id, pets[2].id, pets[3].id]);
    
    console.log('✅ Created health records');
    
    // Create sample care plans
    console.log('📋 Creating sample care plans...');
    await query(`
      INSERT INTO care_plans (pet_id, plan_type, title, description, frequency, custom_parameters, start_date)
      VALUES 
        ($1, 'feeding', 'Daily Feeding Schedule', 'Regular feeding times for optimal health', 'daily', '{"meals": 3, "portion_size": "2 cups", "food_type": "dry food"}', '2023-01-01'),
        ($1, 'exercise', 'Daily Exercise', 'Regular exercise for physical and mental health', 'daily', '{"duration": 30, "type": "walk", "intensity": "moderate"}', '2023-01-01'),
        ($2, 'grooming', 'Weekly Grooming', 'Regular grooming to maintain coat health', 'weekly', '{"brushing": true, "nail_trim": false, "bath": false}', '2023-01-01'),
        ($3, 'training', 'Obedience Training', 'Basic obedience and socialization', 'weekly', '{"sessions": 3, "duration": 15, "focus": ["sit", "stay", "come"]}', '2023-01-01')
    `, [pets[0].id, pets[0].id, pets[1].id, pets[2].id]);
    
    console.log('✅ Created care plans');
    
    // Create sample local resources (Lagos, Nigeria)
    console.log('🏪 Creating sample local resources...');
    await query(`
      INSERT INTO local_resources (name, category, address, location_lat, location_lng, phone, website, rating, price_range, verified)
      VALUES 
        ('Pet Care Veterinary Clinic', 'vet', '123 Victoria Island, Lagos', 6.4244, 3.4292, '+2348012345678', 'https://petcare.com', 4.5, '$$$', true),
        ('City Pet Store', 'pet_store', '456 Ikoyi Road, Lagos', 6.4544, 3.4392, '+2348023456789', 'https://citypet.com', 4.2, '$$', true),
        ('Pampered Paws Grooming', 'groomer', '789 Lekki Phase 1, Lagos', 6.4644, 3.4492, '+2348034567890', 'https://pamperedpaws.com', 4.8, '$$$', true),
        ('Dog Training Academy', 'trainer', '321 Ikeja, Lagos', 6.6044, 3.3492, '+2348045678901', 'https://dogacademy.com', 4.6, '$$', true),
        ('Lagos Animal Shelter', 'shelter', '654 Surulere, Lagos', 6.4944, 3.3792, '+2348056789012', 'https://lagosshelter.com', 4.3, '$', true)
    `);
    
    console.log('✅ Created local resources');
    
    // Create sample reminders
    console.log('⏰ Creating sample reminders...');
    const scheduledTime = new Date();
    scheduledTime.setHours(scheduledTime.getHours() + 2);
    
    await query(`
      INSERT INTO reminders (user_id, pet_id, title, description, reminder_type, scheduled_for)
      VALUES 
        ($1, $2, 'Feeding Time', 'Give Buddy his evening meal', 'feeding', $3),
        ($1, $3, 'Vaccination Due', 'Annual vaccination appointment', 'vet_visit', $3),
        ($2, $4, 'Grooming Appointment', 'Monthly grooming session', 'grooming', $3),
        ($3, $5, 'Training Session', 'Evening obedience training', 'training', $3)
    `, [users[0].id, pets[0].id, scheduledTime, users[1].id, pets[3].id, users[2].id, pets[4].id]);
    
    console.log('✅ Created reminders');
    
    console.log('🎉 Database seeding completed successfully!');
    console.log('\n📊 Summary:');
    console.log(`- Users: ${users.length}`);
    console.log(`- Pets: ${pets.length}`);
    console.log('- Health records: 5');
    console.log('- Care plans: 4');
    console.log('- Local resources: 5');
    console.log('- Reminders: 4');
    
  } catch (error) {
    console.error('❌ Seeding failed:', error);
    process.exit(1);
  }
}

// Run seeding if this script is executed directly
if (require.main === module) {
  seedDatabase();
}

module.exports = { seedDatabase };