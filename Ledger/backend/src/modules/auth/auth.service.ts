import bcrypt from 'bcrypt';
import jwt from 'jsonwebtoken';
import { config } from '../../config';
import { prisma } from '../../prisma';

interface RegisterPayload {
    name: string;
    email: string;
    password: string;
    role: string;
}

interface LoginPayload {
    email: string;
    password: string;
}

export class AuthService {
    async register(payload: RegisterPayload) {
        const existing = await prisma.user.findUnique({ where: { email: payload.email } });
        if (existing) {
            throw new Error('Email already registered');
        }
        const passwordHash = await bcrypt.hash(payload.password, 12);
        const user = await prisma.user.create({
            data: {
                name: payload.name,
                email: payload.email,
                passwordHash,
                role: payload.role || 'user',
                refreshTokens: [],
            },
        });
        const token = this.createToken(user.id, user.role);
        const refreshToken = this.createRefreshToken(user.id, user.role);
        await prisma.user.update({
            where: { id: user.id },
            data: { refreshTokens: { push: refreshToken } },
        });
        return { token, refreshToken, user: this.publicUser(user) };
    }

    async login(payload: LoginPayload) {
        const user = await prisma.user.findUnique({ where: { email: payload.email } });
        if (!user) {
            throw new Error('Invalid credentials');
        }
        const valid = await bcrypt.compare(payload.password, user.passwordHash);
        if (!valid) {
            throw new Error('Invalid credentials');
        }
        const token = this.createToken(user.id, user.role);
        const refreshToken = this.createRefreshToken(user.id, user.role);
        await prisma.user.update({
            where: { id: user.id },
            data: { refreshTokens: { push: refreshToken } },
        });
        return { token, refreshToken, user: this.publicUser(user) };
    }

    async refreshToken(payload: { refreshToken: string }) {
        const decoded = jwt.verify(payload.refreshToken, config.jwtRefreshSecret) as { userId: string; role: string };
        const user = await prisma.user.findUnique({ where: { id: decoded.userId } });
        if (!user || !user.refreshTokens.includes(payload.refreshToken)) {
            throw new Error('Invalid refresh token');
        }
        const token = this.createToken(user.id, user.role);
        return { token, refreshToken: payload.refreshToken, user: this.publicUser(user) };
    }

    private createToken(userId: string, role: string) {
        return jwt.sign({ userId, role }, config.jwtSecret, { expiresIn: '15m' });
    }

    private createRefreshToken(userId: string, role: string) {
        return jwt.sign({ userId, role }, config.jwtRefreshSecret, { expiresIn: '30d' });
    }

    private publicUser(user: { id: string; name: string; email: string; role: string; createdAt: Date; updatedAt: Date }) {
        return {
            id: user.id,
            name: user.name,
            email: user.email,
            role: user.role,
            createdAt: user.createdAt,
            updatedAt: user.updatedAt,
        };
    }
}
