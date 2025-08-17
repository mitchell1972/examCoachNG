export const JAMB_SUBJECTS = {
  // Compulsory
  USE_OF_ENGLISH: {
    code: 'ENG',
    name: 'Use of English',
    questionCount: 60,
    duration: 60, // minutes
    sections: [
      'Comprehension Passages',
      'Antonyms and Synonyms',
      'Sentence Completion',
      'Oral English',
      'Lexis and Structure'
    ]
  },
  
  // Sciences
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
  },
  
  // Commercial
  ECONOMICS: {
    code: 'ECO',
    name: 'Economics',
    questionCount: 40,
    duration: 60,
    sections: [
      'Basic Economic Concepts',
      'Microeconomics',
      'Macroeconomics',
      'International Trade',
      'Economic Development'
    ]
  },
  ACCOUNTING: {
    code: 'ACC',
    name: 'Accounting',
    questionCount: 40,
    duration: 60,
    sections: [
      'Financial Accounting',
      'Cost Accounting',
      'Management Accounting',
      'Government Accounting',
      'Auditing'
    ]
  },
  COMMERCE: {
    code: 'COM',
    name: 'Commerce',
    questionCount: 40,
    duration: 60,
    sections: [
      'Trade',
      'Business Organizations',
      'Finance',
      'Marketing',
      'Business Communication'
    ]
  },
  
  // Arts
  LITERATURE: {
    code: 'LIT',
    name: 'Literature in English',
    questionCount: 40,
    duration: 60,
    sections: [
      'African Prose',
      'Non-African Prose',
      'African Drama',
      'Non-African Drama',
      'Poetry'
    ]
  },
  GOVERNMENT: {
    code: 'GOV',
    name: 'Government',
    questionCount: 40,
    duration: 60,
    sections: [
      'Political Theory',
      'Nigerian Government',
      'International Relations',
      'Public Administration',
      'Political Parties'
    ]
  },
  HISTORY: {
    code: 'HIS',
    name: 'History',
    questionCount: 40,
    duration: 60,
    sections: [
      'Nigerian History Pre-1800',
      'Nigerian History 1800-1960',
      'Nigerian History Post-1960',
      'African History',
      'World History'
    ]
  },
  GEOGRAPHY: {
    code: 'GEO',
    name: 'Geography',
    questionCount: 40,
    duration: 60,
    sections: [
      'Physical Geography',
      'Human Geography',
      'Regional Geography',
      'Map Reading',
      'GIS and Remote Sensing'
    ]
  }
};

export const getSubjectByCode = (code: string) => {
  return Object.values(JAMB_SUBJECTS).find(subject => subject.code === code);
};

export const getAllSubjects = () => {
  return Object.values(JAMB_SUBJECTS);
};