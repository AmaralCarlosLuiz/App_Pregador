-- ==============================================================================
-- PREGADOR PRO - SCHEMA DE BANCO DE DADOS (SUPABASE / POSTGRESQL)
-- Arquitetura Multiplataforma para Pastores e Ministros
-- Versão 100% Idempotente (Execução Segura)
-- ==============================================================================

-- 1. EXTENSÕES
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- 2. TABELA: PROFILES (Extensão de auth.users)
CREATE TABLE IF NOT EXISTS public.profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    full_name TEXT NOT NULL DEFAULT 'Ministro do Evangelho',
    avatar_url TEXT,
    ministry_title TEXT DEFAULT 'Pastor',
    church_name TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

-- Limpa policies existentes para permitir re-execução sem erro
DROP POLICY IF EXISTS "Perfis visíveis para o próprio usuário" ON public.profiles;
CREATE POLICY "Perfis visíveis para o próprio usuário"
    ON public.profiles FOR SELECT
    USING (auth.uid() = id);

DROP POLICY IF EXISTS "Usuário pode atualizar seu próprio perfil" ON public.profiles;
CREATE POLICY "Usuário pode atualizar seu próprio perfil"
    ON public.profiles FOR UPDATE
    USING (auth.uid() = id);

DROP POLICY IF EXISTS "Usuário pode inserir seu próprio perfil" ON public.profiles;
CREATE POLICY "Usuário pode inserir seu próprio perfil"
    ON public.profiles FOR INSERT
    WITH CHECK (auth.uid() = id);

-- Trigger para criar perfil automaticamente no SignUp
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO public.profiles (id, full_name, avatar_url)
    VALUES (
        new.id,
        COALESCE(new.raw_user_meta_data->>'full_name', 'Pastor Titular'),
        new.raw_user_meta_data->>'avatar_url'
    )
    ON CONFLICT (id) DO NOTHING;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- 3. TABELA: SERMONS (Sermões e Esboços Homiléticos)
CREATE TABLE IF NOT EXISTS public.sermons (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    biblical_reference TEXT NOT NULL,
    category TEXT NOT NULL DEFAULT 'Geral',
    sermon_type TEXT NOT NULL DEFAULT 'Expositivo' CHECK (sermon_type IN ('Expositivo', 'Temático', 'Textual', 'Evangelístico', 'Devocional')),
    content JSONB NOT NULL DEFAULT '{}'::jsonb,
    is_favorite BOOLEAN NOT NULL DEFAULT false,
    status TEXT NOT NULL DEFAULT 'draft' CHECK (status IN ('draft', 'ready', 'archived')),
    preach_count INTEGER NOT NULL DEFAULT 0,
    last_preached_at TIMESTAMPTZ,
    estimated_duration_minutes INTEGER DEFAULT 40,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

CREATE INDEX IF NOT EXISTS idx_sermons_user_id ON public.sermons(user_id);
CREATE INDEX IF NOT EXISTS idx_sermons_category ON public.sermons(category);
CREATE INDEX IF NOT EXISTS idx_sermons_status ON public.sermons(status);
CREATE INDEX IF NOT EXISTS idx_sermons_updated_at ON public.sermons(updated_at DESC);

ALTER TABLE public.sermons ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Usuários podem ver apenas seus próprios sermões" ON public.sermons;
CREATE POLICY "Usuários podem ver apenas seus próprios sermões"
    ON public.sermons FOR SELECT
    USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Usuários podem criar seus próprios sermões" ON public.sermons;
CREATE POLICY "Usuários podem criar seus próprios sermões"
    ON public.sermons FOR INSERT
    WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "Usuários podem atualizar seus próprios sermões" ON public.sermons;
CREATE POLICY "Usuários podem atualizar seus próprios sermões"
    ON public.sermons FOR UPDATE
    USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Usuários podem excluir seus próprios sermões" ON public.sermons;
CREATE POLICY "Usuários podem excluir seus próprios sermões"
    ON public.sermons FOR DELETE
    USING (auth.uid() = user_id);

-- 4. TABELA: SERMON_TEMPLATES (Modelos Homiléticos Públicos e Curados)
CREATE TABLE IF NOT EXISTS public.sermon_templates (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title TEXT NOT NULL,
    theme TEXT NOT NULL,
    key_verse TEXT NOT NULL,
    sermon_type TEXT NOT NULL DEFAULT 'Expositivo',
    content JSONB NOT NULL DEFAULT '{}'::jsonb,
    tags TEXT[] DEFAULT ARRAY[]::TEXT[],
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

ALTER TABLE public.sermon_templates ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Modelos de sermão são públicos para leitura" ON public.sermon_templates;
CREATE POLICY "Modelos de sermão são públicos para leitura"
    ON public.sermon_templates FOR SELECT
    USING (true);

-- 5. SEED DATA: MODELOS HOMILÉTICOS INICIAIS (Inserção segura condicional)
INSERT INTO public.sermon_templates (title, theme, key_verse, sermon_type, tags, content)
SELECT v.title, v.theme, v.key_verse, v.sermon_type, v.tags, v.content
FROM (
  VALUES
  (
    'A Paz que Excede Todo Entendimento',
    'Vencendo a Ansiedade pela Oração e Gratidão',
    'Filipenses 4:6-7',
    'Expositivo',
    ARRAY['Ansiedade', 'Paz', 'Oração', 'Fé'],
    '{
        "introduction": "Em um mundo tomado por incertezas e sobrecarga emocional, o apóstolo Paulo nos presenteia com um antídoto divino para a ansiedade.",
        "blocks": [
            {
                "title": "1. O Mandamento: Não Andeis Ansiosos",
                "biblicalReference": "Filipenses 4:6a",
                "explanation": "Paulo não minimiza as dores, mas proíbe que a ansiedade governe o coração do crente. A palavra grega merimnao sugere estar dividido em duas direções.",
                "application": "Identifique hoje as preocupações que tentam sequestrar a sua atenção do Senhor e entregue-as no altar.",
                "illustration": "Assim como uma corda puxada para lados opostos se rompe, a alma dividida pelo medo perde sua força."
            },
            {
                "title": "2. O Método: Oração, Súplica e Ações de Graças",
                "biblicalReference": "Filipenses 4:6b",
                "explanation": "A oração com ações de graças nos lembra das fidelidades passadas de Deus antes de pedir por livramentos futuros.",
                "application": "Pratique a gratidão ativa mesmo quando as circunstâncias exteriores parecerem adversas.",
                "illustration": "O pássaro canta mesmo antes do amanhecer porque sabe com certeza que o sol virá."
            },
            {
                "title": "3. O Milagre: A Guarda da Paz de Deus",
                "biblicalReference": "Filipenses 4:7",
                "explanation": "A paz de Deus atua como uma sentinela militar romana (phroureo) guardando a fortaleza dos nossos sentimentos e pensamentos em Cristo Jesus.",
                "application": "Permita que a presença do Espírito Santo guarde a sua mente dos pensamentos de derrota.",
                "illustration": "Enquanto a tempestade ruge do lado de fora do submarino, no fundo das águas reina uma calmaria inabalável."
            }
        ],
        "conclusion": "A paz não é a ausência de tempestades, mas a presença inegociável de Cristo no barco.",
        "appeal": "Convide aqueles que estão com o fardo pesado a trocarem sua ansiedade pelo fardo leve de Cristo."
    }'::jsonb
  ),
  (
    'O Bom Samaritano: A Prática do Amor Radical',
    'Quem é o meu Próximo?',
    'Lucas 10:25-37',
    'Expositivo',
    ARRAY['Amor', 'Misericórdia', 'Igreja Relevante', 'Discipulado'],
    '{
        "introduction": "Jesus é questionado por um doutor da lei e transforma uma discussão teórica em uma convocação inadiável à compaixão prática.",
        "blocks": [
            {
                "title": "1. A Cegueira da Religiosidade Indiferente",
                "biblicalReference": "Lucas 10:31-32",
                "explanation": "Tanto o sacerdote quanto o levita viram a vítima caída, mas passaram de largo. O culto sem amor ao próximo torna-se estéril.",
                "application": "Nossa comunhão com Deus no altar deve se refletir no cuidado com o ferido na calçada.",
                "illustration": "Um médico que sabe toda a anatomia, mas se recusa a estancar o sangue do enfermo que sangra em sua porta."
            },
            {
                "title": "2. O Cuidado que Custa Preço e Tempo",
                "biblicalReference": "Lucas 10:33-35",
                "explanation": "O samaritano moveu-se de íntima compaixão (splagchnizomai), cuidou das feridas com óleo e vinho e pagou as diárias na estalagem.",
                "application": "O amor cristão autêntico demanda recursos, empatia e disposição para alterar nossa própria agenda.",
                "illustration": "As mãos que ajudam são mais sagradas do que os lábios que apenas rezam sem se importar."
            }
        ],
        "conclusion": "Jesus encerra com o imperativo definitivo: Vai e faze tu o mesmo.",
        "appeal": "Desafie a igreja a ser as mãos estendidas de Jesus em sua comunidade e família nesta semana."
    }'::jsonb
  ),
  (
    'Edificando sobre a Rocha',
    'Fundamentos Inabaláveis para a Família',
    'Mateus 7:24-27',
    'Temático',
    ARRAY['Família', 'Fundamento', 'Palavra de Deus', 'Obediência'],
    '{
        "introduction": "A mesma tempestade que atingiu a casa edificada na areia também atingiu a casa edificada na rocha. A diferença nunca foi o vento, mas a fundação.",
        "blocks": [
            {
                "title": "1. Ouvir e Praticar: A Rocha da Obediência",
                "biblicalReference": "Mateus 7:24",
                "explanation": "Não basta frequentar o templo e ouvir sermões; a rocha é a aplicação fiel dos princípios do Reino no cotidiano do lar.",
                "application": "Estabeleça o culto doméstico e o perdão mútuo diário como colunas inegociáveis de sua casa.",
                "illustration": "O iceberg revela apenas 10% de sua estrutura; 90% de sua firmeza está oculta sob a água, assim como a vida secreta de oração de um lar."
            },
            {
                "title": "2. As Tempestades São Inevitáveis",
                "biblicalReference": "Mateus 7:25",
                "explanation": "Chuvas, rios e ventos simbolizam crises financeiras, perdas e conflitos. Nenhuma família é imune à tempestade.",
                "application": "Não se desespere quando os ventos soprarem, porque quem sustenta sua casa é o Senhor Jesus.",
                "illustration": "As raízes profundas da sequoia entrelaçam-se com as outras árvores, permitindo que resistam aos furacões mais intensos."
            }
        ],
        "conclusion": "Casas bonitas na areia desmoronam no primeiro temporal. Casas na rocha permanecem para sempre.",
        "appeal": "Oração de consagração das famílias e casais ao Senhorio de Cristo."
    }'::jsonb
  )
) AS v(title, theme, key_verse, sermon_type, tags, content)
WHERE NOT EXISTS (
    SELECT 1 FROM public.sermon_templates t WHERE t.title = v.title
);
