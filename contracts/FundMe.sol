// Get Funds from user
// Withdraw Funds
// Set a minimum funding value in USD

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {PriceConverter} from "./PriceConverter.sol";

error NotOwner();

contract FundMe{
    using PriceConverter for uint256;
    uint256 public constant MINIMUM_USD = 5e18;
    address[] public funders;
    mapping(address funder => uint256 amountFunded) public addressToAmountFunded;
    address immutable i_owner;
    
    constructor(){
        i_owner = msg.sender;
    }

    // Allow users to send money 
    function fund() public payable {

        // Have a minimum $5 sent
        require(msg.value.getConversionRate() >= MINIMUM_USD, "didn't send enough ETH");

        funders.push(msg.sender);
        addressToAmountFunded[msg.sender] +=  msg.value;
    }

    // withdraw money
    function withdraw() public onlyOwner {
        for(uint256 funderIndex = 0; funderIndex<funders.length;funderIndex++){
            address funder = funders[funderIndex];
            addressToAmountFunded[funder] = 0;
        }
        funders = new address[](0);

        //call is one of the method to send Eth from one account or contract to another. 
        (bool callSuccess,) = payable(msg.sender).call{value: address(this).balance}("");
        require(callSuccess, "Call failed");
    }

    // modifier created for only Owner of this contract
    modifier onlyOwner(){
        if(msg.sender != i_owner){
            revert NotOwner();
        }
        _;
    }

    // What happens if someone sends this contract ETH without calling the fund() function ?
    // for that, we are using receive & fallback function which is a special type of low level function
    receive() external payable{
        fund();
    }

    fallback() external payable {
        fund();
     }

}