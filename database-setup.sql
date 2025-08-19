-- Create users table
CREATE TABLE IF NOT EXISTS users (
    id SERIAL PRIMARY KEY,
    phone VARCHAR(20) UNIQUE NOT NULL,
    name VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create questions table
CREATE TABLE IF NOT EXISTS questions (
    id SERIAL PRIMARY KEY,
    subject_code VARCHAR(10) NOT NULL,
    subject_name VARCHAR(100) NOT NULL,
    year INTEGER NOT NULL,
    question_text TEXT NOT NULL,
    options JSONB NOT NULL,
    correct_answer VARCHAR(10) NOT NULL,
    explanation TEXT,
    difficulty VARCHAR(20),
    topic VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create practice_sessions table
CREATE TABLE IF NOT EXISTS practice_sessions (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id),
    subject_code VARCHAR(10) NOT NULL,
    total_questions INTEGER NOT NULL,
    correct_answers INTEGER DEFAULT 0,
    time_spent INTEGER DEFAULT 0,
    status VARCHAR(20) DEFAULT 'in_progress',
    started_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    completed_at TIMESTAMP
);

-- Create session_answers table
CREATE TABLE IF NOT EXISTS session_answers (
    id SERIAL PRIMARY KEY,
    session_id INTEGER REFERENCES practice_sessions(id),
    question_id INTEGER REFERENCES questions(id),
    user_answer VARCHAR(10),
    is_correct BOOLEAN,
    time_spent INTEGER,
    answered_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Insert sample questions for testing
INSERT INTO questions (subject_code, subject_name, year, question_text, options, correct_answer, explanation, difficulty, topic)
VALUES 
('MTH', 'Mathematics', 2023, 'What is 2 + 2?', '{"A": "3", "B": "4", "C": "5", "D": "6"}', 'B', 'Basic addition: 2 + 2 = 4', 'Easy', 'Arithmetic'),
('MTH', 'Mathematics', 2023, 'Solve for x: 2x + 4 = 10', '{"A": "2", "B": "3", "C": "4", "D": "5"}', 'B', '2x + 4 = 10, 2x = 6, x = 3', 'Medium', 'Algebra'),
('ENG', 'English', 2023, 'Choose the correct spelling:', '{"A": "Recieve", "B": "Receive", "C": "Receve", "D": "Receeve"}', 'B', 'The correct spelling is "receive" (i before e except after c)', 'Easy', 'Spelling'),
('ENG', 'English', 2023, 'What is a synonym for "happy"?', '{"A": "Sad", "B": "Angry", "C": "Joyful", "D": "Tired"}', 'C', 'Joyful means feeling or expressing great happiness', 'Easy', 'Vocabulary'),
('PHY', 'Physics', 2023, 'What is the SI unit of force?', '{"A": "Joule", "B": "Watt", "C": "Newton", "D": "Pascal"}', 'C', 'Newton (N) is the SI unit of force', 'Medium', 'Units'),
('PHY', 'Physics', 2023, 'What is the speed of light in vacuum?', '{"A": "3×10^8 m/s", "B": "3×10^6 m/s", "C": "3×10^10 m/s", "D": "3×10^4 m/s"}', 'A', 'The speed of light in vacuum is approximately 3×10^8 meters per second', 'Medium', 'Waves'),
('CHM', 'Chemistry', 2023, 'What is the chemical symbol for Gold?', '{"A": "Go", "B": "Gd", "C": "Au", "D": "Ag"}', 'C', 'Au comes from the Latin word Aurum meaning gold', 'Easy', 'Elements'),
('CHM', 'Chemistry', 2023, 'What is the pH of pure water?', '{"A": "0", "B": "7", "C": "14", "D": "10"}', 'B', 'Pure water has a neutral pH of 7', 'Easy', 'Acids and Bases'),
('BIO', 'Biology', 2023, 'What is the powerhouse of the cell?', '{"A": "Nucleus", "B": "Mitochondria", "C": "Ribosome", "D": "Chloroplast"}', 'B', 'Mitochondria produces ATP energy for the cell', 'Easy', 'Cell Biology'),
('BIO', 'Biology', 2023, 'What process do plants use to make food?', '{"A": "Respiration", "B": "Digestion", "C": "Photosynthesis", "D": "Fermentation"}', 'C', 'Photosynthesis converts light energy into chemical energy', 'Easy', 'Plant Biology');

-- Verify the setup
SELECT 'Database setup complete!' as message;
SELECT COUNT(*) as total_questions FROM questions;
