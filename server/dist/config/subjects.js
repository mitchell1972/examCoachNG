"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.getAllSubjects = exports.getSubjectByCode = exports.JAMB_SUBJECTS = void 0;
exports.JAMB_SUBJECTS = {
    USE_OF_ENGLISH: {
        code: 'ENG',
        name: 'Use of English',
        questionCount: 60,
        duration: 60,
        sections: [
            'Comprehension Passages',
            'Antonyms and Synonyms',
            'Sentence Completion',
            'Oral English',
            'Lexis and Structure'
        ]
    },
    MATHEMATICS: {
        code: 'MTH',
        name: 'Mathematics',
        questionCount: 40,
        duration: 60,
        sections: [
            'Number and Numeration',
            'Algebra',
            'Geometry/Trigonometry',
            'Calculus',
            'Statistics'
        ]
    },
    PHYSICS: {
        code: 'PHY',
        name: 'Physics',
        questionCount: 40,
        duration: 60,
        sections: [
            'Mechanics',
            'Thermal Physics',
            'Waves and Optics',
            'Electricity and Magnetism',
            'Modern Physics'
        ]
    },
    CHEMISTRY: {
        code: 'CHM',
        name: 'Chemistry',
        questionCount: 40,
        duration: 60,
        sections: [
            'Physical Chemistry',
            'Inorganic Chemistry',
            'Organic Chemistry',
            'Environmental Chemistry',
            'Analytical Chemistry'
        ]
    },
    BIOLOGY: {
        code: 'BIO',
        name: 'Biology',
        questionCount: 40,
        duration: 60,
        sections: [
            'Cell Biology',
            'Plant Biology',
            'Animal Biology',
            'Ecology',
            'Genetics and Evolution'
        ]
    }
};
const getSubjectByCode = (code) => {
    return Object.values(exports.JAMB_SUBJECTS).find(subject => subject.code === code);
};
exports.getSubjectByCode = getSubjectByCode;
const getAllSubjects = () => {
    return Object.values(exports.JAMB_SUBJECTS);
};
exports.getAllSubjects = getAllSubjects;
//# sourceMappingURL=subjects.js.map