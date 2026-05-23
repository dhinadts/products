export interface BankBalance {
    id: string;
    accountName: string;
    bankName: string;
    accountType: string;
    balance: number;
}

export class BankBalancesService {
    listBalances(): BankBalance[] {
        return [
            {
                id: 'axis-savings',
                accountName: 'Savings Account',
                bankName: 'Axis Bank',
                accountType: 'Savings',
                balance: 100000,
            },
            {
                id: 'axis-current',
                accountName: 'Current Account',
                bankName: 'Axis Bank',
                accountType: 'Current',
                balance: 100000,
            },
            {
                id: 'hdfc-salary',
                accountName: 'Salary Account',
                bankName: 'HDFC Bank',
                accountType: 'Salary',
                balance: 55000,
            },
        ];
    }
}
