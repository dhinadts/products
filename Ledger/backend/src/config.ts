import dotenv from 'dotenv';

dotenv.config();

export const config = {
    port: process.env.PORT || '4000',
    jwtSecret: process.env.JWT_SECRET || 'replace-with-secure-secret',
    jwtRefreshSecret: process.env.JWT_REFRESH_SECRET || 'replace-with-secure-refresh-secret',
    mongoUri: process.env.MONGO_URI || 'mongodb://localhost:27017/ledger',
    gmailUser: process.env.GMAIL_USER || '',
    gmailAppPassword: process.env.GMAIL_APP_PASSWORD || '',
};
