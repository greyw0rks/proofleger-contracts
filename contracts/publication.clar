;; publication.clar
;; ProofLedger Publication Registry
;; Register academic papers, articles, and research publications on-chain

(define-map publications
  { hash: (buff 32) }
  { author: principal, title: (string-ascii 150),
    abstract-hash: (buff 32), doi: (string-ascii 100),
    pub-type: (string-ascii 30), published-at: uint,
    citation-count: uint })

(define-map citations
  { citing-hash: (buff 32), cited-hash: (buff 32) }
  { cited-at: uint, citer: principal })

(define-data-var total-publications uint u0)

;; publish: register a new publication
;; Errors: u1 = hash already published
(define-public (publish (hash (buff 32)) (title (string-ascii 150))
                         (abstract-hash (buff 32)) (doi (string-ascii 100))
                         (pub-type (string-ascii 30)))
  (begin
    (asserts! (is-none (map-get? publications { hash: hash })) (err u1))
    (map-set publications { hash: hash }
      { author: tx-sender, title: title, abstract-hash: abstract-hash,
        doi: doi, pub-type: pub-type,
        published-at: stacks-block-height, citation-count: u0 })
    (var-set total-publications (+ (var-get total-publications) u1))
    (ok true)))

;; cite: record that one publication cites another
;; Errors: u2 = cited paper not found, u3 = already cited
(define-public (cite (citing-hash (buff 32)) (cited-hash (buff 32)))
  (let ((cited (unwrap! (map-get? publications { hash: cited-hash }) (err u2))))
    (asserts! (is-none (map-get? citations { citing-hash: citing-hash, cited-hash: cited-hash })) (err u3))
    (map-set citations { citing-hash: citing-hash, cited-hash: cited-hash }
      { cited-at: stacks-block-height, citer: tx-sender })
    (map-set publications { hash: cited-hash }
      (merge cited { citation-count: (+ (get citation-count cited) u1) }))
    (ok true)))

(define-read-only (get-publication (hash (buff 32)))
  (map-get? publications { hash: hash }))

(define-read-only (get-citation-count (hash (buff 32)))
  (default-to u0 (get citation-count (map-get? publications { hash: hash }))))