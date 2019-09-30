pragma solidity ^0.4.18;

contract Game{
	address owner;
	address public wallet;
	mapping (address => uint) public playersPocket;
	uint winPercent = 40;
	uint random;
	event plays(address player, uint quantity, string win_lose);
	event wallet_in_out(string text, uint quantity, string thereAre, uint wallet_quantity);

	modifier onlyOwner(){
		if (msg.sender == owner){
			_;
		}
	}

	function Game() public{
		owner = msg.sender;
		wallet = this;
		playersPocket[wallet] = wallet.balance;
	}

	function walletHave() public constant returns(string, uint){
		return ("The wallet have:", wallet.balance);
	}

	function insertMoney() public payable{
		playersPocket[msg.sender] = msg.value;
		wallet_in_out("The owner has deposited ", msg.value, "There are now in wallet ", wallet.balance);
	}

	function play(uint quantity) public{
		if (haveMoney(quantity, msg.sender)){
			if (randNum() >= winPercent){
				playersPocket[msg.sender] = playersPocket[msg.sender] - quantity;
				plays(msg.sender, quantity, "Lose")
			}else{
				playersPocket[msg.sender] = playersPocket[msg.sender] + quantity;
				plays(msg.sender, quantity, "Win")
			}
		}
	}

	function outWallet(uint quantity) public onlyOwner returns(bool){
		if (quantity <= playersPocket[wallet]){
			return false;
		}
		playersPocket[wallet] -= msg.value;
		return owner.send(quantity);
	}

	function changePosibility(uint percent) public onlyOwner{
		winPercent = percent;
	}

	function haveMoney(uint quantity, address player) private view returns(bool){
		if ( playersPocket[player] >= quantity){ return true;}
		return false;
	}

	function kill() public onlyOwner{
		selfdestruct(owner);
	}

	function randNum() private returns(uint){
		random++;
		return (uint(keccak256(now, msg.sender, random)) % 100);
	}

	function getBack(uint quantity) public returns(bool){
		if (haveMoney(quantity, msg.sender)){
			playersPocket[msg.sender] = playersPocket[msg.sender] - quantity;
			return msg.sender.send(quantity);
		}else{
			return false;
		}
	}

	function inWallet() public onlyOwner payable{
		playersPocket[wallet] += msg.value;
		wallet_in_out("The owner has withdrawn ", msg.value, "There are now in wallet ", wallet.balance);
	}
}