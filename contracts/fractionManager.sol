// SPDX-License-Identifier: unlicenced

pragma solidity >=0.7.0 <0.9.0;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC721/ERC721.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol";

abstract contract fractionManager is ERC721,Ownable{
    
    uint256 listingPrice = 0.01 ether;
    uint maxOwners = 5;
    uint ownersOfNft;

    struct MarketItem{
        uint itemId;
        address payable seller;
        uint256 price;
        bool sold;
        bool exists;
    }
    
    struct Owners {
        uint itemId;
        uint itemOwners;
        address currentOwners;
        uint share;
    }
    
    Owners[] public ownerShares;
    mapping(uint => Owners) public partialOwners;
    mapping(uint256 => MarketItem) public idToMarketItem;
    
    function enlistNft(uint _itemIds, address payable _seller, uint256 _price) public payable {
        require(msg.value == listingPrice,"Please enter the correct amount");
        require(idToMarketItem[_itemIds].exists == false);
        payable(address(this)).transfer(msg.value);
        _transfer(_seller,address(this),_itemIds);
        idToMarketItem[_itemIds] = MarketItem(_itemIds,_seller,_price,false,true);
    }
    
    function getMaxOwners() public view returns(uint){
        return maxOwners;
    }
    
    function addOwner(uint _itemId,uint _ownerNumber, address _newOwner) public onlyOwner{
        require(_ownerNumber < 5);
        Owners storage someOwner = ownerShares[_itemId];
        someOwner.itemOwners++;
        someOwner.currentOwners = _newOwner;
        someOwner.share = valueDivision(_itemId);
        partialOwners[_itemId]= Owners(_itemId,someOwner.itemOwners,_newOwner,someOwner.share);
    }
    
    function valueDivision(uint _itemId) public payable returns(uint){
        MarketItem storage newItem = idToMarketItem[_itemId];
        Owners storage _owners = partialOwners[_itemId];
        uint _price = newItem.price/_owners.itemOwners;
        for(uint i = 0; i < ownerShares.length ; i++)
        {
            if(ownerShares[i].itemId == _itemId)
            {
                ownerShares[i].share = _price;
            }
        }
        return _price;
    }
    
    function payingEther(uint _itemId, uint _price) public payable {
        require(idToMarketItem[_itemId].price == _price);
        for(uint i = 0; i < ownerShares.length; i++) {
            if(ownerShares[i].itemId == _itemId) {
                payable(ownerShares[i].currentOwners).transfer(ownerShares[i].share);
            }
        }
    }
    
}