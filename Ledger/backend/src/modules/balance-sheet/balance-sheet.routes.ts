import { Router } from 'express';
import { BalanceSheetService } from './balance-sheet.service';

export const balanceSheetRouter = Router();
const service = new BalanceSheetService();

balanceSheetRouter.get('/current', async (_req, res, next) => {
    try {
        const summary = await service.getCurrentBalanceSheet();
        res.json({ success: true, data: summary });
    } catch (err) {
        next(err);
    }
});

balanceSheetRouter.post('/items', async (req, res, next) => {
    try {
        const item = await service.addItem(req.body);
        res.status(201).json({ success: true, data: item });
    } catch (err) {
        next(err);
    }
});

balanceSheetRouter.post('/sync', async (req, res, next) => {
    try {
        const items = Array.isArray(req.body.items) ? req.body.items : [];
        const result = await service.syncItems(items);
        res.json({ success: true, data: result });
    } catch (err) {
        next(err);
    }
});

balanceSheetRouter.put('/items/:id', async (req, res, next) => {
    try {
        const item = await service.updateItem(req.params.id, req.body);
        res.json({ success: true, data: item });
    } catch (err) {
        next(err);
    }
});

balanceSheetRouter.delete('/items/:id', async (req, res, next) => {
    try {
        const result = await service.deleteItem(req.params.id);
        res.json({ success: true, data: result });
    } catch (err) {
        next(err);
    }
});
