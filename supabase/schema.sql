
create extension if not exists "uuid-ossp";
create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  email text unique, full_name text, display_name text, dob date, parent_contact text,
  squad_level text check (squad_level in ('Beginner','Intermediate','Advanced')) default 'Beginner',
  sublevel text check (sublevel in ('S1','S2','S3')) default 'S3',
  group_no int check (group_no between 0 and 4) default 4,
  join_date date default now(), status text check (status in ('active','on_hold')) default 'active',
  medical_notes text, consent_photo boolean default false, consent_video boolean default false,
  role text check (role in ('admin','coach','swimmer')) default 'swimmer', inserted_at timestamptz default now()
);
create index if not exists idx_profiles_email on public.profiles(email);
alter table public.profiles enable row level security;
create or replace function public.handle_new_user() returns trigger as $$
begin
  insert into public.profiles (id,email,full_name,display_name)
  values (new.id,new.email,coalesce(new.raw_user_meta_data->>'full_name', split_part(new.email,'@',1)),
          coalesce(new.raw_user_meta_data->>'full_name', split_part(new.email,'@',1)))
  on conflict (id) do nothing; return new;
end; $$ language plpgsql security definer;
create or replace trigger on_auth_user_created after insert on auth.users for each row execute function public.handle_new_user();
create policy "profiles select" on public.profiles for select using (auth.uid() = id or exists(select 1 from public.profiles p where p.id = auth.uid() and p.role in ('admin','coach')));
create policy "profiles self update" on public.profiles for update using (auth.uid() = id) with check (auth.uid() = id);
create policy "profiles admin upsert" on public.profiles for insert with check (exists(select 1 from public.profiles p where p.id = auth.uid() and p.role = 'admin'));
create policy "profiles admin update" on public.profiles for update using (exists(select 1 from public.profiles p where p.id = auth.uid() and p.role = 'admin'));
create table if not exists public.attendance ( id bigserial primary key, user_id uuid not null references public.profiles(id) on delete cascade, date date not null, present boolean not null, created_by uuid references public.profiles(id), note text, inserted_at timestamptz default now(), unique(user_id,date) );
alter table public.attendance enable row level security;
create policy "attendance read" on public.attendance for select using (user_id = auth.uid() or exists(select 1 from public.profiles p where p.id = auth.uid() and p.role in ('admin','coach')));
create policy "attendance insert" on public.attendance for insert with check (exists(select 1 from public.profiles p where p.id = auth.uid() and p.role in ('admin','coach')));
create policy "attendance update" on public.attendance for update using (exists(select 1 from public.profiles p where p.id = auth.uid() and p.role in ('admin','coach')));
create table if not exists public.workouts ( id bigserial primary key, user_id uuid not null references public.profiles(id) on delete cascade, date date not null, session_name text, group_no int, total_meters int, main_set text, notes text, rpe int check (rpe between 1 and 10), created_by uuid references public.profiles(id), inserted_at timestamptz default now() );
alter table public.workouts enable row level security;
create index if not exists workouts_user_date_idx on public.workouts(user_id,date);
create policy "workouts read" on public.workouts for select using (user_id = auth.uid() or exists(select 1 from public.profiles p where p.id = auth.uid() and p.role in ('admin','coach')));
create policy "workouts insert" on public.workouts for insert with check (exists(select 1 from public.profiles p where p.id = auth.uid() and p.role in ('admin','coach')));
create policy "workouts update" on public.workouts for update using (exists(select 1 from public.profiles p where p.id = auth.uid() and p.role in ('admin','coach')));
create table if not exists public.payments ( id bigserial primary key, user_id uuid not null references public.profiles(id) on delete cascade, period date not null, amount numeric(10,2), status text check (status in ('paid','pending','overdue')) default 'pending', due_date date, paid_on date, notes text, unique(user_id,period) );
alter table public.payments enable row level security;
create policy "payments read" on public.payments for select using (user_id = auth.uid() or exists(select 1 from public.profiles p where p.id = auth.uid() and p.role in ('admin','coach')));
create policy "payments upsert" on public.payments for insert with check (exists(select 1 from public.profiles p where p.id = auth.uid() and p.role = 'admin'));
create policy "payments update" on public.payments for update using (exists(select 1 from public.profiles p where p.id = auth.uid() and p.role = 'admin'));
create table if not exists public.videos ( id bigserial primary key, youtube_id text not null unique, title text, description text, group_min int default 4, group_max int default 0, level text, sublevel text, inserted_at timestamptz default now() );
alter table public.videos enable row level security;
create policy "videos read" on public.videos for select using (auth.role() = 'authenticated');
create policy "videos insert" on public.videos for insert with check (exists(select 1 from public.profiles p where p.id = auth.uid() and p.role = 'admin'));
