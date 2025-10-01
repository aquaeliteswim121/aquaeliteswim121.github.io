<script>
// static/js/auth.js
(function () {
  const { createClient } = window.supabase;
  window.supabase = createClient(window.SUPABASE_URL, window.SUPABASE_ANON);

  const loginBtn  = document.getElementById('loginBtn');
  const logoutBtn = document.getElementById('logoutBtn');

  function warn(msg){
    const el = document.getElementById('authWarn');
    if (el){ el.textContent = msg; el.classList.remove('hidden'); }
  }

  function gateNav(session){
    const authLinks  = document.querySelectorAll('[data-auth="auth-only"]');
    const adminLinks = document.querySelectorAll('[data-role="admin"]');
    authLinks.forEach(a => a.style.display = session ? "" : "none");
    if (session){
      window.supabase.from('profiles').select('role').eq('id', session.user.id).single()
        .then(({data}) => {
          const isAdmin = data && data.role === 'admin';
          adminLinks.forEach(a => a.style.display = isAdmin ? "" : "none");
        })
        .catch(() => adminLinks.forEach(a => a.style.display = "none"));
    } else {
      adminLinks.forEach(a => a.style.display = "none");
    }
  }

  function setNav(session){
    if (loginBtn && logoutBtn){
      if (session) { loginBtn.classList.add('hidden'); logoutBtn.classList.remove('hidden'); }
      else         { loginBtn.classList.remove('hidden'); logoutBtn.classList.add('hidden'); }
    }
    gateNav(session);
  }

  // NEW: wait briefly for Supabase to restore session from storage
  async function waitForSession(timeoutMs = 1800){
    const start = Date.now();
    let { data: { session } } = await supabase.auth.getSession();
    while (!session && (Date.now() - start) < timeoutMs) {
      await new Promise(r => setTimeout(r, 120));
      ({ data: { session } } = await supabase.auth.getSession());
    }
    return session || null;
  }

  // NEW: soft mode avoids immediate redirect (prevents flicker)
  window.requireAuth = async (redirectTo = '/', { soft = false } = {}) => {
    const session = await waitForSession(1800);
    if (!session) {
      if (soft) return null;        // caller decides what to show
      window.location.href = redirectTo;
      return null;
    }
    setNav(session);
    return session;
  };

  if (loginBtn) {
    loginBtn.addEventListener('click', async () => {
      if (!window.SUPABASE_URL || !window.SUPABASE_ANON){ warn('Supabase not configured'); return; }
      await supabase.auth.signInWithOAuth({
        provider: 'google',
        options: { redirectTo: window.location.origin + '/dashboard/' }
      });
    });
  }

  if (logoutBtn) {
    logoutBtn.addEventListener('click', async () => {
      await supabase.auth.signOut();
      window.location.href = '/';
    });
  }

  supabase.auth.onAuthStateChange((_event, session) => setNav(session));
})();
</script>
