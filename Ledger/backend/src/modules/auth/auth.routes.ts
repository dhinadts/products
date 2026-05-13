import { Router } from 'express';
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
