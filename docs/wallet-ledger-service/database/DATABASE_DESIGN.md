 # Database design — Wallet Ledger Service (technical)

 This document is a minimal technical layout for JPA mapping. It lists entities and their columns only (name, Java type, suggested SQL type, PK/FK, nullability, default). No narrative guidance included.

 ## wallet_account

 | Column | Java type (JPA) | SQL type | PK/FK | Null | Default |
 |---|---:|---|---:|---:|---:|
 | wallet_account_id | UUID | uuid | PK | NOT NULL | - |
 | user_id | UUID | uuid | FK -> user.id (optional) | NOT NULL | - |
 | balance | BigDecimal | numeric(20,8) |  | NOT NULL | 0 |
 | currency | String | varchar(8) |  | NOT NULL | - |
 | status | String / Enum | varchar(16) |  | NOT NULL | 'active' |
 | created_at | OffsetDateTime | timestamptz |  | NOT NULL | now() |
 | updated_at | OffsetDateTime | timestamptz |  | NOT NULL | now() |
 | deleted_at | OffsetDateTime | timestamptz |  | NULL | NULL |
 | is_deleted | Boolean | boolean |  | NOT NULL | false |

 ## ledger_transaction

 | Column | Java type (JPA) | SQL type | PK/FK | Null | Default |
 |---|---:|---|---:|---:|---:|
 | ledger_transaction_id | UUID | uuid | PK | NOT NULL | - |
 | wallet_account_id | UUID | uuid | FK -> wallet_account.wallet_account_id | NOT NULL | - |
 | type | String / Enum | varchar(32) |  | NOT NULL | - |
 | amount | BigDecimal | numeric(20,8) |  | NOT NULL | - |
 | currency | String | varchar(8) |  | NOT NULL | - |
 | status | String / Enum | varchar(16) |  | NOT NULL | 'pending' |
 | reference_id | String | varchar(128) |  | NULL | NULL |
 | metadata | Map / JSON | jsonb |  | NULL | NULL |
 | created_at | OffsetDateTime | timestamptz |  | NOT NULL | now() |
 | updated_at | OffsetDateTime | timestamptz |  | NOT NULL | now() |
 | deleted_at | OffsetDateTime | timestamptz |  | NULL | NULL |
 | is_deleted | Boolean | boolean |  | NOT NULL | false |

 ## transaction_journal

 | Column | Java type (JPA) | SQL type | PK/FK | Null | Default |
 |---|---:|---|---:|---:|---:|
 | transaction_journal_id | UUID | uuid | PK | NOT NULL | - |
 | ledger_transaction_id | UUID | uuid | FK -> ledger_transaction.ledger_transaction_id | NOT NULL | - |
 | action | String / Enum | varchar(32) |  | NOT NULL | - |
 | performed_by | String | varchar(64) |  | NULL | NULL |
 | timestamp | OffsetDateTime | timestamptz |  | NOT NULL | now() |
 | metadata | Map / JSON | jsonb |  | NULL | NULL |

 ## wallet_event_log

 | Column | Java type (JPA) | SQL type | PK/FK | Null | Default |
 |---|---:|---|---:|---:|---:|
 | wallet_event_log_id | UUID | uuid | PK | NOT NULL | - |
 | wallet_account_id | UUID | uuid | FK -> wallet_account.wallet_account_id | NOT NULL | - |
 | event_type | String | varchar(64) |  | NOT NULL | - |
 | description | String | text |  | NULL | NULL |
 | created_at | OffsetDateTime | timestamptz |  | NOT NULL | now() |

 ---

 Notes:
 - This file is intentionally minimal. Indexes and partitioning will be added later via migrations when data grows. No CREATE TABLE scripts are included.
