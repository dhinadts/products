import { Router } from 'express';
import { NotificationService } from './notification.service';

export const notificationRouter = Router();
const service = new NotificationService();

notificationRouter.post('/send', async (req, res, next) => {
    try {
        const notification = await service.logNotification(req.body);
        res.status(201).json({ success: true, data: notification });
    } catch (err) {
        next(err);
    }
});

notificationRouter.get('/history', async (_req, res, next) => {
    try {
        const notifications = await service.listNotifications();
        res.json({ success: true, data: notifications });
    } catch (err) {
        next(err);
    }
});

notificationRouter.post('/sync', async (req, res, next) => {
    try {
        const notifications = Array.isArray(req.body.notifications) ? req.body.notifications : [];
        const result = await service.syncNotifications(notifications);
        res.json({ success: true, data: result });
    } catch (err) {
        next(err);
    }
});

notificationRouter.patch('/:id/read', async (req, res, next) => {
    try {
        const notification = await service.markRead(req.params.id, req.body.isRead ?? true);
        res.json({ success: true, data: notification });
    } catch (err) {
        next(err);
    }
});

notificationRouter.delete('/:id', async (req, res, next) => {
    try {
        const result = await service.deleteNotification(req.params.id);
        res.json({ success: true, data: result });
    } catch (err) {
        next(err);
    }
});
