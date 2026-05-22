import { Router } from 'express';
import { LedgerService } from './ledger.service';

export const ledgerRouter = Router();
const service = new LedgerService();

ledgerRouter.get('/', async (_req, res, next) => {
    try {
        const entries = await service.listEntries();
        res.json({ success: true, data: entries });
    } catch (err) {
        next(err);
    }
});

ledgerRouter.post('/entry', async (req, res, next) => {
    try {
        const entry = await service.createEntry(req.body);
        res.status(201).json({ success: true, data: entry });
    } catch (err) {
        next(err);
    }
});

ledgerRouter.post('/sync', async (req, res, next) => {
    try {
        const entries = Array.isArray(req.body.entries) ? req.body.entries : [];
        const result = await service.syncEntries(entries);
        res.json({ success: true, data: result });
    } catch (err) {
        next(err);
    }
});

ledgerRouter.put('/entry/:id', async (req, res, next) => {
    try {
        const entry = await service.updateEntry(req.params.id, req.body);
        res.json({ success: true, data: entry });
    } catch (err) {
        next(err);
    }
});

ledgerRouter.delete('/entry/:id', async (req, res, next) => {
    try {
        const result = await service.deleteEntry(req.params.id);
        res.json({ success: true, data: result });
    } catch (err) {
        next(err);
    }
});
