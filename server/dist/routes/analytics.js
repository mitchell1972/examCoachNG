"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = __importDefault(require("express"));
const database_1 = require("../config/database");
const router = express_1.default.Router();
router.get('/platform-stats', async (req, res) => {
    try {
        const [userStats, questionStats, sessionStats] = await Promise.all([
            (0, database_1.query)(`
        SELECT 
          COUNT(*) as total_users,
          COUNT(CASE WHEN last_active >= NOW() - INTERVAL '30 days' THEN 1 END) as active_users_30d,
          COUNT(CASE WHEN last_active >= NOW() - INTERVAL '7 days' THEN 1 END) as active_users_7d
        FROM users
      `),
            (0, database_1.query)(`
        SELECT 
          COUNT(*) as total_questions,
          COUNT(DISTINCT subject_code) as total_subjects,
          COUNT(CASE WHEN verified = true THEN 1 END) as verified_questions
        FROM questions
      `),
            (0, database_1.query)(`
        SELECT 
          COUNT(*) as total_sessions,
          COUNT(CASE WHEN status = 'completed' THEN 1 END) as completed_sessions,
          AVG(score) as avg_score
        FROM sessions
        WHERE created_at >= NOW() - INTERVAL '30 days'
      `)
        ]);
        res.json({
            success: true,
            data: {
                users: userStats.rows[0],
                questions: questionStats.rows[0],
                sessions: sessionStats.rows[0]
            }
        });
    }
    catch (error) {
        console.error('Error fetching platform stats:', error);
        res.status(500).json({
            success: false,
            error: 'Failed to fetch platform statistics'
        });
    }
});
router.get('/subject-performance', async (req, res) => {
    try {
        const { days = '30' } = req.query;
        const result = await (0, database_1.query)(`
      SELECT 
        s.subject_code,
        COUNT(s.id) as total_sessions,
        COUNT(CASE WHEN s.status = 'completed' THEN 1 END) as completed_sessions,
        AVG(s.score) as avg_score,
        AVG(CASE WHEN s.status = 'completed' THEN 
          (s.score::float / s.question_count) * 100 
        END) as avg_percentage,
        COUNT(DISTINCT a.user_id) as unique_users
      FROM sessions s
      LEFT JOIN attempts a ON s.id = a.session_id
      WHERE s.created_at >= NOW() - INTERVAL '${parseInt(days)} days'
      GROUP BY s.subject_code
      ORDER BY completed_sessions DESC
    `);
        res.json({
            success: true,
            data: result.rows.map(row => ({
                subjectCode: row.subject_code,
                totalSessions: parseInt(row.total_sessions),
                completedSessions: parseInt(row.completed_sessions),
                avgScore: parseFloat(row.avg_score) || 0,
                avgPercentage: parseFloat(row.avg_percentage) || 0,
                uniqueUsers: parseInt(row.unique_users) || 0
            }))
        });
    }
    catch (error) {
        console.error('Error fetching subject performance:', error);
        res.status(500).json({
            success: false,
            error: 'Failed to fetch subject performance analytics'
        });
    }
});
router.get('/difficulty-stats', async (req, res) => {
    try {
        const { subjectCode } = req.query;
        let queryText = `
      SELECT 
        q.difficulty,
        COUNT(a.id) as total_attempts,
        COUNT(CASE WHEN a.is_correct = true THEN 1 END) as correct_attempts,
        AVG(a.time_spent_ms) as avg_time_ms
      FROM questions q
      LEFT JOIN attempts a ON q.id = a.question_id
    `;
        const queryParams = [];
        if (subjectCode) {
            queryText += ` WHERE q.subject_code = $1`;
            queryParams.push(subjectCode);
        }
        queryText += `
      GROUP BY q.difficulty
      ORDER BY q.difficulty
    `;
        const result = await (0, database_1.query)(queryText, queryParams);
        res.json({
            success: true,
            data: result.rows.map(row => ({
                difficulty: row.difficulty,
                totalAttempts: parseInt(row.total_attempts) || 0,
                correctAttempts: parseInt(row.correct_attempts) || 0,
                accuracy: row.total_attempts > 0 ?
                    Math.round((row.correct_attempts / row.total_attempts) * 100 * 100) / 100 : 0,
                avgTimeMs: Math.round(parseFloat(row.avg_time_ms)) || 0
            }))
        });
    }
    catch (error) {
        console.error('Error fetching difficulty stats:', error);
        res.status(500).json({
            success: false,
            error: 'Failed to fetch difficulty statistics'
        });
    }
});
exports.default = router;
//# sourceMappingURL=analytics.js.map