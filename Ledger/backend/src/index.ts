import dotenv from 'dotenv';
import { app } from './app';
import { config } from './config';

dotenv.config();

const port = Number(config.port);
console.log(`Balance Sheet Ledger backend running on port ${port}`);
});
