import { Router } from 'express';
import jwt from 'jsonwebtoken';
import { config } from '../../config';
import { AuthService } from './auth.service';

export const authRouter = Router();
const service = new AuthService();

authRouter.post('/register', async (req, res, next) => {
    try {
        const result = await service.register(req.body);
        res.json({ success: true, data: result });
    } catch (err) {
        next(err);
    }
});

authRouter.post('/login', async (req, res, next) => {
    try {
        const result = await service.login(req.body);
        res.json({ success: true, data: result });
    } catch (err) {
        next(err);
    }
});

authRouter.post('/refresh', async (req, res, next) => {
    try {
        const result = await service.refreshToken(req.body);
        res.json({ success: true, data: result });
    } catch (err) {
        next(err);
    }
});

authRouter.patch('/profile', async (req, res, next) => {
    try {
        const userId = getUserId(req.headers.authorization);
        if (!userId) {
            res.status(401).json({ success: false, error: 'Authentication required' });
            return;
        }

        const user = await service.updateProfile(userId, req.body);
        res.json({ success: true, data: user });
    } catch (err) {
        next(err);
    }
});

function getUserId(authHeader?: string) {
    if (!authHeader?.startsWith('Bearer ')) {
        return undefined;
    }

    try {
        const token = authHeader.slice(7);
        const payload = jwt.verify(token, config.jwtSecret) as { userId: string };
        return payload.userId;
    } catch (error) {
        return undefined;
    }
}
