# 💸 ATPay – Digital Wallet & Payment Service

## 📌 1. Mục tiêu sản phẩm
Xây dựng hệ thống **ví điện tử ATPay**, cho phép:
- Nạp tiền, rút tiền, chuyển tiền P2P, thanh toán QR.
- Thanh toán hóa đơn (điện, nước, điện thoại – mock).
- Quản trị, đối soát, thông báo và KYC cơ bản.

Hệ thống hướng tới:
- **An toàn – Nhanh – Dễ dùng**  
- **Kiến trúc microservice**, phục vụ **scalability & observability**

---

## 🧱 2. Phạm vi MVP (Phase 1)
### ✅ Bao gồm
1. Đăng ký / Đăng nhập (OTP SMS hoặc Email)
2. Quản lý người dùng & hồ sơ KYC (upload CCCD)
3. Liên kết ngân hàng (mock)
4. Nạp tiền / Rút tiền / Chuyển tiền P2P
5. Thanh toán QR (static & dynamic)
6. Thanh toán hóa đơn mock (data pack, top-up phone)
7. Quản lý ví: số dư, lịch sử giao dịch, biên lai
8. Thông báo (push/email) theo sự kiện giao dịch
9. Quản trị: duyệt KYC, tra soát, khóa ví, cấu hình hạn mức/fee
10. Cấu hình khuyến mãi cơ bản (voucher / hoàn tiền)

### 🚫 Không bao gồm (Phase sau)
- Thẻ vật lý/ảo
- Loyalty nâng cao
- Trả góp / tín dụng
- Đầu tư hoặc bảo hiểm

---

## 👥 3. Nhân vật sử dụng
| Vai trò | Mô tả |
|----------|--------|
| **End-user** | Dùng ví để nạp, rút, chuyển tiền, thanh toán QR |
| **Merchant** | Tạo QR, nhận thanh toán, đối soát giao dịch |
| **Ops/CS** | Duyệt KYC, xử lý khiếu nại, hoàn tiền, khóa tài khoản |
| **Finance** | Xem sổ cái, xuất báo cáo đối soát, file settlement |

---

## ⚙️ 4. Yêu cầu chức năng chi tiết

### 4.1. Tài khoản & KYC
- Đăng ký bằng **số điện thoại → OTP → tạo PIN thanh toán (6 số)**  
- Hồ sơ người dùng: họ tên, DOB, email, địa chỉ, trạng thái KYC  
- Upload CCCD + selfie, xét duyệt thủ công hoặc tự động (mock)  
- Trạng thái: `UNVERIFIED → PENDING → VERIFIED / REJECTED`

---

### 4.2. Liên kết ngân hàng (mock)
- Thêm tài khoản ngân hàng (STK, bank code)  
- Xác thực **micro-deposit** (mock) hoặc OTP  
- Cho phép hủy liên kết, lưu nhật ký thay đổi

---

### 4.3. Nạp – Rút – Chuyển
| Loại | Mô tả |
|-------|--------|
| **Top-up** | Tạo lệnh nạp → chờ `BANK_CONFIRMED` (mock webhook) → ghi sổ ledger |
| **Cash-out** | Trừ số dư → gửi yêu cầu rút → `BANK_SETTLED` → hoàn tất hoặc hoàn tiền |
| **P2P Transfer** | Chuyển tiền theo số ĐT hoặc QR, xác thực PIN, idempotent key |

- Tra cứu lịch sử theo loại giao dịch / thời gian / trạng thái

---

### 4.4. Thanh toán QR & Merchant
- Merchant có `merchantId`, tạo:
  - **QR tĩnh**: `merchantId + optional amount`
  - **QR động**: `merchantId + orderId + amount`
- User quét QR → xác thực PIN → thanh toán
- Merchant dashboard: danh sách đơn, tổng doanh thu
- Đối soát: file settlement (CSV) hoặc API truy vấn

---

### 4.5. Thanh toán hóa đơn (mock)
- Danh mục dịch vụ (điện thoại, data pack)
- Tạo order → call provider (mock) → `CAPTURED` hoặc `REFUNDED`

---

### 4.6. Hạn mức & Phí
| Trạng thái KYC | Giới hạn |
|----------------|-----------|
| **Unverified** | Số dư ≤ 5,000,000₫; giao dịch/ngày ≤ 2,000,000₫ |
| **Verified** | Số dư ≤ 100,000,000₫; giao dịch/ngày ≤ 50,000,000₫ |

| Loại phí | Mức |
|-----------|------|
| Top-up | 0₫ |
| Cash-out | 0.5% (min 5,000₫) |
| P2P | 0₫ |
| Merchant MDR | 0.8–1.2% |

---

### 4.7. An toàn & Chống gian lận
- Xác thực **PIN** cho mọi giao dịch tài chính  
- **Rate limit** theo IP/device  
- **Velocity rule**: chặn nhiều giao dịch nhỏ liên tiếp  
- Danh sách đen thiết bị / tài khoản đáng ngờ  
- **Audit log** đầy đủ (ai – làm gì – khi nào)

---

### 4.8. Khiếu nại & Hoàn tiền
- Người dùng hoặc merchant tạo **ticket** kèm bằng chứng  
- Ops có thể reverse / refund giao dịch (bút toán ngược ledger)

---

## 🧠 5. Yêu cầu phi chức năng
| Tiêu chí | Mô tả |
|-----------|--------|
| **Bảo mật** | JWT + refresh token; mã hóa dữ liệu; ký HMAC cho webhook |
| **Đúng đắn tài chính** | Double-entry ledger; mọi thay đổi số dư qua bút toán |
| **Khả dụng** | 99.9% uptime (MVP), RTO ≤ 30’, RPO ≤ 5’ |
| **Hiệu năng** | P99 latency ≤ 800ms; 200 RPS ổn định |
| **Observability** | Log có correlationId; metrics/traces (OpenTelemetry + Grafana) |
| **Tuân thủ** | Lưu lịch sử ≥ 5 năm; mask PII khi export |

---

## 💾 6. Domain & Sổ cái
**Ledger**  
| Trường | Ý nghĩa |
|---------|----------|
| `entryId` | ID bút toán |
| `txId` | Mã giao dịch |
| `accountId` | Tài khoản tham chiếu |
| `direction` | DEBIT / CREDIT |
| `amount` | Giá trị |
| `currency` | Loại tiền |
| `status` | INIT / CAPTURED / SETTLED / REFUNDED |
| `narration` | Diễn giải |

**Accounts mẫu:**
- `USER_WALLET:<userId>`
- `MERCHANT_SETTLEMENT:<merchantId>`
- `FEE_REVENUE`
- `PROMO_POOL`
- `BANK_CLEARING`

**Bất biến:**  
> Tổng DEBIT = Tổng CREDIT cho mỗi `txId`.

---

## 🧩 7. Kiến trúc Microservice (đề xuất)

| Service | Chức năng chính |
|----------|----------------|
| `auth-service` | OTP, JWT, PIN verify |
| `user-kyc-service` | Hồ sơ & trạng thái KYC |
| `wallet-ledger-service` | Account, ledger, balance, limit |
| `payment-service` | P2P, QR pay, bill pay (saga/outbox) |
| `merchant-service` | Merchant, QR, đối soát, MDR |
| `bank-gateway-service` | Mock bank, webhook confirm |
| `promotion-service` | Voucher, cashback rules |
| `notification-service` | Email, SMS, push |
| `reporting-service` | Báo cáo, settlement, export CSV |

**Giao tiếp:**
- REST/gRPC (sync) với header `Idempotency-Key`
- Kafka topics (async):  
  - `wallet.tx.created`  
  - `payment.captured`  
  - `bank.transfer.confirmed`  
  - `kyc.status.changed`

---

## 🔑 8. API chính (rút gọn)
| API | Mô tả |
|------|-------|
| `POST /auth/register` | Gửi OTP |
| `POST /auth/verify-otp` | Xác thực OTP, tạo token |
| `POST /user/kyc` | Upload CCCD, selfie |
| `GET /wallet/balance` | Lấy số dư |
| `POST /wallet/topup` | Nạp tiền |
| `POST /wallet/cashout` | Rút tiền |
| `POST /payments/p2p` | Chuyển tiền P2P |
| `POST /payments/qr/pay` | Thanh toán QR |
| `POST /merchant/qr` | Tạo QR code |
| `GET /transactions` | Lịch sử giao dịch |
| `POST /disputes` | Khiếu nại |

---

## ⚖️ 9. Quy tắc nghiệp vụ
- Mọi giao dịch yêu cầu **PIN** (3 lần sai → khóa 15 phút)  
- Kiểm tra **hạn mức** trước `AUTHORIZATION`  
- **Idempotency** trong 24h cho cùng `idempotencyKey`  
- **Refund** chỉ cho giao dịch `CAPTURED` trong T ngày  
- **P2P**: không chuyển cho chính mình  
- **QR**: dynamic phải khớp `amount`, static cho phép nhập linh hoạt

---

## 📊 10. Báo cáo & Đối soát
- Báo cáo tổng nạp/rút/P2P/doanh thu merchant (ngày/tuần/tháng)
- Settlement merchant hằng ngày:
  - File CSV hoặc API confirm
  - Chu kỳ: T+1

---

## ⚠️ 11. Giả định & Rủi ro
- Bank/Napas mock ở MVP  
- OTP/SMS sandbox  
- Có thể xảy ra **race condition** khi update balance → cần **ledger atomicity**

---

## ✅ 12. Tiêu chí nghiệm thu (DoD)
- 20+ test case end-to-end: đăng ký → KYC → top-up → QR pay → refund → cash-out  
- Đáp ứng P99 latency và error budget  
- Restart service không gây lệch sổ ledger  
- Tài liệu: README, sơ đồ kiến trúc, ERD, Postman collection, runbook

---

## 🧭 13. Tech Stack Gợi ý
- **Backend:** Spring Boot 3.x / Java 17, Kafka, Redis, PostgreSQL, MongoDB  
- **Security:** JWT + Refresh Token (Redis), HMAC webhook, BCrypt PIN  
- **Frontend:** React + Tailwind + React Query  
- **Infra:** Docker Compose / K8s, Grafana + Prometheus + Loki  
- **CI/CD:** GitHub Actions, versioning bằng semantic tag  

---

![last-commit](https://img.shields.io/github/last-commit/AT-PAY/Business-Document)
![release](https://img.shields.io/github/v/release/AT-PAY/Business-Document)

[Changelog](./CHANGELOG.md) • [Release History](./docs/RELEASE_HISTORY.md)