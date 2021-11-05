//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "hardhat/console.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "./ComponentNFT.sol";

interface ComponentInterface {
    function disassemble(address owner, bytes4 componentCode) external;
}

/**
 @title An simple example of assemblable NFT
 @author Justa Liang
 */
contract AssemblableNFT is ERC721Enumerable {

    /// @dev Token counter
    uint private _counter;

    /// @notice NFT assembly number
    mapping (uint => bytes4) public assemblyCodeOf; 

    /// @dev Component contract
    ComponentInterface public componentContract;

    /// @dev Base URI
    string public baseURI;

    /// @dev Max supply of token
    uint private _maxSupply;

    constructor(
        string memory name_,
        string memory symbol_,
        string memory baseURI_,
        string memory itemsURI_,
        uint maxSupply
    )
        ERC721(name_, symbol_)
    {
        _counter = 1;
        baseURI = baseURI_;
        _maxSupply = maxSupply;
        componentContract = ComponentInterface(address(new ComponentNFT(itemsURI_)));

        console.log("Deploying a Assemblable NFT");
        console.log("    name:", name());
        console.log("    symbol:", symbol());
        console.log("    baseURI:", baseURI);
        console.log("    maxSupply:", _maxSupply);
    }

    /// @notice Use assembly number to map token instead of tokenId
    function tokenURI(uint tokenId) public view override returns (string memory) {
        return string(abi.encodePacked(baseURI, assemblyCodeOf[tokenId]));
    }

    /// @notice Mint token with some assembly number
    function mint() external {
        require(
            _counter < _maxSupply,
            "mint: sold out"
        );
        _safeMint(_msgSender(), _counter);
        // for example blockhash as assembly number
        assemblyCodeOf[_counter] = bytes4(blockhash(block.number));
        _counter++;
    }

    /// @notice disassemble NFT
    function disassemble(uint tokenId, bytes4 componentCode) external {
        require(
            _isApprovedOrOwner(_msgSender(), tokenId),
            "disassemble: not owner"
        );
        bytes4 assemblyCode = assemblyCodeOf[tokenId];
        bytes4 assemblyCodeAfter = 0x0;
        for (uint8 i = 0; i < 4; i++) {
            console.log(i, ":", uint8(componentCode[i]));
            if (assemblyCode[i] == componentCode[i]) {
                continue;
            }
            else if (componentCode[i] == 0x0) {
                assemblyCodeAfter |= bytes4(assemblyCode[i]) << i*4;
            }
            else {
                revert(
                    "disassemble: not disassemblable"
                );
            }
        }
        assemblyCode = assemblyCodeAfter;
        componentContract.disassemble(_msgSender(), componentCode);
    }

    /// @dev Assemble an NFT (only call by ComponentNFT contract)
    function assemble(address owner, uint tokenId, bytes4 componentCode) external {
        require(
            _isApprovedOrOwner(owner, tokenId),
            "assemble: not owner"
        );
        require(
            _msgSender() == address(componentContract),
            "assemble: not allowed"
        );
        bytes4 assemblyCode = assemblyCodeOf[tokenId];
        bytes4 assemblyCodeAfter = 0x0;
        for (uint8 i = 0; i < 4; i++) {
            if (componentCode[i] == 0x0) {
                assemblyCodeAfter |= bytes4(assemblyCode[i]) << i*4;
            }
            else {
                assemblyCodeAfter |= bytes4(componentCode[i]) << i*4;
            }
        }
        assemblyCodeOf[tokenId] = assemblyCodeAfter;
    }
}
