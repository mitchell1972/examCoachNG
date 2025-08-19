import { Router, Request, Response } from 'express';
import bcrypt from 'bcryptjs';
import { v4 as uuidv4 } from 'uuid';
import { query } from '../config/database';
import { generateToken } from '../middleware/auth';
import { Logger } from '../utils/logger';

const router = Router();

// Validation helper
function validateEmail(email: string): boolean {
  const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
  return emailRegex.test(email);
}

/**
 * User Registration
 * POST /api/auth/register
 */
router.post('/register', async (req: Request, res: Response): Promise<Response> => {
  try {
    const { email, password, fullName, phoneNumber } = req.body;

    // Validate input
    if (!email || !password || !fullName) {
      return res.status(400).json({ error: 'Email, password, and full name are required' });
    }

    if (!validateEmail(email)) {
      return res.status(400).json({ error: 'Invalid email format' });
    }

    if (password.length < 8) {
      return res.status(400).json({ error: 'Password must be at least 8 characters long' });
    }

    // Check if user already exists
    const existingUser = await query(
      'SELECT id FROM users WHERE email = $1',
      [email]
    );

    if (existingUser.rows.length > 0) {
      return res.status(409).json({ error: 'User with this email already exists' });
    }

    // Hash password
    const salt = await bcrypt.genSalt(10);
    const hashedPassword = await bcrypt.hash(password, salt);

    // Create user
    const userId = uuidv4();
    const result = await query(
      `INSERT INTO users (id, email, password_hash, full_name, phone_number, created_at, updated_at)
       VALUES ($1, $2, $3, $4, $5, NOW(), NOW())
       RETURNING id, email, full_name, phone_number, created_at`,
      [userId, email, hashedPassword, fullName, phoneNumber || null]
    );

    const user = result.rows[0];

    // Generate token
    const token = generateToken({
      id: user.id,
      email: user.email,
      role: 'user'
    });

    // Return user data and token
    return res.status(201).json({
      message: 'Registration successful',
      user: {
        id: user.id,
        email: user.email,
        fullName: user.full_name,
        phoneNumber: user.phone_number
      },
      token
    });

  } catch (error: any) {
    Logger.error('Registration error:', error);
    return res.status(500).json({ error: 'Registration failed' });
  }
});

/**
 * User Login
 * POST /api/auth/login
 */
router.post('/login', async (req: Request, res: Response): Promise<Response> => {
  try {
    const { email, password } = req.body;

    // Validate input
    if (!email || !password) {
      return res.status(400).json({ error: 'Email and password are required' });
    }

    // Find user
    const result = await query(
      'SELECT id, email, password_hash, full_name, phone_number FROM users WHERE email = $1',
      [email]
    );

    if (result.rows.length === 0) {
      return res.status(401).json({ error: 'Invalid credentials' });
    }

    const user = result.rows[0];

    // Verify password
    const isValidPassword = await bcrypt.compare(password, user.password_hash);
    if (!isValidPassword) {
      return res.status(401).json({ error: 'Invalid credentials' });
    }

    // Update last login
    await query(
      'UPDATE users SET last_login = NOW() WHERE id = $1',
      [user.id]
    );

    // Generate token
    const token = generateToken({
      id: user.id,
      email: user.email,
      role: 'user'
    });

    // Return user data and token
    return res.json({
      message: 'Login successful',
      user: {
        id: user.id,
        email: user.email,
        fullName: user.full_name,
        phoneNumber: user.phone_number
      },
      token
    });

  } catch (error: any) {
    Logger.error('Login error:', error);
    return res.status(500).json({ error: 'Login failed' });
  }
});

/**
 * Refresh Token
 * POST /api/auth/refresh
 */
router.post('/refresh', async (req: Request, res: Response): Promise<Response> => {
  try {
    const { token } = req.body;

    if (!token) {
      return res.status(400).json({ error: 'Token is required' });
    }

    // Verify old token (even if expired, we just want to extract the payload)
    const decoded = jwt.decode(token) as any;
    
    if (!decoded || !decoded.id) {
      return res.status(401).json({ error: 'Invalid token' });
    }

    // Check if user still exists and is active
    const result = await query(
      'SELECT id, email FROM users WHERE id = $1',
      [decoded.id]
    );

    if (result.rows.length === 0) {
      return res.status(401).json({ error: 'User not found' });
    }

    const user = result.rows[0];

    // Generate new token
    const newToken = generateToken({
      id: user.id,
      email: user.email,
      role: decoded.role || 'user'
    });

    return res.json({
      message: 'Token refreshed successfully',
      token: newToken
    });

  } catch (error: any) {
    Logger.error('Token refresh error:', error);
    return res.status(500).json({ error: 'Token refresh failed' });
  }
});

/**
 * Get Current User
 * GET /api/auth/me
 * Requires authentication
 */
router.get('/me', async (req: Request, res: Response): Promise<Response> => {
  try {
    // This endpoint should be protected by auth middleware
    // The middleware should attach user to req.user
    if (!req.user) {
      return res.status(401).json({ error: 'Authentication required' });
    }

    // Get full user details
    const result = await query(
      'SELECT id, email, full_name, phone_number, created_at, last_login FROM users WHERE id = $1',
      [req.user.id]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'User not found' });
    }

    const user = result.rows[0];

    return res.json({
      user: {
        id: user.id,
        email: user.email,
        fullName: user.full_name,
        phoneNumber: user.phone_number,
        createdAt: user.created_at,
        lastLogin: user.last_login
      }
    });

  } catch (error: any) {
    Logger.error('Get user error:', error);
    return res.status(500).json({ error: 'Failed to get user information' });
  }
});

/**
 * Change Password
 * POST /api/auth/change-password
 * Requires authentication
 */
router.post('/change-password', async (req: Request, res: Response): Promise<Response> => {
  try {
    if (!req.user) {
      return res.status(401).json({ error: 'Authentication required' });
    }

    const { currentPassword, newPassword } = req.body;

    if (!currentPassword || !newPassword) {
      return res.status(400).json({ error: 'Current and new passwords are required' });
    }

    if (newPassword.length < 8) {
      return res.status(400).json({ error: 'New password must be at least 8 characters long' });
    }

    // Get user's current password hash
    const result = await query(
      'SELECT password_hash FROM users WHERE id = $1',
      [req.user.id]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'User not found' });
    }

    // Verify current password
    const isValidPassword = await bcrypt.compare(currentPassword, result.rows[0].password_hash);
    if (!isValidPassword) {
      return res.status(401).json({ error: 'Current password is incorrect' });
    }

    // Hash new password
    const salt = await bcrypt.genSalt(10);
    const hashedPassword = await bcrypt.hash(newPassword, salt);

    // Update password
    await query(
      'UPDATE users SET password_hash = $1, updated_at = NOW() WHERE id = $2',
      [hashedPassword, req.user.id]
    );

    return res.json({ message: 'Password changed successfully' });

  } catch (error: any) {
    Logger.error('Change password error:', error);
    return res.status(500).json({ error: 'Failed to change password' });
  }
});

// Import jwt for token decoding
import jwt from 'jsonwebtoken';

export default router;
