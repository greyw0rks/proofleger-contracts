# ProofLedger Medical Records

The `medical-records.clar` contract anchors medical document hashes with consent tracking.

## Privacy by Design

Only SHA-256 hashes are stored on-chain — no medical data is ever visible.
The hash proves a document existed and was issued by a specific provider.

## Anchor a Medical Record

```clarity
;; Called by the healthcare provider
(contract-call? .medical-records anchor-record
  0x<document-hash>
  SP_PATIENT_ADDRESS
  "lab-result")  ;; Type: lab-result, prescription, xray, diagnosis, referral
```

## Patient Consent

Patient explicitly approves the record being linked to their wallet:

```clarity
(contract-call? .medical-records grant-consent 0x<hash>)
```

## Verify a Record

```clarity
(contract-call? .medical-records get-record 0x<hash>)
;; Returns: { provider, patient, record-type, issued-at, patient-consented }
```