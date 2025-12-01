-- ======================================================================
-- 🚀 FAST DATA GENERATOR (REAL TABLES) for wallet-ledger-service
-- ----------------------------------------------------------------------
-- ⚠️ WARNING:
--   - Dev/Test only. Không dùng cho production.
--   - Script này cố gắng tối ưu tốc độ ở mức session (tắt bớt safety).
--   - Data được insert TRỰC TIẾP vào các bảng:
--       wallet_account, ledger_transaction, transaction_journal, wallet_event_log
-- ======================================================================

\echo '==== 🧠 START FAST DATA GENERATION ON REAL TABLES (DEV ONLY) ===='

BEGIN;

-- ⚙️ Tắt bớt ràng buộc / trigger trong session này
--  - session_replication_role = replica: bỏ qua FK, trigger user-defined
--  - synchronous_commit = OFF: không chờ WAL flush (có thể mất data nếu crash)
SET session_replication_role = replica;
SET LOCAL synchronous_commit = OFF;

-- Optional: tăng memory cho bulk operation (tùy DB)
SET LOCAL temp_buffers = '256MB';
SET LOCAL maintenance_work_mem = '1GB';

-- ----------------------------------------------------------------------
-- ⚙️ Step 1. Ensure pgcrypto extension (for gen_random_uuid)
-- ----------------------------------------------------------------------
\echo '==== ✅ Ensuring pgcrypto extension ===='

CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- ----------------------------------------------------------------------
-- ⚙️ Step 2. Seed wallet_account nếu đang ít/không có data
-- ----------------------------------------------------------------------
\echo '==== 💰 Ensuring at least 10k wallet_account records ===='

DO $$
DECLARE
    existing_count bigint;
    target_count   bigint := 10000;
BEGIN
    SELECT COUNT(*) INTO existing_count FROM wallet_account;

    IF existing_count < target_count THEN
        INSERT INTO wallet_account (
            wallet_account_id,
            user_id,
            balance,
            currency,
            status,
            created_at,
            updated_at,
            deleted_at,
            is_deleted
        )
        SELECT
            gen_random_uuid()                      AS wallet_account_id,
            gen_random_uuid()                      AS user_id,
            0                                      AS balance,
            'VND'                                  AS currency,
            'active'                               AS status,
            now()                                  AS created_at,
            now()                                  AS updated_at,
            NULL                                   AS deleted_at,
            FALSE                                  AS is_deleted
        FROM generate_series(existing_count + 1, target_count);

        RAISE NOTICE 'Seeded wallet_account from % to % records', existing_count, target_count;
    ELSE
        RAISE NOTICE 'wallet_account already has % records, skip seeding', existing_count;
    END IF;
END $$;

-- ----------------------------------------------------------------------
-- ⚙️ Step 3. (Optional) Xoá data cũ trong 3 bảng transaction để sạch
-- ----------------------------------------------------------------------
-- \echo '==== 🧹 Truncating ledger_transaction, transaction_journal, wallet_event_log ===='
--
-- TRUNCATE TABLE
--     ledger_transaction,
--     transaction_journal,
--     wallet_event_log;

-- ----------------------------------------------------------------------
-- ⚙️ Step 4. Function generate_ledger_data trên CÁC BẢNG THẬT
-- ----------------------------------------------------------------------
\echo '==== ⚙️ Creating function generate_ledger_data() on REAL tables ===='

CREATE OR REPLACE FUNCTION generate_ledger_data(
    p_start_date    date,
    p_end_date      date,
    p_daily_count   integer   -- số ledger_transaction muốn generate mỗi ngày (xấp xỉ)
) RETURNS void
LANGUAGE plpgsql
AS $$
DECLARE
    d date;
BEGIN
    d := p_start_date;

    WHILE d <= p_end_date LOOP
        -- 1) Insert bulk ledger_transaction cho ngày d
        WITH inserted_ledger AS (
            INSERT INTO ledger_transaction (
                ledger_transaction_id,
                wallet_account_id,
                type,
                amount,
                currency,
                status,
                reference_id,
                metadata,
                created_at,
                updated_at,
                deleted_at,
                is_deleted
            )
            SELECT
                gen_random_uuid() AS ledger_transaction_id,
                wa.wallet_account_id,
                CASE WHEN random() < 0.5 THEN 'DEBIT' ELSE 'CREDIT' END AS type,
                ROUND((random() * 1000000)::numeric, 2) AS amount,
                'VND' AS currency,
                'completed' AS status,
                NULL AS reference_id,
                NULL AS metadata,
                (d::timestamptz + (random() * interval '1 day')) AS created_at,
                (d::timestamptz + (random() * interval '1 day')) AS updated_at,
                NULL AS deleted_at,
                FALSE AS is_deleted
            FROM (
                -- Mỗi ngày random 500 ví khác nhau
                SELECT wallet_account_id
                FROM wallet_account
                ORDER BY random()
                LIMIT 500
            ) wa
            -- Chia đều p_daily_count trên 500 ví
            CROSS JOIN generate_series(1, GREATEST(1, p_daily_count / 500))
            RETURNING
                ledger_transaction_id,
                wallet_account_id,
                created_at
        )

        -- 2) Insert tương ứng vào transaction_journal
        , inserted_journal AS (
            INSERT INTO transaction_journal (
                transaction_journal_id,
                ledger_transaction_id,
                action,
                performed_by,
                "timestamp",
                metadata
            )
            SELECT
                gen_random_uuid() AS transaction_journal_id,
                il.ledger_transaction_id,
                'CREATED'         AS action,
                'system'          AS performed_by,
                il.created_at     AS "timestamp",
                NULL              AS metadata
            FROM inserted_ledger il
            RETURNING 1
        )

        -- 3) Insert tương ứng vào wallet_event_log
        INSERT INTO wallet_event_log (
            wallet_event_log_id,
            wallet_account_id,
            event_type,
            description,
            created_at
        )
        SELECT
            gen_random_uuid()                AS wallet_event_log_id,
            il.wallet_account_id,
            'LEDGER_TRANSACTION_CREATED'     AS event_type,
            NULL                             AS description,
            il.created_at                    AS created_at
        FROM inserted_ledger il;

        RAISE NOTICE '✅ Generated data for %, approx % ledger rows', d, p_daily_count;

        d := d + 1;
    END LOOP;
END;
$$;

-- ----------------------------------------------------------------------
-- ⚙️ Step 5. Gọi hàm để generate dữ liệu
-- ----------------------------------------------------------------------
\echo '==== 🗓️ Generating data 2020-01-01 → 2020-01-31, 10k/day ===='

-- 🔧 Bạn chỉnh lại khoảng thời gian & p_daily_count tuỳ ý:
SELECT generate_ledger_data(
    '2024-01-01'::date,
    '2024-12-31'::date,
    30000          -- số ledger_transaction/ngày (xấp xỉ)
);

-- Ví dụ thêm (comment sẵn):
-- SELECT generate_ledger_data('2020-01-01', '2020-12-31', 10000);

-- SELECT generate_ledger_data('2020-01-01', '2020-12-31', 50000);

-- ----------------------------------------------------------------------
-- ⚙️ Step 6. Re-enable constraint / trigger mode cho session
-- ----------------------------------------------------------------------
\echo '==== 🔒 Re-enabling session_replication_role DEFAULT ===='

SET session_replication_role = DEFAULT;

COMMIT;

\echo '==== ✅ DONE: FAST data generation on REAL TABLES completed ===='

SELECT COUNT(1) FROM ledger_transaction;

SELECT pg_size_pretty(pg_database_size('wallet_ledger')) AS db_size;

SELECT
  relname AS table_name,
  pg_size_pretty(pg_relation_size(relid))      AS table_data,
  pg_size_pretty(pg_indexes_size(relid))       AS indexes,
  pg_size_pretty(pg_total_relation_size(relid)) AS total
FROM pg_catalog.pg_statio_user_tables
ORDER BY pg_total_relation_size(relid) DESC;
