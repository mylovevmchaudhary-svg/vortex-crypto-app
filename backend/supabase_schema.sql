-- Vortex Coin (VTX) Production Backend Schema (Supabase / PostgreSQL)
-- Prevents client-side balance tampering and verifies AdMob SSV callbacks.

create extension if not exists "pgcrypto";

create table if not exists public.users (
  id uuid primary key default gen_random_uuid(),
  auth_uid uuid unique,
  display_name text not null default 'Pioneer',
  email text,
  referral_code text unique not null,
  referred_by_user_id uuid references public.users(id),
  bsc_wallet_address text unique check (bsc_wallet_address ~ '^0x[a-fA-F0-9]{40}$'),
  wallet_provider text,
  balance_vtx numeric(20, 4) not null default 0 check (balance_vtx >= 0),
  ad_earned_vtx numeric(20, 4) not null default 0,
  mining_earned_vtx numeric(20, 4) not null default 0,
  referral_earned_vtx numeric(20, 4) not null default 0,
  offer_earned_vtx numeric(20, 4) not null default 0,
  total_ads_watched integer not null default 0,
  streak_day integer not null default 0,
  last_streak_claim_at timestamptz,
  mining_active_until timestamptz,
  last_mining_sync_at timestamptz,
  boost_2x_until timestamptz,
  airdrop_registered boolean not null default false,
  is_banned boolean not null default false,
  created_at timestamptz not null default now()
);

-- AdMob Server-Side Verification (SSV) idempotent log
-- Google AdMob hits your Edge Function with transaction_id + ECDSA signature.
create table if not exists public.ad_reward_logs (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.users(id) on delete cascade,
  ssv_transaction_id text unique not null,
  placement text not null check (placement in ('watchAndEarn', 'miningBoost2x', 'mysteryCrate')),
  reward_vtx numeric(20, 4) not null check (reward_vtx > 0 and reward_vtx <= 200),
  boost_hours integer not null default 0,
  created_at timestamptz not null default now()
);

create table if not exists public.offer_completions (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.users(id) on delete cascade,
  offer_id text not null,
  reward_vtx numeric(20, 4) not null,
  completed_at timestamptz not null default now(),
  unique (user_id, offer_id)
);

create table if not exists public.ledger_transactions (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.users(id) on delete cascade,
  tx_type text not null,
  title text not null,
  subtitle text not null,
  amount_vtx numeric(20, 4) not null,
  created_at timestamptz not null default now()
);

-- 1B Airdrop Snapshot table exported to Merkle Tree generator before BSC claim launch
create table if not exists public.airdrop_snapshots (
  id uuid primary key default gen_random_uuid(),
  user_id uuid unique not null references public.users(id),
  bsc_wallet_address text not null,
  base_balance_vtx numeric(20, 4) not null,
  multiplier numeric(6, 2) not null,
  final_airdrop_wei numeric(38, 0) not null,
  merkle_proof jsonb,
  created_at timestamptz not null default now()
);

alter table public.users enable row level security;
alter table public.ad_reward_logs enable row level security;
alter table public.offer_completions enable row level security;
alter table public.ledger_transactions enable row level security;

create policy "Users read own profile"
  on public.users for select
  using (auth.uid() = auth_uid);

create policy "Users read own ledger"
  on public.ledger_transactions for select
  using (
    user_id in (select id from public.users where auth_uid = auth.uid())
  );

-- Atomic RPC called by your verified AdMob SSV Webhook (service_role only)
create or replace function public.fn_credit_verified_ad_reward(
  p_user_id uuid,
  p_ssv_transaction_id text,
  p_placement text,
  p_reward_vtx numeric,
  p_boost_hours integer default 0
)
returns numeric
language plpgsql
security definer
as $$
declare
  v_today_count integer;
  v_new_balance numeric;
begin
  select count(*) into v_today_count
  from public.ad_reward_logs
  where user_id = p_user_id
    and created_at >= date_trunc('day', now());

  if v_today_count >= 15 then
    raise exception 'Daily ad cap reached';
  end if;

  insert into public.ad_reward_logs (
    user_id, ssv_transaction_id, placement, reward_vtx, boost_hours
  ) values (
    p_user_id, p_ssv_transaction_id, p_placement, p_reward_vtx, p_boost_hours
  );

  update public.users
  set
    balance_vtx = balance_vtx + p_reward_vtx,
    ad_earned_vtx = ad_earned_vtx + p_reward_vtx,
    total_ads_watched = total_ads_watched + 1,
    boost_2x_until = case
      when p_boost_hours > 0 then
        greatest(coalesce(boost_2x_until, now()), now()) + make_interval(hours => p_boost_hours)
      else boost_2x_until
    end
  where id = p_user_id and is_banned = false
  returning balance_vtx into v_new_balance;

  insert into public.ledger_transactions (user_id, tx_type, title, subtitle, amount_vtx)
  values (
    p_user_id,
    'adReward',
    'Verified Rewarded Ad',
    'SSV TX: ' || p_ssv_transaction_id,
    p_reward_vtx
  );

  return v_new_balance;
end;
$$;
