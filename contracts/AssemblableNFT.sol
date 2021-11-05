//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "hardhat/console.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
// import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";

interface ComponentInterface {
    function mintTo(address owner, uint componentNumber) external;
}

/**
 @title An simple example of assemblable NFT
 @author Justa Liang
 */
contract AssemblableNFT is ERC721Enumerable {

    using Strings for uint;

    /// @dev Token counter
    uint private _counter;

    /// @notice NFT assembly number
    mapping (uint => uint) public assemblyNumberOf; 

    /// @dev Component contract
    ComponentInterface public componentContract;

    /// @dev Base URI
    string public baseURI;

    /// @dev Max supply of token
    uint private _maxSupply;

    /// @dev Max assembly number allowed
    uint private _maxAssembly;

    /// @dev Setup name, symbol and baseURI
    constructor(
        string memory name_,
        string memory symbol_,
        string memory baseURI_,
        uint maxSupply,
        uint maxAssembly
    )
        ERC721(name_, symbol_)
    {
        _counter = 1;
        baseURI = baseURI_;
        _maxSupply = maxSupply;
        _maxAssembly = maxAssembly;
        console.log("Deploying a Assemblable NFT:");
        console.log("    name:", name());
        console.log("    symbol:", symbol());
        console.log("    baseURI:", baseURI);
        console.log("    maxSupply:", _maxSupply);
        console.log("    maxAssembly:", _maxAssembly);
    }

    /// @notice Use assembly number to map token instead of tokenId
    function tokenURI(uint tokenId) public view override returns (string memory) {
        return string(abi.encodePacked(baseURI, assemblyNumberOf[tokenId].toString()));
    }

    /// @notice Mint token with some assembly number
    function mint() external {
        require(
            _counter < _maxSupply,
            "mint: sold out"
        );
        _safeMint(_msgSender(), _counter);
        // for example blockhash as assembly number
        assemblyNumberOf[_counter] = uint(blockhash(block.number))%_maxAssembly;
        _counter++;
    }

    /// @notice disassemble NFT
    function disassemble(uint tokenId, uint componentNumber) external {
        require(
            _isApprovedOrOwner(_msgSender(), tokenId),
            "disassemble: not owner"
        );
        _isDecomposable(assemblyNumberOf[tokenId], componentNumber);
        assemblyNumberOf[tokenId] -= componentNumber;
        componentContract.mintTo(_msgSender(), componentNumber);
    }

    /// @dev Assemble an NFT (only call by Component NFT contract)
    function assemble(address owner, uint tokenId, uint componentNumber) external {
        require(
            _isApprovedOrOwner(owner, tokenId),
            "assemble: not owner"
        );
        require(
            _msgSender() == address(componentContract),
            "assemble: not allowed"
        );
        uint tens = 10**bytes(componentNumber.toString()).length;
        assemblyNumberOf[tokenId] = assemblyNumberOf[tokenId]/tens*tens + componentNumber;
    }

    /// @dev Check if assembly number is decomposable by component number
    function _isDecomposable(uint assemblyNumber, uint componentNumber) private view {
        uint digits = bytes(componentNumber.toString()).length;
        console.log("component digits:", digits);
        for (uint i = 0; i < digits; i++) {
            uint currDigit = componentNumber/10;
            require(
                currDigit == 0 ||
                currDigit == assemblyNumber/10,
                "disassemble: serial error"
            );
            componentNumber /= 10;
            assemblyNumber /= 10;
        }        
    }
}
