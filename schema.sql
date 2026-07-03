-- ══════════════════════════════════════════════════════════════════════════
-- TURNI — estensione dello schema CrunchClub esistente
-- Friggitoria Fratelli Caruso, Palermo
-- Riusa la tabella "addetti" già esistente nel progetto Supabase CrunchClub
-- (wxhysgthyebydoupsjrh.supabase.co) invece di crearne una nuova.
-- ══════════════════════════════════════════════════════════════════════════

-- NOTA: questo file NON crea la tabella addetti (esiste già). La referenzia soltanto.
-- Struttura addetti esistente, per riferimento:
--   id bigint primary key generated always as identity
--   nome text not null
--   pin text not null
--   ruolo text default 'addetto'   -- 'admin' | 'addetto'
--   attivo boolean default true

-- ── MODIFICHE MANUALI AL PATTERN AUTOMATICO (ferie, malattie, eccezioni) ──
create table if not exists turni_override (
  id bigint generated always as identity primary key,
  data date not null,
  addetto_id bigint references addetti(id) not null,
  tipo_turno text not null,     -- 'mezza_giornata' | 'giornata_intera' | 'mattina' | 'pomeriggio' | 'riposo'
  motivo text,
  creato_il timestamptz default now(),
  creato_da bigint references addetti(id),
  unique (data, addetto_id)
);

-- ── RICHIESTE DI SCAMBIO TURNO ─────────────────────────────────────────────
create table if not exists richieste_scambio (
  id bigint generated always as identity primary key,
  data_turno date not null,
  richiedente_id bigint references addetti(id) not null,
  destinatario_id bigint references addetti(id) not null,
  stato text not null default 'pending',  -- 'pending' | 'approvato' | 'rifiutato'
  creato_il timestamptz default now(),
  gestito_da bigint references addetti(id),
  gestito_il timestamptz,
  note text
);

create index if not exists idx_override_data on turni_override(data);
create index if not exists idx_scambio_stato on richieste_scambio(stato);
create index if not exists idx_scambio_data on richieste_scambio(data_turno);

-- ══════════════════════════════════════════════════════════════════════════
-- ROW LEVEL SECURITY — stesso pattern aperto usato dalle altre tabelle CrunchClub
-- ══════════════════════════════════════════════════════════════════════════
alter table turni_override enable row level security;
alter table richieste_scambio enable row level security;

drop policy if exists "turni_override_all" on turni_override;
drop policy if exists "richieste_scambio_all" on richieste_scambio;

create policy "turni_override_all" on turni_override for all using (true) with check (true);
create policy "richieste_scambio_all" on richieste_scambio for all using (true) with check (true);

-- ══════════════════════════════════════════════════════════════════════════
-- IMPORTANTE: assicurati che i 5 dipendenti + te siano già presenti in "addetti"
-- Se non ci sono ancora, aggiungili dalla sezione "Addetti" dell'app CrunchClub
-- (Totò, Davide, Francesco, Mimmo, Vito, più il tuo utente admin).
-- L'app turni userà gli STESSI record e PIN già configurati lì.
-- ══════════════════════════════════════════════════════════════════════════
