# Contributing to ProofLedger Contracts

## Getting Started

```bash
git clone https://github.com/greyw0rks/proofleger-contracts.git
cd proofleger-contracts
npm install
```

## Adding a New Contract

1. Create `contracts/my-contract.clar`
2. Add to `Clarinet.toml`
3. Write tests in `tests/my-contract_test.ts`
4. Document in `docs/`
5. Add error codes to `docs/error-codes.md`
6. Update `CHANGELOG.md`
7. Open a PR

## Contract Standards

- Use `stacks-block-height` not `block-height`
- All public functions must have `asserts!` guards
- Error codes must be documented
- No hardcoded principals
- Prefer `string-ascii` over `string-utf8`

## Running Tests

```bash
clarinet check  # syntax check
clarinet test   # run all tests
```