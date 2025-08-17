# ExamCoach Mobile App

## Overview

ExamCoach is a cross-platform mobile application (Android & iOS) built with Flutter for exam preparation. The app features an offline-first architecture with synchronized learning content, interactive quizzes, progress tracking, and premium pack purchases. The system uses a Node.js/TypeScript backend for content delivery, user management, and payment processing, with an AI microservice for question generation and validation.

## User Preferences

Preferred communication style: Simple, everyday language.

## Recent Changes

**August 17, 2025**
- ✅ Successfully debugged and fixed Flutter web app deployment issues
- ✅ Resolved Flutter SDK Git repository configuration problems  
- ✅ Built and deployed working Flutter web application on port 5000
- ✅ Confirmed app functionality with working counter button and proper ExamCoach branding
- ✅ Created fully functional JAMB test application with interactive quizzes
- ✅ Implemented complete question bank for Mathematics, English, Physics, and Chemistry
- ✅ Added real-time scoring, progress tracking, and visual answer feedback
- ✅ Built responsive web interface accessible at /jamb_test.html on port 5000
- ✅ Received comprehensive backend specification for production-ready JAMB system

## System Architecture

### Frontend Architecture (Flutter)
- **Cross-platform approach**: Single Flutter codebase targeting both Android and iOS
- **Offline-first design**: Local SQLite database using Drift ORM for content storage and synchronization
- **State management**: Riverpod with hooks for reactive state management and immutable models using Freezed
- **Navigation**: go_router for declarative routing with deep link support
- **Local storage**: shared_preferences for user settings and small flags

### Backend Architecture (Node.js/TypeScript)
- **API server**: Express.js REST API handling authentication, content delivery, and user management
- **Database**: PostgreSQL with comprehensive JAMB question bank and user performance tracking
- **Question management**: Advanced question selection with difficulty adaptation and bloom filters
- **AI integration**: Separate microservice for RAG-based question generation and validation
- **Background processing**: Question pack updates, analytics, and content synchronization
- **Payment integration**: Paystack/Flutterwave for Android, Apple IAP for iOS
- **Real-time analytics**: User performance tracking with mastery levels and weak area identification

### Data Storage Solutions
- **Local database**: SQLite with Drift ORM for offline content storage
- **Server database**: PostgreSQL for user data, content, and analytics
- **Sync strategy**: Server-wins for entitlements and pack versions, client-wins for user progress
- **Conflict resolution**: Merge strategy for statistics (sum attempts, max accuracy)

### Authentication and Authorization
- **User authentication**: JWT-based authentication through backend API
- **Session management**: Persistent login with secure token storage
- **Authorization**: Role-based access control for premium content

### Payment Processing
- **Android**: Paystack/Flutterwave web checkout integration
- **iOS**: Apple In-App Purchases using StoreKit
- **Entitlements**: Server-side storage and validation for both platforms
- **Webhook handling**: Payment confirmation and entitlement updates

### Performance Optimizations
- **Image handling**: Cached network images with lazy loading
- **Progressive loading**: Question pagination in chunks of 20
- **Loading states**: Shimmer effects for better UX
- **Content caching**: Local storage for downloaded packs and media

## JAMB Subject Configuration

The system supports comprehensive JAMB subjects:
- **Compulsory**: Use of English (60 questions, 60 minutes)
- **Sciences**: Mathematics, Physics, Chemistry, Biology (40 questions each)
- **Commercial**: Economics, Accounting, Commerce (40 questions each)  
- **Arts**: Literature, Government, CRK, History, Geography (40 questions each)

Each subject includes detailed sections and syllabus alignment for authentic JAMB preparation.

## External Dependencies

### Mobile Dependencies
- **dio**: HTTP client with interceptors for API communication
- **riverpod**: State management and dependency injection
- **go_router**: Navigation and routing
- **drift**: SQLite ORM for local database operations
- **firebase_messaging**: Push notifications via FCM
- **workmanager**: Background task scheduling
- **fl_chart**: Data visualization for progress tracking
- **cached_network_image**: Image caching and optimization

### Backend Services
- **PostgreSQL**: Primary database with comprehensive JAMB question bank
- **Redis**: Caching and session management
- **Bull Queue**: Background job processing for analytics and pack generation
- **Firebase**: Push notifications (FCM for Android, APNs for iOS)
- **Payment processors**: Paystack/Flutterwave for Android, Apple IAP for iOS
- **Analytics**: Firebase Analytics for user behavior tracking
- **Monitoring**: Sentry for crash reporting and error tracking
- **AI services**: Custom microservice for question generation and validation

### Development Tools
- **Testing framework**: Flutter test suite with unit, widget, and integration tests
- **Build tools**: Flutter SDK for cross-platform compilation
- **Version control**: Git with monorepo structure containing both client and server code