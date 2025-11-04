;; PaulicBit fungible token (simple SIP-010-like implementation)

(define-data-var initialized bool false)
(define-data-var owner (optional principal) none)
(define-data-var total-supply uint u0)
(define-map balances { account: principal } { balance: uint })

;; Token metadata
(define-constant TOKEN-NAME "PaulicBit")
(define-constant TOKEN-SYMBOL "PBIT")
(define-constant TOKEN-DECIMALS u8)

;; Error codes
(define-constant ERR-NOT-INITIALIZED u100)
(define-constant ERR-ALREADY-INITIALIZED u101)
(define-constant ERR-NOT-OWNER u102)
(define-constant ERR-INSUFFICIENT-FUNDS u103)
(define-constant ERR-ZERO-TRANSFER u104)
(define-constant ERR-ZERO-MINT u105)

;; Helpers
(define-private (get-balance-internal (who principal))
  (default-to u0 (get balance (map-get? balances { account: who }))))

(define-read-only (get-owner)
  (ok (var-get owner)))

;; One-time initializer to set the token owner to the caller
(define-public (initialize)
  (if (var-get initialized)
      (err ERR-ALREADY-INITIALIZED)
      (begin
        (var-set owner (some tx-sender))
        (var-set initialized true)
        (ok true))))

(define-public (mint (recipient principal) (amount uint))
  (if (not (var-get initialized))
      (err ERR-NOT-INITIALIZED)
      (if (is-eq amount u0)
          (err ERR-ZERO-MINT)
          (match (var-get owner) owner-principal
            (if (is-eq tx-sender owner-principal)
                (begin
                  (var-set total-supply (+ (var-get total-supply) amount))
                  (let ((rec-bal (get-balance-internal recipient)))
                    (map-set balances { account: recipient } { balance: (+ rec-bal amount) })
                    (ok true)))
                (err ERR-NOT-OWNER))
            (err ERR-NOT-INITIALIZED)))))

(define-public (burn (amount uint))
  (if (not (var-get initialized))
      (err ERR-NOT-INITIALIZED)
      (if (is-eq amount u0)
          (err ERR-ZERO-TRANSFER)
          (let ((sender tx-sender)
                (sender-bal (get-balance-internal tx-sender)))
            (if (< sender-bal amount)
                (err ERR-INSUFFICIENT-FUNDS)
                (begin
                  (map-set balances { account: sender } { balance: (- sender-bal amount) })
                  (var-set total-supply (- (var-get total-supply) amount))
                  (ok true)))))))

(define-public (transfer (recipient principal) (amount uint))
  (if (not (var-get initialized))
      (err ERR-NOT-INITIALIZED)
      (if (is-eq amount u0)
          (err ERR-ZERO-TRANSFER)
          (let ((sender tx-sender)
                (sender-bal (get-balance-internal tx-sender)))
            (if (< sender-bal amount)
                (err ERR-INSUFFICIENT-FUNDS)
                (begin
                  (map-set balances { account: sender } { balance: (- sender-bal amount) })
                  (let ((rec-bal (get-balance-internal recipient)))
                    (map-set balances { account: recipient } { balance: (+ rec-bal amount) })
                    (ok true))))))))

;; Read-only views
(define-read-only (get-name)
  (ok TOKEN-NAME))

(define-read-only (get-symbol)
  (ok TOKEN-SYMBOL))

(define-read-only (get-decimals)
  (ok TOKEN-DECIMALS))

(define-read-only (get-total-supply)
  (ok (var-get total-supply)))

(define-read-only (get-balance (who principal))
  (ok (get-balance-internal who)))
