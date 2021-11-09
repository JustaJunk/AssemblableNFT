//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "hardhat/console.sol";
import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";

interface ComponentInterface {
    function mint(address owner, bytes4 componentCode) external;
    function burn(address owner, bytes4 componentCode) external;
}

/**
 @title An simple example of component NFT
 @author Justa Liang
 */
contract ComponentNFT is ERC1155, ComponentInterface {

    /// @dev Token counter
    uint private _counter;

    /// @dev AssemblableNFT contract address
    address public tokenContract;

    constructor(
        string memory uri_
    )
        ERC1155(uri_)
    {
        _counter = 0;
        tokenContract = _msgSender();
        console.log("Deploying a Component NFT");
        console.log("    URI:", uri_);
    }

    /// @dev Mint items for owner when token got dissembled (only call by AssemblableNFT contract)
    function mint(address owner, bytes4 componentCode) override external {
        require(
            _msgSender() == tokenContract,
            "mint: not allowed"
        );
        (uint[] memory ids, uint[] memory amounts) = _decodeToItems(componentCode);
        _mintBatch(owner, ids, amounts, "");
    }

    /// @dev Burn items from owner when token got assembled (only call by AssemblableNFT contract)
    function burn(address owner, bytes4 componentCode) override external {
        require(
            _msgSender() == tokenContract,
            "burn: not allowed"
        );
        (uint[] memory ids, uint[] memory amounts) = _decodeToItems(componentCode);
        _burnBatch(owner, ids, amounts);
    }

    /// @dev Decode component code to item ids
    function _decodeToItems(bytes4 componentCode)
        private pure returns (uint[] memory itemList, uint[] memory amounts)
    {
        bytes4 mask = 0xFF000000;
        uint8 itemNum = 0;
        for (uint8 i = 0; i < 4; i++) {
            if (componentCode & mask != 0) {
                itemNum++;
            }
            mask >>= 8;
        }
        itemList = new uint[](itemNum);
        amounts = new uint[](itemNum);
        mask = 0xFF000000;
        uint8 itemIdx = 0;
        for (uint8 i = 0; i < 4; i++) {
            bytes4 itemCode = componentCode & mask;
            if (itemCode != 0) {
                itemList[itemIdx] = uint32(itemCode);
                amounts[itemIdx] = 1;
                itemIdx++;
            }
            mask >>= 8;
        }
    }
}