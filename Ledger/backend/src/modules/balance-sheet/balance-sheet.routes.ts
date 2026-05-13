import { Router } from 'express';

export const balanceSheetRouter = Router();

balanceSheetRouter.get('/current', async (req, res) => {
    res.json({ success: true, data: { assets: [], liabilities: [] } });
});
