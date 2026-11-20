-- ==============================================================================
-- PREGADOR PRO - LIBERAÇÃO DE GRAVAÇÃO DIRETA EM NUVEM (SUPABASE)
-- Execute este script no SQL Editor:
-- https://supabase.com/dashboard/project/yahvhltbfpebaievpumg/sql/new
-- ==============================================================================

-- 1. Remove a trava de Foreign Key com auth.users para permitir gravação imediata
--    do perfil master (Pr. Carlos Luiz Amaral) em qualquer aparelho sem exigir login manual
ALTER TABLE public.profiles DROP CONSTRAINT IF EXISTS profiles_id_fkey;
ALTER TABLE public.sermons DROP CONSTRAINT IF EXISTS sermons_user_id_fkey;

-- 2. Adiciona coluna opcional de configurações (tema claro/escuro, voz, etc.) no perfil
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS settings JSONB DEFAULT '{}'::jsonb;

-- 3. Atualiza as políticas RLS para permitir leitura e gravação direta pelo app
DROP POLICY IF EXISTS "Perfis visíveis para o próprio usuário" ON public.profiles;
DROP POLICY IF EXISTS "Usuário pode atualizar seu próprio perfil" ON public.profiles;
DROP POLICY IF EXISTS "Usuário pode inserir seu próprio perfil" ON public.profiles;
DROP POLICY IF EXISTS "Acesso completo ao perfil do app" ON public.profiles;

CREATE POLICY "Acesso completo ao perfil do app"
    ON public.profiles FOR ALL
    TO anon, authenticated
    USING (true)
    WITH CHECK (true);

DROP POLICY IF EXISTS "Usuários podem ver apenas seus próprios sermões" ON public.sermons;
DROP POLICY IF EXISTS "Usuários podem criar seus próprios sermões" ON public.sermons;
DROP POLICY IF EXISTS "Usuários podem atualizar seus próprios sermões" ON public.sermons;
DROP POLICY IF EXISTS "Usuários podem excluir seus próprios sermões" ON public.sermons;
DROP POLICY IF EXISTS "Acesso completo aos sermões do app" ON public.sermons;

CREATE POLICY "Acesso completo aos sermões do app"
    ON public.sermons FOR ALL
    TO anon, authenticated
    USING (true)
    WITH CHECK (true);

-- 4. Garante o registro inicial do Perfil Master do Pastor Carlos Luiz Amaral
INSERT INTO public.profiles (id, full_name, ministry_title, church_name)
VALUES (
    '00000000-0000-4000-8000-000000000001',
    'Pr. Carlos Luiz Amaral',
    'Pastor Titular',
    'Igreja Batista'
)
ON CONFLICT (id) DO NOTHING;
