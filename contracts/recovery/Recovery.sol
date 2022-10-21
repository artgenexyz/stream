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

contract Recovery is Ownable {
    address public immutable streamReceiver =
        0x98CDE40f98E7c77507820C0caEf055CC3cc3fA79;
    address public immutable streamFactory =
        0x1C4663902A55A8346B5bD1131d7405A3513944fD;

    // impersonate buildship deployer
    // deploy stream factory
    // run recover()
    // test that tx returned success
    // check gas usage

    constructor() {}

    function recover() public payable onlyOwner returns (bool) {
        require(streamReceiver.balance != 0, "streamReceiver has no balance");

        // check that streamFactory.code is not empty
        require(
            Address.isContract(streamFactory),
            "Recovery: streamFactory.code is empty"
        );
        // require(c.length > 0, "Recovery: streamFactory.code is empty");

        // connect to a streamFactory contract
        Factory f = Factory(streamFactory);

        SafeStream stream;
        address _stream;

        // deploy a contract from streamFactory until streamstreamReceiver address is reached

        SafeStream.Member[] memory m_empty = new SafeStream.Member[](0);
        SafeStream.Member[] memory m = new SafeStream.Member[](1);

        m[0] = SafeStream.Member({account: address(0), value: 1, total: 1});

        while (true) {
            _stream = f.genesis("", address(0), m_empty);

            console.log("deployed stream: %s", _stream);

            if (_stream == 0x6eeF990e51F935C84C7f3F58B93B440f07E95431) {
                break;
            }
        }

        m[0] = SafeStream.Member({account: msg.sender, value: 1, total: 1});

        _stream = f.genesis("", msg.sender, m);

        stream = SafeStream(payable(_stream));

        require(_stream == streamReceiver, "Recovery: streamReceiver address not reached");
        require(
            address(stream) == _stream,
            "Recovery: stream address mismatch"
        );

        console.log(
            "stream balance: (%s) %s",
            address(stream),
            address(stream).balance
        );

        uint _balance = msg.sender.balance;
        console.log("balance: %s", _balance);

        Address.sendValue(payable(stream), msg.value);

        console.log("balance: %s", msg.sender.balance);
        require(
            msg.sender.balance > _balance,
            "Recovery: failed to recover 2 eth"
        );

        require(
            address(stream).balance == 0,
            "Recovery: failed to recover 2 eth"
        );

        return true;
    }
}
