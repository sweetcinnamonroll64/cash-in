-- ============================================================
-- Cash-in App — Supabase Schema
-- ============================================================

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- ============================================================
-- Table: table_user_id
-- ============================================================
CREATE TABLE IF NOT EXISTS table_user_id (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id     TEXT UNIQUE NOT NULL,
  password    TEXT NOT NULL,
  email       TEXT,
  created_at  TIMESTAMPTZ DEFAULT NOW()
);

-- Default admin user
INSERT INTO table_user_id (user_id, password, email)
VALUES ('admin', 'admin', 'admin@cashin.app')
ON CONFLICT (user_id) DO NOTHING;

-- ============================================================
-- Table: table_keuangan
-- ============================================================
CREATE TABLE IF NOT EXISTS table_keuangan (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id     TEXT NOT NULL REFERENCES table_user_id(user_id) ON DELETE CASCADE,
  tipe        TEXT NOT NULL CHECK (tipe IN ('pemasukan', 'pengeluaran')),
  keterangan  TEXT NOT NULL,
  nominal     BIGINT NOT NULL CHECK (nominal > 0),
  tanggal     DATE NOT NULL,
  created_at  TIMESTAMPTZ DEFAULT NOW()
);

-- Index untuk performa filter tanggal
CREATE INDEX IF NOT EXISTS idx_keuangan_tanggal ON table_keuangan(tanggal);
CREATE INDEX IF NOT EXISTS idx_keuangan_user_id ON table_keuangan(user_id);
CREATE INDEX IF NOT EXISTS idx_keuangan_tipe    ON table_keuangan(tipe);

-- ============================================================
-- Row Level Security (RLS)
-- ============================================================
-- Disable RLS untuk MVP (bisa diaktifkan nanti)
ALTER TABLE table_user_id    DISABLE ROW LEVEL SECURITY;
ALTER TABLE table_keuangan   DISABLE ROW LEVEL SECURITY;
