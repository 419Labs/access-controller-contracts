import pytest
import pytest_asyncio
from starkware.starknet.testing.contract import StarknetContract
from starkware.starknet.testing.starknet import Starknet
from starkware.starkware_utils.error_handling import StarkException
from utils import Signer

# Testing vars
owner = Signer(123456789987654321)
not_owner = Signer(111111111987654323)
address1 = Signer(111111111987654324)
address2 = Signer(111111111987654325)


@pytest_asyncio.fixture
async def starknet() -> Starknet:
    return await Starknet.empty()


@pytest_asyncio.fixture
async def contract(starknet: Starknet) -> StarknetContract:
    return await starknet.deploy("contracts/AccessController.cairo", constructor_calldata=[10, owner.public_key])


def describe_is_allowed():

    @pytest.mark.asyncio
    async def it_should_return_false_when_address_is_not_in_whitelist(contract):
        # When
        execution = await contract.isAllowed(address1.public_key).call()

        # Then
        assert execution.result.is_allowed == 0


def describe_free_slot_count():

    @pytest.mark.asyncio
    async def it_should_return_remaining_slot_number(contract):
        # When
        execution = await contract.freeSlotsCount().call()

        # Then
        assert execution.result.free_slots_count == 10


def describe_get_owner():

    @pytest.mark.asyncio
    async def it_should_return_owner_public_key(contract):
        # When
        execution = await contract.getOwner().call()

        # Then
        assert execution.result.owner == owner.public_key


def describe_increase_max_slot():

    @pytest.mark.asyncio
    async def it_should_succeed_when_caller_is_owner(contract):
        # When
        await contract.increaseMaxSlots(2).invoke(caller_address=owner.public_key)

        # Then
        execution = await contract.freeSlotsCount().call()
        assert execution.result.free_slots_count == 12

    @pytest.mark.asyncio
    async def it_should_fail_when_caller_is_not_owner(contract):
        # When
        with pytest.raises(StarkException):
            await contract.increaseMaxSlots(2).invoke(caller_address=not_owner.public_key)

        # Then
        execution = await contract.freeSlotsCount().call()
        assert execution.result.free_slots_count == 10


def describe_register():

    @pytest.mark.asyncio
    async def it_should_add_address_to_whitelist(contract):
        # When
        await contract.register().invoke(caller_address=address1.public_key)

        # Then
        execution = await contract.isAllowed(address1.public_key).call()
        assert execution.result.is_allowed == 1
        execution = await contract.freeSlotsCount().call()
        assert execution.result.free_slots_count == 9


def describe_force_register():

    @pytest.mark.asyncio
    async def it_should_add_address_to_whitelist_when_caller_is_owner(contract: StarknetContract):
        # When
        await contract.forceRegister(address1.public_key).invoke(caller_address=owner.public_key)

        # Then
        execution = await contract.isAllowed(address1.public_key).call()
        assert execution.result.is_allowed == 1
        execution = await contract.freeSlotsCount().call()
        assert execution.result.free_slots_count == 9

    @pytest.mark.asyncio
    async def it_should_fail_when_caller_is_not_owner(contract: StarknetContract):
        # When
        with pytest.raises(StarkException):
            await contract.forceRegister(address1.public_key).invoke(caller_address=not_owner.public_key)

        # Then
        execution = await contract.isAllowed(address1.public_key).call()
        assert execution.result.is_allowed == 0
        execution = await contract.freeSlotsCount().call()
        assert execution.result.free_slots_count == 10


def describe_force_register_batch():

    @pytest.mark.asyncio
    async def it_should_add_addresses_to_whitelist_when_caller_is_owner(contract: StarknetContract):
        # When
        await contract.forceRegisterBatch([address1.public_key,
                                           address2.public_key]).invoke(caller_address=owner.public_key)

        # Then
        execution = await contract.isAllowed(address1.public_key).call()
        assert execution.result.is_allowed == 1
        execution = await contract.isAllowed(address2.public_key).call()
        assert execution.result.is_allowed == 1
        execution = await contract.freeSlotsCount().call()
        assert execution.result.free_slots_count == 8

    @pytest.mark.asyncio
    async def it_should_fail_when_caller_is_not_owner(contract: StarknetContract):
        # When
        with pytest.raises(StarkException):
            await contract.forceRegisterBatch([address1.public_key,
                                               address2.public_key]).invoke(caller_address=not_owner.public_key)

        # Then
        execution = await contract.isAllowed(address1.public_key).call()
        assert execution.result.is_allowed == 0
        execution = await contract.isAllowed(address2.public_key).call()
        assert execution.result.is_allowed == 0
        execution = await contract.freeSlotsCount().call()
        assert execution.result.free_slots_count == 10


def describe_transfer_ownership():

    @pytest.mark.asyncio
    async def it_should_succeed_when_caller_is_owner(contract: StarknetContract):
        # When
        await contract.transferOwnership(address1.public_key).invoke(caller_address=owner.public_key)

        # Then
        execution = await contract.getOwner().call()
        assert execution.result.owner == address1.public_key

    @pytest.mark.asyncio
    async def it_should_fail_when_caller_is_not_owner(contract: StarknetContract):
        # When
        with pytest.raises(StarkException):
            await contract.transferOwnership(address1.public_key).invoke(caller_address=not_owner.public_key)

        # Then
        execution = await contract.getOwner().call()
        assert execution.result.owner == owner.public_key
