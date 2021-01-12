// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";

interface IVaultV2 {
    function deposit(uint256 _amount, address _owner) external returns (uint256 _shares);
}

contract YVProxy {

    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    address public rewardsAddress;
    address public vaultAddress;
    address public token;

    uint256 public depositFee = 500; // 5%    
    uint256 public FEE_MAX = 10000; // 100%

    constructor(address _token, address _vaultAddress, address _rewardsAddress, uint256 _depositFee) {
        token = _token;
        vaultAddress = _vaultAddress;
        rewardsAddress = _rewardsAddress;
        depositFee = _depositFee;
    }

    function deposit(uint256 _amount) public {

        // Get the desposit and ensure that _amount is transfered
        uint256 _before = IERC20(token).balanceOf(address(this));
        IERC20(token).safeTransferFrom(msg.sender, address(this), _amount);
        uint256 _after = IERC20(token).balanceOf(address(this));
        _amount = _after.sub(_before);
        
        // Take fee
        IERC20(token).safeTransfer(rewardsAddress, _amount.mul(depositFee).div(FEE_MAX));

        // Deposit to vault
        depositToVault(msg.sender, _amount);
    }

    function depositToVault(address _owner, uint256 _amount) internal {
        IERC20(token).safeApprove(vaultAddress, _amount);

        // Deposit into the vault, the sender is the owner
        IVaultV2(vaultAddress).deposit(_amount, _owner);
    }
}
