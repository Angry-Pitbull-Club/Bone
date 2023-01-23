-include .env

# Test contracts
.PHONY: test
test : 
ifneq (,$(findstring i, $(MAKEFLAGS)))
	echo output
	forge test -vvvvv >> output.txt
else
	forge test	
endif

# .PHONY: testLocal
# testLocal :
# 	forge test --gas-report --rpc-url 127.0.0.1:8545

# all:
# # Search for the "-i" flag. MAKEFLAGS is just a list of single characters, one per flag. So look for "i" in this case.
# ifneq (,$(findstring i, $(MAKEFLAGS)))
# 	echo "i was passed to MAKEFLAGS"
# endif

.PHONY: script
script :
	forge script script/Bone.s.sol:BoneScript --fork-url http://localhost:8545 --broadcast

abi :
	solc "@openzeppelin/=lib/openzeppelin-contracts/" --abi --pretty-json src/AngryPitbullClubDummy.sol -o ./abi/; solc "@openzeppelin/=lib/openzeppelin-contracts/" --abi --pretty-json src/Bone.sol -o ./abi/

cleanABI :
	rm -rf abi; make abi

deployLocal :
	source .env; forge script script/Bone.s.sol --rpc-url http://127.0.0.1:8545 --broadcast

anvil:
	anvil --gas-price