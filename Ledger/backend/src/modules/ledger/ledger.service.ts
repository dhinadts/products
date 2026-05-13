import { Db } from 'mongodb';
import { connectToDatabase } from '../../db/mongo';

export class LedgerService {
    private db: Db | undefined;

    private async getDb() {
        if (!this.db) {
            this.db = await connectToDatabase();
        }
        return this.db;
    }

    async listEntries() {
        const db = await this.getDb();
        return db.collection('ledgerEntries').find().toArray();
    }

    async createEntry(entry: any) {
        const db = await this.getDb();
        // validate debit/credit and amount
        return db.collection('ledgerEntries').insertOne({
            ...entry,
            createdAt: new Date(),
            updatedAt: new Date(),
        });
    }
}
