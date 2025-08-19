-- ExamCoach Database Setup Script
-- Run this script to set up the complete database schema

-- ============================================
-- 1. CREATE USERS TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    full_name VARCHAR(255) NOT NULL,
    phone_number VARCHAR(20),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_login TIMESTAMP,
    is_active BOOLEAN DEFAULT true,
    role VARCHAR(50) DEFAULT 'user'
);

CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);
CREATE INDEX IF NOT EXISTS idx_users_phone ON users(phone_number);

-- ============================================
-- 2. CREATE QUESTIONS TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS questions (
    id SERIAL PRIMARY KEY,
    subject_code VARCHAR(10) NOT NULL,
    year INTEGER,
    question_number INTEGER,
    question_text TEXT NOT NULL,
    options JSONB NOT NULL,
    correct_option CHAR(1) NOT NULL,
    explanation TEXT,
    topic VARCHAR(255),
    difficulty VARCHAR(20),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_questions_subject ON questions(subject_code);
CREATE INDEX IF NOT EXISTS idx_questions_year ON questions(year);
CREATE INDEX IF NOT EXISTS idx_questions_topic ON questions(topic);

-- ============================================
-- 3. CREATE SESSIONS TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS practice_sessions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    subject_code VARCHAR(10) NOT NULL,
    session_type VARCHAR(50) NOT NULL,
    total_questions INTEGER NOT NULL,
    answered_questions INTEGER DEFAULT 0,
    correct_answers INTEGER DEFAULT 0,
    time_spent INTEGER DEFAULT 0,
    score DECIMAL(5,2),
    status VARCHAR(20) DEFAULT 'in_progress',
    started_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    completed_at TIMESTAMP,
    questions_data JSONB,
    answers_data JSONB
);

CREATE INDEX IF NOT EXISTS idx_sessions_user ON practice_sessions(user_id);
CREATE INDEX IF NOT EXISTS idx_sessions_subject ON practice_sessions(subject_code);
CREATE INDEX IF NOT EXISTS idx_sessions_status ON practice_sessions(status);

-- ============================================
-- 4. CREATE SUBSCRIPTIONS TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS subscriptions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id VARCHAR(255) NOT NULL,
    product_id VARCHAR(100) NOT NULL,
    platform VARCHAR(20) NOT NULL CHECK (platform IN ('android', 'ios')),
    order_id VARCHAR(255) NOT NULL,
    purchase_token TEXT,
    expiry_date TIMESTAMP NOT NULL,
    auto_renewing BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    -- Ensure one active subscription per user per platform
    UNIQUE(user_id, platform)
);

CREATE INDEX IF NOT EXISTS idx_subscriptions_user_id ON subscriptions(user_id);
CREATE INDEX IF NOT EXISTS idx_subscriptions_expiry_date ON subscriptions(expiry_date);
CREATE INDEX IF NOT EXISTS idx_subscriptions_product_id ON subscriptions(product_id);

-- ============================================
-- 5. CREATE SUBSCRIPTION HISTORY TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS subscription_history (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    subscription_id UUID REFERENCES subscriptions(id),
    user_id VARCHAR(255) NOT NULL,
    product_id VARCHAR(100) NOT NULL,
    platform VARCHAR(20) NOT NULL,
    order_id VARCHAR(255) NOT NULL,
    action VARCHAR(50) NOT NULL,
    metadata JSONB,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_subscription_history_user_id ON subscription_history(user_id);
CREATE INDEX IF NOT EXISTS idx_subscription_history_subscription_id ON subscription_history(subscription_id);

-- ============================================
-- 6. CREATE ANALYTICS TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS user_analytics (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    event_type VARCHAR(100) NOT NULL,
    event_data JSONB,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_analytics_user ON user_analytics(user_id);
CREATE INDEX IF NOT EXISTS idx_analytics_event ON user_analytics(event_type);
CREATE INDEX IF NOT EXISTS idx_analytics_created ON user_analytics(created_at);

-- ============================================
-- 7. CREATE FUNCTIONS AND TRIGGERS
-- ============================================

-- Function to update the updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Apply update trigger to all tables with updated_at
CREATE TRIGGER update_users_updated_at 
    BEFORE UPDATE ON users
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_questions_updated_at 
    BEFORE UPDATE ON questions
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_subscriptions_updated_at 
    BEFORE UPDATE ON subscriptions
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Function to log subscription changes
CREATE OR REPLACE FUNCTION log_subscription_change()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        INSERT INTO subscription_history (
            subscription_id, user_id, product_id, platform, 
            order_id, action, metadata
        ) VALUES (
            NEW.id, NEW.user_id, NEW.product_id, NEW.platform,
            NEW.order_id, 'purchased', 
            jsonb_build_object('auto_renewing', NEW.auto_renewing)
        );
    ELSIF TG_OP = 'UPDATE' THEN
        -- Log renewal
        IF OLD.expiry_date < NEW.expiry_date THEN
            INSERT INTO subscription_history (
                subscription_id, user_id, product_id, platform,
                order_id, action, metadata
            ) VALUES (
                NEW.id, NEW.user_id, NEW.product_id, NEW.platform,
                NEW.order_id, 'renewed',
                jsonb_build_object(
                    'old_expiry', OLD.expiry_date,
                    'new_expiry', NEW.expiry_date
                )
            );
        END IF;
        
        -- Log cancellation
        IF OLD.auto_renewing = true AND NEW.auto_renewing = false THEN
            INSERT INTO subscription_history (
                subscription_id, user_id, product_id, platform,
                order_id, action, metadata
            ) VALUES (
                NEW.id, NEW.user_id, NEW.product_id, NEW.platform,
                NEW.order_id, 'cancelled',
                jsonb_build_object('expiry_date', NEW.expiry_date)
            );
        END IF;
    END IF;
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Trigger to log subscription changes
CREATE TRIGGER log_subscription_changes
    AFTER INSERT OR UPDATE ON subscriptions
    FOR EACH ROW
    EXECUTE FUNCTION log_subscription_change();

-- ============================================
-- 8. GRANT PERMISSIONS
-- ============================================
-- Note: Replace 'examcoach' with your actual database user
-- GRANT ALL ON ALL TABLES IN SCHEMA public TO examcoach;
-- GRANT ALL ON ALL SEQUENCES IN SCHEMA public TO examcoach;
-- GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA public TO examcoach;

-- ============================================
-- Migration Complete
-- ============================================
SELECT 'Database migration completed successfully!' as status;
