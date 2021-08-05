// SPDX-License-Identifier: MIT

pragma solidity 0.6.12;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";

// Zion is the coolest place in the universe. You come in with some Trustbar, and leave with more! The longer you stay, the more Trustbar you get.
//
// This contract handles swapping to and from xTrustbar, Trustbar's staking token.
contract Zion is ERC20("Zion", "xTRUSTBAR"){
    using SafeMath for uint256;
    IERC20 public trustbar;

    // Define the Trustbar token contract
    constructor(IERC20 _trustbar) public {
        trustbar = _trustbar;
    }

    // Enter.... Pay some TRUSTBARs. Earn some shares.
    // Locks Trustbar and mints xTrustbar
    function enter(uint256 _amount) public {
        // Gets the amount of Trustbar locked in the contract
        uint256 totalTrustbar = trustbar.balanceOf(address(this));
        // Gets the amount of xTrustbar in existence
        uint256 totalShares = totalSupply();
        // If no xTrustbar exists, mint it 1:1 to the amount put in
        if (totalShares == 0 || totalTrustbar == 0) {
            _mint(msg.sender, _amount);
        } 
        // Calculate and mint the amount of xTrustbar the Trustbar is worth. The ratio will change overtime, as xTrustbar is burned/minted and Trustbar deposited + gained from fees / withdrawn.
        else {
            uint256 what = _amount.mul(totalShares).div(totalTrustbar);
            _mint(msg.sender, what);
        }
        // Lock the Trustbar in the contract
        trustbar.transferFrom(msg.sender, address(this), _amount);
    }

    // Leave.. Claim back your TRUSTBARs.
    // Unlocks the staked + gained Trustbar and burns xTrustbar
    function leave(uint256 _share) public {
        // Gets the amount of xTrustbar in existence
        uint256 totalShares = totalSupply();
        // Calculates the amount of Trustbar the xTrustbar is worth
        uint256 what = _share.mul(trustbar.balanceOf(address(this))).div(totalShares);
        _burn(msg.sender, _share);
        trustbar.transfer(msg.sender, what);
    }
}