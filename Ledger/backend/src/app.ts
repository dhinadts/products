import express from 'express';
import cors from 'cors';
import bodyParser from 'body-parser';
import { ApolloServer } from 'apollo-server-express';
import { authRouter } from './modules/auth/auth.routes';
import { ledgerRouter } from './modules/ledger/ledger.routes';
import { balanceSheetRouter } from './modules/balance-sheet/balance-sheet.routes';
import { notificationRouter } from './modules/notifications/notification.routes';
import { errorHandler } from './middleware/error-handler';
import { createContext } from './graphql/context';
import { typeDefs } from './graphql/typeDefs';
import { resolvers } from './graphql/resolvers';

export async function createApp() {
    const app = express() as express.Application;

    app.use(cors());
    app.use(bodyParser.json());
    app.get('/api/health', (_req, res) => {
        res.json({ success: true, data: { status: 'ok' } });
    });
    app.use('/api/auth', authRouter);
    app.use('/api/ledger', ledgerRouter);
    app.use('/api/balance-sheet', balanceSheetRouter);
    app.use('/api/notifications', notificationRouter);

    const server = new ApolloServer({
        typeDefs,
        resolvers,
        context: createContext,
    });

    await server.start();
    server.applyMiddleware({ app: app as any, path: '/graphql' });

    app.use(errorHandler);

    return app;
}
