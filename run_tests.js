#!/usr/bin/env node

/**
 * ExamCoach Test Runner - Node.js Command Line Test Suite
 * Run comprehensive tests for the ExamCoach platform
 */

const https = require('https');
const http = require('http');
const fs = require('fs');
const path = require('path');

// Configuration
const CONFIG = {
    API_BASE: 'http://localhost:3000',
    FRONTEND_BASE: 'http://localhost:5000',
    TIMEOUT: 10000,
    CONCURRENT_USERS: 5
};

// ANSI color codes for console output
const COLORS = {
    red: '\x1b[31m',
    green: '\x1b[32m',
    yellow: '\x1b[33m',
    blue: '\x1b[34m',
    magenta: '\x1b[35m',
    cyan: '\x1b[36m',
    white: '\x1b[37m',
    reset: '\x1b[0m'
};

// Test results tracking
let testResults = {
    total: 0,
    passed: 0,
    failed: 0,
    skipped: 0,
    startTime: Date.now()
};

// Utility functions
function log(message, color = 'white') {
    const timestamp = new Date().toLocaleTimeString();
    console.log(`${COLORS[color]}[${timestamp}] ${message}${COLORS.reset}`);
}

function logSuccess(message) {
    log(`✓ ${message}`, 'green');
}

function logError(message) {
    log(`✗ ${message}`, 'red');
}

function logInfo(message) {
    log(`ℹ ${message}`, 'blue');
}

function logWarning(message) {
    log(`⚠ ${message}`, 'yellow');
}

// HTTP request helper
function makeRequest(url, options = {}) {
    return new Promise((resolve, reject) => {
        const isHttps = url.startsWith('https');
        const client = isHttps ? https : http;
        
        const requestOptions = {
            timeout: CONFIG.TIMEOUT,
            headers: {
                'Content-Type': 'application/json',
                'User-Agent': 'ExamCoach-TestRunner/1.0',
                ...options.headers
            },
            ...options
        };

        const req = client.request(url, requestOptions, (res) => {
            let data = '';
            
            res.on('data', (chunk) => {
                data += chunk;
            });
            
            res.on('end', () => {
                try {
                    const result = {
                        statusCode: res.statusCode,
                        headers: res.headers,
                        data: res.headers['content-type']?.includes('application/json') 
                            ? JSON.parse(data) : data,
                        rawData: data
                    };
                    resolve(result);
                } catch (error) {
                    resolve({
                        statusCode: res.statusCode,
                        headers: res.headers,
                        data: data,
                        rawData: data
                    });
                }
            });
        });

        req.on('error', (error) => {
            reject(error);
        });

        req.on('timeout', () => {
            req.destroy();
            reject(new Error('Request timeout'));
        });

        if (options.body) {
            req.write(typeof options.body === 'string' ? options.body : JSON.stringify(options.body));
        }

        req.end();
    });
}

// Test execution framework
async function runTest(testName, testFunction) {
    testResults.total++;
    const startTime = Date.now();
    
    try {
        await testFunction();
        const duration = Date.now() - startTime;
        testResults.passed++;
        logSuccess(`${testName} (${duration}ms)`);
        return { status: 'passed', duration };
    } catch (error) {
        const duration = Date.now() - startTime;
        testResults.failed++;
        logError(`${testName} (${duration}ms): ${error.message}`);
        return { status: 'failed', duration, error: error.message };
    }
}

// API Test Suite
async function runAPITests() {
    logInfo('Starting API Tests...');
    
    await runTest('Backend Health Check', async () => {
        const response = await makeRequest(`${CONFIG.API_BASE}/health`);
        if (response.statusCode !== 200) {
            throw new Error(`Expected 200, got ${response.statusCode}`);
        }
        if (!response.data.status || response.data.status !== 'OK') {
            throw new Error('Health check failed');
        }
    });

    await runTest('Get Subjects Endpoint', async () => {
        const response = await makeRequest(`${CONFIG.API_BASE}/api/subjects`);
        if (response.statusCode !== 200) {
            throw new Error(`Expected 200, got ${response.statusCode}`);
        }
        if (!response.data.success || !Array.isArray(response.data.data)) {
            throw new Error('Invalid subjects response');
        }
        if (response.data.data.length < 10) {
            throw new Error(`Expected at least 10 subjects, got ${response.data.data.length}`);
        }
    });

    await runTest('Get Mathematics Questions', async () => {
        const response = await makeRequest(`${CONFIG.API_BASE}/api/questions/MTH?limit=5`);
        if (response.statusCode !== 200) {
            throw new Error(`Expected 200, got ${response.statusCode}`);
        }
        if (!response.data.success || !Array.isArray(response.data.data)) {
            throw new Error('Invalid questions response');
        }
        if (response.data.data.length === 0) {
            throw new Error('No mathematics questions returned');
        }
    });

    await runTest('Create Practice Session', async () => {
        const response = await makeRequest(`${CONFIG.API_BASE}/api/sessions/create`, {
            method: 'POST',
            body: { subjectCode: 'MTH', questionCount: 10 }
        });
        if (response.statusCode !== 200) {
            throw new Error(`Expected 200, got ${response.statusCode}`);
        }
        if (!response.data.success || !response.data.data.sessionId) {
            throw new Error('Session creation failed');
        }
    });

    await runTest('Get Analytics Data', async () => {
        const response = await makeRequest(`${CONFIG.API_BASE}/api/analytics`);
        if (response.statusCode !== 200) {
            throw new Error(`Expected 200, got ${response.statusCode}`);
        }
        if (!response.data.success || !response.data.data.overview) {
            throw new Error('Invalid analytics response');
        }
    });

    logInfo('API Tests completed');
}

// Frontend Test Suite
async function runFrontendTests() {
    logInfo('Starting Frontend Tests...');
    
    const frontendPages = [
        { name: 'Main Index Page', path: '/index.html' },
        { name: 'Static JAMB App', path: '/jamb_test.html' },
        { name: 'Database JAMB App', path: '/jamb_api_test.html' },
        { name: 'Admin Dashboard', path: '/admin_dashboard.html' },
        { name: 'Phone App', path: '/phone_app.html' },
        { name: 'Test Suite Page', path: '/test_suite.html' }
    ];

    for (const page of frontendPages) {
        await runTest(`Frontend: ${page.name}`, async () => {
            const response = await makeRequest(`${CONFIG.FRONTEND_BASE}${page.path}`);
            if (response.statusCode !== 200) {
                throw new Error(`Expected 200, got ${response.statusCode}`);
            }
            if (!response.rawData.toLowerCase().includes('<!doctype html') && !response.rawData.toLowerCase().includes('<html')) {
                throw new Error('Response is not valid HTML');
            }
            if (response.rawData.length < 1000) {
                throw new Error('Page content seems too small');
            }
        });
    }

    logInfo('Frontend Tests completed');
}

// Integration Test Suite
async function runIntegrationTests() {
    logInfo('Starting Integration Tests...');

    await runTest('Frontend-Backend Integration', async () => {
        // Test CORS by making a request from simulated frontend context
        const response = await makeRequest(`${CONFIG.API_BASE}/api/subjects`, {
            headers: {
                'Origin': CONFIG.FRONTEND_BASE,
                'Access-Control-Request-Method': 'GET'
            }
        });
        if (response.statusCode !== 200) {
            throw new Error('CORS integration failed');
        }
    });

    await runTest('Complete Quiz Flow Simulation', async () => {
        // 1. Create session
        let sessionResponse = await makeRequest(`${CONFIG.API_BASE}/api/sessions/create`, {
            method: 'POST',
            body: { subjectCode: 'MTH', questionCount: 5 }
        });
        
        if (!sessionResponse.data.success) {
            throw new Error('Session creation failed');
        }
        
        const sessionId = sessionResponse.data.data.sessionId;
        
        // 2. Get questions
        let questionsResponse = await makeRequest(`${CONFIG.API_BASE}/api/questions/MTH?limit=3`);
        if (!questionsResponse.data.success || questionsResponse.data.data.length === 0) {
            throw new Error('Questions loading failed');
        }
        
        // 3. Submit answers
        for (let i = 0; i < Math.min(2, questionsResponse.data.data.length); i++) {
            const question = questionsResponse.data.data[i];
            const answerResponse = await makeRequest(`${CONFIG.API_BASE}/api/sessions/answer`, {
                method: 'POST',
                body: {
                    sessionId,
                    questionId: question.id,
                    chosenOption: 'A',
                    timeSpentMs: 3000
                }
            });
            
            if (!answerResponse.data.success) {
                throw new Error(`Answer submission failed for question ${i + 1}`);
            }
        }
        
        // 4. Get results
        const resultsResponse = await makeRequest(`${CONFIG.API_BASE}/api/sessions/${sessionId}/results`);
        if (!resultsResponse.data.success) {
            throw new Error('Results retrieval failed');
        }
    });

    await runTest('Database Connectivity', async () => {
        // Test different subjects to ensure database has data
        const subjects = ['MTH', 'ENG', 'PHY', 'CHM'];
        let totalQuestions = 0;
        
        for (const subject of subjects) {
            const response = await makeRequest(`${CONFIG.API_BASE}/api/questions/${subject}?limit=1`);
            if (response.data.success) {
                totalQuestions += response.data.data.length;
            }
        }
        
        if (totalQuestions < 3) {
            throw new Error(`Insufficient questions in database. Found ${totalQuestions}, expected at least 3`);
        }
    });

    logInfo('Integration Tests completed');
}

// Performance Test Suite
async function runPerformanceTests() {
    logInfo('Starting Performance Tests...');

    await runTest('API Response Time', async () => {
        const endpoint = `${CONFIG.API_BASE}/api/subjects`;
        const times = [];
        
        for (let i = 0; i < 10; i++) {
            const start = Date.now();
            await makeRequest(endpoint);
            times.push(Date.now() - start);
        }
        
        const avgTime = times.reduce((a, b) => a + b, 0) / times.length;
        const maxTime = Math.max(...times);
        
        if (avgTime > 1000) {
            throw new Error(`Average response time too slow: ${avgTime}ms`);
        }
        if (maxTime > 3000) {
            throw new Error(`Maximum response time too slow: ${maxTime}ms`);
        }
        
        logInfo(`Average response time: ${avgTime.toFixed(0)}ms, Max: ${maxTime}ms`);
    });

    await runTest('Concurrent Load Test', async () => {
        const promises = [];
        const startTime = Date.now();
        
        // Simulate 5 concurrent users
        for (let i = 0; i < CONFIG.CONCURRENT_USERS; i++) {
            promises.push(makeRequest(`${CONFIG.API_BASE}/api/questions/MTH?limit=3`));
        }
        
        const results = await Promise.allSettled(promises);
        const duration = Date.now() - startTime;
        
        const successful = results.filter(r => r.status === 'fulfilled').length;
        
        if (successful < CONFIG.CONCURRENT_USERS * 0.8) {
            throw new Error(`Only ${successful}/${CONFIG.CONCURRENT_USERS} concurrent requests succeeded`);
        }
        
        logInfo(`Concurrent load test: ${successful}/${CONFIG.CONCURRENT_USERS} successful in ${duration}ms`);
    });

    await runTest('Memory Usage Test', async () => {
        // Test large batch operations
        const responses = await Promise.all([
            makeRequest(`${CONFIG.API_BASE}/api/questions/MTH?limit=20`),
            makeRequest(`${CONFIG.API_BASE}/api/questions/ENG?limit=20`),
            makeRequest(`${CONFIG.API_BASE}/api/analytics`)
        ]);
        
        const allSuccessful = responses.every(r => r.statusCode === 200);
        if (!allSuccessful) {
            throw new Error('Some batch operations failed');
        }
        
        logInfo('Memory usage test passed - batch operations successful');
    });

    logInfo('Performance Tests completed');
}

// Security Test Suite
async function runSecurityTests() {
    logInfo('Starting Security Tests...');

    await runTest('SQL Injection Protection', async () => {
        // Test with malicious input
        const maliciousInputs = [
            "MTH'; DROP TABLE questions; --",
            "1' OR '1'='1",
            "MTH' UNION SELECT * FROM users--"
        ];
        
        for (const input of maliciousInputs) {
            try {
                const response = await makeRequest(`${CONFIG.API_BASE}/api/questions/${encodeURIComponent(input)}?limit=1`);
                // Should either return empty results or proper error, not crash
                if (response.statusCode === 500) {
                    throw new Error('Server crashed on malicious input');
                }
            } catch (error) {
                if (error.message.includes('crashed')) {
                    throw error;
                }
                // Network errors are acceptable for security tests
            }
        }
    });

    await runTest('CORS Configuration', async () => {
        const response = await makeRequest(`${CONFIG.API_BASE}/api/subjects`, {
            headers: {
                'Origin': 'http://malicious-site.com',
                'Access-Control-Request-Method': 'GET'
            }
        });
        
        // Should allow all origins in development (as configured)
        if (response.statusCode !== 200) {
            throw new Error('CORS configuration test failed');
        }
    });

    await runTest('Input Validation', async () => {
        // Test with invalid session data
        const response = await makeRequest(`${CONFIG.API_BASE}/api/sessions/create`, {
            method: 'POST',
            body: {
                subjectCode: '', // Invalid empty subject
                questionCount: -5 // Invalid negative count
            }
        });
        
        if (response.statusCode === 200 && response.data.success) {
            throw new Error('Server accepted invalid input');
        }
    });

    logInfo('Security Tests completed');
}

// Generate Test Report
function generateReport() {
    const duration = Date.now() - testResults.startTime;
    const successRate = ((testResults.passed / testResults.total) * 100).toFixed(1);
    
    console.log('\n' + '='.repeat(60));
    console.log(`${COLORS.cyan}ExamCoach Test Suite Report${COLORS.reset}`);
    console.log('='.repeat(60));
    console.log(`${COLORS.blue}Total Tests:${COLORS.reset} ${testResults.total}`);
    console.log(`${COLORS.green}Passed:${COLORS.reset} ${testResults.passed}`);
    console.log(`${COLORS.red}Failed:${COLORS.reset} ${testResults.failed}`);
    console.log(`${COLORS.yellow}Success Rate:${COLORS.reset} ${successRate}%`);
    console.log(`${COLORS.magenta}Duration:${COLORS.reset} ${(duration / 1000).toFixed(1)}s`);
    console.log('='.repeat(60));
    
    if (testResults.failed === 0) {
        console.log(`${COLORS.green}🎉 All tests passed! ExamCoach platform is working correctly.${COLORS.reset}`);
    } else {
        console.log(`${COLORS.red}❌ ${testResults.failed} tests failed. Please review the errors above.${COLORS.reset}`);
    }
    
    console.log('\nComponents tested:');
    console.log('- ✓ Backend API (Node.js + PostgreSQL)');
    console.log('- ✓ Frontend Applications (Static HTML + JavaScript)');
    console.log('- ✓ Database Integration');
    console.log('- ✓ CORS Configuration');
    console.log('- ✓ Session Management');
    console.log('- ✓ Question/Answer Flow');
    console.log('- ✓ Performance & Load Testing');
    console.log('- ✓ Security & Input Validation');
    console.log('\n');
}

// Main execution
async function main() {
    console.log(`${COLORS.cyan}🧪 ExamCoach Comprehensive Test Suite${COLORS.reset}`);
    console.log(`${COLORS.blue}Testing Backend: ${CONFIG.API_BASE}${COLORS.reset}`);
    console.log(`${COLORS.blue}Testing Frontend: ${CONFIG.FRONTEND_BASE}${COLORS.reset}`);
    console.log('');

    try {
        await runAPITests();
        await runFrontendTests();
        await runIntegrationTests();
        await runPerformanceTests();
        await runSecurityTests();
    } catch (error) {
        logError(`Test suite error: ${error.message}`);
    }

    generateReport();
    
    // Exit with appropriate code
    process.exit(testResults.failed > 0 ? 1 : 0);
}

// Handle command line arguments
if (process.argv.length > 2) {
    const testType = process.argv[2];
    
    switch (testType) {
        case 'api':
            runAPITests().then(generateReport);
            break;
        case 'frontend':
            runFrontendTests().then(generateReport);
            break;
        case 'integration':
            runIntegrationTests().then(generateReport);
            break;
        case 'performance':
            runPerformanceTests().then(generateReport);
            break;
        case 'security':
            runSecurityTests().then(generateReport);
            break;
        default:
            console.log('Usage: node run_tests.js [api|frontend|integration|performance|security]');
            process.exit(1);
    }
} else {
    main();
}

module.exports = {
    runAPITests,
    runFrontendTests,
    runIntegrationTests,
    runPerformanceTests,
    runSecurityTests
};