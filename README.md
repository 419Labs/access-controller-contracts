# Access Controller Contracts
[![License](https://img.shields.io/badge/License-Apache_2.0-blue.svg)](https://opensource.org/licenses/Apache-2.0) ![version](https://img.shields.io/badge/version-1.0.0-blue)

Simple on-chain access controller contract. This contract permit an on-chain registration mechanism with a concept of slots. 

Owner can specify a number of slots (`maxSlotsCount`). Everyone is able to `register` to get a slot. When the `slotUsedCount` eq the `maxSlotsCount` there is no more space to register.

With this simple approach you can use an on-chain contract to manage accesses of your contracts or even of your frontends. This is a very useful tool when you want to give progessive access.


## Contracts

The contract has three state variables:

```cairo
@storage_var
func AccessController_maxSlotsCount() -> (max: felt):
end

@storage_var
func AccessController_slotUsedCount() -> (entries: felt):
end

@storage_var
func AccessController_whitelist(address: felt) -> (whitelisted: felt):
end
```

### Deploy

When deploying the contract you have to pass two args:

```cairo
(
    initial_allowed_access: felt, # Number of initial slots available
    owner_address: felt           # Owner of the contract who will be able to increase # of slots
)
```

### Management

Once you deployed the contract, you can increase the number of maximum slots available. To do that make a transaction by invoking the `increaseMaxSlots` function from the owner wallet. The argument is `increase_max_slots_by` which is the number of slots you want to add. 

Other useful functions can be found [here](https://github.com/419Labs/access-controller-contracts/blob/update/docs/contracts/AccessController.cairo)


## Use in ReactJS

Using this contract is deadsimple. First of all import ABI and create your `Contract` object:

```javascript
import { Contract, json } from "starknet";

const compiledARFController = json.parse(JSON.stringify(arfControllerAbi));
arfControllerContract: new Contract(
    compiledARFController,
    CONTROLLER_CONTRACT_ADDRESS
);
```

Verify if an address is allowed/registered:

```javascript
accessControllerContract
    .isAllowed("0x1234...6789")
    .then((response: CallContractResponse) => {
        // response.is_allowed
    })
```

Permit a user to register in order to get a free slot:

```javascript
accessControllerContract
    .invoke("register", [])
    .then((response: AddTransactionResponse) => {
        // Transaction added
    }).catch(() => {
        // Error
    });
```

Check the number of available slots:

```javascript
accessControllerContract
      .freeSlotsCount()
      .then((response: CallContractResponse) => {
        // response.free_slots_count
      })
```

## Use case

This contract has been used for [Alpha Road](https://twitter.com/alpharoad_fi) during the first Testnet phases of the launch of our first offering: a one-click revisited AMM.

## Tests

### Run tests

First, install requirements:

```sh
pip install -r requirements.txt
pip install -r tests/requirements.txt
```

Run all tests:

```sh
pytest
```

Run a specific test:

```sh
pytest tests/test_AccessController.py -k test_transfer_ownership_should_fail_when_caller_is_not_owner
```

### Linter

To make our tests readable we use a standard linter: [flake8](https://flake8.pycqa.org/en/latest/)

Run linter:

```sh
flake8 . --count --exit-zero --max-complexity=10 --max-line-length=120 --statistics
```

Flake will only act as linter and will not help you to fix/format your python files. We recommend using: [yapf](https://github.com/google/yapf)

E.g:

```sh
yapf --recursive --style='{based_on_style: pep8, column_limit: 120, indent_width: 4}' -i tests
```

## Improvements

Feel free to improve this by providing a PR.
