import { createAuthClient } from "better-auth/react";

function resolveBaseUrl(): string {
  if (typeof window !== "undefined") {
    return window.location.origin;
  }
  const appUrlFromEnv =
    process.env.NEXT_PUBLIC_APP_URL ||
    (process.env.NEXT_PUBLIC_VERCEL_PROJECT_PRODUCTION_URL
      ? `https://${process.env.NEXT_PUBLIC_VERCEL_PROJECT_PRODUCTION_URL}`
      : process.env.VERCEL_URL
        ? `https://${process.env.VERCEL_URL}`
        : undefined);
  return appUrlFromEnv || "http://localhost:3000";
}

export const authClient: ReturnType<typeof createAuthClient> = createAuthClient(
  {
    baseURL: resolveBaseUrl(),
    basePath: "/api/auth",
  }
);

// This destructuring is necessary to avoid weird better-auth type errors
export const signIn: typeof authClient.signIn = authClient.signIn;
export const signOut: typeof authClient.signOut = authClient.signOut;
export const signUp: typeof authClient.signUp = authClient.signUp;
export const useSession: typeof authClient.useSession = authClient.useSession;
