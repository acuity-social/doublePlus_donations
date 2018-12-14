
pragma solidity ^0.5.0;

import "../mix-item-store/src/item_store_ipfs_sha256.sol";
import "../mix-item-store/src/item_store_registry.sol";

import "./Blurbs.sol";

contract Blurbs_Proxy {

    Blurbs blurbs;
    ItemStoreIpfsSha256 itemStore;

    constructor(Blurbs _blurbs, ItemStoreIpfsSha256 _itemStore) public {
        blurbs = _blurbs;
        itemStore = _itemStore;
    }

    function addBlurb(bytes32 _itemId, uint8 _blurbType) public {
        blurbs.addBlurb(_itemId, _blurbType);
    }

    function withdraw() public {
        blurbs.withdraw();
    }

    function donate(uint amount, bytes32 itemId) public {
        blurbs.donate.value(amount)(itemId);
    }

    function create(bytes32 flagsNonce, bytes32 ipfsHash) external returns (bytes32 itemId) {
        itemId = itemStore.create(flagsNonce, ipfsHash);
    }

    function getNewItemId(address owner, bytes32 nonce) public view returns (bytes32 itemId) {
        itemId = itemStore.getNewItemId(owner, nonce);
    }



}