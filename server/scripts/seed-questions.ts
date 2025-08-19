import { Pool } from 'pg';
import dotenv from 'dotenv';

dotenv.config();

const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
});

const sampleQuestions = [
  // Mathematics
  {
    subjectCode: 'MTH',
    section: 'Algebra',
    year: 2024,
    questionNumber: 1,
    stem: 'If 2x + 3 = 7, what is the value of x?',
    optionA: '1',
    optionB: '2',
    optionC: '3',
    optionD: '4',
    correctOption: 'B',
    explanation: 'Solving: 2x + 3 = 7, therefore 2x = 4, so x = 2',
    difficulty: 2,
    syllabustopic: 'Linear Equations',
    verified: true
  },
  
  // Economics
  {
    subjectCode: 'ECO',
    section: 'Microeconomics',
    year: 2024,
    questionNumber: 1,
    stem: 'In a perfectly competitive market, individual firms are price _____.',
    optionA: 'makers',
    optionB: 'discriminators',
    optionC: 'takers',
    optionD: 'regulators',
    correctOption: 'C',
    explanation: 'Firms in perfect competition cannot influence price; they are price takers.',
    difficulty: 2,
    syllabustopic: 'Market Structures',
    verified: true
  },
  
  // Accounting
  {
    subjectCode: 'ACC',
    section: 'Financial Accounting',
    year: 2024,
    questionNumber: 1,
    stem: 'Which of the following is a liability?',
    optionA: 'Accounts Receivable',
    optionB: 'Inventory',
    optionC: 'Accounts Payable',
    optionD: 'Prepaid Rent',
    correctOption: 'C',
    explanation: 'Accounts Payable represents amounts owed to suppliers; it is a liability.',
    difficulty: 1,
    syllabustopic: 'Statement of Financial Position',
    verified: true
  },
  
  // Commerce
  {
    subjectCode: 'COM',
    section: 'Trade',
    year: 2024,
    questionNumber: 1,
    stem: 'The exchange of goods and services within a country is known as _____.',
    optionA: 'foreign trade',
    optionB: 'home trade',
    optionC: 'counter trade',
    optionD: 'barter trade',
    correctOption: 'B',
    explanation: 'Home trade refers to domestic trade within a country.',
    difficulty: 1,
    syllabustopic: 'Trade',
    verified: true
  },
  
  // Literature in English
  {
    subjectCode: 'LIT',
    section: 'Poetry',
    year: 2024,
    questionNumber: 1,
    stem: 'A figure of speech that compares two unlike things using “like” or “as” is called _____.',
    optionA: 'metaphor',
    optionB: 'simile',
    optionC: 'personification',
    optionD: 'hyperbole',
    correctOption: 'B',
    explanation: 'A simile makes comparisons using like or as.',
    difficulty: 1,
    syllabustopic: 'Figures of Speech',
    verified: true
  },
  
  // Government
  {
    subjectCode: 'GOV',
    section: 'Political Theory',
    year: 2024,
    questionNumber: 1,
    stem: 'The separation of powers was popularized by _____.',
    optionA: 'Karl Marx',
    optionB: 'Montesquieu',
    optionC: 'Max Weber',
    optionD: 'John Locke',
    correctOption: 'B',
    explanation: 'Baron de Montesquieu articulated the separation of powers in The Spirit of the Laws.',
    difficulty: 2,
    syllabustopic: 'Separation of Powers',
    verified: true
  },
  
  // History
  {
    subjectCode: 'HIS',
    section: 'African History',
    year: 2024,
    questionNumber: 1,
    stem: 'The trans-Saharan trade primarily connected West Africa with _____.',
    optionA: 'Europe',
    optionB: 'North Africa',
    optionC: 'East Asia',
    optionD: 'Southern Africa',
    correctOption: 'B',
    explanation: 'Trans-Saharan routes linked West African states with North African markets.',
    difficulty: 2,
    syllabustopic: 'Trade Routes',
    verified: true
  },
  
  // Geography
  {
    subjectCode: 'GEO',
    section: 'Physical Geography',
    year: 2024,
    questionNumber: 1,
    stem: 'Which layer of the atmosphere contains the ozone layer?',
    optionA: 'Troposphere',
    optionB: 'Stratosphere',
    optionC: 'Mesosphere',
    optionD: 'Thermosphere',
    correctOption: 'B',
    explanation: 'Most atmospheric ozone is concentrated in the lower stratosphere.',
    difficulty: 2,
    syllabustopic: 'Atmosphere',
    verified: true
  },
  {
    subjectCode: 'MTH',
    section: 'Algebra',
    year: 2024,
    questionNumber: 2,
    stem: 'What is the square root of 144?',
    optionA: '10',
    optionB: '11',
    optionC: '12',
    optionD: '13',
    correctOption: 'C',
    explanation: '√144 = 12 because 12 × 12 = 144',
    difficulty: 1,
    syllabustopic: 'Square Roots',
    verified: true
  },
  {
    subjectCode: 'MTH',
    section: 'Algebra',
    year: 2024,
    questionNumber: 3,
    stem: 'Find the value of x in the equation: 3x - 6 = 15',
    optionA: '5',
    optionB: '6',
    optionC: '7',
    optionD: '8',
    correctOption: 'C',
    explanation: 'Solving: 3x - 6 = 15, therefore 3x = 21, so x = 7',
    difficulty: 2,
    syllabustopic: 'Linear Equations',
    verified: true
  },
  {
    subjectCode: 'MTH',
    section: 'Calculus',
    year: 2024,
    questionNumber: 4,
    stem: 'If log₁₀ 100 = x, what is the value of x?',
    optionA: '1',
    optionB: '2',
    optionC: '10',
    optionD: '100',
    correctOption: 'B',
    explanation: 'log₁₀ 100 = 2 because 10² = 100',
    difficulty: 2,
    syllabustopic: 'Logarithms',
    verified: true
  },

  // Use of English
  {
    subjectCode: 'ENG',
    section: 'Lexis and Structure',
    year: 2024,
    questionNumber: 1,
    stem: 'Choose the correct form: "Neither John nor his friends ____ coming to the party."',
    optionA: 'is',
    optionB: 'are',
    optionC: 'was',
    optionD: 'were',
    correctOption: 'B',
    explanation: 'With "neither...nor" constructions, the verb agrees with the nearest subject. "Friends" is plural, so we use "are".',
    difficulty: 3,
    syllabustopic: 'Subject-Verb Agreement',
    verified: true
  },
  {
    subjectCode: 'ENG',
    section: 'Antonyms and Synonyms',
    year: 2024,
    questionNumber: 2,
    stem: 'What is the synonym of "meticulous"?',
    optionA: 'Careless',
    optionB: 'Careful',
    optionC: 'Quick',
    optionD: 'Lazy',
    correctOption: 'B',
    explanation: 'Meticulous means showing great attention to detail; being very careful and precise.',
    difficulty: 2,
    syllabustopic: 'Vocabulary',
    verified: true
  },
  {
    subjectCode: 'ENG',
    section: 'Lexis and Structure',
    year: 2024,
    questionNumber: 3,
    stem: 'Choose the correctly punctuated sentence:',
    optionA: 'The students\' books are on the table.',
    optionB: 'The student\'s books are on the table.',
    optionC: 'The students books are on the table.',
    optionD: 'The students book\'s are on the table.',
    correctOption: 'A',
    explanation: 'When referring to books belonging to multiple students, the apostrophe comes after the "s" in "students\'".',
    difficulty: 2,
    syllabustopic: 'Punctuation',
    verified: true
  },

  // Physics
  {
    subjectCode: 'PHY',
    section: 'Mechanics',
    year: 2024,
    questionNumber: 1,
    stem: 'What is the unit of force in the SI system?',
    optionA: 'Joule',
    optionB: 'Newton',
    optionC: 'Watt',
    optionD: 'Pascal',
    correctOption: 'B',
    explanation: 'The Newton (N) is the SI unit of force, named after Sir Isaac Newton.',
    difficulty: 1,
    syllabustopic: 'Units and Measurements',
    verified: true
  },
  {
    subjectCode: 'PHY',
    section: 'Mechanics',
    year: 2024,
    questionNumber: 2,
    stem: 'The acceleration due to gravity on Earth is approximately:',
    optionA: '9.8 m/s²',
    optionB: '10 m/s²',
    optionC: '8.9 m/s²',
    optionD: '11 m/s²',
    correctOption: 'A',
    explanation: 'The standard acceleration due to gravity on Earth is 9.8 m/s² or approximately 9.81 m/s².',
    difficulty: 1,
    syllabustopic: 'Gravity',
    verified: true
  },
  {
    subjectCode: 'PHY',
    section: 'Waves and Optics',
    year: 2024,
    questionNumber: 3,
    stem: 'Light travels fastest in:',
    optionA: 'Water',
    optionB: 'Glass',
    optionC: 'Vacuum',
    optionD: 'Air',
    correctOption: 'C',
    explanation: 'Light travels fastest in a vacuum at approximately 3×10⁸ m/s, as there are no particles to slow it down.',
    difficulty: 2,
    syllabustopic: 'Properties of Light',
    verified: true
  },
  {
    subjectCode: 'PHY',
    section: 'Mechanics',
    year: 2024,
    questionNumber: 4,
    stem: 'Which of the following is a vector quantity?',
    optionA: 'Speed',
    optionB: 'Mass',
    optionC: 'Velocity',
    optionD: 'Temperature',
    correctOption: 'C',
    explanation: 'Velocity is a vector quantity because it has both magnitude and direction, unlike speed which only has magnitude.',
    difficulty: 2,
    syllabustopic: 'Scalars and Vectors',
    verified: true
  },

  // Chemistry
  {
    subjectCode: 'CHM',
    section: 'Inorganic Chemistry',
    year: 2024,
    questionNumber: 1,
    stem: 'What is the chemical formula for water?',
    optionA: 'H₂O',
    optionB: 'CO₂',
    optionC: 'NaCl',
    optionD: 'O₂',
    correctOption: 'A',
    explanation: 'Water consists of two hydrogen atoms bonded to one oxygen atom, hence H₂O.',
    difficulty: 1,
    syllabustopic: 'Chemical Formulas',
    verified: true
  },
  {
    subjectCode: 'CHM',
    section: 'Atomic Structure',
    year: 2024,
    questionNumber: 2,
    stem: 'How many protons does a carbon atom have?',
    optionA: '4',
    optionB: '6',
    optionC: '8',
    optionD: '12',
    correctOption: 'B',
    explanation: 'Carbon has atomic number 6, which means it has 6 protons in its nucleus.',
    difficulty: 1,
    syllabustopic: 'Atomic Structure',
    verified: true
  },
  {
    subjectCode: 'CHM',
    section: 'Environmental Chemistry',
    year: 2024,
    questionNumber: 3,
    stem: 'What is the most abundant gas in Earth\'s atmosphere?',
    optionA: 'Oxygen',
    optionB: 'Carbon dioxide',
    optionC: 'Nitrogen',
    optionD: 'Hydrogen',
    correctOption: 'C',
    explanation: 'Nitrogen makes up about 78% of Earth\'s atmosphere, making it the most abundant gas.',
    difficulty: 2,
    syllabustopic: 'Atmospheric Chemistry',
    verified: true
  },
  {
    subjectCode: 'CHM',
    section: 'Inorganic Chemistry',
    year: 2024,
    questionNumber: 4,
    stem: 'Which of the following is an alkali metal?',
    optionA: 'Calcium',
    optionB: 'Sodium',
    optionC: 'Aluminum',
    optionD: 'Iron',
    correctOption: 'B',
    explanation: 'Sodium (Na) is an alkali metal found in Group 1 of the periodic table.',
    difficulty: 2,
    syllabustopic: 'Periodic Table',
    verified: true
  },

  // Biology
  {
    subjectCode: 'BIO',
    section: 'Cell Biology',
    year: 2024,
    questionNumber: 1,
    stem: 'What is the basic unit of life?',
    optionA: 'Tissue',
    optionB: 'Organ',
    optionC: 'Cell',
    optionD: 'Organism',
    correctOption: 'C',
    explanation: 'The cell is the smallest structural and functional unit of all living organisms.',
    difficulty: 1,
    syllabustopic: 'Cell Theory',
    verified: true
  },
  {
    subjectCode: 'BIO',
    section: 'Plant Biology',
    year: 2024,
    questionNumber: 2,
    stem: 'Photosynthesis primarily takes place in which part of the plant?',
    optionA: 'Roots',
    optionB: 'Stem',
    optionC: 'Leaves',
    optionD: 'Flowers',
    correctOption: 'C',
    explanation: 'Photosynthesis occurs mainly in the leaves, specifically in the chloroplasts of leaf cells.',
    difficulty: 1,
    syllabustopic: 'Photosynthesis',
    verified: true
  },
  {
    subjectCode: 'BIO',
    section: 'Animal Biology',
    year: 2024,
    questionNumber: 3,
    stem: 'Which blood type is known as the universal donor?',
    optionA: 'A',
    optionB: 'B',
    optionC: 'AB',
    optionD: 'O',
    correctOption: 'D',
    explanation: 'Type O blood lacks A and B antigens, making it compatible with all other blood types.',
    difficulty: 2,
    syllabustopic: 'Blood Groups',
    verified: true
  },
  {
    subjectCode: 'BIO',
    section: 'Genetics and Evolution',
    year: 2024,
    questionNumber: 4,
    stem: 'DNA stands for:',
    optionA: 'Deoxyribonucleic Acid',
    optionB: 'Diribonucleic Acid',
    optionC: 'Deoxyribose Acid',
    optionD: 'Deoxy Acid',
    correctOption: 'A',
    explanation: 'DNA is an abbreviation for Deoxyribonucleic Acid, the molecule that carries genetic information.',
    difficulty: 1,
    syllabustopic: 'Molecular Biology',
    verified: true
  }
];

const seedQuestions = async () => {
  const client = await pool.connect();
  
  try {
    console.log('Seeding JAMB questions...');
    
    for (const question of sampleQuestions) {
      await client.query(`
        INSERT INTO questions (
          subject_code, section, year, question_number, stem,
          option_a, option_b, option_c, option_d, correct_option,
          explanation, difficulty, syllabus_topic, verified, source
        ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15)
        ON CONFLICT DO NOTHING
      `, [
        question.subjectCode,
        question.section,
        question.year,
        question.questionNumber,
        question.stem,
        question.optionA,
        question.optionB,
        question.optionC,
        question.optionD,
        question.correctOption,
        question.explanation,
        question.difficulty,
        question.syllabustopic,
        question.verified,
        'JAMB'
      ]);
    }
    
    console.log('✅ Successfully seeded questions!');
    
  } catch (error) {
    console.error('❌ Error seeding questions:', error);
    throw error;
  } finally {
    client.release();
  }
};

if (require.main === module) {
  seedQuestions()
    .then(() => {
      console.log('Question seeding completed');
      process.exit(0);
    })
    .catch((error) => {
      console.error('Question seeding failed:', error);
      process.exit(1);
    });
}

export { seedQuestions };