# Declare this file as a StarkNet contract.
%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from contracts.libraries.Ownable import (
    Ownable_initializer,
    Ownable_get_owner,
    Ownable_transfer_ownership
)   
from contracts.libraries.AccessController_base import (
    AccessController_initializer,
    AccessController_isAllowed,
    AccessController_freeSlotsCount,
    AccessController_increaseMaxSlots,
    AccessController_register,
    AccessController_forceRegister,
    AccessController_forceRegisterBatch
)
from starkware.starknet.common.syscalls import get_caller_address

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

#
# Getters
#

@view
func isAllowed{
        syscall_ptr : felt*, 
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }(address: felt) -> (is_allowed: felt):
    let (is_allowed) = AccessController_isAllowed(address)
    return (is_allowed)
end

@view
func freeSlotsCount{
        syscall_ptr : felt*, 
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }() -> (free_slots_count: felt):
    let (free_slots_count) = AccessController_freeSlotsCount()
    return (free_slots_count)
end

@view
func getOwner{
        syscall_ptr : felt*, 
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }() -> (owner: felt):
    let (owner) = Ownable_get_owner()
    return (owner=owner)
end

#
# Externals
#

@external
func increaseMaxSlots{
        syscall_ptr : felt*, 
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }(increase_max_slots_by: felt):
    # Ownable check in function
    AccessController_increaseMaxSlots(increase_max_slots_by)
    return ()
end

@external
func register{
        syscall_ptr : felt*, 
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }():
    # Anyone can register a new slot
    # Tx will fail if no more slots available
    let (caller_address) = get_caller_address()
    AccessController_register(caller_address)
    return ()
end

@external
func forceRegister{
        syscall_ptr: felt*, 
        pedersen_ptr: HashBuiltin*,
        range_check_ptr
    }(address: felt):
    # Ownable check in function
    # Force the register, total count will be increase
    AccessController_forceRegister(address)
    return ()
end

@external
func forceRegisterBatch{
        syscall_ptr: felt*, 
        pedersen_ptr: HashBuiltin*,
        range_check_ptr
    }(batch_address_len : felt, batch_address : felt*):
    # Ownable check in function
    # Force the batch register, total count will be increase
    AccessController_forceRegisterBatch(batch_address_len, batch_address)
    return ()
end

@external
func transferOwnership{
        syscall_ptr : felt*, 
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }(new_owner: felt) -> (new_owner: felt):
    # Ownable check in function
    Ownable_transfer_ownership(new_owner)
    return (new_owner=new_owner)
end