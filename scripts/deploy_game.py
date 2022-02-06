from scripts.helpful_scripts import get_account, get_contract, fund_with_link
from brownie import Game, network, config, MockEventResult
import time


def deploy_game(amount_of_prizes, outcome1, outcome2, mocked=True):
    account = get_account()
    if mocked:
        MockEventResult.deploy({"from": account})

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


def bet(team, amount, account_number=0):
    account = get_account(account_number)
    game = Game[-1]  # this means get latest deployed version of contract!
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
    # lets hard code this for now
    deploy_game(
        amount_of_prizes=5,
        outcome1=bytes("team1", encoding="utf8"),
        outcome2=bytes("team2", encoding="utf8"),
    )
