# CQ
# AllInOne V3 Final ERD + PostgreSQL

This is the authoritative V3 package aligning:
- microservice database ownership
- Mermaid ERD
- PostgreSQL migrations

## Key decisions
- No `WALLET_ACCOUNTS`.
- One `wallets` row represents one Global or Arena wallet.
- Cross-service UUIDs are references only; they are not PostgreSQL FKs.
- Same-service relationships are real PostgreSQL foreign keys.
- Payment accounts belong to payment providers.
- Gold Coin conversion is traceable through `gold_coin_transactions.reward_conversion_id`.

## Service databases
identity_db
user_db
wallet_db
ledger_db
deposit_db
withdrawal_db
payment_db
referral_db
product_db
sportsbook_db
trading_db
igaming_db
risk_db
reporting_db
audit_db
notification_db
file_db
reconciliation_db

## Migration rule
Run only the migration for a service in that service's database. Do not run all files in one database.

## Important
The source requirements do not specify exact reward rates, qualifying thresholds, KYC field sets,
payment provider names, sportsbook odds providers, trading venues, or retention periods. These remain
configuration/business decisions and are not hard-coded here.
