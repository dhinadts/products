import express from "express";
import cors from "cors";
import bodyParser from "body-parser";
import { ApolloServer } from "apollo-server-express";
import { authRouter } from "./modules/auth/auth.routes";
import { ledgerRouter } from "./modules/ledger/ledger.routes";
import { bankBalancesRouter } from "./modules/bank-balances/bank-balances.routes";
import { balanceSheetRouter } from "./modules/balance-sheet/balance-sheet.routes";
import { notificationRouter } from "./modules/notifications/notification.routes";
import { errorHandler } from "./middleware/error-handler";
import { createContext } from "./graphql/context";
import { typeDefs } from "./graphql/typeDefs";
import { resolvers } from "./graphql/resolvers";
import { prisma } from "./prisma";

const allowedProductionOrigins = new Set([
  "https://dhinadts.github.io",
  "https://dhinadts.github.io/products",
  "https://dhinadts.github.io/products/",
   "https://ledger-06q7.onrender.com",
  "*",
]);

function isAllowedOrigin(origin?: string) {
  if (!origin) {
    return true;
  }

  if (allowedProductionOrigins.has(origin)) {
    return true;
  }

  try {
    const { hostname, protocol } = new URL(origin);
    return (
      protocol === "http:" &&
      (hostname === "localhost" || hostname === "127.0.0.1")
    );
  } catch {
    return false;
  }finally {
    console.log(`CORS check for origin: ${origin}, allowed: ${
      isAllowedOrigin(origin)
    }`);
    console.log(process.env.MONGO_URI);
  }
}

export async function createApp() {
  const app = express() as express.Application;

  await prisma.$connect();

  app.use(
    cors({
      origin(origin, callback) {
        callback(null, isAllowedOrigin(origin));
      },
      credentials: true,
    }),
  );
  app.use(express.json());
  app.use(bodyParser.json());
  app.get("/api/health", (_req, res) => {
    res.json({ success: true, data: { status: "ok" } });
  });
  app.use("/api/auth", authRouter);
  app.use("/api/ledger", ledgerRouter);
  app.use("/api/bank-balances", bankBalancesRouter);
  app.use("/api/balance-sheet", balanceSheetRouter);
  app.use("/api/notifications", notificationRouter);

  const server = new ApolloServer({
    typeDefs,
    resolvers,
    context: createContext,
  });

  await server.start();
  server.applyMiddleware({ app: app as any, path: "/graphql" });

  app.use(errorHandler);

  return app;
}
