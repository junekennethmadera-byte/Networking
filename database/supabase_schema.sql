-- Liquidation Flow / Supabase setup
-- Run this once in Supabase Dashboard > SQL Editor.

create extension if not exists pgcrypto;

create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  full_name text not null,
  role text not null default 'requester' check (role in ('requester', 'finsec', 'treasurer')),
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create unique index if not exists one_finsec_profile on public.profiles(role) where role = 'finsec';
create unique index if not exists one_treasurer_profile on public.profiles(role) where role = 'treasurer';

create table if not exists public.cash_advance_requests (
  id uuid primary key default gen_random_uuid(),
  reference_no text not null unique,
  requester_id uuid not null references auth.users(id) on delete restrict,
  requester_name text not null,
  requester_email text not null,
  position text,
  account_title text not null,
  account_title_other text,
  particulars jsonb not null default '[]'::jsonb,
  particulars_other text,
  amount numeric(14,2) not null check (amount > 0),
  needed_by date,
  notes text,
  status text not null default 'pending_finsec_approval' check (status in (
    'pending_finsec_approval','approved_for_disbursement','unliquidated_cash_advance',
    'overdue_liquidation','for_liquidation_approval','liquidated',
    'for_voucher_recorded','rejected'
  )),
  finsec_approved_at timestamptz,
  approved_by_finsec uuid references auth.users(id),
  disbursed_at timestamptz,
  liquidation_deadline date,
  liquidated_at timestamptz,
  submitted_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.liquidations (
  id uuid primary key default gen_random_uuid(),
  cash_advance_id uuid not null references public.cash_advance_requests(id) on delete cascade,
  submitted_by uuid not null references auth.users(id) on delete restrict,
  total_liquidated_amount numeric(14,2) not null check (total_liquidated_amount >= 0),
  remarks text,
  status text not null default 'pending' check (status in ('pending','approved','rejected')),
  approved_by_finsec uuid references auth.users(id),
  approved_at timestamptz,
  submitted_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.liquidation_files (
  id uuid primary key default gen_random_uuid(),
  liquidation_id uuid not null references public.liquidations(id) on delete cascade,
  file_name text not null,
  storage_path text not null unique,
  file_type text,
  uploaded_by uuid not null references auth.users(id) on delete restrict,
  uploaded_at timestamptz not null default now()
);

create table if not exists public.audit_logs (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references auth.users(id) on delete set null,
  action text not null,
  entity_type text,
  entity_id uuid,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now()
);

create or replace function public.set_updated_at()
returns trigger language plpgsql as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

drop trigger if exists profiles_updated_at on public.profiles;
create trigger profiles_updated_at before update on public.profiles
for each row execute function public.set_updated_at();
drop trigger if exists cash_advance_requests_updated_at on public.cash_advance_requests;
create trigger cash_advance_requests_updated_at before update on public.cash_advance_requests
for each row execute function public.set_updated_at();
drop trigger if exists liquidations_updated_at on public.liquidations;
create trigger liquidations_updated_at before update on public.liquidations
for each row execute function public.set_updated_at();

create or replace function public.create_profile_for_user()
returns trigger language plpgsql security definer set search_path = public as $$
begin
  insert into public.profiles (id, full_name, role)
  values (new.id, coalesce(new.raw_user_meta_data->>'full_name', split_part(new.email, '@', 1)), 'requester')
  on conflict (id) do nothing;
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created after insert on auth.users
for each row execute function public.create_profile_for_user();

insert into public.profiles (id, full_name, role)
select id, coalesce(raw_user_meta_data->>'full_name', split_part(email, '@', 1)), 'requester'
from auth.users
on conflict (id) do nothing;

create or replace function public.assign_cash_advance_reference()
returns trigger language plpgsql as $$
begin
  if new.reference_no is null or btrim(new.reference_no) = '' then
    new.reference_no := 'CA-' || to_char(now(), 'YYMMDD') || '-' || upper(substr(replace(gen_random_uuid()::text, '-', ''), 1, 6));
  end if;
  return new;
end;
$$;

drop trigger if exists cash_advance_reference on public.cash_advance_requests;
create trigger cash_advance_reference before insert on public.cash_advance_requests
for each row execute function public.assign_cash_advance_reference();

insert into storage.buckets (id, name, public)
values ('cash-advance-documents', 'cash-advance-documents', false)
on conflict (id) do nothing;

alter table public.profiles enable row level security;
alter table public.cash_advance_requests enable row level security;
alter table public.liquidations enable row level security;
alter table public.liquidation_files enable row level security;
alter table public.audit_logs enable row level security;

create or replace function public.is_staff()
returns boolean language sql stable security definer set search_path = public as $$
  select exists (
    select 1 from public.profiles
    where id = auth.uid() and role in ('finsec', 'treasurer') and is_active
  );
$$;

create or replace function public.is_finsec()
returns boolean language sql stable security definer set search_path = public as $$
  select exists (
    select 1 from public.profiles
    where id = auth.uid() and role = 'finsec' and is_active
  );
$$;

drop policy if exists profiles_self_read on public.profiles;
create policy profiles_self_read on public.profiles for select to authenticated using (id = auth.uid());
drop policy if exists profiles_staff_read on public.profiles;
create policy profiles_staff_read on public.profiles for select to authenticated
using (public.is_staff());

drop policy if exists requests_read on public.cash_advance_requests;
create policy requests_read on public.cash_advance_requests for select to authenticated
using (requester_id = auth.uid() or public.is_staff());
drop policy if exists requests_requester_insert on public.cash_advance_requests;
create policy requests_requester_insert on public.cash_advance_requests for insert to authenticated
with check (requester_id = auth.uid());
drop policy if exists requests_staff_update on public.cash_advance_requests;
create policy requests_staff_update on public.cash_advance_requests for update to authenticated
using (public.is_staff())
with check (true);

drop policy if exists liquidations_read on public.liquidations;
create policy liquidations_read on public.liquidations for select to authenticated
using (submitted_by = auth.uid() or public.is_staff());
drop policy if exists liquidations_requester_insert on public.liquidations;
create policy liquidations_requester_insert on public.liquidations for insert to authenticated
with check (submitted_by = auth.uid());
drop policy if exists liquidations_finsec_update on public.liquidations;
create policy liquidations_finsec_update on public.liquidations for update to authenticated
using (public.is_finsec())
with check (true);

drop policy if exists liquidation_files_read on public.liquidation_files;
create policy liquidation_files_read on public.liquidation_files for select to authenticated using (true);
drop policy if exists liquidation_files_insert on public.liquidation_files;
create policy liquidation_files_insert on public.liquidation_files for insert to authenticated with check (uploaded_by = auth.uid());

drop policy if exists audit_logs_insert on public.audit_logs;
create policy audit_logs_insert on public.audit_logs for insert to authenticated with check (user_id = auth.uid());
drop policy if exists audit_logs_read on public.audit_logs;
create policy audit_logs_read on public.audit_logs for select to authenticated using (true);

drop policy if exists storage_documents_insert on storage.objects;
create policy storage_documents_insert on storage.objects for insert to authenticated
with check (bucket_id = 'cash-advance-documents' and (storage.foldername(name))[1] = auth.uid()::text);
drop policy if exists storage_documents_read on storage.objects;
create policy storage_documents_read on storage.objects for select to authenticated
using (bucket_id = 'cash-advance-documents');
