// SPDX-License-Identifier: MIT
pragma solidity 0.6.6;

// import "@chainlink/contracts/src/v0.6/interfaces/LinkTokenInterface.sol";

contract MockEventResult {
    // LinkTokenInterface public LINK;

    // event GameWinner(bytes32);

    // constructor() {
    //     // (address linkAddress) public {
    //     // LINK = LinkTokenInterface(linkAddress);
    // }

    function getOutcome() public pure returns (bytes32) {
        //onlyLINK
        // for mocking purposes, we will simply return this for now
        return bytes32("team1");
    }

    function isFinished() public pure returns (bool) {
        //onlyLINK
        // for mocking purposes, we will simply return this for now
        return bool(true);
    }

    // modifier onlyLINK() {
    //     require(msg.sender == address(LINK), "Must use LINK token");
    //     _;
    // }
}
