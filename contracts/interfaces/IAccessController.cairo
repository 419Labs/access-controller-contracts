%lang starknet

from starkware.cairo.common.uint256 import Uint256

@contract_interface
namespace IAccessController:
    func isAllowed(address: felt) -> (is_allowed: felt):
    end

    func freeSlotsCount() -> (free_slots_count: felt):
    end

    func getOwner() -> (owner: felt):
    end

    func increaseMaxSlots(increase_max_slots_by: felt) -> ():
    end

    func register() -> ():
    end

    func forceRegister(address: felt) -> ():
    end

    func forceRegisterBatch(batch_address_len : felt, batch_address : felt*) -> ():
    end

    func transferOwnership(new_owner: felt) -> (new_owner: felt):
    end
end
