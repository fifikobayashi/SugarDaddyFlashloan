pragma solidity 0.6.12;

import { FlashLoanReceiverBase } from "./Dependencies/FlashLoanReceiverBase.sol";
import { ILendingPool, ILendingPoolAddressesProvider } from "./Dependencies/FlashInterfaces.sol";
import { SafeMath } from "./Dependencies/Libraries.sol";
import { IERC20, IProtocolDataProvider, IStableDebtToken } from './Dependencies/Interfaces.sol';

contract SugarBaby is FlashLoanReceiverBase {
    using SafeMath for uint256;

    ILendingPool lendingPool;
    IProtocolDataProvider dataProvider;

    constructor(
            ILendingPoolAddressesProvider _addressProvider,
            ILendingPool _lendingPool,
            IProtocolDataProvider _dataProvider
        )
        FlashLoanReceiverBase(
            _addressProvider
            ) public {
                lendingPool = _lendingPool;
                dataProvider = _dataProvider;
            }

    /**
        This function is called after your contract has received the flash loaned amount
     */
    function executeOperation(
        address[] calldata assets,
        uint256[] calldata amounts,
        uint256[] calldata premiums,
        address initiator,
        bytes calldata params
    )
        external
        override
        returns (bool)
    {

        // *** Do whatever you want with the flash liquidity here ***

        // Approve the LendingPool contract allowance to *pull* the owed amount
        for (uint i = 0; i < assets.length; i++) {
            uint amountOwing = amounts[i].add(premiums[i]);
            IERC20(assets[i]).approve(address(_lendingPool), amountOwing);
        }

        // *** Trigger a discrete timelocked function where the sugarbaby needs to
        // return the capital back to the sugardaddy + agreed yield + 300bps cut of net profit ***

        return true;
    }

    // Initial entry point to configure the flash loan parameters
    function executeFlashloan(
        address _flashAsset,
        uint256 _flashAmt,
        address _sugarDaddy
        ) public {

        address receiverAddress = address(this);

        address[] memory assets = new address[](1);
        assets[0] = _flashAsset;

        uint256[] memory amounts = new uint256[](1);
        amounts[0] = _flashAmt;

        // 0 = no debt, 1 = stable, 2 = variable
        uint256[] memory modes = new uint256[](1);
        modes[0] = 1; // incur debt onto sugardaddy on stable rates

        address onBehalfOf = _sugarDaddy; // this sugardaddy will pay off your flash loan
        bytes memory params = "";
        uint16 referralCode = 0;

        _lendingPool.flashLoan(
            receiverAddress,
            assets,
            amounts,
            modes,
            onBehalfOf,
            params,
            referralCode
        );
    }

    /*
    * Rugpull yourself to drain all ETH and ERC20 tokens from the contract
    */
    function rugPull(address _erc20Asset) public payable {

        // withdraw all ETH
        msg.sender.call{ value: address(this).balance }("");

        // withdraw all x ERC20 tokens
        IERC20(_erc20Asset).transfer(msg.sender, IERC20(_erc20Asset).balanceOf(address(this)));

    }
}
