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
        return deploy_game(5, "team1", "team2")

    @pytest.fixture
    def team1(self):
        return ([1, 2, 3, 4, 5, 6, 7, 8, 9, 10], [10, 11, 12, 13, 4, 15, 16, 1, 2, 3])

    @pytest.fixture
    def team2(self):
        return ([7, 8, 9, 10, 11, 12], [20, 2, 4, 1, 9, 8])

    def test_check_player_exists(self, game, team1, team2):
        game.playersTeamOne = team1[0]
        game.playersTeamTwo = team2[0]
        player_idx = game.checkPlayerExists(5, 1)
        assert player_idx == 4
        player_idx = game.checkPlayerExists(7, 2)
        assert player_idx == 0
        player_idx = game.checkPlayerExists(1, 2)
        assert player_idx == -1

    def test_get_lowest_bet(self, game, team1, team2):
        assert game.getLowestBet(team1[1]) == 7
        assert game.getLowestBet(team2[1]) == 3

    def test_bet(self):
        pass

    # test que o endereco da aposta entra na lista certa
    # test que o endereco da aposta entra na lista top 5 se for top 5
    # test que o endereco da aposta NAO entra na lista top 5 se nao for top 5
    # test que o endereco da aposta nao duplica na lista
    # test que o endereco da aposta pode aparecer nos dois times
    # test que o endereco da aposta, caso ja exista, aumente o valor da sua aposta na lista de valores de apostas
    # test que o endereco da aposta, caso ja exista no top5, aumente o valor da sua aposta na lista de top5
    # test que apostas iguais ao minimo nao entram no top5

    def test_distribute_prizes(self):
        pass

    def test_distribute_prizes_owner_only(self):
        pass

    def test_cant_bet_closed_game(self):
        pass
