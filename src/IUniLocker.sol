// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Enumerable.sol";

interface IUniswapLocker is IERC721Enumerable {
    event Lock(
        address indexed lpToken,
        uint256 indexed tokenId,
        uint256 amountOrId,
        uint256 unlockBlock,
        address indexed owner
    );
    event Unlock(
        address indexed lpToken,
        uint256 indexed tokenId,
        uint256 amountOrId,
        address indexed owner
    );

    event ClaimProfit(
        address indexed lpToken,
        uint256 indexed tokenId,
        uint256 profit0,
        uint256 profit1,
        address indexed owner
    );

    struct LockItem {
        address lpToken;
        uint256 amountOrId;
        uint256 unlockBlock;
    }

    /**
     * lock lp token in this contract
     * @param lpToken the lp token to lock
     * @param amountOrId  the amount of lp token to lock in v2 or the id of the lp token in v3
     * @param unlockBlock  the time when the lp token can be unlocked
     */
    function lock(
        address lpToken,
        uint256 amountOrId,
        uint256 unlockBlock
    ) external returns (uint256 id);
    /**
     * claim profit from the lp token
     * @param _id the id of the lp token lock item to claim profit
     */
    function claimProfit(uint256 _id) external;

    // lockItems
    function lockItem(uint256) external view returns (LockItem memory item);
}
