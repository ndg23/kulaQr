-- Inscription sans attente : un nouveau compte est actif tout de suite (plus de blocage avant activation par un admin).
-- Le trigger qui crée la ligne users à chaque nouvelle inscription la créait inactive ; il la crée désormais active.
-- Les comptes suspendus à la main par un admin restent suspendus : seul le comportement par défaut change.
-- Relançable sans risque. À exécuter dans l'éditeur SQL de Supabase.
BEGIN;

ALTER TABLE public.users ALTER COLUMN is_active SET DEFAULT TRUE;

CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO public.users (id, email, full_name, phone, role, subscription_tier, is_active, subscription_starts_at, subscription_ends_at)
    VALUES (
        NEW.id,
        NEW.email,
        COALESCE(
            NEW.raw_user_meta_data->>'full_name',
            NEW.raw_user_meta_data->>'name',
            SPLIT_PART(NEW.email, '@', 1),
            'Utilisateur'
        ),
        NEW.raw_user_meta_data->>'phone',
        'owner',
        'demo',
        TRUE,
        NOW(),
        NOW() + INTERVAL '7 days'
    )
    ON CONFLICT (id) DO UPDATE SET
        email = EXCLUDED.email,
        full_name = EXCLUDED.full_name,
        updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;

COMMIT;

-- Comptes déjà inscrits et restés en attente : à regarder avant d'activer.
-- (Ne lance pas la mise à jour à l'aveugle : un compte inactif peut aussi avoir été suspendu volontairement.)
-- SELECT id, email, full_name, created_at FROM public.users WHERE is_active = FALSE AND role = 'owner' ORDER BY created_at DESC;
--
-- Pour activer ceux de la liste que tu veux (propriétaire puis son établissement) :
-- UPDATE public.users SET is_active = TRUE WHERE id IN ('<id>', '<id>');
-- UPDATE public.establishments SET is_active = TRUE WHERE user_id IN ('<id>', '<id>');
