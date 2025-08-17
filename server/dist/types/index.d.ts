export interface User {
    id: string;
    phone: string;
    name?: string;
    email?: string;
    selectedSubjects: string[];
    createdAt: Date;
    lastActive: Date;
}
export interface Question {
    id: string;
    subjectCode: string;
    section: string;
    year?: number;
    questionNumber?: number;
    stem: string;
    optionA: string;
    optionB: string;
    optionC: string;
    optionD: string;
    optionE?: string;
    correctOption: 'A' | 'B' | 'C' | 'D' | 'E';
    explanation?: string;
    difficulty: number;
    imageUrl?: string;
    syllabustopic?: string;
    tags: string[];
    verified: boolean;
    source: string;
    createdAt: Date;
    updatedAt: Date;
}
export interface Session {
    id: string;
    userId: string;
    mode: 'practice' | 'mock' | 'topic';
    subjectCode: string;
    topic?: string;
    questionCount: number;
    timeLimit: number;
    startedAt: Date;
    endedAt?: Date;
    score?: number;
    status: 'active' | 'paused' | 'completed' | 'abandoned';
    metadata?: any;
}
export interface Attempt {
    id: string;
    sessionId: string;
    questionId: string;
    userId: string;
    chosenOption?: 'A' | 'B' | 'C' | 'D' | 'E';
    isCorrect?: boolean;
    timeSpentMs: number;
    flagged: boolean;
    createdAt: Date;
}
export interface UserPerformance {
    userId: string;
    subjectCode: string;
    topic: string;
    totalAttempts: number;
    correctAttempts: number;
    accuracy: number;
    averageTimeMs: number;
    masteryLevel: number;
    weakAreas: string[];
    lastUpdated: Date;
}
export interface QuestionFilter {
    subjectCode?: string;
    section?: string;
    difficulty?: number[];
    year?: number[];
    verified?: boolean;
    excludeIds?: string[];
    limit?: number;
    offset?: number;
}
export interface CreateSessionRequest {
    subjectCode: string;
    mode: 'practice' | 'mock' | 'topic';
    topic?: string;
    questionCount?: number;
    timeLimit?: number;
}
export interface SubmitAnswerRequest {
    sessionId: string;
    questionId: string;
    chosenOption: 'A' | 'B' | 'C' | 'D' | 'E';
    timeSpentMs: number;
    flagged?: boolean;
}
//# sourceMappingURL=index.d.ts.map