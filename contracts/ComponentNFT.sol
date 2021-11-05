//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "hardhat/console.sol";
import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";

interface AssemblyInterface {
    function assemble(address owner, uint tokenId, bytes4 componentCode) external;
}

/**
 @title An simple example of component NFT
 @author Justa Liang
 */
contract ComponentNFT is ERC1155 {

    /// @dev Token counter
    uint private _counter;

    /// @dev Component contract
    AssemblyInterface public assemblyContract;

    constructor(
        string memory uri_
    )
        ERC1155(uri_)
    {
        _counter = 0;
        assemblyContract = AssemblyInterface(_msgSender());
        console.log("Deploying a Component NFT");
        console.log("    URI:", uri_);
    }

    /// @dev Dissemble an NFT and mint items for owner (only call by AssemblableNFT contract)
    function disassemble(address owner, bytes4 componentCode) external {
        require(
            _msgSender() == address(assemblyContract),
            "assemble: not allowed"
        );
        for (uint i = 0; i < 4; i++) {
            if (componentCode[i] != 0x0) {
                _mint(owner, uint32(bytes4(componentCode[i]) << i*4), 1, "");
            }
        }
    }
}