#!/usr/bin/env bash

set -ex

export SOLC_FLAGS=${SOLC_FLAGS:-"--optimize"}
export ETH_GAS=${ETH_GAS:-"4500000"}

function amt {
  seth --to-uint256 $(seth --to-wei $1 eth)
}

keys=($(seth rpc eth_accounts))

lad=${keys[1]}
gal=${keys[2]}
ali=${keys[3]}
bob=${keys[4]}

cd dss
dapp build

VAT=$(dapp create Vat)
PIE=$(dapp create Dai20 $VAT)

FLIPPER=$(dapp create Flipper $VAT $(seth --to-bytes32 $(seth --from-ascii 'fake ilk')))

seth send $FLIPPER 'kick(address lad, address gal, uint tab, uint lot, uint bid)' \
          $lad $gal $(amt 50) $(amt 100) $(amt 0)

ID=$(seth call $FLIPPER 'kicks()')

seth send -F $ali $FLIPPER 'tend(uint id, uint lot, uint bid)' \
                  $ID $(amt 100) $(amt 1)

seth send -F $bob $FLIPPER 'tend(uint id, uint lot, uint bid)' \
                  $ID $(amt 100) $(amt 50)

seth send -F $ali $FLIPPER 'dent(uint id, uint lot, uint bid)' \
                  $ID $(amt 95) $(amt 50)
