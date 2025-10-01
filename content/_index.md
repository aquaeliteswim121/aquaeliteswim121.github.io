
---
title: "Welcome"
---

<section class="hero">
  <h1>Aqua Elite Swim Club</h1>
  <p class="lead">Dashboards for swimmers • Admin tools for coaches • Clean and simple.</p>
  <div class="cta-row">
    <button id="googleLogin" class="btn">Sign in with Google</button>
    <a class="btn secondary" href="/blog/">Read the Blog</a>
  </div>
  <div id="authWarn" class="banner hidden">Supabase not configured. Set <code>[params.supabase]</code> in <code>config.toml</code>.</div>
</section>

<section class="grid features">
  <div class="feature"><h3>Attendance Heatmap</h3><p class="muted">GitHub-style presence for last 180 days.</p></div>
  <div class="feature"><h3>Workouts</h3><p class="muted">Coach-logged sessions with meters, main set, RPE.</p></div>
  <div class="feature"><h3>Skill Levels</h3><p class="muted">Beginner/Intermediate/Advanced × S3 → S1.</p></div>
  <div class="feature"><h3>Payments (Tracker)</h3><p class="muted">Paid/Pending/Overdue — admin only to edit.</p></div>
  <div class="feature"><h3>Video Library</h3><p class="muted">YouTube embeds filtered by training group.</p></div>
  <div class="feature"><h3>Admin</h3><p class="muted">Roster, attendance, workouts, payments, seeding.</p></div>
</section>

<script>
  document.getElementById('googleLogin').addEventListener('click', async () => {
    if (!window.supabase || !window.SUPABASE_URL || !window.SUPABASE_ANON){
      document.getElementById('authWarn').classList.remove('hidden');
      return;
    }
    await supabase.auth.signInWithOAuth({
      provider: 'google', options: { redirectTo: window.location.origin + '/dashboard/' }
    });
  });
</script>
