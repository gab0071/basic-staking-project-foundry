-include .env
.PHONY: all test clean deploy fund help install snapshot format anvil 

DEFAULT_ANVIL_KEY := 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80

NETWORK_ARGS := --rpc-url http://localhost:8545 --private-key $(DEFAULT_ANVIL_KEY) --broadcast

help:
	@echo "Usage:"
	@echo "  make deploy [ARGS=...]\n    example: make deploy ARGS=\"--network sepolia\""
	@echo ""
	@echo "  make fund [ARGS=...]\n    example: make fund ARGS=\"--network sepolia\""

all: clean remove install update build

# Clean the repo
clean  :; forge clean

# Remove modules
remove :; rm -rf .gitmodules && rm -rf .git/modules/* && rm -rf lib && touch .gitmodules && git add . && git commit -m "modules"
install :; forge install
# Update Dependencies
update:; forge update

build:; forge build

test:; forge test

deploy:
	@forge script script/DeployMainContract.s.sol:DeployMainContract $(NETWORK_ARGS)

deploy-sepolia:
	@forge script script/DeployMainContract.s.sol:DeployMainContract --rpc-url $(SEPOLIA_RPC_URL) --private-key $(SEPOLIA_PRIVATE_KEY) --etherscan-api-key $(ETHERSCAN_API_KEY) --broadcast --verify


verbose:; forge test -vvvv

format:; forge fmt

snapshot:; forge snapshot

anvil:; anvil -m 'test test test test test test test test test test test junk' --steps-tracing --block-time 1

coverage:; forge coverage