pragma solidity 0.6.12;

import { IERC20, ILendingPool, IProtocolDataProvider, IStableDebtToken } from './Dependencies/Interfaces.sol';
import { SafeERC20 } from './Dependencies/Libraries.sol';

contract SugarDaddy {
    using SafeERC20 for IERC20;

    ILendingPool lendingPool;
    IProtocolDataProvider dataProvider;

    constructor(
            ILendingPool _lendingPool,
            IProtocolDataProvider _dataProvider
        ) public {
            lendingPool = _lendingPool;
            dataProvider = _dataProvider;
        }

    // Configurates the Sugardaddy by depositing the requisite collateral, enable it for delegation and then approve delegation to sugarbaby
    function configureSugardaddy(
        address _sugarbaby,
        address _flashAsset,
        uint256 _depositAmount,
        address _debtAsset,
        uint256 _delegateAmount
        ) public {

        depositCollateral(_flashAsset, address(this), _depositAmount);
        //setUserUseReserveAsCollateral(_flashAsset); no longer required as this is called as part of depositing on V2
        approveDebtIncuree(_sugarbaby, _delegateAmount, _debtAsset);
    }

    // Deposits collateral into the Aave, to enable debt delegation
    function depositCollateral(address asset, address depositOnBehalfOf, uint256 amount) public {

        IERC20(asset).safeApprove(address(lendingPool), amount);
        lendingPool.deposit(asset, amount, address(this), 0);
    }

    // Enables the asset to be used as collateral
    function setUserUseReserveAsCollateral(address asset) public {

        lendingPool.setUserUseReserveAsCollateral(asset, true);
    }

    // Approves the flash loan executor to incure debt on this contract's behalf
    function approveDebtIncuree(address borrower, uint256 amount, address debtAsset) public {

        IStableDebtToken(debtAsset).approveDelegation(borrower, amount);
    }

    // Pay off the incurred debt
    function repayBorrower(uint256 amount, address asset) public {

        IERC20(asset).safeTransferFrom(msg.sender, address(this), amount);
        IERC20(asset).safeApprove(address(lendingPool), amount);
        lendingPool.repay(asset, amount, 1, address(this));
    }

    // Withdraw all of a collateral as the underlying asset, if no outstanding loans delegated
    function withdrawCollateral(address asset, uint256 amount) public {

        lendingPool.withdraw(asset, amount, address(this));
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
