import { prisma } from "@repo/db";
import { betterAuth } from "better-auth";
import { prismaAdapter } from "better-auth/adapters/prisma";

const appUrlFromEnv =
  process.env.NEXT_PUBLIC_APP_URL ||
  (process.env.NEXT_PUBLIC_VERCEL_PROJECT_PRODUCTION_URL
    ? `https://${process.env.NEXT_PUBLIC_VERCEL_PROJECT_PRODUCTION_URL}`
    : process.env.VERCEL_URL
      ? `https://${process.env.VERCEL_URL}`
      : undefined);

const baseURL = appUrlFromEnv || "http://localhost:3000";
const trustedOrigins =
  process.env.NEXT_PUBLIC_TRUSTED_ORIGINS?.split(",").map((s) => s.trim()).filter(Boolean) || [baseURL, "http://localhost:3000"];

export const auth: ReturnType<typeof betterAuth> = betterAuth({
  database: prismaAdapter(prisma, {
    provider: "postgresql",
  }),
  socialProviders: {
    github: {
      clientId: process.env.GITHUB_CLIENT_ID as string,
      clientSecret: process.env.GITHUB_CLIENT_SECRET as string,
    },
  },
  secret: process.env.BETTER_AUTH_SECRET as string,
  trustedOrigins,
  callbacks: {
    redirect: {
      signInRedirect: "/",
      signUpRedirect: "/",
    },
  },
});
