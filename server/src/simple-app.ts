import express from 'express';
import cors from 'cors';
import dotenv from 'dotenv';
import { query } from './config/database';

dotenv.config();

const app = express();
const PORT = process.env.PORT || 3000;

// Basic middleware
app.use(cors());
app.use(express.json());

// Health check
app.get('/health', (req, res) => {
  res.json({ 
    status: 'OK', 
    timestamp: new Date().toISOString(),
    message: 'ExamCoach Backend is running'
  });
});

// Get all subjects
app.get('/api/subjects', (req, res) => {
  const subjects = [
    { code: 'ENG', name: 'Use of English', questionCount: 60, duration: 60 },
    { code: 'MTH', name: 'Mathematics', questionCount: 40, duration: 60 },
    { code: 'PHY', name: 'Physics', questionCount: 40, duration: 60 },
    { code: 'CHM', name: 'Chemistry', questionCount: 40, duration: 60 },
    { code: 'BIO', name: 'Biology', questionCount: 40, duration: 60 },
    { code: 'ECO', name: 'Economics', questionCount: 40, duration: 60 },
    { code: 'ACC', name: 'Accounting', questionCount: 40, duration: 60 },
    { code: 'COM', name: 'Commerce', questionCount: 40, duration: 60 },
    { code: 'LIT', name: 'Literature', questionCount: 40, duration: 60 },
    { code: 'GOV', name: 'Government', questionCount: 40, duration: 60 },
    { code: 'HIS', name: 'History', questionCount: 40, duration: 60 },
    { code: 'GEO', name: 'Geography', questionCount: 40, duration: 60 }
  ];
  
  res.json({
    success: true,
    data: subjects
  });
});

// Get questions by subject
app.get('/api/questions/:subjectCode', async (req, res) => {
  try {
    const { subjectCode } = req.params;
    const { limit = '20' } = req.query;

    const result = await query(`
      SELECT 
        id, subject_code, section, stem,
        option_a, option_b, option_c, option_d, option_e,
        correct_option, explanation, difficulty
      FROM questions 
      WHERE subject_code = $1 AND verified = true
      ORDER BY RANDOM() 
      LIMIT $2
    `, [subjectCode.toUpperCase(), parseInt(limit as string)]);

    const questions = result.rows.map(row => ({
      id: row.id,
      subjectCode: row.subject_code,
      section: row.section,
      stem: row.stem,
      optionA: row.option_a,
      optionB: row.option_b,
      optionC: row.option_c,
      optionD: row.option_d,
      optionE: row.option_e,
      correctOption: row.correct_option,
      explanation: row.explanation,
      difficulty: row.difficulty
    }));

    return res.json({
      success: true,
      data: questions
    });

  } catch (error) {
    console.error('Error fetching questions:', error);
    return res.status(500).json({
      success: false,
      error: 'Failed to fetch questions'
    });
  }
});

// Create session
app.post('/api/sessions/create', async (req, res) => {
  try {
    const { subjectCode, questionCount = 20 } = req.body;

    if (!subjectCode) {
      return res.status(400).json({
        success: false,
        error: 'Subject code is required'
      });
    }

    // Create session
    const sessionResult = await query(`
      INSERT INTO sessions (subject_code, question_count, mode, time_limit)
      VALUES ($1, $2, 'practice', 60)
      RETURNING id, started_at
    `, [subjectCode.toUpperCase(), questionCount]);

    const sessionId = sessionResult.rows[0].id;

    return res.json({
      success: true,
      data: {
        sessionId,
        subjectCode: subjectCode.toUpperCase(),
        questionCount,
        startedAt: sessionResult.rows[0].started_at
      }
    });

  } catch (error) {
    console.error('Error creating session:', error);
    return res.status(500).json({
      success: false,
      error: 'Failed to create session'
    });
  }
});

// Submit answer
app.post('/api/sessions/answer', async (req, res) => {
  try {
    const { sessionId, questionId, chosenOption, timeSpentMs = 0 } = req.body;

    if (!sessionId || !questionId || !chosenOption) {
      return res.status(400).json({
        success: false,
        error: 'Session ID, question ID, and chosen option are required'
      });
    }

    // Get correct answer
    const questionResult = await query(`
      SELECT correct_option, explanation FROM questions WHERE id = $1
    `, [questionId]);

    if (questionResult.rows.length === 0) {
      return res.status(404).json({
        success: false,
        error: 'Question not found'
      });
    }

    const correctOption = questionResult.rows[0].correct_option;
    const explanation = questionResult.rows[0].explanation;
    const isCorrect = chosenOption.toUpperCase() === correctOption.toUpperCase();

    // Insert attempt
    await query(`
      INSERT INTO attempts (session_id, question_id, chosen_option, is_correct, time_spent_ms)
      VALUES ($1, $2, $3, $4, $5)
    `, [sessionId, questionId, chosenOption.toUpperCase(), isCorrect, timeSpentMs]);

    return res.json({
      success: true,
      data: {
        isCorrect,
        correctOption,
        explanation,
        chosenOption: chosenOption.toUpperCase()
      }
    });

  } catch (error) {
    console.error('Error submitting answer:', error);
    return res.status(500).json({
      success: false,
      error: 'Failed to submit answer'
    });
  }
});

// Get session results
app.get('/api/sessions/:sessionId/results', async (req, res) => {
  try {
    const { sessionId } = req.params;

    const resultQuery = await query(`
      SELECT 
        COUNT(*) as total_questions,
        COUNT(CASE WHEN is_correct = true THEN 1 END) as correct_answers,
        AVG(time_spent_ms) as avg_time_ms
      FROM attempts 
      WHERE session_id = $1
    `, [sessionId]);

    if (resultQuery.rows.length === 0) {
      return res.status(404).json({
        success: false,
        error: 'Session not found'
      });
    }

    const result = resultQuery.rows[0];
    const score = parseInt(result.correct_answers);
    const total = parseInt(result.total_questions);
    const percentage = total > 0 ? (score / total) * 100 : 0;

    res.json({
      success: true,
      data: {
        sessionId,
        totalQuestions: total,
        correctAnswers: score,
        percentage: Math.round(percentage * 100) / 100,
        avgTimeMs: Math.round(parseFloat(result.avg_time_ms) || 0)
      }
    });

  } catch (error) {
    console.error('Error fetching results:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to fetch session results'
    });
  }
});

// Root endpoint
app.get('/', (req, res) => {
  res.json({
    message: 'ExamCoach JAMB Backend API',
    version: '1.0.0',
    endpoints: [
      'GET /health',
      'GET /api/subjects',
      'GET /api/questions/:subjectCode',
      'POST /api/sessions/create',
      'POST /api/sessions/answer',
      'GET /api/sessions/:sessionId/results'
    ]
  });
});

// Error handling
app.use((err: any, req: express.Request, res: express.Response, next: express.NextFunction) => {
  console.error('Error:', err);
  res.status(err.status || 500).json({
    error: 'Internal server error'
  });
});

app.listen(PORT, () => {
  console.log(`🚀 ExamCoach Backend running on port ${PORT}`);
  console.log(`📚 Health check: http://localhost:${PORT}/health`);
  console.log(`🔗 API: http://localhost:${PORT}/api/subjects`);
});

export default app;