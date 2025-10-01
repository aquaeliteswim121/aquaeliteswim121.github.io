
(function(){
  const { createClient } = window.supabase;
  window.supabase = createClient(window.SUPABASE_URL, window.SUPABASE_ANON);
  const loginBtn = document.getElementById('loginBtn');
  const logoutBtn = document.getElementById('logoutBtn');
  function warn(msg){ const el = document.getElementById('authWarn'); if (el){ el.textContent = msg; el.classList.remove('hidden'); } }
  function gateNav(session){
    const authLinks = document.querySelectorAll('[data-auth="auth-only"]');
    const adminLinks = document.querySelectorAll('[data-role="admin"]');
    authLinks.forEach(a => a.style.display = session ? "" : "none");
    if (session){
      window.supabase.from('profiles').select('role').eq('id', session.user.id).single().then(({data})=>{
        const isAdmin = data && data.role === 'admin';
        adminLinks.forEach(a => a.style.display = isAdmin ? "" : "none");
      }).catch(()=> adminLinks.forEach(a => a.style.display = "none"));
    } else adminLinks.forEach(a => a.style.display = "none");
  }
  function setNav(session){
    if (loginBtn && logoutBtn){
      if (session) { loginBtn.classList.add('hidden'); logoutBtn.classList.remove('hidden'); }
      else { loginBtn.classList.remove('hidden'); logoutBtn.classList.add('hidden'); }
    }
    gateNav(session);
  }
  if (loginBtn) loginBtn.addEventListener('click', async () => {
    if (!window.SUPABASE_URL || !window.SUPABASE_ANON){ warn('Supabase not configured'); return; }
    await supabase.auth.signInWithOAuth({ provider: 'google', options: { redirectTo: window.location.origin + '/dashboard/' } });
  });
  if (logoutBtn) logoutBtn.addEventListener('click', async () => { await supabase.auth.signOut(); window.location.href = '/'; });
  window.requireAuth = async (redirectTo='/') => {
    const { data: { session } } = await supabase.auth.getSession();
    if (!session) window.location.href = redirectTo; setNav(session); return session;
  };
  supabase.auth.onAuthStateChange((_event, session) => setNav(session));
})();
