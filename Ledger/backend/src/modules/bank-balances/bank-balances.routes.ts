import { Router } from 'express';
import { BankBalancesService } from './bank-balances.service';

export const bankBalancesRouter = Router();
const service = new BankBalancesService();

bankBalancesRouter.get('/', (_req, res) => {
    res.json({ success: true, data: service.listBalances() });
});
