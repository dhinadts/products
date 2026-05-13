import { Router } from 'express';

export const ledgerRouter = Router();

ledgerRouter.get('/', async (req, res) => {
    res.json({ success: true, data: [] });
});

ledgerRouter.post('/entry', async (req, res) => {
    res.json({ success: true, message: 'Ledger entry endpoint placeholder' });
});
