import { Db } from 'mongodb';
import { connectToDatabase } from '../../db/mongo';
import bcrypt from 'bcrypt';
import jwt from 'jsonwebtoken';
import { config } from '../../config';

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
    private db: Db | undefined;

    private async getDb() {
        if (!this.db) {
            this.db = await connectToDatabase();
        }
        return this.db;
    }

    async register(payload: RegisterPayload) {
        const db = await this.getDb();
        const existing = await db.collection('users').findOne({ email: payload.email });
        if (existing) {
            throw new Error('Email already registered');
        }
        const passwordHash = await bcrypt.hash(payload.password, 12);
        const result = await db.collection('users').insertOne({
            name: payload.name,
            email: payload.email,
            passwordHash,
            role: payload.role,
            refreshTokens: [],
            createdAt: new Date(),
            updatedAt: new Date(),
        });
        return { userId: result.insertedId };
    }

    async login(payload: LoginPayload) {
        const db = await this.getDb();
        const user = await db.collection('users').findOne({ email: payload.email });
        if (!user) {
            throw new Error('Invalid credentials');
        }
        const valid = await bcrypt.compare(payload.password, user.passwordHash);
        if (!valid) {
            throw new Error('Invalid credentials');
        }
        const token = jwt.sign({ userId: user._id, role: user.role }, config.jwtSecret, { expiresIn: '15m' });
        const refreshToken = jwt.sign({ userId: user._id, role: user.role }, config.jwtRefreshSecret, { expiresIn: '30d' });
        await db.collection('users').updateOne({ _id: user._id }, { $push: { refreshTokens: refreshToken } });
        return { token, refreshToken };
    }

    async refreshToken(payload: { refreshToken: string }) {
        const db = await this.getDb();
        const decoded = jwt.verify(payload.refreshToken, config.jwtRefreshSecret) as any;
        const user = await db.collection('users').findOne({ _id: decoded.userId, refreshTokens: payload.refreshToken });
        if (!user) {
            throw new Error('Invalid refresh token');
        }
        const token = jwt.sign({ userId: user._id, role: user.role }, config.jwtSecret, { expiresIn: '15m' });
        return { token };
    }
}
