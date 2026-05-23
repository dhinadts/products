import { Collection, MongoClient, ObjectId } from 'mongodb';
import { config } from '../../config';
import { prisma } from '../../prisma';

interface LedgerEntryPayload {
    date: string;
    particulars: string;
    ledgerRef: string;
    debit: number;
    credit: number;
    status?: string;
    tags?: string[];
    createdBy?: string;
}

interface LedgerEntryDocument {
    _id?: ObjectId;
    date: Date;
    particulars: string;
    ledgerRef: string;
    debit: number;
    credit: number;
    status: string;
    tags: string[];
    createdBy: string;
    createdAt: Date;
    updatedAt: Date;
}

const mongoClient = new MongoClient(config.mongoUri);
let mongoConnection: Promise<MongoClient> | undefined;

export class LedgerService {
    async listEntries() {
        return prisma.ledgerEntry.findMany({
            orderBy: { date: 'desc' },
        });
    }

    async createEntry(entry: LedgerEntryPayload) {
        const debit = Number(entry.debit || 0);
        const credit = Number(entry.credit || 0);
        const date = new Date(entry.date);
        const particulars = entry.particulars?.trim();
        const ledgerRef = entry.ledgerRef?.trim();

        if (!particulars) {
            throw new Error('Particulars are required');
        }

        if (!ledgerRef) {
            throw new Error('Ledger reference is required');
        }

        if (Number.isNaN(date.getTime())) {
            throw new Error('Entry date is invalid');
        }

        if (debit < 0 || credit < 0) {
            throw new Error('Ledger amounts cannot be negative');
        }

        if (debit === 0 && credit === 0) {
            throw new Error('Enter either debit or credit amount');
        }

        if (debit > 0 && credit > 0) {
            throw new Error('Ledger entry cannot have both debit and credit amounts');
        }

        const now = new Date();
        const document: LedgerEntryDocument = {
            date,
            particulars,
            ledgerRef,
            debit,
            credit,
            status: entry.status || 'PENDING',
            tags: entry.tags || [],
            createdBy: entry.createdBy || 'system',
            createdAt: now,
            updatedAt: now,
        };
        const collection = await this.ledgerCollection();
        const result = await collection.insertOne(document);

        return this.publicEntry({ ...document, _id: result.insertedId });
    }

    async updateEntry(id: string, entry: Partial<LedgerEntryPayload>) {
        if ((entry.debit ?? 0) > 0 && (entry.credit ?? 0) > 0) {
            throw new Error('Ledger entry cannot have both debit and credit amounts');
        }

        const collection = await this.ledgerCollection();
        const result = await collection.findOneAndUpdate(
            { _id: new ObjectId(id) },
            {
                $set: {
                    ...(entry.date ? { date: new Date(entry.date) } : {}),
                    ...(entry.particulars !== undefined ? { particulars: entry.particulars } : {}),
                    ...(entry.ledgerRef !== undefined ? { ledgerRef: entry.ledgerRef } : {}),
                    ...(entry.debit !== undefined ? { debit: Number(entry.debit) } : {}),
                    ...(entry.credit !== undefined ? { credit: Number(entry.credit) } : {}),
                    ...(entry.status !== undefined ? { status: entry.status } : {}),
                    ...(entry.tags !== undefined ? { tags: entry.tags } : {}),
                    ...(entry.createdBy !== undefined ? { createdBy: entry.createdBy } : {}),
                    updatedAt: new Date(),
                },
            },
            { returnDocument: 'after' },
        );

        if (!result.value) {
            throw new Error('Ledger entry not found');
        }

        return this.publicEntry(result.value);
    }

    async deleteEntry(id: string) {
        const collection = await this.ledgerCollection();
        await collection.deleteOne({ _id: new ObjectId(id) });
        return { id };
    }

    async resetTestData() {
        const collection = await this.ledgerCollection();
        const now = new Date();
        const year = now.getFullYear();
        const month = now.getMonth();
        const day = now.getDate();
        const sampleEntries: LedgerEntryDocument[] = [
            {
                date: new Date(year, month, day, 9, 15),
                particulars: 'Salary Credit',
                ledgerRef: 'Salary Account - HDFC Bank',
                debit: 25000,
                credit: 0,
                status: 'Received',
                tags: ['Test', 'Salary'],
                createdBy: 'test-data',
                createdAt: now,
                updatedAt: now,
            },
            {
                date: new Date(year, month, day, 10, 0),
                particulars: 'Client Invoice',
                ledgerRef: 'Current Account - Axis Bank',
                debit: 18000,
                credit: 0,
                status: 'To Receive',
                tags: ['Test', 'Receivable'],
                createdBy: 'test-data',
                createdAt: now,
                updatedAt: now,
            },
            {
                date: new Date(year, month, day, 10, 30),
                particulars: 'Vendor Payment',
                ledgerRef: 'Current Account - Axis Bank',
                debit: 0,
                credit: 8500,
                status: 'Paid',
                tags: ['Test', 'Payable'],
                createdBy: 'test-data',
                createdAt: now,
                updatedAt: now,
            },
            {
                date: new Date(year, month, day, 11, 0),
                particulars: 'Office Rent',
                ledgerRef: 'Current Account - Axis Bank',
                debit: 0,
                credit: 12000,
                status: 'Unpaid',
                tags: ['Test', 'Payable'],
                createdBy: 'test-data',
                createdAt: now,
                updatedAt: now,
            },
            {
                date: new Date(year, month, day, 11, 30),
                particulars: 'Equipment Advance',
                ledgerRef: 'Savings Account - Axis Bank',
                debit: 0,
                credit: 6000,
                status: 'On Hold',
                tags: ['Test', 'Hold'],
                createdBy: 'test-data',
                createdAt: now,
                updatedAt: now,
            },
            {
                date: new Date(year, month, day, 12, 0),
                particulars: 'Service Refund',
                ledgerRef: 'Savings Account - Axis Bank',
                debit: 5200,
                credit: 0,
                status: 'Received',
                tags: ['Test', 'Refund'],
                createdBy: 'test-data',
                createdAt: now,
                updatedAt: now,
            },
        ];

        await collection.deleteMany({});
        const result = await collection.insertMany(sampleEntries);

        return sampleEntries.map((entry, index) =>
            this.publicEntry({ ...entry, _id: result.insertedIds[index] }),
        );
    }

    async syncEntries(entries: LedgerEntryPayload[]) {
        const results = [];

        for (const entry of entries) {
            results.push(await this.createEntry(entry));
        }

        return results;
    }

    private async ledgerCollection(): Promise<Collection<LedgerEntryDocument>> {
        mongoConnection ||= mongoClient.connect();
        const client = await mongoConnection;
        return client.db(this.databaseName()).collection<LedgerEntryDocument>('LedgerEntry');
    }

    private databaseName() {
        const url = new URL(config.mongoUri);
        return url.pathname.replace('/', '').trim() || 'ledger';
    }

    private publicEntry(entry: LedgerEntryDocument) {
        return {
            id: entry._id?.toHexString() || '',
            date: entry.date,
            particulars: entry.particulars,
            ledgerRef: entry.ledgerRef,
            debit: entry.debit,
            credit: entry.credit,
            status: entry.status,
            tags: entry.tags,
            createdBy: entry.createdBy,
            createdAt: entry.createdAt,
            updatedAt: entry.updatedAt,
        };
    }
}
