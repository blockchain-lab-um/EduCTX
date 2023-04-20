# EduCTX
Certificates are issued by the university and stored in the blockchain. The certificates are issued in the form of ERC-721 tokens.

## Usage
1. Run `migrations/1_eductx_migration.js` script to deploy the contracts.
2. Use `scripts/init_communication.js` script to initialize communication between contracts.

After that, you can use deployed smart contracts for issuing certificates and rewarding students. You can assign CA role to the address, which will be able to issue certificates. CA can be assigned by the owner of the contract.

CA can issue certificates for students. The certificate is issued in the form of ERC-721 token. The token is stored in the blockchain and cannot be transferred to another address.

CA can also assign certified persons to issue certificates in its name. Certified person can issue certificates just like CA.