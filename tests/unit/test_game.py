from scripts.helpful_scripts import (
    LOCAL_BLOCKCHAIN_ENVIRONMENTS,
    get_account,
    fund_with_link,
    get_contract,
)
from brownie import Game, accounts, config, network, exceptions
from scripts.deploy_game import deploy_game
from web3 import Web3
import pytest


# if network.show_active() not in LOCAL_BLOCKCHAIN_ENVIRONMENTS:
#     pytest.skip()
class TestGame:
    @pytest.fixture
    def game(self):
        return deploy_game(
            5, bytes("team1", encoding="utf8"), bytes("team2", encoding="utf8")
        )

    @pytest.fixture
    def team1(self):
        return (
            [get_account(i) for i in range(1, 11)],
            [10, 11, 12, 13, 4, 15, 16, 1, 2, 3],
        )

    @pytest.fixture
    def team2(self):
        return ([get_account(i) for i in range(7, 13)], [20, 2, 4, 1, 9, 8])

    def test_check_player_exists(self, game, team1, team2):
        game.playersTeamOne = team1[0]
        game.playersTeamTwo = team2[0]
        assert game.checkPlayerExists(get_account(7))
        assert game.checkPlayerExists(get_account(12))
        assert game.checkPlayerExists(get_account(1))
        assert not game.checkPlayerExists(get_account(19))

    @pytest.mark.skip("internal function")
    def test_get_lowest_bet(self, game, team1, team2):
        assert game.getLowestBet(team1[1]) == 7
        assert game.getLowestBet(team2[1]) == 3

    def test_event_result(self, game):
        assert game.getEventResult() == bytes("team1", encoding="utf-8")

    def test_bet(self):
        pass

    # test que o endereco da aposta entra na lista certa
    # test que o endereco da aposta entra na lista top 5 se for top 5
    # test que o endereco da aposta NAO entra na lista top 5 se nao for top 5
    # test que o endereco da aposta pode aparecer nos dois times
    # test que o endereco da aposta, caso ja exista, aumente o valor da sua aposta na lista de valores de apostas

    def test_sum_of_bets(self, game, team1, team2):
        # test que o endereco da aposta, caso ja exista no top5, aumente o valor da sua aposta na lista de top5
        account = get_account()
        # game.playersTeamOne = team1[0]
        # game.playersTeamTwo = team2[0]
        game.bet(1, {"from": account, "value": 7 * 10 ** 18})
        game.bet(2, {"from": account, "value": 7 * 10 ** 18})
        game.bet(2, {"from": account, "value": 7 * 10 ** 18})
        assert game.totalBetsOne() == 7 * 10 ** 18
        assert game.totalBetsTwo() == 14 * 10 ** 18

    @pytest.mark.skip("getLowestBet is internal")
    def test_same_bet_value(self, game, team1, team2):
        # test que apostas iguais ao minimo nao entram no top5
        # game.playersTeamOne = team1[0]
        # game.playersTeamTwo = team2[0]
        game.bet(1, {"from": get_account(5), "value": 7 * 10 ** 18})
        game.bet(2, {"from": get_account(7), "value": 7 * 10 ** 18})
        game.bet(2, {"from": get_account(1), "value": 7 * 10 ** 18})
        assert game.getLowestBet((team1[1])) == 7
        assert game.getLowestBet((team2[1])) == 7

    def test_duplication_of_list(self, game, team1, team2):
        # test que o endereco da aposta nao duplica na lista
        game.playersTeamOne = team1[0]
        game.playersTeamTwo = team2[0]

        assert (
            len(
                set(
                    [x for x in game.playersTeamOne if game.playersTeamOne.count(x) > 1]
                )
            )
            == 0
        )
        assert (
            len(
                set(
                    [x for x in game.playersTeamTwo if game.playersTeamTwo.count(x) > 1]
                )
            )
            == 0
        )

    def test_distribute_prizes(self):
        account = get_account()
        game = deploy_game(
            2, bytes("team1", encoding="utf8"), bytes("team2", encoding="utf8")
        )
        game.bet(1, {"from": account, "value": 7 * 10 ** 18})
        game.bet(1, {"from": get_account(2), "value": 7 * 10 ** 18})
        game.bet(2, {"from": get_account(5), "value": 9 * 10 ** 18})

        game.distributePrizes({"from": account})

        assert account

    def test_distribute_prizes_owner_only(self):
        pass

    def test_cant_bet_closed_game(self):
        pass
