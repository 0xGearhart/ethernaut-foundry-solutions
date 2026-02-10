-include .env

.PHONY: all clean remove install build test snapshot coverage coverage-report gas-report anvil deploy demo

DEFAULT_ANVIL_KEY := 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80

all: clean remove install build

# Clean the repo
clean  :; forge clean

# Remove modules
remove :; rm -rf .gitmodules && rm -rf .git/modules/* && rm -rf lib && touch .gitmodules && git add . && git commit -m "modules"

# Install dependencies
install :; forge install cyfrin/foundry-devops@0.4.0 && forge install foundry-rs/forge-std@v1.13.0 && forge install --root contracts openzeppelin-contracts-06=OpenZeppelin/openzeppelin-contracts@8e0296096449d9b1cd7c5631e917330635244c37 openzeppelin-contracts-08=OpenZeppelin/openzeppelin-contracts@ecd2ca2cd7cac116f7a37d0e474bbb3d7d5e1c4d openzeppelin-contracts-upgradeable=OpenZeppelin/openzeppelin-contracts-upgradeable@2d081f24cac1a867f6f73d512f2022e1fa987854 openzeppelin-contracts-v4.6.0=OpenZeppelin/openzeppelin-contracts@d4fb3a89f9d0a39c7ee6f2601d33ffbf30085322 openzeppelin-contracts-v5.4.0=OpenZeppelin/openzeppelin-contracts@c64a1edb67b6e3f4a15cca8909c9482ad33a02b0


# Build contracts
build:; forge build

# Run test suite
test :; forge test 

# Run forge coverage with minimal fuzz/invariant runs to save time
coverage :; FOUNDRY_PROFILE=coverage forge coverage

# Generate Gas Snapshot
snapshot :; forge snapshot

# Generate table showing gas cost for each function
gas-report :; forge test --gas-report > gas.txt

anvil :; anvil -m 'test test test test test test test test test test test junk' --steps-tracing --block-time 1

NETWORK_ARGS := --rpc-url http://localhost:8545 --private-key $(DEFAULT_ANVIL_KEY) --broadcast

ifeq ($(findstring --network eth MAINNET,$(ARGS)),--network eth MAINNET)
	NETWORK_ARGS := --rpc-url $(ETH_MAINNET_RPC_URL) --account defaultKey --broadcast --verify --etherscan-api-key $(ETHERSCAN_API_KEY) -vvvv
endif

ifeq ($(findstring --network eth sepolia,$(ARGS)),--network eth sepolia)
	NETWORK_ARGS := --rpc-url $(ETH_SEPOLIA_RPC_URL) --account defaultKey --broadcast --verify --etherscan-api-key $(ETHERSCAN_API_KEY) -vvvv
endif

ifeq ($(findstring --network arb MAINNET,$(ARGS)),--network arb MAINNET)
	NETWORK_ARGS := --rpc-url $(ARB_MAINNET_RPC_URL) --account defaultKey --broadcast --verify --etherscan-api-key $(ETHERSCAN_API_KEY) -vvvv
endif

ifeq ($(findstring --network arb sepolia,$(ARGS)),--network arb sepolia)
	NETWORK_ARGS := --rpc-url $(ARB_SEPOLIA_RPC_URL) --account defaultKey --broadcast --verify --etherscan-api-key $(ETHERSCAN_API_KEY) -vvvv
endif

deploy:
	@forge script script/Deploy.s.sol:Deploy $(NETWORK_ARGS)

interact:
	@forge script script/Interactions.s.sol $(NETWORK_ARGS)