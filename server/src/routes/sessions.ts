import express from 'express';
import { query } from '../config/database';
import { JAMB_SUBJECTS } from '../config/subjects';
import { CreateSessionRequest, SubmitAnswerRequest } from '../types';

const router = express.Router();

// Create a new practice session
router.post('/create', async (req, res): Promise<any> => {
  try {
    const { 
      subjectCode, 
      mode = 'practice', 
      topic, 
      questionCount,
      timeLimit 
    }: CreateSessionRequest = req.body;

    if (!subjectCode) {
      return res.status(400).json({
        success: false,
        error: 'Subject code is required'
      });
    }

    // Get subject configuration
    const subject = Object.values(JAMB_SUBJECTS).find(s => s.code === subjectCode.toUpperCase());
    if (!subject) {
      return res.status(400).json({
        success: false,
        error: 'Invalid subject code'
      });
    }

    const finalQuestionCount = questionCount || subject.questionCount;
    const finalTimeLimit = timeLimit || subject.duration;

    // Create session
    const sessionResult = await query(`
      INSERT INTO sessions (
        user_id, mode, subject_code, topic, question_count, time_limit, metadata
      ) VALUES ($1, $2, $3, $4, $5, $6, $7)
      RETURNING id, started_at
    `, [
      null, // user_id will be set when we implement authentication
      mode,
      subjectCode.toUpperCase(),
      topic,
      finalQuestionCount,
      finalTimeLimit,
      JSON.stringify({ created_by: 'anonymous' })
    ]);

    const sessionId = sessionResult.rows[0].id;

    // Select random questions for the session
    let questionQuery = `
      SELECT id FROM questions 
      WHERE subject_code = $1 AND verified = true
    `;
    const queryParams = [subjectCode.toUpperCase()];

    if (topic) {
      questionQuery += ` AND section = $2`;
      queryParams.push(topic);
    }

    questionQuery += ` ORDER BY RANDOM() LIMIT $${queryParams.length + 1}`;
    queryParams.push(finalQuestionCount.toString());

    const questionsResult = await query(questionQuery, queryParams);

    // Insert selected questions into session_questions
    if (questionsResult.rows.length > 0) {
      const sessionQuestionInserts = questionsResult.rows.map((q, index) => 
        `('${sessionId}', '${q.id}', ${index + 1})`
      ).join(', ');

      await query(`
        INSERT INTO session_questions (session_id, question_id, question_order)
        VALUES ${sessionQuestionInserts}
      `);
    }

    res.json({
      success: true,
      data: {
        sessionId,
        subjectCode: subjectCode.toUpperCase(),
        mode,
        topic,
        questionCount: questionsResult.rows.length,
        timeLimit: finalTimeLimit,
        startedAt: sessionResult.rows[0].started_at
      }
    });

  } catch (error) {
    console.error('Error creating session:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to create session'
    });
  }
});

// Get session questions
router.get('/questions/:sessionId', async (req, res) => {
  try {
    const { sessionId } = req.params;

    const result = await query(`
      SELECT 
        q.id, q.stem, q.option_a, q.option_b, q.option_c, q.option_d, q.option_e,
        q.difficulty, q.image_url, sq.question_order
      FROM questions q
      JOIN session_questions sq ON q.id = sq.question_id
      WHERE sq.session_id = $1
      ORDER BY sq.question_order
    `, [sessionId]);

    const questions = result.rows.map(row => ({
      id: row.id,
      stem: row.stem,
      optionA: row.option_a,
      optionB: row.option_b,
      optionC: row.option_c,
      optionD: row.option_d,
      optionE: row.option_e,
      difficulty: row.difficulty,
      imageUrl: row.image_url,
      order: row.question_order
    }));

    res.json({
      success: true,
      data: questions
    });

  } catch (error) {
    console.error('Error fetching session questions:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to fetch session questions'
    });
  }
});

// Submit an answer
router.post('/answer', async (req, res): Promise<any> => {
  try {
    const { 
      sessionId, 
      questionId, 
      chosenOption, 
      timeSpentMs,
      flagged = false 
    }: SubmitAnswerRequest = req.body;

    if (!sessionId || !questionId || !chosenOption) {
      return res.status(400).json({
        success: false,
        error: 'Session ID, question ID, and chosen option are required'
      });
    }

    // Get the correct answer
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
      INSERT INTO attempts (
        session_id, question_id, user_id, chosen_option, 
        is_correct, time_spent_ms, flagged
      ) VALUES ($1, $2, $3, $4, $5, $6, $7)
    `, [
      sessionId,
      questionId,
      null, // user_id will be set when we implement authentication
      chosenOption.toUpperCase(),
      isCorrect,
      timeSpentMs,
      flagged
    ]);

    res.json({
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
    res.status(500).json({
      success: false,
      error: 'Failed to submit answer'
    });
  }
});

// Complete session and get results  
router.post('/complete/:sessionId', async (req, res): Promise<any> => {
  try {
    const { sessionId } = req.params;

    // Calculate session results
    const resultQuery = await query(`
      SELECT 
        COUNT(*) as total_questions,
        COUNT(CASE WHEN is_correct = true THEN 1 END) as correct_answers,
        AVG(time_spent_ms) as avg_time_ms,
        s.subject_code,
        s.mode,
        s.topic,
        s.time_limit
      FROM attempts a
      JOIN sessions s ON a.session_id = s.id
      WHERE a.session_id = $1
      GROUP BY s.subject_code, s.mode, s.topic, s.time_limit
    `, [sessionId]);

    if (resultQuery.rows.length === 0) {
      return res.status(404).json({
        success: false,
        error: 'Session not found or no answers submitted'
      });
    }

    const result = resultQuery.rows[0];
    const score = parseInt(result.correct_answers);
    const percentage = (score / parseInt(result.total_questions)) * 100;

    // Update session with final score
    await query(`
      UPDATE sessions 
      SET score = $1, ended_at = NOW(), status = 'completed'
      WHERE id = $2
    `, [score, sessionId]);

    // Get detailed results by question
    const detailedResults = await query(`
      SELECT 
        q.id,
        q.stem,
        q.correct_option,
        q.explanation,
        q.section,
        a.chosen_option,
        a.is_correct,
        a.time_spent_ms,
        a.flagged
      FROM attempts a
      JOIN questions q ON a.question_id = q.id
      WHERE a.session_id = $1
      ORDER BY a.created_at
    `, [sessionId]);

    res.json({
      success: true,
      data: {
        sessionId,
        subjectCode: result.subject_code,
        mode: result.mode,
        topic: result.topic,
        totalQuestions: parseInt(result.total_questions),
        correctAnswers: score,
        percentage: Math.round(percentage * 100) / 100,
        avgTimeMs: Math.round(parseFloat(result.avg_time_ms)),
        timeLimit: result.time_limit,
        questions: detailedResults.rows.map(row => ({
          id: row.id,
          stem: row.stem,
          correctOption: row.correct_option,
          chosenOption: row.chosen_option,
          isCorrect: row.is_correct,
          explanation: row.explanation,
          section: row.section,
          timeSpentMs: row.time_spent_ms,
          flagged: row.flagged
        }))
      }
    });

  } catch (error) {
    console.error('Error completing session:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to complete session'
    });
  }
});

export default router;