-- ============================================
-- FlexPack Project Manager — Supabase Setup SQL
-- Paste this into Supabase SQL Editor and RUN
-- ============================================

-- 1. USERS TABLE
CREATE TABLE IF NOT EXISTS public.users (
  id BIGSERIAL PRIMARY KEY,
  username TEXT UNIQUE NOT NULL,
  password TEXT NOT NULL,
  role TEXT NOT NULL DEFAULT 'employee' CHECK (role IN ('admin', 'employee')),
  status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'approved')),
  created_at TIMESTAMPTZ DEFAULT now()
);

-- 2. PROJECTS TABLE
CREATE TABLE IF NOT EXISTS public.projects (
  id BIGSERIAL PRIMARY KEY,
  name TEXT NOT NULL,
  description TEXT DEFAULT '',
  status TEXT NOT NULL DEFAULT 'active' CHECK (status IN ('active', 'completed', 'on_hold')),
  created_by TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- 3. TASKS TABLE
CREATE TABLE IF NOT EXISTS public.tasks (
  id BIGSERIAL PRIMARY KEY,
  project_id BIGINT REFERENCES public.projects(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  description TEXT DEFAULT '',
  start_date DATE,
  due_date DATE,
  is_complete BOOLEAN DEFAULT false,
  assigned_to TEXT DEFAULT '',
  created_at TIMESTAMPTZ DEFAULT now()
);

-- 4. DAILY REPORTS TABLE
CREATE TABLE IF NOT EXISTS public.daily_reports (
  id BIGSERIAL PRIMARY KEY,
  username TEXT NOT NULL,
  project_id BIGINT REFERENCES public.projects(id) ON DELETE SET NULL,
  company TEXT DEFAULT '',
  guests INTEGER DEFAULT 0,
  report_date DATE NOT NULL DEFAULT CURRENT_DATE,
  content TEXT DEFAULT '',
  attachment_url TEXT DEFAULT '',
  attachment_name TEXT DEFAULT '',
  created_at TIMESTAMPTZ DEFAULT now()
);

-- 5. PHOTOS TABLE (metadata)
CREATE TABLE IF NOT EXISTS public.photos (
  id BIGSERIAL PRIMARY KEY,
  url TEXT NOT NULL,
  filename TEXT DEFAULT '',
  project_id BIGINT REFERENCES public.projects(id) ON DELETE SET NULL,
  uploaded_by TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- 6. SEED ADMIN USER (default login: admin / 8888)
INSERT INTO public.users (username, password, role, status)
VALUES ('admin', '8888', 'admin', 'approved')
ON CONFLICT (username) DO NOTHING;

-- 7. ENABLE ROW LEVEL SECURITY
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.projects ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.tasks ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.daily_reports ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.photos ENABLE ROW LEVEL SECURITY;

-- 8. RLS POLICIES — Allow all authenticated operations via service_role (simplified)
CREATE POLICY "Allow all for users" ON public.users USING (true) WITH CHECK (true);
CREATE POLICY "Allow all for projects" ON public.projects USING (true) WITH CHECK (true);
CREATE POLICY "Allow all for tasks" ON public.tasks USING (true) WITH CHECK (true);
CREATE POLICY "Allow all for daily_reports" ON public.daily_reports USING (true) WITH CHECK (true);
CREATE POLICY "Allow all for photos" ON public.photos USING (true) WITH CHECK (true);

-- 9. CREATE STORAGE BUCKET for photos
INSERT INTO storage.buckets (id, name, public)
VALUES ('flexpack-photos', 'flexpack-photos', true)
ON CONFLICT (id) DO NOTHING;

-- Allow public access to storage bucket
CREATE POLICY "Public Access" ON storage.objects FOR ALL USING (bucket_id = 'flexpack-photos') WITH CHECK (bucket_id = 'flexpack-photos');

-- ============================================
-- VERIFICATION
-- ============================================
SELECT table_name FROM information_schema.tables 
WHERE table_schema = 'public' AND table_type = 'BASE TABLE'
ORDER BY table_name;

SELECT '✅ Setup complete! Admin login: admin / 8888' AS status;
