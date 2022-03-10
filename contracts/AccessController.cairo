# Declare this file as a StarkNet contract.
%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from contracts.libraries.Ownable import (
    Ownable_initializer,
    Ownable_only_owner
)   
from contracts.libraries.AccessController_base import (
    AccessController_initializer,
    AccessController_freeSlotsCount,
    AccessController_increaseMaxSlots,
    AccessController_register,
    AccessController_forceRegister
)

@constructor
func constructor{
        syscall_ptr: felt*, 
        pedersen_ptr: HashBuiltin*,
        range_check_ptr
    }(
        initial_allowed_access: felt,
        owner_address: felt
    ):
    Ownable_initializer(owner_address)
    AccessController_initializer(initial_allowed_access)
    return ()
end

@view
func freeSlotsCount{
        syscall_ptr : felt*, 
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }() -> (free_slots_count):
    let (free_slots_count) = AccessController_freeSlotsCount()
    return (free_slots_count)
end

@external
func increaseMaxSlots{
        syscall_ptr : felt*, 
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }(increase_max_count_by: felt):
    # Only Owner should be able to increase the available slots
    Ownable_only_owner()
    AccessController_increaseMaxSlots(increase_max_count_by)
    return ()
end

@external
func register{
        syscall_ptr : felt*, 
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }(address: felt):
    # Anyone can register a new slot
    # Tx will fail if no more slots available
    AccessController_register(address)
    return ()
end

@external
func forceRegister{
        syscall_ptr: felt*, 
        pedersen_ptr: HashBuiltin*,
        range_check_ptr
    }(address: felt):
    # Only Owner should be able to force a register
    Ownable_only_owner()
    # Force the register, total count will be increase
    AccessController_forceRegister(address)
    return ()
end