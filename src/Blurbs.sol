
pragma solidity ^0.5.0;

import "../mix-item-store/src/item_store_interface.sol";
import "../mix-item-store/src/item_store_registry.sol";

contract Blurbs {

    modifier notInitialized(bytes32 itemId) {
        require (blurbData[itemId].owner == address(0x0));
        _;
    }

    modifier Initialized(bytes32 itemId) {
        require (blurbData[itemId].owner != address(0x0));
        _;
    }

    event donation(bytes32 indexed itemId, address indexed itemOwner, uint amount);
    event blurbAdded(bytes32 indexed itemId, uint8 blurbType, address indexed itemOwner);
    event withdrawal(address indexed itemOwner, uint amount);

    ItemStoreRegistry itemStoreRegistry;

    mapping (address => mapping (uint8 => bytes32[])) blurbsByType;

    mapping (bytes32 => Blurb) blurbData;
    
    struct Blurb {
        uint8 blurbType;
        address owner;
        uint256 donationsReceived;
        uint128 timesDonated;
        uint256 createdOn;
    }

    mapping (address => uint256) pendingWithdrawals;

    constructor(ItemStoreRegistry _itemStoreRegistry) public {
        itemStoreRegistry = _itemStoreRegistry;
    }

    function addBlurb(bytes32 _itemId, uint8 _blurbType) public notInitialized(_itemId) {
        
        ItemStoreInterface itemStore = itemStoreRegistry.getItemStore(_itemId);
        
        //check if item exist
        require(itemStore.getInUse(_itemId));

        //check if items owner is the msg.sender
        require(itemStore.getOwner(_itemId) == msg.sender);

        blurbsByType[msg.sender][_blurbType].push(_itemId);

        Blurb storage currentBlurb = blurbData[_itemId];

        currentBlurb.owner = msg.sender;
        currentBlurb.createdOn = block.timestamp;
        currentBlurb.blurbType = _blurbType;

        emit blurbAdded(_itemId, _blurbType, msg.sender);

    }

    function donate(bytes32 _itemId) public payable Initialized(_itemId) {

        require(msg.value > 0);

        address _owner = blurbData[_itemId].owner;

        require(_owner != msg.sender);

        pendingWithdrawals[_owner] += msg.value;

        blurbData[_itemId].donationsReceived += msg.value;

        blurbData[_itemId].timesDonated = uint128(blurbData[_itemId].timesDonated + 1);

        emit donation(_itemId, _owner, msg.value);

    }

    function withdraw() public {
        
        uint256 _amount = pendingWithdrawals[msg.sender];
        
        pendingWithdrawals[msg.sender] = 0;
        
        msg.sender.transfer(_amount);

        emit withdrawal(msg.sender, _amount);

    }

    function getBlurbInfo(bytes32 _itemId) public view returns (address owner, uint256 donationsReceived, uint128 timesDonated, uint8 blurbType, uint256 createdOn) {
        
        Blurb storage _blurb = blurbData[_itemId];
        
        owner = _blurb.owner;
        donationsReceived = _blurb.donationsReceived;
        timesDonated = _blurb.timesDonated;
        blurbType = _blurb.blurbType;
        createdOn = _blurb.createdOn;

    }

    function getBlurbsByType(address addr, uint8 _blurbType) public view returns (bytes32[] memory) {
        return blurbsByType[addr][_blurbType];
    }

    function getBlurbTotalDonations(bytes32 _itemId) public view returns (uint256) {
        return blurbData[_itemId].donationsReceived;
    }

    function getBlurbTimesDonated(bytes32 _itemId) public view returns (uint128) {
        return blurbData[_itemId].timesDonated;
    }

    function currentBalance (address addr) public view returns (uint256) {
        return pendingWithdrawals[addr];
    }

    function getBlurbType (bytes32 _itemId) public view returns (uint8) {
        return blurbData[_itemId].blurbType;
    }

    function getBlurbOwner(bytes32 _itemId) public view returns (address) {
        return blurbData[_itemId].owner;
    }

}
