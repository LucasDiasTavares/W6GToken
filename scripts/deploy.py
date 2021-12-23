from brownie import CoinToken
from scripts.utils import get_account
from web3 import Web3

SAFE_BALANCE = Web3.toWei(1, "ether")

# string name,
# string symbol,
# uint256 decimals,
# uint256 supply,
# uint256 Fee,
# address FeeAddress,
# address tokenOwner


def deploy():
    account = get_account()
    CoinToken.deploy('TavaresCoin', 'TVK', 18, 50000000, 7,
                     '0xA1f367f583819621Ac0c34DE18C92AE70f32D5b9',
                     account, {"from": account})


def main():
    deploy()
