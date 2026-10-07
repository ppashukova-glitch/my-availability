-- Run this entire file in Supabase Dashboard -> SQL Editor.

create table if not exists public.availability (
  date date primary key,
  status text not null default 'off'
    check (status in ('available','limited','unavailable','off','overtime','compensatory')),
  hours numeric(5,2) not null default 0,
  note text not null default '',
  updated_at timestamptz not null default now()
);

alter table public.availability enable row level security;

-- Colleagues can read the calendar.
drop policy if exists "calendar is publicly readable" on public.availability;
create policy "calendar is publicly readable"
on public.availability
for select
to anon, authenticated
using (true);

-- Prototype editing policy:
-- Anyone who knows the public app URL can technically write.
-- For a real deployment, replace this with authenticated-owner policies.
drop policy if exists "calendar can be edited in prototype" on public.availability;
create policy "calendar can be edited in prototype"
on public.availability
for insert
to anon, authenticated
with check (true);

drop policy if exists "calendar can be updated in prototype" on public.availability;
create policy "calendar can be updated in prototype"
on public.availability
for update
to anon, authenticated
using (true)
with check (true);

-- Realtime: add the table to the publication.
alter publication supabase_realtime add table public.availability;

-- Optional: seed a few example days. Delete these lines if you don't want them.
insert into public.availability (date, status, hours, note)
values
  (current_date, 'available', 0, ''),
  (current_date + 1, 'limited', 0, 'Только если совсем срочно'),
  (current_date + 2, 'unavailable', 0, ''),
  (current_date + 3, 'overtime', 3, '+3 часа'),
  (current_date + 4, 'compensatory', 0, 'Отгул за сверхурочные')
on conflict (date) do nothing;
