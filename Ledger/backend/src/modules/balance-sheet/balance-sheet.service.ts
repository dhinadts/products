import { Db } from 'mongodb';
import { connectToDatabase } from '../../db/mongo';

export class BalanceSheetService {
    private db: Db | undefined;

    private async getDb() {
        if (!this.db) {
            this.db = await connectToDatabase();
        }
        return this.db;
    }

    async getCurrentBalanceSheet() {
        const db = await this.getDb();
        const assets = await db.collection('balanceSheet').find({ type: 'asset' }).toArray();
        const liabilities = await db.collection('balanceSheet').find({ type: 'liability' }).toArray();
        return { assets, liabilities };
    }
}
