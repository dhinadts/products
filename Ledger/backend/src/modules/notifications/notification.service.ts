import { Db } from 'mongodb';
import { connectToDatabase } from '../../db/mongo';

export class NotificationService {
    private db: Db | undefined;

    private async getDb() {
        if (!this.db) {
            this.db = await connectToDatabase();
        }
        return this.db;
    }

    async logNotification(notification: any) {
        const db = await this.getDb();
        return db.collection('notifications').insertOne({
            ...notification,
            createdAt: new Date(),
        });
    }
}
