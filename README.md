# Decentralized KYC System on Aptos
### A simple and secure decentralized Know Your Customer (KYC) verification system implemented on the Aptos blockchain.

## Overview
This project implements a decentralized KYC system that allows authorized verifiers to validate user identities on the Aptos blockchain. The system maintains a registry of trusted verifiers and stores verification data for each user.

## Features

- Authorized Verifiers: Only approved entities can verify user identities
- On-chain Verification: User verification status is stored directly on the blockchain
- Privacy-Focused: Stores only hashed verification data rather than raw KYC information
- Verification Revocation: Allows verifiers to revoke verification if needed

## Installation

### Clone this repository  
```bash
git clone <repository-url>
cd decentralized-kyc
```
## Compile the Move module
```bash
aptos move compile
```