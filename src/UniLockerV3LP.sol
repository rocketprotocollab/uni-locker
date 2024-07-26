// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import "./IUniLocker.sol";
import "./AbstractUniLocker.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "./uniswap/INonfungiblePositionManager.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract UniLockerV3LP is AbstractUniLocker {
    using SafeERC20 for IERC20;

    address public immutable positionManager;

    constructor(
        address _feeTo,
        uint256 _feeToRate,
        address _positionManager
    ) AbstractUniLocker("UniLockerV3LP", "UL-V3LP", msg.sender) {
        feeTo = _feeTo;
        feeToRate = _feeToRate;
        positionManager = _positionManager;
    }

    function claimProfit(uint256 _id) external {
        // calcuate profit from the lp token
        LockItem storage item = lockItems[_id];

        // owner required
        require(
            ownerOf(_id) == msg.sender || feeTo == msg.sender,
            "UniLocker: not the LP owner or feeTo"
        );

        // calculate profit
        INonfungiblePositionManager _positionManager = INonfungiblePositionManager(
                item.lpToken
            );

        (, , address token0, address token1, , , , , , , , ) = _positionManager
            .positions(item.amountOrId);

        address owner = ownerOf(_id);

        INonfungiblePositionManager.CollectParams
            memory collectParams = INonfungiblePositionManager.CollectParams({
                tokenId: item.amountOrId,
                recipient: address(this),
                amount0Max: type(uint128).max,
                amount1Max: type(uint128).max
            });

        (uint256 amount0, uint256 amount1) = _positionManager.collect(
            collectParams
        );

        uint256 fee0 = (amount0 * feeToRate) / 10000;
        uint256 fee1 = (amount1 * feeToRate) / 10000;

        amount0 -= fee0;
        amount1 -= fee1;

        if (amount0 > 0) {
            IERC20(token0).safeTransfer(owner, amount0);
        }
        if (amount1 > 0) {
            IERC20(token1).safeTransfer(owner, amount1);
        }
        if (fee0 > 0) {
            IERC20(token0).safeTransfer(feeTo, fee0);
        }
        if (fee1 > 0) {
            IERC20(token1).safeTransfer(feeTo, fee1);
        }

        emit ClaimProfit(item.lpToken, _id, amount0, amount1, msg.sender);
    }

    function _transferLP(
        address lpToken,
        address from,
        address to,
        uint256 amountOrId
    ) internal virtual override {
        require(lpToken == positionManager, "UniLockerV3LP: invalid lp token");
        IERC721(lpToken).transferFrom(from, to, amountOrId);
    }

}
