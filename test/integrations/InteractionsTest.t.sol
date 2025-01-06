// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";
import {FundFundMe, WithdrawFundMe} from "../../script/Interactions.s.sol";

contract InteractionsTest is Test {
    FundMe fundMe;
    address USER = makeAddr("user");

    function setUp() external {
        DeployFundMe deployFundme = new DeployFundMe();
        fundMe = deployFundme.run();
        vm.deal(USER, 100 ether);
    }

    function testUserCanFund() public {
        FundFundMe fundFundMe = new FundFundMe();
        vm.deal(address(fundFundMe), 100 ether);
        // console.log("fundFundMeBalance:", address(fundFundMe).balance);
        fundFundMe.fundFundMe(address(fundMe));
        // console.log("fundFundMeBalanceafter:", address(fundFundMe).balance);
        // address funder = fundMe.getFunders(0);
        // assertEq(funder, address(fundFundMe));
    }

    function testUserCanWithdraw() public {
        FundFundMe fundFundMe = new FundFundMe();
        fundFundMe.fundFundMe(address(fundMe));

        WithdrawFundMe withdrawFundMe = new WithdrawFundMe();
        withdrawFundMe.withdrawFundMe(address(fundMe));
        assertEq(address(fundMe).balance, 0);
    }
}
