import express from 'express';
import { query } from '../config/database';

const router = express.Router();

// Create a new user (simplified for demo)
router.post('/register', async (req, res): Promise<any> => {
  try {
    const { phone, name, email, selectedSubjects = [] } = req.body;

    if (!phone) {
      return res.status(400).json({
        success: false,
        error: 'Phone number is required'
      });
    }

    const result = await query(`
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

  } catch (error: any) {
    if (error.code === '23505') { // Unique constraint violation
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

// Get user by phone
router.get('/by-phone/:phone', async (req, res): Promise<any> => {
  try {
    const { phone } = req.params;

    const result = await query(`
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

  } catch (error) {
    console.error('Error fetching user:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to fetch user'
    });
  }
});

export default router;