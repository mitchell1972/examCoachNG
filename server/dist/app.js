"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = __importDefault(require("express"));
const cors_1 = __importDefault(require("cors"));
const helmet_1 = __importDefault(require("helmet"));
const compression_1 = __importDefault(require("compression"));
const express_rate_limit_1 = __importDefault(require("express-rate-limit"));
const dotenv_1 = __importDefault(require("dotenv"));
const database_1 = require("./config/database");
const path_1 = __importDefault(require("path"));
const questions_1 = __importDefault(require("./routes/questions"));
const sessions_1 = __importDefault(require("./routes/sessions"));
const users_1 = __importDefault(require("./routes/users"));
const analytics_1 = __importDefault(require("./routes/analytics"));
dotenv_1.default.config();
const app = (0, express_1.default)();
const PORT = process.env.PORT || 3000;
app.use((0, helmet_1.default)());
const corsOrigins = process.env.CORS_ORIGINS
    ? process.env.CORS_ORIGINS.split(',').map(origin => origin.trim())
    : ['http://localhost:3000', 'http://localhost:5000', 'http://localhost:5500'];
app.use((0, cors_1.default)({
    origin: process.env.NODE_ENV === 'production' ? corsOrigins : '*',
    methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
    allowedHeaders: ['Content-Type', 'Authorization'],
    credentials: true
}));
const limiter = (0, express_rate_limit_1.default)({
    windowMs: parseInt(process.env.RATE_LIMIT_WINDOW_MS || '900000'),
    max: parseInt(process.env.RATE_LIMIT_MAX_REQUESTS || '100'),
    message: {
        error: 'Too many requests from this IP, please try again later.'
    }
});
app.use('/api/', limiter);
app.use((0, compression_1.default)());
app.use(express_1.default.json({ limit: '10mb' }));
app.use(express_1.default.urlencoded({ extended: true }));
app.get('/health', (req, res) => {
    res.json({
        status: 'OK',
        timestamp: new Date().toISOString(),
        environment: process.env.NODE_ENV || 'development'
    });
});

// Basic Auth middleware (protects /admin)
const basicAuth = (req, res, next) => {
    const header = req.headers['authorization'] || '';
    const cookie = req.headers['cookie'] || '';
    const expectedUser = process.env.ADMIN_USER || 'admin';
    const expectedPass = process.env.ADMIN_PASS || 'change-me';
    
    // Check if user is coming from logout (has the logout cookie)
    if (cookie.includes('admin_logged_out=true')) {
        // Clear the logout cookie and force re-authentication
        res.setHeader('Set-Cookie', 'admin_logged_out=; Path=/admin; Max-Age=0; HttpOnly; SameSite=Lax');
        res.setHeader('WWW-Authenticate', 'Basic realm="ExamCoach Admin"');
        return res.status(401).send('Please log in again');
    }
    
    if (!header.startsWith('Basic ')) {
        res.setHeader('WWW-Authenticate', 'Basic realm="ExamCoach Admin"');
        return res.status(401).send('Authentication required');
    }
    
    try {
        const base64 = header.replace('Basic ', '');
        const [user, pass] = Buffer.from(base64, 'base64').toString('utf8').split(':');
        
        // Check for invalid logout credentials (used to clear browser cache)
        if (user === 'logout' && pass === 'logout') {
            res.setHeader('WWW-Authenticate', 'Basic realm="ExamCoach Admin"');
            return res.status(401).send('Invalid credentials');
        }
        
        if (user === expectedUser && pass === expectedPass) {
            return next();
        }
    }
    catch (e) { }
    res.setHeader('WWW-Authenticate', 'Basic realm="ExamCoach Admin"');
    return res.status(401).send('Unauthorized');
};

// Serve the dashboard only to authenticated users
const sendDashboard = (req, res) => {
    const dashboardPath = path_1.default.resolve(__dirname, 'private', 'admin_dashboard.html');
    // Allow inline scripts/styles used by the static HTML dashboard
    res.removeHeader('Content-Security-Policy');
    res.sendFile(dashboardPath);
};
app.get('/admin', basicAuth, sendDashboard);
app.get('/admin/', basicAuth, sendDashboard);
// Logout endpoint: uses JavaScript to clear browser's cached credentials
app.get('/admin/logout', (req, res) => {
    // Set a cookie to indicate logout state
    res.setHeader('Set-Cookie', 'admin_logged_out=true; Path=/admin; Max-Age=60; HttpOnly; SameSite=Lax');
    
    // Send HTML that uses XMLHttpRequest with invalid credentials to clear the browser cache
    res.send(`
        <!DOCTYPE html>
        <html>
        <head>
            <title>Logging out...</title>
            <style>
                body { font-family: system-ui; padding: 40px; text-align: center; }
                .message { margin: 20px auto; max-width: 400px; }
            </style>
        </head>
        <body>
            <div class="message">
                <h2>Logging out...</h2>
                <p>You have been logged out successfully.</p>
                <p>You can <a href="/admin">log in again</a> or close this window.</p>
            </div>
            <script>
                // Clear browser's cached Basic Auth credentials by sending invalid ones
                var xhr = new XMLHttpRequest();
                xhr.open('GET', '/admin', false, 'logout', 'logout');
                xhr.send();
            </script>
        </body>
        </html>
    `);
});
// Backward-compat: redirect old path to /admin
app.get('/admin_dashboard.html', (req, res) => res.status(404).json({ error: 'Not found' }));
app.use('/api/questions', questions_1.default);
app.use('/api/sessions', sessions_1.default);
app.use('/api/users', users_1.default);
app.use('/api/analytics', analytics_1.default);
app.get('/', (req, res) => {
    res.json({
        message: 'ExamCoach JAMB CBT Backend API',
        version: '1.0.0',
        documentation: '/api/docs',
        health: '/health'
    });
});
app.use((err, req, res, next) => {
    console.error('Error:', err);
    res.status(err.status || 500).json({
        error: process.env.NODE_ENV === 'production'
            ? 'Internal server error'
            : err.message,
        ...(process.env.NODE_ENV !== 'production' && { stack: err.stack })
    });
});
app.use('*', (req, res) => {
    res.status(404).json({
        error: 'Route not found',
        path: req.originalUrl
    });
});
process.on('SIGTERM', async () => {
    console.log('SIGTERM received, shutting down gracefully');
    await database_1.pool.end();
    process.exit(0);
});
process.on('SIGINT', async () => {
    console.log('SIGINT received, shutting down gracefully');
    await database_1.pool.end();
    process.exit(0);
});
if (require.main === module) {
    app.listen(PORT, () => {
        console.log(`🚀 ExamCoach Backend running on port ${PORT}`);
        console.log(`📚 Environment: ${process.env.NODE_ENV || 'development'}`);
        console.log(`🔗 Health check: http://localhost:${PORT}/health`);
    });
}
exports.default = app;
//# sourceMappingURL=app.js.map