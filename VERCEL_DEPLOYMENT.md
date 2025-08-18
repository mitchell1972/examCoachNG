# Deploy Everything to Vercel (Free, No Trial Limits!)

## Why Vercel Instead of Railway?
- **Vercel**: Generous free tier, no expiration, perfect for your app
- **Railway**: 30-day trial, then requires payment
- **Solution**: Use Vercel for both backend API and frontend + Supabase for free PostgreSQL

## Step 1: Set Up Free PostgreSQL Database (Supabase)

1. **Go to Supabase**: https://supabase.com
2. **Sign up** (free, no credit card)
3. **Create New Project**:
   - Project name: `examcoach`
   - Database Password: (save this!)
   - Region: Choose closest to you
4. **Get your Database URL**:
   - Go to Settings → Database
   - Copy the **Connection String** (URI)
   - It looks like: `postgresql://postgres:[YOUR-PASSWORD]@db.xxxx.supabase.co:5432/postgres`

## Step 2: Deploy to Vercel

1. **Go to Vercel**: https://vercel.com
2. **Sign in with GitHub**
3. **Click "Add New Project"**
4. **Import** `mitchell1972/examCoachNG`
5. **Configure Environment Variables** (IMPORTANT!):
   
   Click "Environment Variables" and add:
   ```
   DATABASE_URL = [Your Supabase connection string]
   NODE_ENV = production
   PORT = 3000
   ```

6. **Click "Deploy"**

## Step 3: Run Database Setup

After deployment, you need to create tables in your Supabase database:

### Option A: Using Supabase SQL Editor
1. Go to your Supabase project
2. Click "SQL Editor"
3. Run these queries:

```sql
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

-- Insert sample questions
INSERT INTO questions (subject_code, subject_name, year, question_text, options, correct_answer, explanation, difficulty, topic)
VALUES 
('MTH', 'Mathematics', 2023, 'What is 2 + 2?', '{"A": "3", "B": "4", "C": "5", "D": "6"}', 'B', 'Basic addition', 'Easy', 'Arithmetic'),
('ENG', 'English', 2023, 'Choose the correct spelling:', '{"A": "Recieve", "B": "Receive", "C": "Receve", "D": "Receeve"}', 'B', 'Correct spelling is receive', 'Easy', 'Spelling'),
('PHY', 'Physics', 2023, 'What is the SI unit of force?', '{"A": "Joule", "B": "Watt", "C": "Newton", "D": "Pascal"}', 'C', 'Newton is the SI unit of force', 'Medium', 'Units'),
('CHM', 'Chemistry', 2023, 'What is the chemical symbol for Gold?', '{"A": "Go", "B": "Gd", "C": "Au", "D": "Ag"}', 'C', 'Au comes from the Latin word Aurum', 'Easy', 'Elements'),
('BIO', 'Biology', 2023, 'What is the powerhouse of the cell?', '{"A": "Nucleus", "B": "Mitochondria", "C": "Ribosome", "D": "Chloroplast"}', 'B', 'Mitochondria produces ATP energy', 'Easy', 'Cell Biology');
```

### Option B: Run setup script locally
```bash
# Update your local .env with Supabase URL
echo "DATABASE_URL=your-supabase-url-here" > server/.env

# Run setup
cd server
npx tsx scripts/setup-database.ts
npx tsx scripts/seed-questions.ts
```

## Step 4: Update Frontend URLs

Your Vercel app URL will be something like: `examcoachng.vercel.app`

The API will be at the same domain, so update your HTML files:

```bash
# Update all HTML files to use your Vercel URL
node update-api-url.js https://examcoachng.vercel.app

# Commit and push
git add -A
git commit -m "Update API URLs for Vercel deployment"
git push
```

Vercel will auto-redeploy with the new changes.

## Step 5: Test Your App

1. Visit: `https://examcoachng.vercel.app/phone_app.html`
2. Check that it shows "Connected to Backend Database"
3. Try selecting a subject and starting practice

## URLs After Deployment

- **Main App**: `https://examcoachng.vercel.app/phone_app.html`
- **Admin Dashboard**: `https://examcoachng.vercel.app/admin_dashboard.html`
- **Test Suite**: `https://examcoachng.vercel.app/test_suite.html`
- **API Health Check**: `https://examcoachng.vercel.app/health`
- **API Subjects**: `https://examcoachng.vercel.app/api/questions/subjects`

## Advantages of This Setup

✅ **Vercel**:
- Free tier: 100GB bandwidth/month
- Unlimited websites
- Automatic HTTPS
- Global CDN
- No time limits

✅ **Supabase**:
- Free tier: 500MB database
- No time limits
- Built-in auth if needed later
- Real-time subscriptions
- SQL editor

## Troubleshooting

### If API calls fail:
1. Check Vercel Function logs: Vercel Dashboard → Functions tab
2. Verify DATABASE_URL is set correctly in Vercel environment variables
3. Check browser console for CORS errors

### If database connection fails:
1. Verify Supabase connection string is correct
2. Check if tables are created in Supabase
3. Ensure your Supabase project is active

## Cost: $0/month
Both Vercel and Supabase have generous free tiers perfect for your app!
