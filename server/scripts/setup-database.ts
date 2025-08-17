import { Pool } from 'pg';
import dotenv from 'dotenv';

dotenv.config();

const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
});

const createTables = async () => {
  const client = await pool.connect();
  
  try {
    console.log('Setting up ExamCoach database...');
    
    // Enable UUID extension
    await client.query('CREATE EXTENSION IF NOT EXISTS "uuid-ossp";');
    
    // Users table
    await client.query(`
      CREATE TABLE IF NOT EXISTS users (
        id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
        phone VARCHAR(20) UNIQUE NOT NULL,
        name VARCHAR(100),
        email VARCHAR(100),
        password_hash VARCHAR(200),
        selected_subjects TEXT[],
        created_at TIMESTAMP DEFAULT NOW(),
        last_active TIMESTAMP DEFAULT NOW()
      );
    `);
    
    // JAMB Question Bank
    await client.query(`
      CREATE TABLE IF NOT EXISTS questions (
        id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
        subject_code VARCHAR(3) NOT NULL,
        section VARCHAR(100) NOT NULL,
        year INTEGER,
        question_number INTEGER,
        stem TEXT NOT NULL,
        option_a TEXT NOT NULL,
        option_b TEXT NOT NULL,
        option_c TEXT NOT NULL,
        option_d TEXT NOT NULL,
        option_e TEXT,
        correct_option CHAR(1) NOT NULL,
        explanation TEXT,
        difficulty INTEGER DEFAULT 2 CHECK (difficulty BETWEEN 1 AND 5),
        image_url TEXT,
        syllabus_topic VARCHAR(200),
        tags TEXT[],
        verified BOOLEAN DEFAULT FALSE,
        source VARCHAR(50) DEFAULT 'JAMB',
        created_at TIMESTAMP DEFAULT NOW(),
        updated_at TIMESTAMP DEFAULT NOW()
      );
    `);
    
    // Create indexes for questions
    await client.query(`
      CREATE INDEX IF NOT EXISTS idx_subject_section ON questions(subject_code, section);
      CREATE INDEX IF NOT EXISTS idx_year_subject ON questions(year, subject_code);
      CREATE INDEX IF NOT EXISTS idx_difficulty ON questions(difficulty);
    `);
    
    // Question Media
    await client.query(`
      CREATE TABLE IF NOT EXISTS question_media (
        id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
        question_id UUID REFERENCES questions(id) ON DELETE CASCADE,
        media_type VARCHAR(20),
        media_url TEXT NOT NULL,
        caption TEXT,
        position INTEGER DEFAULT 0
      );
    `);
    
    // Comprehension Passages
    await client.query(`
      CREATE TABLE IF NOT EXISTS passages (
        id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
        title VARCHAR(200),
        content TEXT NOT NULL,
        author VARCHAR(100),
        source VARCHAR(200),
        year INTEGER,
        created_at TIMESTAMP DEFAULT NOW()
      );
    `);
    
    // Link passages to questions
    await client.query(`
      CREATE TABLE IF NOT EXISTS passage_questions (
        passage_id UUID REFERENCES passages(id) ON DELETE CASCADE,
        question_id UUID REFERENCES questions(id) ON DELETE CASCADE,
        question_order INTEGER,
        PRIMARY KEY (passage_id, question_id)
      );
    `);
    
    // Question Packs
    await client.query(`
      CREATE TABLE IF NOT EXISTS packs (
        id VARCHAR(100) PRIMARY KEY,
        subject_code VARCHAR(3) NOT NULL,
        topic VARCHAR(200),
        version INTEGER NOT NULL,
        size_bytes INTEGER,
        checksum VARCHAR(100),
        question_count INTEGER,
        min_app_version VARCHAR(20),
        is_active BOOLEAN DEFAULT TRUE,
        created_at TIMESTAMP DEFAULT NOW(),
        UNIQUE(subject_code, topic, version)
      );
    `);
    
    // Pack Questions
    await client.query(`
      CREATE TABLE IF NOT EXISTS pack_questions (
        pack_id VARCHAR(100) REFERENCES packs(id),
        question_id UUID REFERENCES questions(id),
        sequence_number INTEGER,
        PRIMARY KEY (pack_id, question_id)
      );
    `);
    
    // Sessions
    await client.query(`
      CREATE TABLE IF NOT EXISTS sessions (
        id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
        user_id UUID REFERENCES users(id),
        mode VARCHAR(20) NOT NULL,
        subject_code VARCHAR(3) NOT NULL,
        topic VARCHAR(200),
        question_count INTEGER,
        time_limit INTEGER,
        started_at TIMESTAMP DEFAULT NOW(),
        ended_at TIMESTAMP,
        score INTEGER,
        status VARCHAR(20) DEFAULT 'active',
        metadata JSONB
      );
    `);
    
    // Session Questions
    await client.query(`
      CREATE TABLE IF NOT EXISTS session_questions (
        session_id UUID REFERENCES sessions(id) ON DELETE CASCADE,
        question_id UUID REFERENCES questions(id),
        question_order INTEGER,
        PRIMARY KEY (session_id, question_id)
      );
    `);
    
    // Attempts
    await client.query(`
      CREATE TABLE IF NOT EXISTS attempts (
        id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
        session_id UUID REFERENCES sessions(id),
        question_id UUID REFERENCES questions(id),
        user_id UUID REFERENCES users(id),
        chosen_option CHAR(1),
        is_correct BOOLEAN,
        time_spent_ms INTEGER,
        flagged BOOLEAN DEFAULT FALSE,
        created_at TIMESTAMP DEFAULT NOW()
      );
    `);
    
    // Create index for attempts
    await client.query(`
      CREATE INDEX IF NOT EXISTS idx_user_question ON attempts(user_id, question_id);
    `);
    
    // User Performance
    await client.query(`
      CREATE TABLE IF NOT EXISTS user_performance (
        user_id UUID REFERENCES users(id),
        subject_code VARCHAR(3),
        topic VARCHAR(200),
        total_attempts INTEGER DEFAULT 0,
        correct_attempts INTEGER DEFAULT 0,
        accuracy DECIMAL(5,2),
        average_time_ms INTEGER,
        mastery_level INTEGER DEFAULT 1,
        weak_areas TEXT[],
        last_updated TIMESTAMP DEFAULT NOW(),
        PRIMARY KEY (user_id, subject_code, topic)
      );
    `);
    
    // Subscriptions
    await client.query(`
      CREATE TABLE IF NOT EXISTS subscriptions (
        id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
        user_id UUID REFERENCES users(id),
        plan_type VARCHAR(50),
        status VARCHAR(20),
        started_at TIMESTAMP NOT NULL,
        expires_at TIMESTAMP NOT NULL,
        payment_provider VARCHAR(50),
        payment_reference VARCHAR(200),
        amount_paid DECIMAL(10,2),
        currency VARCHAR(3) DEFAULT 'NGN',
        metadata JSONB,
        created_at TIMESTAMP DEFAULT NOW()
      );
    `);
    
    console.log('✅ Database tables created successfully!');
    
  } catch (error) {
    console.error('❌ Error setting up database:', error);
    throw error;
  } finally {
    client.release();
  }
};

if (require.main === module) {
  createTables()
    .then(() => {
      console.log('Database setup completed');
      process.exit(0);
    })
    .catch((error) => {
      console.error('Database setup failed:', error);
      process.exit(1);
    });
}

export { createTables };