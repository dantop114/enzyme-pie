//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import {IComptroller} from "./interfaces/IComptroller.sol";

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract EnzymePie is ERC20, Ownable {
    using SafeERC20 for IERC20;

    IComptroller public comptroller;

    event PoolJoin(address indexed account, uint256 amount);
    event PoolExit(address indexed account, uint256 amount);
    event ComptrollerChanged(address oldComptroller, address newComptroller);

    constructor(
        string memory _name,
        string memory _symbol,
        address _comptroller
    ) ERC20(_name, _symbol) Ownable() {
        comptroller = IComptroller(_comptroller);
    }

    function joinPie(uint256 amount, uint256 minShares) external {
        address[] memory buyers = new address[](1);
        uint256[] memory amounts = new uint256[](1);
        uint256[] memory minSharesReceived = new uint256[](1);

        buyers[0] = address(this);
        amounts[0] = amount;
        minSharesReceived[0] = minShares;

        uint256[] memory shares = comptroller.buyShares(
            buyers,
            amounts,
            minSharesReceived
        );

        _mint(_msgSender(), shares[0]);

        emit PoolJoin(_msgSender(), shares[0]);
    }

    function exitPie(uint256 amount)
        external
        returns (
            address[] memory payoutAssets_,
            uint256[] memory payoutAmounts_
        )
    {
        address[] memory _empty = new address[](0);

        (payoutAssets_, payoutAmounts_) = comptroller.redeemSharesDetailed(
            amount,
            _empty,
            _empty
        );

        for (uint256 i = 0; i < payoutAssets_.length; i++) {
            IERC20(payoutAssets_[i]).safeTransfer(
                _msgSender(),
                payoutAmounts_[i]
            );
        }

        _burn(_msgSender(), amount);

        emit PoolExit(_msgSender(), amount);
    }

    function setComptroller(address _newComptroller) external onlyOwner {
        emit ComptrollerChanged(address(comptroller), _newComptroller);

        comptroller = IComptroller(_newComptroller);
    }
}
