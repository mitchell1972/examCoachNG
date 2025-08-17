"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = __importDefault(require("express"));
const database_1 = require("../config/database");
const router = express_1.default.Router();
router.post('/register', async (req, res) => {
    try {
        const { phone, name, email, selectedSubjects = [] } = req.body;
        if (!phone) {
            return res.status(400).json({
                success: false,
                error: 'Phone number is required'
            });
        }
        const result = await (0, database_1.query)(`
      INSERT INTO users (phone, name, email, selected_subjects)
      VALUES ($1, $2, $3, $4)
      RETURNING id, phone, name, email, selected_subjects, created_at
    `, [phone, name, email, selectedSubjects]);
        res.json({
            success: true,
            data: {
                id: result.rows[0].id,
                phone: result.rows[0].phone,
                name: result.rows[0].name,
                email: result.rows[0].email,
                selectedSubjects: result.rows[0].selected_subjects,
                createdAt: result.rows[0].created_at
            }
        });
    }
    catch (error) {
        if (error.code === '23505') {
            return res.status(409).json({
                success: false,
                error: 'Phone number already registered'
            });
        }
        console.error('Error registering user:', error);
        res.status(500).json({
            success: false,
            error: 'Failed to register user'
        });
    }
});
router.get('/phone/:phone', async (req, res) => {
    try {
        const { phone } = req.params;
        const result = await (0, database_1.query)(`
      SELECT id, phone, name, email, selected_subjects, created_at, last_active
      FROM users 
      WHERE phone = $1
    `, [phone]);
        if (result.rows.length === 0) {
            return res.status(404).json({
                success: false,
                error: 'User not found'
            });
        }
        res.json({
            success: true,
            data: {
                id: result.rows[0].id,
                phone: result.rows[0].phone,
                name: result.rows[0].name,
                email: result.rows[0].email,
                selectedSubjects: result.rows[0].selected_subjects,
                createdAt: result.rows[0].created_at,
                lastActive: result.rows[0].last_active
            }
        });
    }
    catch (error) {
        console.error('Error fetching user:', error);
        res.status(500).json({
            success: false,
            error: 'Failed to fetch user'
        });
    }
});
exports.default = router;
//# sourceMappingURL=users.js.map