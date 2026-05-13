import express from 'express';
import cors from 'cors';
import bodyParser from 'body-parser';
import { authRouter } from './modules/auth/auth.routes';
import { ledgerRouter } from './modules/ledger/ledger.routes';
import { balanceSheetRouter } from './modules/balance-sheet/balance-sheet.routes';
import { notificationRouter } from './modules/notifications/notification.routes';
import { errorHandler } from './middleware/error-handler';

const app = express();

app.use(cors());
app.use(bodyParser.json());
app.use('/api/auth', authRouter);
app.use('/api/ledger', ledgerRouter);
app.use('/api/balance-sheet', balanceSheetRouter);
app.use('/api/notifications', notificationRouter);
app.use(errorHandler);

export { app };
