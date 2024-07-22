// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import "./IUniLocker.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";

abstract contract AbstractUniLocker is IUniswapLocker, Ownable, ERC721Enumerable {
    using SafeERC20 for IERC20;

    address public feeTo;
    uint256 public immutable feeToRate;
    uint256 private _tokenIDTracker;

    mapping(uint256 => LockItem) public lockItems;

    constructor(
        string memory name,
        string memory symbol,
        address owner
    ) ERC721(name, symbol) Ownable(owner) {
        feeTo = msg.sender;
        feeToRate = 600;
        _tokenIDTracker = 1;
    }

    // lockItem
    function lockItem(uint256 tokenId)
        public
        view
        override
        returns (LockItem memory item)
    {
        return lockItems[tokenId];
    }

    function setFeeTo(address _feeTo) external onlyOwner {
        feeTo = _feeTo;
    }

    function lock(
        address lpToken,
        uint256 amountOrId,
        uint256 unlockBlock
    ) public override returns (uint256 id) {
        require(
            unlockBlock > block.number,
            "UniLocker: unlockBlock must be in the future"
        );
        require(amountOrId > 0, "UniLocker: amountOrId must be greater than 0");

        _transferLP(lpToken, msg.sender, address(this), amountOrId);

        uint256 tokenId = _tokenIDTracker++;
        _mint(msg.sender, tokenId);
        lockItems[tokenId] = LockItem(lpToken, amountOrId, unlockBlock);

        emit Lock(lpToken, tokenId, amountOrId, unlockBlock, msg.sender);
        return tokenId;
    }

    function unlock(uint256 tokenId) public virtual override {
        LockItem storage item = lockItems[tokenId];
        require(item.unlockBlock <= block.number, "UniLocker: still locked");

        address _tokenOwner = ownerOf(tokenId);
        require(_tokenOwner == msg.sender, "UniLocker: not the LP owner");

        _burn(tokenId);
        _transferLP(item.lpToken, address(this), _tokenOwner, item.amountOrId);

        delete lockItems[tokenId];
        emit Unlock(item.lpToken, tokenId, item.amountOrId, _tokenOwner);
    }

    function _transferLP(
        address lpToken,
        address from,
        address to,
        uint256 amountOrId
    ) internal virtual;
}
