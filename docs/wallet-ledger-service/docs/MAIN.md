# Main logic and API — Wallet Ledger Service (technical)

## 1. Business logic

### 1.1. Create wallet for user
    - When user register or active wallet.
    - Init balance = 0, status = active.

### 1.2. Add money to wallet
    - From bank gateway or merchant-service
    - Log transaction deposit, update balance

### 1.3. Withdraw money from wallet
    - To bank account
    - Transaction withdraw, check balance and status of wallet.

### 1.4. Transfer money from wallet to others wallet.
    - From wallet A to wallet B
    - Transaction transfer, log transaction both A and B.

### 1.5. Payment order
    - Transaction payment, linked merchant or payment service
    - Check balance, status, and promotion if have.

### 1.6. Refund
    - Transaction refund, update balance.

### 1.7. Lock/Unlock wallet
    - When have abnormal case or request from user

### 1.8. History transaction
    - Query according to time, type, status

### 1.9. Audit/Journal
    - Write step by step handle transaction to service checking, rollback

### 1.10. Cal current balance
    - May be using cache or get from ledger

## 2. API

### Wallet Accout API
| Name | Method | Endpoint | Description |
| ---- | ---- | ---- | ---- |
| WL_A001 | POST | /wallets/create | Create a new wallet |
| WL_A002 | GET | /wallets/{walletId} | Get info wallet |
| WL_A003 | PATCH | /wallets/{walletId}/freeze | Lock/Freeze wallet |
| WL_A004 | PATCH | /wallets/{walletId}/unfreeze | Unlock wallet |

### Transaction API
| Name | Method | Endpoint | Description |
| ---- | ---- | ---- | ---- |
| WL_A101 | POST | /transactions/deposit | Add Money |
| WL_A102 | POST | /transactions/withdraw | Withdraw money |
| WL_A103 | POST | /transactions/transfer | Transfer money |
| WL_A104 | POST | /transactions/payment | Payment |
| WL_A105 | POST | /transactions/refund | Refund |
| WL_A106 | GET | /transactions/{transactionId} | Get detail transaction |
| WL_A107 | GET | /wallets/{walletId}/transaction | Get history transaction of wallet |

### Balance API
| Name | Method | Endpoint | Description |
| ---- | ---- | ---- | ---- |
| WL_A201 | GET | /wallets/{walletId}/balance | Get current balance of wallet |

### Journal / Audit API
| Name | Method | Endpoint | Description |
| ---- | ---- | ---- | ---- |
| WL_A301 | GET | /transactions/{transactionId}/journal | Get history transaction |
