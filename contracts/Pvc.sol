// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

error zeroAddress();
error voterAlreadyHasPVC();

contract Pvc is ERC20, Ownable {
    constructor() ERC20("Permanent Voters Card", "PVC") Ownable(msg.sender) {
    }

    function updateOwner(address newOwner) external onlyOwner {
        if (newOwner == address(0)) {
            revert zeroAddress();
        }
        transferOwnership(newOwner);
        _mint(newOwner, 1000e18);
    }

    // Issue a PVC to an eligible voter

    function issuePVC(address voter) external onlyOwner {
        if (balanceOf(voter) != 0) {
            revert voterAlreadyHasPVC();
        }
        _mint(voter, 1e18);
    }
}
