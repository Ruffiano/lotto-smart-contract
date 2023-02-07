// SPDX-License-Identifier: MIT
pragma solidity >0.8.11;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./Testable.sol";

contract Lottery is Ownable {

    address payable[] public players;
    
    uint public lotteryRound;
    uint256 private lotteryIdCounter_;

    mapping (uint => address payable) public lotteryHistory;

     // Represents the status of the lottery
    enum Status { 
        NotStarted,     // The lottery has not started yet
        Open,           // The lottery is open for ticket purchases 
        Closed,         // The lottery is no longer open for ticket purchases
        Completed       // The lottery has been closed and the numbers drawn
    }

    // All the needed info around a lottery
    struct LottoInfo {
        uint256 lotteryID;          // ID for lotto
        Status lotteryStatus;       // Status for lotto
        uint256 prizePoolInCake;    // The amount of cake for prize money
        uint256 costPerTicket;      // Cost per ticket in $cake
        uint256 startingTimestamp;      // Block timestamp for star of lotto
        uint256 closingTimestamp;       // Block timestamp for end of entries
    }
    
    // Lottery ID's to info
    mapping(uint256 => LottoInfo) internal allLotteries_;

    event LotteryOpen(uint256 lotteryId);

    constructor() {
       
        lotteryRound = 1;
    }
    
    function createNewLotto (
        uint256 _prizePoolInCake,
        uint256 _costPerTicket,
        uint256 _startingTimestamp,
        uint256 _closingTimestamp
    )
        external
        onlyOwner()
        returns(uint256 lotteryId)
    {
       // Incrementing lottery ID 
        lotteryIdCounter_ = lotteryIdCounter_++;
        lotteryId = lotteryIdCounter_;

        Status lotteryStatus;
        if(_startingTimestamp >= block.timestamp) {
            lotteryStatus = Status.Open;
        } else {
            lotteryStatus = Status.NotStarted;
        }
        // Saving data in struct
        LottoInfo memory newLottery = LottoInfo(
            lotteryId,
            lotteryStatus,
            _prizePoolInCake,
            _costPerTicket,
            _startingTimestamp,
            _closingTimestamp
        );
        allLotteries_[lotteryId] = newLottery;

          // Emitting important information around new lottery.
        emit LotteryOpen(
            lotteryId
        );

    }


    function getWinnerByLotteryId(uint lottery_id) public view returns (address payable) {
        return lotteryHistory[lottery_id];
    }

    function getBalance() public view returns (uint) {
        return address(this).balance;
    }

    function getPlayers() public view returns (address payable[] memory) {
        return players;
    }

    function enterNumbers(uint8[6] memory numbers) public payable {
        require(msg.value > .03 ether);
        // address if palyer entering lottery
        players.push(payable(msg.sender));
    }



    // modifier onlyOwner() {
    //     require(msg.sender == owner);
    //     _;
    // }
}