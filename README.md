###Decentralized Lottery Smart Contract (Foundry)

Developed a decentralized lottery application as part of the Cyfrin Updraft smart contract development curriculum using Solidity and Foundry. The project implements a secure and automated lottery system where participants can enter by paying an entrance fee, and a winner is selected randomly through Chainlink VRF (Verifiable Random Function). The lottery execution and winner selection process are automated using Chainlink Automation, eliminating the need for manual intervention.

## 🚀 How to Run the Project

### Prerequisites

Make sure you have the following installed:

* Git
* Foundry
* A wallet private key for testing/deployment
* Chainlink VRF subscription (for testnet deployment)

### 1. Clone the Repository

```bash
git clone <repository-url>
cd foundry-smart-contract-lottery
```

### 2. Install Foundry Dependencies

```bash
forge install
```

### 3. Build the Project

Compile the smart contracts:

```bash
forge build
```

### 4. Run the Test Suite

Execute all unit and integration tests:

```bash
forge test
```

For verbose output:

```bash
forge test -vvv
```

### 5. Configure Environment Variables

Create a `.env` file in the root directory and add the required variables:

```env
PRIVATE_KEY=your_private_key
SEPOLIA_RPC_URL=your_rpc_url
ETHERSCAN_API_KEY=your_api_key
```

Load the environment variables:

```bash
source .env
```

### 6. Deploy to a Local Anvil Network

Start a local blockchain:

```bash
anvil
```

Open a new terminal and deploy:

```bash
forge script script/DeployRaffle.s.sol \
--rpc-url http://127.0.0.1:8545 \
--broadcast
```

### 7. Deploy to Sepolia Testnet

```bash
forge script script/DeployRaffle.s.sol \
--rpc-url $SEPOLIA_RPC_URL \
--broadcast \
--verify
```

### 8. Check Contract Status

Use Foundry commands to interact with the deployed contract:

```bash
cast call <contract-address> "<function-signature>"
```

Example:

```bash
cast call <contract-address> "getEntranceFee()(uint256)"
```

### 9. Run Coverage Report

```bash
forge coverage
```

### Useful Commands

```bash
forge build          # Compile contracts
forge test           # Run tests
forge test -vvv      # Verbose testing
forge coverage       # Coverage report
forge fmt            # Format code
anvil                # Local Ethereum node
cast                 # Interact with contracts
```

---

## 📚 Project Overview

This project implements a decentralized lottery (raffle) system using Solidity and Foundry. Users enter the lottery by paying an entrance fee, and a winner is selected automatically using Chainlink VRF for provably fair randomness. Chainlink Automation is used to trigger winner selection without manual intervention, ensuring a fully decentralized and transparent workflow.
