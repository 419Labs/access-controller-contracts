# Access Controller Contracts
[![License](https://img.shields.io/badge/License-Apache_2.0-blue.svg)](https://opensource.org/licenses/Apache-2.0) ![version](https://img.shields.io/badge/version-1.0.0-blue)

Simple on-chain access controller contract

## Use in ReactJS

```javascript
import { Contract, json } from "starknet";

const compiledARFController = json.parse(JSON.stringify(arfControllerAbi));
arfControllerContract: new Contract(
    compiledARFController,
    CONTROLLER_CONTRACT_ADDRESS
);

accessControllerContract
    .isAllowed("0x1234...6789")
    .then((response: CallContractResponse) => {
        // response.is_allowed
    })

accessControllerContract
    .invoke("register", [])
    .then((response: AddTransactionResponse) => {
        // Transaction added
    }).catch(() => {
        // Error
    });

accessControllerContract
      .freeSlotsCount()
      .then((response: CallContractResponse) => {
        // response.free_slots_count
      })

```
## Disclaimer

Project has no tests, you it at your own risks