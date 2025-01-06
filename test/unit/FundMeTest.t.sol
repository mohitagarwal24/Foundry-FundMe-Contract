// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

// Here we will beusing a lot of cheatcodes like prank, makeaddr etc. to ensure test runs smoothly but they arenn't real and works only with test file in solidity

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";

contract FundMeTest is Test {
    FundMe fundMe;

    address USER = makeAddr("user");

    function setUp() external {
        DeployFundMe deployFundme = new DeployFundMe();
        fundMe = deployFundme.run();
        vm.deal(USER, 100 ether);
    }

    function testMinimumDollarIsFive() public view {
        assertEq(fundMe.MINIMUM_USD(), 5 * 10 ** 18);
    }

    function testOwnerIsMsgSender() public view {
        // console.log("msg.sender: ", msg.sender);
        // console.log("fundMe.i_owner(): ", fundMe.i_owner());
        assertEq(fundMe.getOwner(), msg.sender);
    }

    function testVersionIsAccurate() public view {
        assertEq(fundMe.getVersion(), 4);
    }

    function testEnoughEthIsSend() public {
        vm.expectRevert(); // hey ! the next line should revert meaning that (assertEq(fundMe.fund()) should revert))
        fundMe.fund(); // send 0 value
    }

    function testAmountFunded() public {
        vm.prank(USER);
        fundMe.fund{value: 0.1 ether}();
        uint256 amount = fundMe.getAddressToAmountFunded(USER);
        assertEq(amount, 0.1 ether);
    }

    function testFunderToArrayOfFunders() public {
        vm.prank(USER);
        fundMe.fund{value: 0.1 ether}();
        address funder = fundMe.getFunders(0);
        assertEq(funder, USER);
    }

    modifier funded() {
        vm.prank(USER);
        fundMe.fund{value: 0.1 ether}();
        _;
    }

    function testWithdrawIfNotOwner() public {
        // vm.prank(USER);
        // fundMe.fund{value: 0.1 ether}();

        vm.expectRevert(); // hey ! the next line should revert meaning that (assertEq(fundMe.withdraw()) should revert))
        vm.prank(USER);
        fundMe.withdraw();
    }

    function testWithdrawBySingleFunder() public funded {
        // Arrange
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMebalance = address(fundMe).balance;

        // Act
        vm.prank(fundMe.getOwner());
        fundMe.withdraw();

        // Assert
        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        uint256 endingFundMebalance = address(fundMe).balance;
        assertEq(endingFundMebalance, 0);
        assertEq(
            endingOwnerBalance,
            startingOwnerBalance + startingFundMebalance
        );
    }

    function testWithdrawByMultipleFunders() public {
        // Arrange
        uint160 startingFunderIndex = 1;
        uint160 noOfFunders = 10;
        for (uint160 i = startingFunderIndex; i < noOfFunders; i++) {
            // vm.prank(USER);
            // vm.deal new address
            hoax(address(i), 100 ether);
            fundMe.fund{value: (1 ether) * i}();
        }
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMebalance = address(fundMe).balance;

        // Act
        vm.prank(fundMe.getOwner());
        fundMe.withdraw();

        // Assert
        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        uint256 endingFundMebalance = address(fundMe).balance;
        assertEq(endingFundMebalance, 0);
        assertEq(
            endingOwnerBalance,
            startingOwnerBalance + startingFundMebalance
        );
    }
}
