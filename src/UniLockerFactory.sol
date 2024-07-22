// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

// Create2
import "@openzeppelin/contracts/utils/Create2.sol";
import "./UniLockerV3LP.sol";

contract UniLockerFactory {

    function getAddress(
        uint256 salt, 
        address _feeTo,
        uint256 _feeToRate,
        address _positionManager
    ) public view returns (address) {
        bytes32 _salt = keccak256(abi.encodePacked(salt));
        return Create2.computeAddress(
            _salt,
            keccak256(abi.encodePacked(
                type(UniLockerV3LP).creationCode,
                _feeTo,
                _feeToRate,
                _positionManager
            ))
        );
    }

    // deploy
    function deploy(
        uint256 salt, 
        address _feeTo,
        uint256 _feeToRate,
        address _positionManager
    ) public returns (address) {
        bytes32 _salt = keccak256(abi.encodePacked(salt));
        bytes memory bytecode = abi.encodePacked(
            type(UniLockerV3LP).creationCode,
            abi.encode(_feeTo, _feeToRate, _positionManager)
        );
        address _address = Create2.deploy(0, _salt, bytecode);
        return _address;
    }
}