
# Aqua Elite — Hugo + Supabase (Full Starter)

## Supabase first
- Set Google provider (Client ID/Secret), URL Configuration, then run `supabase/schema.sql` and `supabase/seed.sql`.
- After your first login, make yourself admin:
```sql
update public.profiles set role='admin' where email='YOUR_EMAIL';
```

## Configure site
Edit **config.toml**:
```toml
[params.supabase]
url  = "https://<YOUR_PROJECT_REF>.supabase.co"
anon = "<YOUR_ANON_PUBLIC_KEY>"
```

## GitHub Pages
- Public repo: `aquaeliteswim121.github.io`
- Pages → Source = **GitHub Actions** (workflow included)
