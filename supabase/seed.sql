
create or replace function public.seed_videos_defaults()
returns void language plpgsql security definer as $$
begin
  insert into public.videos (youtube_id, title, description, group_min, group_max, level) values
    ('UffZn_-lU54','Streamline & Kicks (Beginner)','Bodyline, push-offs, kick rhythm',3,4,'Beginner'),
    ('_n5O9mQ-PVc','Breathing Timing & Balance','Side-breath timing, balance drills',2,3,'Beginner/Intermediate'),
    ('7cL5tn6gsc4','Dolphin Kick Basics','Underwaters, core-driven kick',0,2,'Intermediate/Advanced')
  on conflict (youtube_id) do nothing;
end; $$;

create or replace function public.seed_sample_for(p_email text)
returns void language plpgsql security definer as $$
declare v_admin boolean; v_id uuid; d date := (current_date - interval '20 days')::date; i int := 0;
begin
  select exists(select 1 from public.profiles p where p.id = auth.uid() and p.role = 'admin') into v_admin;
  if not v_admin then raise exception 'Admin only'; end if;
  select id into v_id from public.profiles where email = p_email;
  if v_id is null then raise exception 'Profile not found for %', p_email; end if;

  i := 0; while i < 20 loop
    insert into public.attendance (user_id, date, present, created_by) values (v_id, d + i, (random() < 0.6), auth.uid())
    on conflict (user_id, date) do nothing; i := i + 1;
  end loop;

  insert into public.workouts (user_id, date, session_name, group_no, total_meters, main_set, notes, rpe, created_by) values
    (v_id, current_date - 12, 'Technique & Balance', 3, 800, '8x50 drill-swim', 'Catch-up & barrel rolls', 5, auth.uid()),
    (v_id, current_date - 9,  'Aerobic Free',        2, 1000,'5x200 @ easy',  'Breathing timing', 6, auth.uid()),
    (v_id, current_date - 6,  'Mixed IM Skills',     2, 900, '6x150 FR/BA/FR','Backstroke intro', 6, auth.uid()),
    (v_id, current_date - 3,  'Endurance Build',     1, 1200,'3x400 pull',     'Long bodyline', 7, auth.uid()),
    (v_id, current_date - 1,  'Sprint Skills',       1, 1100,'16x50 fast/easy','Fast finishes', 8, auth.uid())
  on conflict do nothing;

  insert into public.payments (user_id, period, amount, status, due_date, paid_on) values
    (v_id, date_trunc('month', current_date - interval '2 months')::date, 2500, 'paid', (current_date - interval '2 months')::date + 10, (current_date - interval '2 months')::date + 5),
    (v_id, date_trunc('month', current_date - interval '1 months')::date, 2500, 'paid', (current_date - interval '1 months')::date + 10, (current_date - interval '1 months')::date + 6),
    (v_id, date_trunc('month', current_date)::date,                      2500, 'pending', (date_trunc('month', current_date)::date + 10), null)
  on conflict (user_id, period) do nothing;
end; $$;
