# Testing

## Run Tests

npm test

## Test Coverage

proofleger3
  store: anchors a hash successfully
  store: rejects duplicate hash
  get-doc: returns document metadata
  get-wallet-count: returns correct count
  get-wallet-doc-at: returns hash at index

credentials
  attest: issues attestation successfully
  attest: rejects duplicate from same issuer
  get-attestation: returns attestation metadata
  get-attestation-count: returns correct count

achievements
  mint: mints soulbound NFT successfully
  mint: rejects duplicate for same hash and wallet
  get-token-metadata: returns full token data
  get-last-token-id: returns current counter

## Test Network

All tests run against Clarinet simnet.
No real STX required for testing.
