;; title: PaulicCoin (PLIC) - A Clarity Token Implementation
;; version: 1.0.0
;; summary: A comprehensive token contract with standard functionality
;; description: PaulicCoin is a fungible token implementation with minting, burning, transfers, and allowances

;; ==============================================================================
;; CONSTANTS
;; ==============================================================================

;; Token name and symbol
(define-constant token-name "PaulicCoin")
(define-constant token-symbol "PLIC")
(define-constant token-decimals u8)

;; Total supply: 1,000,000 PLIC (with 8 decimals)
(define-constant total-supply u100000000000000)

;; Contract owner
(define-constant contract-owner tx-sender)

;; Error codes
(define-constant err-owner-only (err u100))
(define-constant err-insufficient-balance (err u101))
(define-constant err-invalid-amount (err u102))
(define-constant err-unauthorized (err u103))
(define-constant err-already-initialized (err u104))
(define-constant err-not-initialized (err u105))

;; ==============================================================================
;; DATA VARIABLES
;; ==============================================================================

;; Track if contract is initialized
(define-data-var initialized bool false)

;; Track total tokens in circulation
(define-data-var tokens-in-circulation uint u0)

;; ==============================================================================
;; DATA MAPS
;; ==============================================================================

;; Token balances for each address
(define-map balances principal uint)

;; Allowances for spending on behalf of others
(define-map allowances { owner: principal, spender: principal } uint)

;; ==============================================================================
;; PUBLIC FUNCTIONS
;; ==============================================================================

;; Initialize the contract - can only be called once by contract owner
(define-public (initialize)
  (begin
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (asserts! (not (var-get initialized)) err-already-initialized)
    (var-set initialized true)
    (var-set tokens-in-circulation total-supply)
    (map-set balances contract-owner total-supply)
    (print { action: "initialize", total-supply: total-supply, owner: contract-owner })
    (ok true)
  )
)

;; Transfer tokens from sender to recipient
(define-public (transfer (amount uint) (recipient principal))
  (begin
    (asserts! (var-get initialized) err-not-initialized)
    (asserts! (> amount u0) err-invalid-amount)
    (let (
      (sender-balance (default-to u0 (map-get? balances tx-sender)))
    )
      (asserts! (>= sender-balance amount) err-insufficient-balance)
      (map-set balances tx-sender (- sender-balance amount))
      (map-set balances recipient (+ (default-to u0 (map-get? balances recipient)) amount))
      (print { 
        action: "transfer", 
        sender: tx-sender, 
        recipient: recipient, 
        amount: amount 
      })
      (ok true)
    )
  )
)

;; Transfer tokens from one address to another (requires allowance)
(define-public (transfer-from (owner principal) (recipient principal) (amount uint))
  (begin
    (asserts! (var-get initialized) err-not-initialized)
    (asserts! (> amount u0) err-invalid-amount)
    (let (
      (owner-balance (default-to u0 (map-get? balances owner)))
      (current-allowance (default-to u0 (map-get? allowances { owner: owner, spender: tx-sender })))
    )
      (asserts! (>= owner-balance amount) err-insufficient-balance)
      (asserts! (>= current-allowance amount) err-unauthorized)
      (map-set balances owner (- owner-balance amount))
      (map-set balances recipient (+ (default-to u0 (map-get? balances recipient)) amount))
      (map-set allowances { owner: owner, spender: tx-sender } (- current-allowance amount))
      (print { 
        action: "transfer-from", 
        owner: owner,
        spender: tx-sender, 
        recipient: recipient, 
        amount: amount 
      })
      (ok true)
    )
  )
)

;; Approve another address to spend tokens on your behalf
(define-public (approve (spender principal) (amount uint))
  (begin
    (asserts! (var-get initialized) err-not-initialized)
    (map-set allowances { owner: tx-sender, spender: spender } amount)
    (print { 
      action: "approve", 
      owner: tx-sender, 
      spender: spender, 
      amount: amount 
    })
    (ok true)
  )
)

;; Mint new tokens (only contract owner can do this)
(define-public (mint (amount uint) (recipient principal))
  (begin
    (asserts! (var-get initialized) err-not-initialized)
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (asserts! (> amount u0) err-invalid-amount)
    (var-set tokens-in-circulation (+ (var-get tokens-in-circulation) amount))
    (map-set balances recipient (+ (default-to u0 (map-get? balances recipient)) amount))
    (print { 
      action: "mint", 
      recipient: recipient, 
      amount: amount,
      new-circulation: (var-get tokens-in-circulation)
    })
    (ok true)
  )
)

;; Burn tokens from sender's balance
(define-public (burn (amount uint))
  (begin
    (asserts! (var-get initialized) err-not-initialized)
    (asserts! (> amount u0) err-invalid-amount)
    (let (
      (sender-balance (default-to u0 (map-get? balances tx-sender)))
    )
      (asserts! (>= sender-balance amount) err-insufficient-balance)
      (var-set tokens-in-circulation (- (var-get tokens-in-circulation) amount))
      (map-set balances tx-sender (- sender-balance amount))
      (print { 
        action: "burn", 
        burner: tx-sender, 
        amount: amount,
        new-circulation: (var-get tokens-in-circulation)
      })
      (ok true)
    )
  )
)

;; ==============================================================================
;; READ ONLY FUNCTIONS
;; ==============================================================================

;; Get token name
(define-read-only (get-name)
  (ok token-name)
)

;; Get token symbol
(define-read-only (get-symbol)
  (ok token-symbol)
)

;; Get token decimals
(define-read-only (get-decimals)
  (ok token-decimals)
)

;; Get total supply
(define-read-only (get-total-supply)
  (ok total-supply)
)

;; Get tokens in circulation
(define-read-only (get-tokens-in-circulation)
  (ok (var-get tokens-in-circulation))
)

;; Get balance of an address
(define-read-only (get-balance (account principal))
  (ok (default-to u0 (map-get? balances account)))
)

;; Get allowance between owner and spender
(define-read-only (get-allowance (owner principal) (spender principal))
  (ok (default-to u0 (map-get? allowances { owner: owner, spender: spender })))
)

;; Check if contract is initialized
(define-read-only (is-initialized)
  (ok (var-get initialized))
)

;; Get contract owner
(define-read-only (get-contract-owner)
  (ok contract-owner)
)
