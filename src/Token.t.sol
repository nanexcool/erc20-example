// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "ds-test/test.sol";

import "./Token.sol";
import "./Token2.sol";

contract User {
    function doApprove(ZXX zxx, address to, uint256 amount) external returns (bool) {
        return zxx.approve(to, amount);
    }
    function doTransfer(ZXX zxx, address to, uint256 amount) external returns (bool) {
        return zxx.transfer(to, amount);
    }
    function doTransferFrom(ZXX zxx, address from, address to, uint256 amount) external returns (bool) {
        return zxx.transferFrom(from, to, amount);
    }
    function doMint(ZXX zxx, address to, uint256 amount) external returns (bool) {
        return zxx.mint(to, amount);
    }
}
contract User2 {
    function doApprove(ZXX2 zxx, address to, uint256 amount) external returns (bool) {
        return zxx.approve(to, amount);
    }
    function doTransfer(ZXX2 zxx, address to, uint256 amount) external returns (bool) {
        return zxx.transfer(to, amount);
    }
    function doTransferFrom(ZXX2 zxx, address from, address to, uint256 amount) external returns (bool) {
        return zxx.transferFrom(from, to, amount);
    }
    function doMint(ZXX2 zxx, address to, uint256 amount) external returns (bool) {
        return zxx.mint(to, amount);
    }
}

contract TokenTest is DSTest {
    ZXX zxx;
    ZXX2 zxx2;
    User u1;
    User u2;
    User2 u3;
    User2 u4;

    function setUp() public {
        zxx = new ZXX();
        zxx2 = new ZXX2();
        u1 = new User();
        u2 = new User();
        u3 = new User2();
        u4 = new User2();
    }

    function test_total_supply() public {
        assertEq(zxx.totalSupply(), 100_000_000e18);
        assertEq(zxx.balanceOf(address(this)), zxx.totalSupply());
    }

    function test_transfer() public {
        uint256 amount = 1 ether;

        zxx.transfer(address(0x1), amount);
        
        assertEq(zxx.balanceOf(address(this)), zxx.totalSupply() - amount);
        assertEq(zxx.balanceOf(address(0x1)), amount);
    }

    function test_transfer_From() public {
        zxx.transfer(address(u1), 1 ether);

        assertEq(zxx.balanceOf(address(u1)), 1 ether);

        u1.doApprove(zxx, address(u2), 0.5 ether);

        assertEq(zxx.allowance(address(u1), address(u2)), 0.5 ether);

        u2.doTransferFrom(zxx, address(u1), address(u2), 0.5 ether);

        assertEq(zxx.balanceOf(address(u1)), 0.5 ether);
        assertEq(zxx.balanceOf(address(u2)), 0.5 ether);

        assertEq(zxx.allowance(address(u1), address(u2)), 0 ether);
    }

    function testFail_transfer_From() public {
        zxx.transfer(address(u1), 1 ether);

        assertEq(zxx.balanceOf(address(u1)), 1 ether);

        u1.doApprove(zxx, address(u2), 0.5 ether);

        assertEq(zxx.allowance(address(u1), address(u2)), 0.5 ether);

        u2.doTransferFrom(zxx, address(u1), address(u2), 0.6 ether);
    }

    function test_mint() public {
        uint256 totalSupply = zxx.totalSupply();

        zxx.mint(address(0x2), 1 ether);
        assertEq(zxx.balanceOf(address(0x2)), 1 ether);
        assertEq(zxx.totalSupply(), totalSupply + 1 ether);
    }

    function testFail_unauthorized_mint() public {
        u1.doMint(zxx, address(u1), 1 ether);
    }

    function test_burn() public {
        uint256 totalSupply = zxx.totalSupply();

        zxx.burn(1 ether);
        assertEq(zxx.balanceOf(address(this)), totalSupply - 1 ether);
        assertEq(zxx.totalSupply(), totalSupply - 1 ether);
    }

    function test_transfer_gas_usage() public {
        uint256 gas = gasleft();
        zxx.transfer(address(0x1), 1 ether);
        emit log_named_uint("ZXX trasfer", gas - gasleft());


    }

    function test_transfer_gas_usage2() public {
        uint256 gas = gasleft();
        zxx2.transfer(address(0x1), 1 ether);
        emit log_named_uint("ZXX2 trasfer", gas - gasleft());
    }

    function test_transferFrom_gas_usage() public {
        zxx.transfer(address(u1), 1 ether);

        assertEq(zxx.balanceOf(address(u1)), 1 ether);

        u1.doApprove(zxx, address(u2), 0.5 ether);

        assertEq(zxx.allowance(address(u1), address(u2)), 0.5 ether);

        uint256 gas = gasleft();
        u2.doTransferFrom(zxx, address(u1), address(u2), 0.5 ether);
        emit log_named_uint("ZXX trasferFrom", gas - gasleft());

        assertEq(zxx.balanceOf(address(u1)), 0.5 ether);
        assertEq(zxx.balanceOf(address(u2)), 0.5 ether);

        assertEq(zxx.allowance(address(u1), address(u2)), 0 ether);
    }

    function test_transferFrom_gas_usage2() public {
        zxx2.transfer(address(u3), 1 ether);

        assertEq(zxx2.balanceOf(address(u3)), 1 ether);

        u3.doApprove(zxx2, address(u4), 0.5 ether);

        assertEq(zxx2.allowance(address(u3), address(u4)), 0.5 ether);

        uint256 gas = gasleft();
        u4.doTransferFrom(zxx2, address(u3), address(u4), 0.5 ether);
        emit log_named_uint("ZXX2 trasferFrom", gas - gasleft());

        assertEq(zxx2.balanceOf(address(u3)), 0.5 ether);
        assertEq(zxx2.balanceOf(address(u4)), 0.5 ether);

        assertEq(zxx2.allowance(address(u3), address(u4)), 0 ether);
    }
}
