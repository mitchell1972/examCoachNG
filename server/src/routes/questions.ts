import express from 'express';
import { query } from '../config/database';
import { JAMB_SUBJECTS } from '../config/subjects';
import { Question, QuestionFilter } from '../types';

const router = express.Router();

// Get all subjects
router.get('/subjects', (req, res) => {
  res.json({
    success: true,
    data: Object.values(JAMB_SUBJECTS)
  });
});

// Get questions by subject with filtering
router.get('/:subjectCode', async (req, res) => {
  try {
    const { subjectCode } = req.params;
    const { 
      section, 
      difficulty, 
      year, 
      verified = 'true',
      limit = '40',
      offset = '0'
    } = req.query;

    let queryText = `
      SELECT 
        id, subject_code, section, year, question_number,
        stem, option_a, option_b, option_c, option_d, option_e,
        correct_option, explanation, difficulty, image_url,
        syllabus_topic, tags, verified, source,
        created_at, updated_at
      FROM questions 
      WHERE subject_code = $1
    `;
    
    const queryParams: any[] = [subjectCode.toUpperCase()];
    let paramCounter = 2;

    if (section) {
      queryText += ` AND section = $${paramCounter}`;
      queryParams.push(section);
      paramCounter++;
    }

    if (difficulty) {
      const difficultyArray = Array.isArray(difficulty) ? difficulty : [difficulty];
      queryText += ` AND difficulty = ANY($${paramCounter})`;
      queryParams.push(difficultyArray.map(Number));
      paramCounter++;
    }

    if (year) {
      queryText += ` AND year = $${paramCounter}`;
      queryParams.push(parseInt(year as string));
      paramCounter++;
    }

    if (verified !== 'false') {
      queryText += ` AND verified = true`;
    }

    queryText += ` ORDER BY RANDOM() LIMIT $${paramCounter} OFFSET $${paramCounter + 1}`;
    queryParams.push(parseInt(limit as string), parseInt(offset as string));

    const result = await query(queryText, queryParams);

    const questions = result.rows.map(row => ({
      id: row.id,
      subjectCode: row.subject_code,
      section: row.section,
      year: row.year,
      questionNumber: row.question_number,
      stem: row.stem,
      optionA: row.option_a,
      optionB: row.option_b,
      optionC: row.option_c,
      optionD: row.option_d,
      optionE: row.option_e,
      correctOption: row.correct_option,
      explanation: row.explanation,
      difficulty: row.difficulty,
      imageUrl: row.image_url,
      syllabustopic: row.syllabus_topic,
      tags: row.tags || [],
      verified: row.verified,
      source: row.source,
      createdAt: row.created_at,
      updatedAt: row.updated_at
    }));

    res.json({
      success: true,
      data: questions,
      meta: {
        total: questions.length,
        limit: parseInt(limit as string),
        offset: parseInt(offset as string)
      }
    });

  } catch (error) {
    console.error('Error fetching questions:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to fetch questions'
    });
  }
});

// Get a specific question by ID
router.get('/single/:id', async (req, res): Promise<any> => {
  try {
    const { id } = req.params;

    const result = await query(`
      SELECT 
        id, subject_code, section, year, question_number,
        stem, option_a, option_b, option_c, option_d, option_e,
        correct_option, explanation, difficulty, image_url,
        syllabus_topic, tags, verified, source,
        created_at, updated_at
      FROM questions 
      WHERE id = $1
    `, [id]);

    if (result.rows.length === 0) {
      return res.status(404).json({
        success: false,
        error: 'Question not found'
      });
    }

    const row = result.rows[0];
    const question = {
      id: row.id,
      subjectCode: row.subject_code,
      section: row.section,
      year: row.year,
      questionNumber: row.question_number,
      stem: row.stem,
      optionA: row.option_a,
      optionB: row.option_b,
      optionC: row.option_c,
      optionD: row.option_d,
      optionE: row.option_e,
      correctOption: row.correct_option,
      explanation: row.explanation,
      difficulty: row.difficulty,
      imageUrl: row.image_url,
      syllabustopic: row.syllabus_topic,
      tags: row.tags || [],
      verified: row.verified,
      source: row.source,
      createdAt: row.created_at,
      updatedAt: row.updated_at
    };

    res.json({
      success: true,
      data: question
    });

  } catch (error) {
    console.error('Error fetching question:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to fetch question'
    });
  }
});

// Get questions statistics
router.get('/:subjectCode/stats', async (req, res) => {
  try {
    const { subjectCode } = req.params;

    const result = await query(`
      SELECT 
        COUNT(*) as total_questions,
        COUNT(CASE WHEN verified = true THEN 1 END) as verified_questions,
        AVG(difficulty) as avg_difficulty,
        COUNT(DISTINCT section) as total_sections,
        COUNT(DISTINCT year) as total_years
      FROM questions 
      WHERE subject_code = $1
    `, [subjectCode.toUpperCase()]);

    const sectionStats = await query(`
      SELECT 
        section,
        COUNT(*) as question_count,
        AVG(difficulty) as avg_difficulty
      FROM questions 
      WHERE subject_code = $1
      GROUP BY section
      ORDER BY question_count DESC
    `, [subjectCode.toUpperCase()]);

    res.json({
      success: true,
      data: {
        overview: result.rows[0],
        sections: sectionStats.rows
      }
    });

  } catch (error) {
    console.error('Error fetching question stats:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to fetch question statistics'
    });
  }
});

export default router;