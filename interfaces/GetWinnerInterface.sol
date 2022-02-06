pragma solidity >0.4.99;

interface GetWinnerInterface {
    // has the event started yet
    function isStarted() external view returns (bool);

    // has the event ended
    function isFinished() external view returns (bool);

    function getOutcome() external view returns (bytes32);
}
