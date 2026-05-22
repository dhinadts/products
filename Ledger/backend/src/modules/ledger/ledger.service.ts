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

export class LedgerService {
    async listEntries() {
        return prisma.ledgerEntry.findMany({
            orderBy: { date: 'desc' },
        });
    }

    async createEntry(entry: LedgerEntryPayload) {
        if (entry.debit > 0 && entry.credit > 0) {
            throw new Error('Ledger entry cannot have both debit and credit amounts');
        }

        return prisma.ledgerEntry.create({
            data: {
                date: new Date(entry.date),
                particulars: entry.particulars,
                ledgerRef: entry.ledgerRef,
                debit: Number(entry.debit || 0),
                credit: Number(entry.credit || 0),
                status: entry.status || 'PENDING',
                tags: entry.tags || [],
                createdBy: entry.createdBy || 'system',
            },
        });
    }

    async updateEntry(id: string, entry: Partial<LedgerEntryPayload>) {
        if ((entry.debit ?? 0) > 0 && (entry.credit ?? 0) > 0) {
            throw new Error('Ledger entry cannot have both debit and credit amounts');
        }

        return prisma.ledgerEntry.update({
            where: { id },
            data: {
                ...(entry.date ? { date: new Date(entry.date) } : {}),
                ...(entry.particulars !== undefined ? { particulars: entry.particulars } : {}),
                ...(entry.ledgerRef !== undefined ? { ledgerRef: entry.ledgerRef } : {}),
                ...(entry.debit !== undefined ? { debit: Number(entry.debit) } : {}),
                ...(entry.credit !== undefined ? { credit: Number(entry.credit) } : {}),
                ...(entry.status !== undefined ? { status: entry.status } : {}),
                ...(entry.tags !== undefined ? { tags: entry.tags } : {}),
                ...(entry.createdBy !== undefined ? { createdBy: entry.createdBy } : {}),
            },
        });
    }

    async deleteEntry(id: string) {
        await prisma.ledgerEntry.delete({ where: { id } });
        return { id };
    }

    async syncEntries(entries: LedgerEntryPayload[]) {
        const results = [];

        for (const entry of entries) {
            results.push(await this.createEntry(entry));
        }

        return results;
    }
}
