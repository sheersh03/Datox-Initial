"use client";

import { useState } from "react";
import { useRouter } from "next/navigation";
import { LockKeyhole, ShieldCheck } from "lucide-react";

export default function LoginPage() {
  const router = useRouter();
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [showPassword, setShowPassword] = useState(false);
  const [remember, setRemember] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [loading, setLoading] = useState(false);

  async function onSubmit(e: React.FormEvent) {
    e.preventDefault();
    setError(null);
    setLoading(true);
    try {
      const res = await fetch("/api/auth/login", {
        method: "POST",
        headers: { "content-type": "application/json" },
        body: JSON.stringify({ email, password, remember }),
      });
      if (!res.ok) {
        const j = await res.json().catch(() => ({}));
        setError(j?.message || "Login failed");
        return;
      }
      const body = await res.json().catch(() => ({}));
      const adminRole = body?.admin?.role;
      if (typeof adminRole === "string" && adminRole.trim()) {
        localStorage.setItem("datox_admin_role", adminRole);
      } else {
        localStorage.removeItem("datox_admin_role");
      }
      router.replace("/");
    } finally {
      setLoading(false);
    }
  }

  return (
    <main className="auth-page">
      <section className="auth-panel auth-panel-brand">
        <div className="auth-brand-mark">DX</div>
        <h1>Datox Admin</h1>
        <p>Secure operations workspace for moderation, compliance, and system oversight.</p>

        <ul className="auth-benefits" aria-label="Platform capabilities">
          <li>
            <ShieldCheck className="icon-16" />
            Encrypted admin sessions
          </li>
          <li>
            <LockKeyhole className="icon-16" />
            Role-aware access controls
          </li>
        </ul>
      </section>

      <section className="auth-panel auth-panel-form">
        <div className="auth-form-head">
          <h2>Welcome back</h2>
          <p>Sign in to continue.</p>
        </div>

        <form onSubmit={onSubmit} className="auth-form">
          <label className="auth-label">
            <span>Email</span>
          <input
            type="email"
            value={email}
            onChange={(e) => setEmail(e.target.value)}
            placeholder="admin@datox.com"
            autoComplete="username"
            className="auth-input"
          />
        </label>

          <label className="auth-label">
            <span>Password</span>
            <div className="password-wrap">
            <input
              type={showPassword ? "text" : "password"}
              value={password}
              onChange={(e) => setPassword(e.target.value)}
              placeholder="Admin password"
              autoComplete="current-password"
              className="auth-input auth-input-password"
            />
            <button
              type="button"
              onClick={() => setShowPassword((v) => !v)}
              aria-label={showPassword ? "Hide password" : "Show password"}
              title={showPassword ? "Hide password" : "Show password"}
              className="password-toggle"
            >
              <span className={`password-icon ${showPassword ? "is-visible" : ""}`}>
                {showPassword ? (
                  <svg width="18" height="18" viewBox="0 0 24 24" fill="none" aria-hidden="true">
                    <path d="M3 3L21 21" stroke="currentColor" strokeWidth="2" strokeLinecap="round" />
                    <path
                      d="M10.6 10.6A2 2 0 0 0 13.4 13.4"
                      stroke="currentColor"
                      strokeWidth="2"
                      strokeLinecap="round"
                    />
                    <path
                      d="M9.36 5.56A9.73 9.73 0 0 1 12 5.2C17 5.2 21 12 21 12A18.2 18.2 0 0 1 18.46 15.32"
                      stroke="currentColor"
                      strokeWidth="2"
                      strokeLinecap="round"
                    />
                    <path
                      d="M6.26 8.28A18.96 18.96 0 0 0 3 12S7 18.8 12 18.8A9.7 9.7 0 0 0 15.14 18.29"
                      stroke="currentColor"
                      strokeWidth="2"
                      strokeLinecap="round"
                    />
                  </svg>
                ) : (
                  <svg width="18" height="18" viewBox="0 0 24 24" fill="none" aria-hidden="true">
                    <path
                      d="M2 12S6 5.2 12 5.2S22 12 22 12S18 18.8 12 18.8S2 12 2 12Z"
                      stroke="currentColor"
                      strokeWidth="2"
                    />
                    <circle cx="12" cy="12" r="3" stroke="currentColor" strokeWidth="2" />
                  </svg>
                )}
              </span>
            </button>
          </div>
        </label>

          <label className="auth-remember">
            <input type="checkbox" checked={remember} onChange={(e) => setRemember(e.target.checked)} />
            <span>Remember me</span>
        </label>

          {error ? <div className="auth-error">{error}</div> : null}

        <button
          disabled={loading}
            className="auth-submit"
        >
          {loading ? "Signing in..." : "Sign in"}
        </button>
      </form>
      </section>
    </main>
  );
}
