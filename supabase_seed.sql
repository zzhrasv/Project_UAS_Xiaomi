-- =============================================================================
-- SEED DATA FOR PROJECT UAS XIAOMI
-- Copy and paste this script into the Supabase Dashboard SQL Editor
-- =============================================================================

-- 1. SEED CATEGORIES (c0000000-...)
INSERT INTO public.categories (id, name, slug, image_url) VALUES
('c0000000-0000-0000-0000-000000000001', 'Smartphones', 'smartphones', 'https://images.unsplash.com/photo-1511707171634-5f897ff02aa9?w=500&auto=format&fit=crop'),
('c0000000-0000-0000-0000-000000000002', 'Wearables', 'wearables', 'https://images.unsplash.com/photo-1575311373937-040b8e1fd5b6?w=500&auto=format&fit=crop'),
('c0000000-0000-0000-0000-000000000003', 'Smart Home', 'smart-home', 'https://images.unsplash.com/photo-1558002038-1055907df827?w=500&auto=format&fit=crop'),
('c0000000-0000-0000-0000-000000000004', 'Audio', 'audio', 'https://images.unsplash.com/photo-1590658268037-6bf12165a8df?w=500&auto=format&fit=crop')
ON CONFLICT (id) DO NOTHING;

-- 2. SEED PRODUCTS (d0000000-...)
INSERT INTO public.products (id, category_id, name, description, base_price, image_urls, is_featured) VALUES
-- Smartphones
('d0000000-0000-0000-0000-000000000001', 'c0000000-0000-0000-0000-000000000001', 'Xiaomi 14', 'Flagship Xiaomi 14 dengan optik Leica generasi terbaru, sensor gambar Light Fusion 900, dan prosesor kencang Snapdragon 8 Gen 3.', 11999000, ARRAY['https://images.unsplash.com/photo-1511707171634-5f897ff02aa9?w=800'], true),
('d0000000-0000-0000-0000-000000000002', 'c0000000-0000-0000-0000-000000000001', 'Redmi Note 13 Pro 5G', 'Redmi Note 13 Pro 5G dengan kamera ultra-jernih 200MP OIS, layar AMOLED 1.5K 120Hz, dan Snapdragon 7s Gen 2.', 4399000, ARRAY['https://images.unsplash.com/photo-1598327105666-5b89351aff97?w=800'], true),
('d0000000-0000-0000-0000-000000000007', 'c0000000-0000-0000-0000-000000000001', 'Redmi 13C', 'Redmi 13C dengan layar mulus 90Hz 6.74 inci, kamera AI 50MP triple, dan baterai besar 5000mAh dengan pengisian daya cepat 18W.', 1499000, ARRAY['https://images.unsplash.com/photo-1565630916779-e303be97b6f5?w=800'], false),

-- Wearables
('d0000000-0000-0000-0000-000000000003', 'c0000000-0000-0000-0000-000000000002', 'Xiaomi Smart Band 8', 'Xiaomi Smart Band 8 dengan layar AMOLED 1.62 inci, penyegaran 60Hz dinamis, masa pakai baterai hingga 16 hari, dan 150+ mode olahraga.', 549000, ARRAY['https://images.unsplash.com/photo-1575311373937-040b8e1fd5b6?w=800'], true),
('d0000000-0000-0000-0000-000000000004', 'c0000000-0000-0000-0000-000000000002', 'Xiaomi Watch 2', 'Xiaomi Watch 2 didukung oleh Google Wear OS, prosesor Snapdragon W5+ Gen 1, pelacakan kesehatan canggih, dan layar AMOLED 1.43 inci.', 2499000, ARRAY['https://images.unsplash.com/photo-1508685096489-7aacd43bd3b1?w=800'], false),

-- Audio
('d0000000-0000-0000-0000-000000000005', 'c0000000-0000-0000-0000-000000000004', 'Xiaomi Buds 5', 'Xiaomi Buds 5 semi-in-ear wireless earbuds dengan Audio Resolusi Tinggi, ANC pintar dinamis, dan ketahanan baterai hingga 39 jam.', 999000, ARRAY['https://images.unsplash.com/photo-1590658268037-6bf12165a8df?w=800'], true),
('d0000000-0000-0000-0000-000000000008', 'c0000000-0000-0000-0000-000000000004', 'Redmi Buds 5 Pro', 'Redmi Buds 5 Pro dengan Driver Ganda Koaksial, peredam bising ANC ultra-lebar 52dB, dan sertifikasi Hi-Res Audio Wireless.', 799000, ARRAY['https://images.unsplash.com/photo-1608156639585-b3a032ef9689?w=800'], false),

-- Smart Home
('d0000000-0000-0000-0000-000000000006', 'c0000000-0000-0000-0000-000000000003', 'Xiaomi Smart Air Purifier 4', 'Xiaomi Smart Air Purifier 4 dengan pembersihan udara ruangan besar 48m², CADR partikel hingga 400m³/jam, dan filter HEPA efisiensi tinggi.', 1899000, ARRAY['https://images.unsplash.com/photo-1558002038-1055907df827?w=800'], false)
ON CONFLICT (id) DO NOTHING;

-- 3. SEED PRODUCT VARIANTS (e0000000-...)
INSERT INTO public.product_variants (id, product_id, ram, storage, price, stock) VALUES
-- Xiaomi 14
('e0000000-0000-0000-0000-000000000001', 'd0000000-0000-0000-0000-000000000001', '12GB', '256GB', 11999000, 35),
('e0000000-0000-0000-0000-000000000002', 'd0000000-0000-0000-0000-000000000001', '12GB', '512GB', 12999000, 15),

-- Redmi Note 13 Pro 5G
('e0000000-0000-0000-0000-000000000003', 'd0000000-0000-0000-0000-000000000002', '8GB', '256GB', 4399000, 60),
('e0000000-0000-0000-0000-000000000009', 'd0000000-0000-0000-0000-000000000002', '12GB', '512GB', 4999000, 25),

-- Redmi 13C
('e0000000-0000-0000-0000-000000000010', 'd0000000-0000-0000-0000-000000000007', '6GB', '128GB', 1499000, 120),
('e0000000-0000-0000-0000-000000000011', 'd0000000-0000-0000-0000-000000000007', '8GB', '256GB', 1799000, 80),

-- Xiaomi Smart Band 8
('e0000000-0000-0000-0000-000000000004', 'd0000000-0000-0000-0000-000000000003', NULL, 'Standard Black', 549000, 200),
('e0000000-0000-0000-0000-000000000012', 'd0000000-0000-0000-0000-000000000003', NULL, 'Gold', 549000, 100),

-- Xiaomi Watch 2
('e0000000-0000-0000-0000-000000000005', 'd0000000-0000-0000-0000-000000000004', NULL, 'Silver', 2499000, 45),
('e0000000-0000-0000-0000-000000000013', 'd0000000-0000-0000-0000-000000000004', NULL, 'Black', 2499000, 30),

-- Xiaomi Buds 5
('e0000000-0000-0000-0000-000000000006', 'd0000000-0000-0000-0000-000000000005', NULL, 'White', 999000, 90),

-- Redmi Buds 5 Pro
('e0000000-0000-0000-0000-000000000014', 'd0000000-0000-0000-0000-000000000008', NULL, 'Midnight Black', 799000, 150),
('e0000000-0000-0000-0000-000000000015', 'd0000000-0000-0000-0000-000000000008', NULL, 'Aurora Purple', 799000, 50),

-- Xiaomi Smart Air Purifier 4
('e0000000-0000-0000-0000-000000000007', 'd0000000-0000-0000-0000-000000000006', NULL, 'Standard White', 1899000, 40)
ON CONFLICT (id) DO NOTHING;

-- 4. SEED SERVICE CENTERS (f0000000-...)
INSERT INTO public.service_centers (id, name, address, city, phone_number, latitude, longitude, operating_hours) VALUES
('f0000000-0000-0000-0000-000000000001', 'Xiaomi Exclusive Service Center Roxy', 'Ruko ITC Roxy Mas Blok D1 No. 5, Jl. KH Hasyim Ashari', 'Jakarta Pusat', '021-63857321', -6.1632, 106.8012, '10:00 - 18:00'),
('f0000000-0000-0000-0000-000000000002', 'Xiaomi Service Center Bandung', 'Jl. Gatot Subroto No. 45, Malabar, Lengkong', 'Bandung', '022-7301234', -6.9247, 107.6203, '09:00 - 17:00'),
('f0000000-0000-0000-0000-000000000003', 'Xiaomi Service Center Surabaya', 'Jl. Raya Gubeng No. 12', 'Surabaya', '031-5018888', -7.2721, 112.7489, '09:00 - 17:00')
ON CONFLICT (id) DO NOTHING;
