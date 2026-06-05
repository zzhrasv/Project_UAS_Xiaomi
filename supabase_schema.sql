-- =============================================================================
-- SQL SCHEMA FOR PROJECT UAS XIAOMI
-- Copy and paste this script into the Supabase Dashboard SQL Editor
-- =============================================================================

-- Enable UUID extension if not enabled
create extension if not exists "uuid-ossp";

-- 1. CATEGORIES TABLE
create table public.categories (
    id uuid primary key default gen_random_uuid(),
    name text not null unique,
    slug text not null unique,
    image_url text,
    created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- Enable RLS for categories
alter table public.categories enable row level security;

-- 2. PRODUCTS TABLE
create table public.products (
    id uuid primary key default gen_random_uuid(),
    category_id uuid references public.categories(id) on delete set null,
    name text not null,
    description text,
    base_price numeric(12, 2) not null check (base_price >= 0),
    image_urls text[] not null default '{}',
    is_featured boolean not null default false,
    created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- Enable RLS for products
alter table public.products enable row level security;

-- 3. PRODUCT VARIANTS TABLE
create table public.product_variants (
    id uuid primary key default gen_random_uuid(),
    product_id uuid references public.products(id) on delete cascade not null,
    ram text,
    storage text,
    price numeric(12, 2) not null check (price >= 0),
    stock integer not null default 0 check (stock >= 0),
    created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- Enable RLS for product_variants
alter table public.product_variants enable row level security;

-- 4. PROFILES TABLE (linked to Supabase Auth)
create table public.profiles (
    id uuid primary key references auth.users(id) on delete cascade,
    full_name text not null,
    phone_number text,
    mi_points integer not null default 0 check (mi_points >= 0),
    created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- Enable RLS for profiles
alter table public.profiles enable row level security;

-- 5. ORDERS TABLE
create table public.orders (
    id uuid primary key default gen_random_uuid(),
    user_id uuid references public.profiles(id) on delete cascade not null,
    status text not null default 'pending' check (status in ('pending', 'paid', 'processing', 'shipped', 'completed', 'cancelled')),
    total_price numeric(12, 2) not null check (total_price >= 0),
    shipping_address text not null,
    mi_points_used integer not null default 0 check (mi_points_used >= 0),
    created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- Enable RLS for orders
alter table public.orders enable row level security;

-- 6. ORDER ITEMS TABLE
create table public.order_items (
    id uuid primary key default gen_random_uuid(),
    order_id uuid references public.orders(id) on delete cascade not null,
    product_id uuid references public.products(id) on delete set null not null,
    variant_id uuid references public.product_variants(id) on delete set null,
    product_name text not null,
    variant_label text,
    price numeric(12, 2) not null check (price >= 0),
    quantity integer not null check (quantity > 0),
    created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- Enable RLS for order_items
alter table public.order_items enable row level security;

-- 7. SERVICE CENTERS TABLE
create table public.service_centers (
    id uuid primary key default gen_random_uuid(),
    name text not null,
    address text not null,
    city text not null,
    phone_number text,
    latitude double precision,
    longitude double precision,
    operating_hours text,
    created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- Enable RLS for service_centers
alter table public.service_centers enable row level security;


-- =============================================================================
-- AUTOMATION: TRIGGER FOR NEW SIGNUPS (Create profile automatically)
-- =============================================================================

-- Create trigger function
create or replace function public.handle_new_user()
returns trigger as $$
begin
  insert into public.profiles (id, full_name, phone_number, mi_points)
  values (
    new.id,
    coalesce(new.raw_user_meta_data->>'full_name', 'Xiaomi User'),
    new.raw_user_meta_data->>'phone_number',
    0
  );
  return new;
end;
$$ language plpgsql security definer;

-- Create the trigger
create or replace trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_user();


-- =============================================================================
-- SECURITY: ROW LEVEL SECURITY (RLS) POLICIES
-- =============================================================================

-- Categories Policies
create policy "Allow public read access to categories" on public.categories 
    for select using (true);

-- Products Policies
create policy "Allow public read access to products" on public.products 
    for select using (true);

-- Product Variants Policies
create policy "Allow public read access to product_variants" on public.product_variants 
    for select using (true);

-- Service Centers Policies
create policy "Allow public read access to service_centers" on public.service_centers 
    for select using (true);

-- Profiles Policies
create policy "Allow users to read their own profile" on public.profiles 
    for select using (auth.uid() = id);

create policy "Allow users to update their own profile" on public.profiles 
    for update using (auth.uid() = id);

-- Orders Policies
create policy "Allow users to read their own orders" on public.orders 
    for select using (auth.uid() = user_id);

create policy "Allow users to create their own orders" on public.orders 
    for insert with check (auth.uid() = user_id);

create policy "Allow users to delete their own orders" on public.orders 
    for delete using (auth.uid() = user_id);

-- Order Items Policies
create policy "Allow users to read their own order items" on public.order_items 
    for select using (
        exists (
            select 1 from public.orders
            where orders.id = order_items.order_id and orders.user_id = auth.uid()
        )
    );

create policy "Allow users to create their own order items" on public.order_items 
    for insert with check (
        exists (
            select 1 from public.orders
            where orders.id = order_items.order_id and orders.user_id = auth.uid()
        )
    );

create policy "Allow users to delete their own order items" on public.order_items 
    for delete using (
        exists (
            select 1 from public.orders
            where orders.id = order_items.order_id and orders.user_id = auth.uid()
        )
    );
