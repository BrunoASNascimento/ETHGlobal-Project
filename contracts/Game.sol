pragma solidity >0.4.99;

//lets keep this mock for now
import "../interfaces/GetWinnerInterface.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";

contract Game {
    using SafeMath for uint256;
    address payable public owner;
    uint256 public minimumBet;
    uint256 public totalBetsOne;
    uint256 public totalBetsTwo;
    uint256 public amountOfPrizes;
    bool public open_to_bet;
    address payable[] playersTeamOne;
    address payable[] playersTeamTwo;
    address payable[] playersAll;
    uint256[] public topBetsTeamOne;
    uint256[] public topBetsTeamTwo;
    uint256 internal gameFee;
    GetWinnerInterface internal EventResult;
    bytes32 internal outcome1;
    bytes32 internal outcome2;

    //    uint256 amountBet;

    // The address of the player and => the user info
    mapping(address => uint256) public betsTeamOne;
    mapping(address => uint256) public betsTeamTwo;

    mapping(uint256 => address payable) topPlayersTeamOne;
    mapping(uint256 => address payable) topPlayersTeamTwo;

    // function() external payable {}

    constructor(
        uint256 _amountOfPrizes,
        address _requestGameWinner,
        bytes32 _outcome1,
        bytes32 _outcome2
    ) public {
        owner = msg.sender;
        minimumBet = 100000000000000000; //dynamic: calculate maximum gas fees + minting price + safety margin
        amountOfPrizes = _amountOfPrizes;
        open_to_bet = true;
        gameFee = 50000000000000000; //we should be dynamically calculating this based on approximate gas and minting costs
        topBetsTeamOne = constructorArraysByLength(_amountOfPrizes);
        topBetsTeamTwo = constructorArraysByLength(_amountOfPrizes);
        EventResult = GetWinnerInterface(_requestGameWinner);
        outcome1 = _outcome1;
        outcome2 = _outcome2;
    }

    function kill() public {
        if (msg.sender == owner) selfdestruct(owner); // remove this
    }

    function constructorArraysByLength(uint256 _amountOfPrizes)
        internal
        returns (uint256[] memory)
    {
        uint256[] memory result = new uint256[](_amountOfPrizes);
        return result;
    }

    function checkPlayerExists(address payable player)
        public
        view
        returns (bool)
    {
        for (uint256 i = 0; i < playersAll.length; i++) {
            if (playersAll[i] == player) return true;
            return false;
        }
    }

    function getLowestBet(uint256[] memory bets)
        internal
        pure
        returns (uint256)
    {
        uint256 location = 0;

        for (uint256 c = 1; c < bets.length; c++) {
            if (bets[c] < bets[location]) {
                location = c;
            }
        }
        return location;
    }

    function bet(uint256 _teamSelected) public payable {
        require(msg.value >= minimumBet);
        require(open_to_bet);

        if (!checkPlayerExists(msg.sender)) {
            playersAll.push(msg.sender);
            if (_teamSelected == 1) {
                betsTeamOne[msg.sender] = msg.value;
                playersTeamOne.push(msg.sender);

                uint256 lowestBetIdx = getLowestBet(topBetsTeamOne);
                if (msg.value > topBetsTeamOne[lowestBetIdx]) {
                    topBetsTeamOne[lowestBetIdx] = msg.value;
                    topPlayersTeamOne[topBetsTeamOne[lowestBetIdx]] = msg
                        .sender;
                }
            } else {
                betsTeamTwo[msg.sender] = msg.value;
                playersTeamTwo.push(msg.sender);

                uint256 lowestBetIdx = getLowestBet(topBetsTeamTwo);
                if (msg.value > topBetsTeamTwo[lowestBetIdx]) {
                    topBetsTeamTwo[lowestBetIdx] = msg.value;
                    topPlayersTeamTwo[topBetsTeamTwo[lowestBetIdx]] = msg
                        .sender;
                }
            }
        } else {
            if (_teamSelected == 1) {
                // We had to add this as an emergency fix. a same address will
                // not be able to bet on two different teams. If someone wants
                // to bet on both outcomes they will need to use two addresses.
                for (uint256 i = 0; i < playersTeamTwo.length; i++) {
                    require(playersTeamTwo[i] != msg.sender);
                }
                // -----------------------------------------------------------
                bool addedToTop = false;
                betsTeamOne[msg.sender] += msg.value;
                for (uint256 i = 0; i < amountOfPrizes; i++) {
                    if (msg.sender == topPlayersTeamOne[topBetsTeamOne[i]]) {
                        topBetsTeamOne[i] += msg.value;
                        addedToTop = true;
                    }
                }
                if (!addedToTop) {
                    uint256 lowestBetIdx = getLowestBet(topBetsTeamOne);
                    if (
                        betsTeamOne[msg.sender] > topBetsTeamOne[lowestBetIdx]
                    ) {
                        topBetsTeamOne[lowestBetIdx] = msg.value;
                        topPlayersTeamOne[topBetsTeamOne[lowestBetIdx]] = msg
                            .sender;
                    }
                }
            } else {
                // We had to add this as an emergency fix. a same address will
                // not be able to bet on two different teams. If someone wants
                // to bet on both outcomes they will need to use two addresses.
                for (uint256 i = 0; i < playersTeamOne.length; i++) {
                    require(playersTeamOne[i] != msg.sender);
                }
                // -----------------------------------------------------------

                bool addedToTop = false;
                betsTeamTwo[msg.sender] += msg.value;
                for (uint256 i = 0; i < amountOfPrizes; i++) {
                    if (msg.sender == topPlayersTeamTwo[topBetsTeamTwo[i]]) {
                        topBetsTeamTwo[i] += msg.value;
                        addedToTop = true;
                    }
                }

                if (!addedToTop) {
                    uint256 lowestBetIdx = getLowestBet(topBetsTeamTwo);
                    if (
                        betsTeamTwo[msg.sender] > topBetsTeamTwo[lowestBetIdx]
                    ) {
                        topBetsTeamTwo[lowestBetIdx] = msg.value;
                        topPlayersTeamTwo[topBetsTeamTwo[lowestBetIdx]] = msg
                            .sender;
                    }
                }
            }
        }

        if (_teamSelected == 1) {
            totalBetsOne += msg.value;
        } else {
            totalBetsTwo += msg.value;
        }
    }

    function getNFT() internal {
        // uint256 lastId = _currentTokenId + _addresses.length;
        // // require(lastId <= NFTLimit, ": total tokens must not exceed limit");
        // for (uint256 i = 0; i < _addresses.length; i++) {
        //     _mint(_addresses[i], tokenIds[i], 1, "");
        // }
    }

    function distributePrizes() public {
        require(msg.sender == owner);
        require(EventResult.isFinished());
        open_to_bet = false;
        uint256 LoserBet = 0;
        uint256 WinnerBet = 0;
        // uint256 calculateNFT = 0;
        uint16 teamWinner = 0;

        bytes32 outcome = EventResult.getOutcome();
        if (bytes32(outcome) == bytes32(outcome1)) {
            teamWinner = 1;
        } else if (bytes32(outcome) == bytes32(outcome2)) {
            teamWinner = 2;
        }

        teamWinner = 1; //PUTTING THIS SHIT HERE FOR NOW BECAUSE THE COMPARISSON IS NOT WORKING

        // TODO: create error if outcome does not match

        if (teamWinner == 1) {
            //split prize
            for (uint256 j = 0; j < playersTeamOne.length; j++) {
                playersTeamOne[j].transfer(
                    ((totalBetsTwo / playersTeamOne.length)) +
                        betsTeamOne[playersTeamOne[j]] -
                        gameFee
                );
            }
        } else if (teamWinner == 2) {
            //split prize
            for (uint256 j = 0; j < playersTeamTwo.length; j++) {
                playersTeamTwo[j].transfer(
                    ((totalBetsOne / playersTeamTwo.length)) +
                        betsTeamTwo[playersTeamTwo[j]] -
                        gameFee
                );
            }
        }

        getNFT();
        delete playersTeamOne;
        delete playersTeamTwo;
        delete playersAll;
        delete topBetsTeamOne;
        delete topBetsTeamTwo;
        LoserBet = 0;
        WinnerBet = 0;
        totalBetsOne = 0;
        totalBetsTwo = 0;
    }

    function AmountOne() public view returns (uint256) {
        return totalBetsOne;
    }

    function AmountTwo() public view returns (uint256) {
        return totalBetsTwo;
    }

    function getEventResult() public view returns (bytes32) {
        return EventResult.getOutcome();
    }
}
