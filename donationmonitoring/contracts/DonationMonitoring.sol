// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.0;
contract DonationMonitoring{

    Request[] private requests;

    // Event that will be emitted whenever a new project is started
    event RequestAdded(
        address contractAddress,
        address requestor,
        string requestName,
        string requestDesc,
        uint256 deadline,
        uint256 goalAmount
    );

    //Calldata is an immutable, temporary location where function arguments are stored, and behaves mostly like memory.
    function addRequest(
        string calldata title,
        string calldata description,
        uint durationInDays,
        uint targetAmount) external {
            uint totalDuration = block.timestamp + (durationInDays*(1 days));

            //msg.sender is not payable by default (since Solidity 0.8.0).
            Request newRequest = new Request(payable(msg.sender), title, description, totalDuration, targetAmount);
            requests.push(newRequest);

            emit RequestAdded(address(newRequest), msg.sender, title, description, totalDuration, targetAmount);

    }



    function returnAllRequests() external view returns(Request[] memory){
        return requests;
    }


}
// function add(uint256 a, uint256 b) internal pure returns (uint256) {
//     uint256 c = a + b;
//     require(c >= a, "SafeMath: addition overflow");

//     return c;
//}

contract Request{


    enum CurrState{
        Ongoing,
        Over,
        Successful
    }


    address payable public receiver;
    uint public requestedAmount;

    uint public completeAt;
    uint256 public currentlyReceived;
    uint public finalDeadline;
    string public title;
    string public description;

    //set status as ongoing as soon as request is added
    CurrState public state = CurrState.Ongoing;//Initializing

    mapping (address => uint) public allDonations;

    // Event that will be emitted whenever funding will be received
    event ReceivedAmount(uint amount, address contributor, uint currTotal);
    // Event that will be emitted whenever the project starter has received the funds
    event RequestorPaid(address recipient);

    // Modifier to check current state
    modifier inState(CurrState _state) {
        require(state == _state);
        _;
    }

     // Modifier to check if the function caller is the project receiver
    modifier isRecevier() {
        require(msg.sender == receiver);
        _;
    }

    //Memory is reserved for variables that are defined within the scope of a function

    constructor(address payable requestor, string memory requestName, string memory requestDesc, uint deadline, uint goalAmount) public {
        receiver=requestor;
        title=requestName;
        description=requestDesc;
        requestedAmount=goalAmount;
        finalDeadline=deadline;
        currentlyReceived=0;


    }

    //Function to fund a project
    function contribute() external inState(CurrState.Ongoing) payable {
        require(msg.sender != receiver);
        allDonations[msg.sender] = allDonations[msg.sender] + msg.value;
        currentlyReceived = currentlyReceived + msg.value;
        emit ReceivedAmount(msg.value, msg.sender ,currentlyReceived);
        checkFundingStatus();
    }

    //Function to change the state of the project
    function checkFundingStatus() public {
        if (currentlyReceived >= requestedAmount) {
            state = CurrState.Successful;
            payOut();
        } else if (block.timestamp > finalDeadline)  {
            state = CurrState.Over;
        }
        completeAt = block.timestamp;
    }

    //Function to give out the fund amount to the project recipient or Creator
    function payOut() internal inState(CurrState.Successful) returns (bool) {
        uint256 totalAmountRaised = currentlyReceived;
        currentlyReceived = 0;

        if (receiver.send(totalAmountRaised)) {
            emit RequestorPaid(receiver);
            return true;
        } else {
            currentlyReceived = totalAmountRaised;
            state = CurrState.Successful;
        }

        return false;
    }

    //Incase of project Expiry -> Function to retrieve donated amount
    function getRefund() public inState(CurrState.Over) returns (bool) {
        require(allDonations[msg.sender] > 0);

        uint payBack = allDonations[msg.sender];
        allDonations[msg.sender] = 0;

        if (!payable(msg.sender).send(payBack)) {
            allDonations[msg.sender] = payBack;
            return false;
        } else {
            currentlyReceived = currentlyReceived - (payBack);
        }

        return true;
    }




    function getDetails() public view returns
    (
        address payable donationRequestor,
        string memory projectTitle,
        string memory projectDesc,
        uint256 deadline,
        CurrState current,
        uint256 currentAmount,
        uint256 goalAmount
    ) {
        donationRequestor = receiver;
        projectTitle = title;
        projectDesc = description;
        deadline = finalDeadline;
        current = state;
        currentAmount = currentlyReceived;
        goalAmount = requestedAmount;
    }


}
