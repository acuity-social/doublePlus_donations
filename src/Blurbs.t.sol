pragma solidity ^0.5.0;

import "../lib/ds-test/src/test.sol";
import "../mix-item-store/src/item_store_ipfs_sha256.sol";
import "../mix-item-store/src/item_store_registry.sol";
import "./Blurbs_Proxy.sol";
import "./Blurbs.sol";

contract BlurbsTest is DSTest {
    ItemStoreRegistry itemStoreRegistry;
    ItemStoreIpfsSha256 itemStore;
    Blurbs blurbs;
    Blurbs_Proxy blurbsProxy;

    function setUp() public {
        itemStoreRegistry = new ItemStoreRegistry();
        itemStore = new ItemStoreIpfsSha256(itemStoreRegistry);
        blurbs = new Blurbs(itemStoreRegistry);
        blurbsProxy = new Blurbs_Proxy(blurbs, itemStore);
    }

    function testFail_basic_sanity() public {
        assertTrue(false);
    }

    function test_basic_sanity() public {
        assertTrue(true);
    }

    function test_addBlurb() public {

        bytes32 itemId0 = itemStore.create(bytes2(0x0000), hex"1234");

        assertEq(blurbs.getBlurbOwner(itemId0), address(0x0));
        assertTrue(blurbs.getBlurbType(itemId0) != uint8(2));
        
        blurbs.addBlurb(itemId0, 2);

        assertTrue(itemId0 == blurbs.getBlurbsByType(address(this),uint8(2))[0]);

        assertTrue(blurbs.getBlurbType(itemId0) == uint8(2));
        assertTrue(blurbs.getBlurbOwner(itemId0) == address(this));

        bytes32 itemId2 = itemStore.create(bytes2(0x0003), hex"1234");
        blurbs.addBlurb(itemId2, 3);
        assertTrue(itemId2 == blurbs.getBlurbsByType(address(this), uint8(3))[0]);

    }

    function testFail_addRepeatBlurb() public{

        bytes32 itemId1 = itemStore.create(bytes2(0x0001), hex"1234");
        blurbs.addBlurb(itemId1, 2);

        assertTrue(blurbs.getBlurbOwner(itemId1) == address(this));
        assertTrue(blurbs.getBlurbType(itemId1) == uint8(2));

        blurbsProxy.addBlurb(itemId1, 3);

    }
    function test_donation() public {

        bytes32 itemId1 = blurbsProxy.create(bytes2(0x0001), hex"1234");

        blurbsProxy.addBlurb(itemId1,3);

        uint donationAmount = 1000000000000000000;

        assertTrue(blurbs.currentBalance(address(blurbsProxy)) == 0);

        blurbs.donate.value(donationAmount)(itemId1);

        assertTrue(blurbs.currentBalance(address(blurbsProxy)) == donationAmount);

        assertTrue(blurbs.getBlurbTimesDonated(itemId1) == 1);

    }

}
