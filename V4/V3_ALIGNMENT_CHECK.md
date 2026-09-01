# V3 ERD ↔ PostgreSQL Alignment Check

Generated from the authoritative V3 files.

## Table inventory
- PostgreSQL tables: 52
- ERD entities: 52
- SQL tables missing from ERD: NONE
- ERD entities missing from SQL: NONE

## Ownership rule
Cross-service UUID references are intentionally not PostgreSQL foreign keys.
`FK` in the Mermaid file is reserved for relationships enforced inside the same service-owned database.

## Deliberate V3 corrections
1. Removed `WALLET_ACCOUNTS`. One row in `wallets` represents one Global or Arena wallet.
2. Added `payment_accounts.provider_id` and the `PAYMENT_PROVIDERS -> PAYMENT_ACCOUNTS` relationship.
3. Added `payment_setting_change_requests` to both ERD and PostgreSQL.
4. Added `USERS -> GOLD_COIN_ACCOUNTS`, `USERS -> RISK_CASES`, and `USERS -> TRADING_POSITIONS` logical relationships.
5. Added `reward_conversions` to `gold_coin_transactions` through `reward_conversion_id`, making coin consumption traceable.
6. Kept customer/admin/user references as UUIDs without cross-service FKs.
7. Added the missing audit, notification, file and reconciliation columns so the ERD represents the actual SQL tables.
8. Kept the Global + three Arena wallet model: GLOBAL, IGAMING, SPORTSBOOK, TRADING.
