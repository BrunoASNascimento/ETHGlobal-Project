pragma solidity >0.4.99;

//lets keep this mock for now
import "../interfaces/GetWinnerInterface.sol";

contract Game {
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
    uint256 internal gasCost;
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
        minimumBet = 100000000000000; //dynamic: calculate maximum gas fees + minting price + safety margin
        amountOfPrizes = _amountOfPrizes;
        open_to_bet = true;
        gasCost = 199462 + 40000; //20% marge
        topBetsTeamOne = [0, 0, 0, 0, 0]; //testando
        topBetsTeamTwo = [0, 0, 0, 0, 0];
        EventResult = GetWinnerInterface(_requestGameWinner);
        outcome1 = _outcome1;
        outcome2 = _outcome2;
    }

    function kill() public {
        if (msg.sender == owner) selfdestruct(owner); // remove this
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

    function getNFT(address payable player, uint256 valueGain) internal {
        // TO DO: Insert contract NFT
        player.transfer(valueGain);
    }

    function distributePrizes() public {
        require(msg.sender == owner);
        open_to_bet = false;
        uint256 LoserBet = 0;
        uint256 WinnerBet = 0;
        uint256 calculateNFT = 0;
        uint16 teamWinner = 0;

        bytes32 outcome = EventResult.getOutcome();
        if (outcome == outcome1) {
            teamWinner = 1;
        } else if (outcome == outcome2) {
            teamWinner = 2;
        }

        // TODO: create error if outcome does not match

        if (teamWinner == 1) {
            LoserBet = totalBetsTwo;
            WinnerBet = totalBetsOne;
        } else if (teamWinner == 2) {
            LoserBet = totalBetsOne;
            WinnerBet = totalBetsTwo;
        }

        if (teamWinner == 1) {
            //Back money
            for (uint256 j = 0; j < playersTeamOne.length; j++) {
                playersTeamOne[j].transfer(
                    (((10000 + (10000 / WinnerBet))) / 10000) - gasCost
                );
            }
            //NFT
            for (uint256 i = 0; i < topBetsTeamOne.length; i++) {
                calculateNFT = LoserBet / topBetsTeamOne.length;
                getNFT(topPlayersTeamOne[topBetsTeamOne[i]], calculateNFT);
            }
        } else {
            //Back money
            for (uint256 j = 0; j < playersTeamTwo.length; j++) {
                playersTeamTwo[j].transfer(
                    (((10000 + (10000 / WinnerBet))) / 10000) - gasCost
                );
            }
            //NFT
            for (uint256 i = 0; i < topBetsTeamTwo.length; i++) {
                calculateNFT = LoserBet / topBetsTeamTwo.length;
                getNFT(topPlayersTeamTwo[topBetsTeamTwo[i]], calculateNFT);
            }
        }

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
}
