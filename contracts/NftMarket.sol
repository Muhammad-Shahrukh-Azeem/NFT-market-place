//SPDX-License-Identifier: Unlicense

pragma solidity >=0.7.0 <0.9.0;

import './fractionManager.sol';

contract NftMarket is fractionManager{

    constructor() ERC721("NewNFT", "NNFT") {}
    
    function sellingNft(uint _itemId,address payable _seller,uint _price) public payable {
        enlistNft(_itemId,_seller,_price);
    }
    
    function additionalowners(uint _itemId,uint _ownerNumber, address _seller) public{
        addOwner(_itemId,_ownerNumber,_seller);
    }
    
    function buyingNft(uint _itemId,address payable _buyer,uint _price) public payable{
        _transfer(address(this),_buyer,_itemId);
        valueDivision(_itemId);
        payingEther(_itemId,_price);
        delete idToMarketItem[_itemId];
        delete partialOwners[_itemId];
    }
}