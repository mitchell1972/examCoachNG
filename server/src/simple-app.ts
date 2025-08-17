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

// Get all sessions (for admin dashboard)
app.get('/api/sessions', async (req, res) => {
  try {
    const result = await query(`
      SELECT 
        s.id, s.subject_code, s.started_at, s.completed_at,
        s.question_count, s.mode, s.time_limit,
        COUNT(a.id) as answers_submitted,
        COUNT(CASE WHEN a.is_correct = true THEN 1 END) as correct_answers
      FROM sessions s
      LEFT JOIN attempts a ON s.id = a.session_id
      GROUP BY s.id, s.subject_code, s.started_at, s.completed_at, s.question_count, s.mode, s.time_limit
      ORDER BY s.started_at DESC
      LIMIT 50
    `);

    const sessions = result.rows.map(row => ({
      id: row.id,
      subjectCode: row.subject_code,
      startedAt: row.started_at,
      completedAt: row.completed_at,
      questionCount: row.question_count,
      mode: row.mode,
      timeLimit: row.time_limit,
      answersSubmitted: parseInt(row.answers_submitted),
      correctAnswers: parseInt(row.correct_answers),
      score: row.answers_submitted > 0 ? Math.round((row.correct_answers / row.answers_submitted) * 100) : 0
    }));

    return res.json({
      success: true,
      data: sessions
    });

  } catch (error) {
    console.error('Error fetching sessions:', error);
    return res.status(500).json({
      success: false,
      error: 'Failed to fetch sessions'
    });
  }
});

// Get analytics data
app.get('/api/analytics', async (req, res) => {
  try {
    const stats = await query(`
      SELECT 
        COUNT(DISTINCT s.id) as total_sessions,
        COUNT(a.id) as total_attempts,
        COUNT(CASE WHEN a.is_correct = true THEN 1 END) as correct_attempts,
        AVG(a.time_spent_ms) as avg_time_ms
      FROM sessions s
      LEFT JOIN attempts a ON s.id = a.session_id
    `);

    const subjectStats = await query(`
      SELECT 
        s.subject_code,
        COUNT(DISTINCT s.id) as sessions,
        COUNT(a.id) as attempts,
        COUNT(CASE WHEN a.is_correct = true THEN 1 END) as correct,
        AVG(a.time_spent_ms) as avg_time
      FROM sessions s
      LEFT JOIN attempts a ON s.id = a.session_id
      GROUP BY s.subject_code
      ORDER BY sessions DESC
    `);

    const analytics = {
      overview: {
        totalSessions: parseInt(stats.rows[0].total_sessions) || 0,
        totalAttempts: parseInt(stats.rows[0].total_attempts) || 0,
        correctAttempts: parseInt(stats.rows[0].correct_attempts) || 0,
        avgTimeMs: Math.round(parseFloat(stats.rows[0].avg_time_ms) || 0),
        successRate: stats.rows[0].total_attempts > 0 ? 
          Math.round((stats.rows[0].correct_attempts / stats.rows[0].total_attempts) * 100) : 0
      },
      bySubject: subjectStats.rows.map(row => ({
        subjectCode: row.subject_code,
        sessions: parseInt(row.sessions),
        attempts: parseInt(row.attempts),
        correct: parseInt(row.correct),
        avgTime: Math.round(parseFloat(row.avg_time) || 0),
        successRate: row.attempts > 0 ? Math.round((row.correct / row.attempts) * 100) : 0
      }))
    };

    return res.json({
      success: true,
      data: analytics
    });

  } catch (error) {
    console.error('Error fetching analytics:', error);
    return res.status(500).json({
      success: false,
      error: 'Failed to fetch analytics'
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
      'GET /api/sessions/:sessionId/results',
      'GET /api/sessions',
      'GET /api/analytics'
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