%lang starknet

from contracts.interfaces.IAccessController import IAccessController
from starkware.starknet.common.syscalls import get_caller_address


@view
func __setup__():
    %{
        context.owner = 123
        context.contract_address = deploy_contract("./contracts/AccessController.cairo", [10, context.owner]).contract_address
    %}
    return ()
end

@external
func test_is_allowed_should_return_false_when_address_is_not_in_whitelist{syscall_ptr : felt*, range_check_ptr}():
    # Given
    tempvar contract_address
    tempvar owner
    %{ ids.contract_address = context.contract_address %}
    %{ ids.owner = context.owner %}

    # When
    let (is_allowed) = IAccessController.isAllowed(contract_address=contract_address, address=owner)

    # Then
    assert is_allowed = 0
    return ()
end

@external
func test_free_slot_count_should_return_remaining_slot_number{syscall_ptr : felt*, range_check_ptr}():
    # Given
    tempvar contract_address
    %{ ids.contract_address = context.contract_address %}

    # When
    let (free_slots_count) = IAccessController.freeSlotsCount(contract_address=contract_address)

    # Then
    assert free_slots_count = 10
    return ()
end

@external
func test_get_owner_should_return_owner_public_key{syscall_ptr : felt*, range_check_ptr}():
    # Given
    tempvar contract_address
    tempvar initial_owner
    %{ ids.contract_address = context.contract_address %}
    %{ ids.initial_owner = context.owner %}

    # When
    let (owner) = IAccessController.getOwner(contract_address=contract_address)

    # Then
    assert owner = initial_owner
    return ()
end

@external
func test_increase_max_slot_should_succeed_when_caller_is_owner{syscall_ptr : felt*, range_check_ptr}():
    # Given
    tempvar contract_address
    %{ ids.contract_address = context.contract_address %}
    %{ stop_prank_callable = start_prank(context.owner, context.contract_address) %}

    # When
    IAccessController.increaseMaxSlots(contract_address=contract_address, increase_max_slots_by=2)

    # Then
    let (free_slots_count) = IAccessController.freeSlotsCount(contract_address=contract_address)
    assert free_slots_count = 12
    %{ stop_prank_callable() %}
    return ()
end

@external
func test_increase_max_slot_should_fail_when_caller_is_not_owner{syscall_ptr : felt*, range_check_ptr}():
    # Given
    tempvar contract_address
    tempvar initial_owner
    %{ ids.contract_address = context.contract_address %}
    %{ ids.initial_owner = context.owner %}

    # When
    %{ expect_revert("TRANSACTION_FAILED") %}
    IAccessController.increaseMaxSlots(contract_address=contract_address, increase_max_slots_by=2)

    # Then
    let (free_slots_count) = IAccessController.freeSlotsCount(contract_address=contract_address)
    assert free_slots_count = 10
    return ()
end

@external
func test_register_should_add_address_to_whitelist{syscall_ptr : felt*, range_check_ptr}():
    # Given
    tempvar contract_address
    %{ ids.contract_address = context.contract_address %}
    %{ stop_prank_callable = start_prank(12345, context.contract_address) %}

    # When
    IAccessController.register(contract_address=contract_address)

    # Then
    let (is_allowed) = IAccessController.isAllowed(contract_address=contract_address, address=12345)
    assert is_allowed = 1
    let (free_slots_count) = IAccessController.freeSlotsCount(contract_address=contract_address)
    assert free_slots_count = 9
    %{ stop_prank_callable() %}
    return ()
end

@external
func test_force_register_should_add_address_to_whitelist_when_caller_is_owner{syscall_ptr : felt*, range_check_ptr}():
    # Given
    tempvar contract_address
    %{ ids.contract_address = context.contract_address %}
    %{ stop_prank_callable = start_prank(123, context.contract_address) %}

    # When
    IAccessController.forceRegister(contract_address=contract_address, address=12345)

    # Then
    let (is_allowed) = IAccessController.isAllowed(contract_address=contract_address, address=12345)
    assert is_allowed = 1
    let (free_slots_count) = IAccessController.freeSlotsCount(contract_address=contract_address)
    assert free_slots_count = 9
    %{ stop_prank_callable() %}
    return ()
end

@external
func test_force_register_should_fail_when_caller_is_not_owner{syscall_ptr : felt*, range_check_ptr}():
    # Given
    tempvar contract_address
    %{ ids.contract_address = context.contract_address %}

    # When
    %{ expect_revert("TRANSACTION_FAILED") %}
    IAccessController.forceRegister(contract_address=contract_address, address=12345)

    # Then
    let (is_allowed) = IAccessController.isAllowed(contract_address=contract_address, address=12345)
    assert is_allowed = 0
    let (free_slots_count) = IAccessController.freeSlotsCount(contract_address=contract_address)
    assert free_slots_count = 10
    %{ stop_prank_callable() %}
    return ()
end

@external
func test_transfer_ownership_should_succeed_when_caller_is_owner{syscall_ptr : felt*, range_check_ptr}():
    # Given
    tempvar contract_address
    %{ ids.contract_address = context.contract_address %}
    %{ stop_prank_callable = start_prank(123, context.contract_address) %}

    # When
    IAccessController.transferOwnership(contract_address=contract_address, new_owner=12345)

    # Then
    let (owner) = IAccessController.getOwner(contract_address=contract_address)
    assert owner = 12345
    %{ stop_prank_callable() %}
    return ()
end

@external
func test_transfer_ownership_should_fail_when_caller_is_not_owner{syscall_ptr : felt*, range_check_ptr}():
    # Given
    tempvar contract_address
    %{ ids.contract_address = context.contract_address %}
    %{ stop_prank_callable = start_prank(123, context.contract_address) %}

    # When
    %{ expect_revert("TRANSACTION_FAILED") %}
    IAccessController.transferOwnership(contract_address=contract_address, new_owner=12345)

    # Then
    let (owner) = IAccessController.getOwner(contract_address=contract_address)
    assert owner = 123
    %{ stop_prank_callable() %}
    return ()
end