from brownie import W6GToken, TokenInGame
from scripts.utils import get_account
from web3 import Web3

SAFE_BALANCE = Web3.toWei(100, "ether")


def deploy_tokenInGame_and_w6gToken():
    account = get_account()
    w6gToken = W6GToken.deploy({"from": account})
    tokenInGame = TokenInGame.deploy(w6gToken, {"from": account})

    # I need some w6gToken for testing in my account... transfering some to me... 99.9%
    # tx = w6gToken.transfer(
    #     tokenInGame.address, w6gToken.totalSupply() - SAFE_BALANCE, {"from": account})
    # tx.wait(1)


def main():
    deploy_tokenInGame_and_w6gToken()
