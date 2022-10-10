%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.starknet.common.syscalls import get_caller_address
from starkware.cairo.common.math import assert_not_zero, assert_nn
from openzeppelin.access.ownable.library import Ownable

//
// Events
//

@event
func Register(registered_address: felt) {
}

@event
func IncreaseMaxSlots(slots_added_count: felt) {
}

//
// Storage
//

@storage_var
func AccessController_maxSlotsCount() -> (max: felt) {
}

@storage_var
func AccessController_slotUsedCount() -> (entries: felt) {
}

@storage_var
func AccessController_whitelist(address: felt) -> (whitelisted: felt) {
}

func AccessController_initializer{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    initial_allowed_access: felt
) {
    // Init max entries
    AccessController_maxSlotsCount.write(initial_allowed_access);
    // count is at 0
    return ();
}

//
// Getters
//

func AccessController_isAllowed{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    address: felt
) -> (is_allowed: felt) {
    // Check if an address is registered in the whitelist
    let (is_allowed) = AccessController_whitelist.read(address);
    return (is_allowed,);
}

// Return the current count of free slots
func AccessController_freeSlotsCount{
    syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr
}() -> (free_slots_count: felt) {
    let (current_max_count) = AccessController_maxSlotsCount.read();
    let (current_count) = AccessController_slotUsedCount.read();
    let free_slots_count = current_max_count - current_count;
    return (free_slots_count,);
}

//
// Externals
//

// Increase the total slots available
func AccessController_increaseMaxSlots{
    syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr
}(increase_max_slots_by: felt) {
    // Only Owner should be able to increase the available slots
    Ownable.assert_only_owner();
    // Check increase value is positive
    assert_nn(increase_max_slots_by);

    let (current_max_count) = AccessController_maxSlotsCount.read();
    let new_max_count = current_max_count + increase_max_slots_by;
    AccessController_maxSlotsCount.write(new_max_count);

    // Emit slots increase event
    IncreaseMaxSlots.emit(slots_added_count=increase_max_slots_by);
    return ();
}

// Register a new whitlisted address if there is at least 1 free slot
// Everybody should be able to register if there is a free slot
func AccessController_register{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    address: felt
) {
    _register(address);
    return ();
}

// Register a new whitelisted address even if there is no more free slot
// Only owner should be able to add it
func AccessController_forceRegister{
    syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr
}(address: felt) {
    alloc_locals;

    // Only Owner should be able to force a register
    Ownable.assert_only_owner();

    // If no free slot -> increase for 1 more
    let (free_slots_count) = AccessController_freeSlotsCount();
    tempvar syscall_ptr = syscall_ptr;
    tempvar pedersen_ptr = pedersen_ptr;
    tempvar range_check_ptr = range_check_ptr;
    if (free_slots_count == 0) {
        AccessController_increaseMaxSlots(1);
    }

    // Register the new whitelisted address
    _register(address);
    return ();
}

func AccessController_forceRegisterBatch{
    syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr
}(batch_address_len: felt, batch_address: felt*) {
    // Only Owner should be able to force a register batch
    Ownable.assert_only_owner();

    if (batch_address_len == 0) {
        return ();
    }

    let new_address_to_register = batch_address[0];
    AccessController_forceRegister(new_address_to_register);

    return AccessController_forceRegisterBatch(
        batch_address_len - 1, batch_address=&batch_address[1]
    );
}

//
// Internals
//

func _register{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(address: felt) {
    let (free_slots_count) = AccessController_freeSlotsCount();

    // Check there is free slots & address not null
    assert_not_zero(free_slots_count);
    assert_not_zero(address);

    // Check not already registered
    let (is_already_registered) = AccessController_whitelist.read(address);

    assert is_already_registered = 0;

    // Write address to whitelisted & increase total count
    AccessController_whitelist.write(address, 1);
    let (current_count) = AccessController_slotUsedCount.read();
    AccessController_slotUsedCount.write(current_count + 1);

    // Emit registration event
    Register.emit(registered_address=address);
    return ();
}
