from scripts.helpful_scripts import get_account, get_contract, fund_with_link
from brownie import Game, network, config, MockedEventResult
import time


def deploy_game(amount_of_prizes, outcome1, outcome2, mocked=True):
    account = get_account()
    if mocked:
        MockedEventResult.deploy()

    game = Game.deploy(
        amount_of_prizes,
        get_contract("event_winner").address,
        outcome1,
        outcome2,
        {"from": account},
        publish_source=config["networks"][network.show_active()].get("verify", False),
    )
    print("Deployed Game!")
    return game


def bet(team, amount):
    account = get_account()
    game = Game[-1]
    tx = game.bet(team, {"from": account, "value": amount})
    tx.wait(1)
    print("You just made a bet on team {team}")


def end_game():
    account = get_account()
    game = Game[-1]

    # tx = fund_with_link(game.address) #we will need to fund with link when there is a real source of game winner
    # tx.wait(1)
    distributePrizes = game.distributePrizes({"from": account})
    distributePrizes.wait(1)
    time.sleep(180)
    # print(f"{game.topBetsTeamOne()} are the winning addresses!")


def main():
    deploy_lottery()
