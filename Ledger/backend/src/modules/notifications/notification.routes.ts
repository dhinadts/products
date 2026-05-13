import { Router } from 'express';

export const notificationRouter = Router();

notificationRouter.post('/send', async (req, res) => {
    res.json({ success: true, message: 'Notification trigger placeholder' });
});

notificationRouter.get('/history', async (req, res) => {
    res.json({ success: true, data: [] });
});
