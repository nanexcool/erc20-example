// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "ds-test/test.sol";

import "./Token.sol";

contract User {
    function doApprove(IERC20 zxx, address to, uint256 amount) external returns (bool) {
        return zxx.approve(to, amount);
    }
    function doTransfer(IERC20 zxx, address to, uint256 amount) external returns (bool) {
        return zxx.transfer(to, amount);
    }
    function doTransferFrom(IERC20 zxx, address from, address to, uint256 amount) external returns (bool) {
        return zxx.transferFrom(from, to, amount);
    }
    function doMint(IERC20 zxx, address to, uint256 amount) external returns (bool) {
        return zxx.mint(to, amount);
    }
}

contract TokenTest is DSTest {
    ZXX zxx;
    User u1;
    User u2;
    User u3;
    User u4;

    function setUp() public {
        if (true) {
            zxx = new ZXX();
        } else {
            bytes memory code = hex"336000556103de80610014600039806000f350fe61000934156103cc565b60003560e01c6370a082318114610066576318160ddd81146100835763a9059cbb8114610093576323b872dd81146100b85763095ea7b381146100e55763dd62ed3e811461010a576340c10f19811461012f5760006000fd610150565b61007e6100796100746102b3565b610386565b610352565b610150565b61008e600154610352565b610150565b6100ab61009e610322565b6100a66102b3565b6101b8565b6100b361035f565b610150565b6100d86100c361033a565b6100cb6102f3565b6100d36102b3565b610212565b6100e061035f565b610150565b6100fd6100f0610322565b6100f86102b3565b6101c8565b61010561035f565b610150565b61012a6101256101186102f3565b6101206102b3565b610396565b610352565b610150565b61014761013a610322565b6101426102b3565b610156565b61014f61035f565b5b506103dd565b6000338154141515610166578081fd5b610172836001546103ac565b60015581611000016101858482546103ac565b81555082815281817fddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef602084a35050505b565b6101c3828233610244565b50505b565b8015156101d55760006000fd5b816101e0823361036c565b558160005280337f8c5be1e5ebec7d5bd14f71427d1e84f3dd0314c0f7b2291e5b200ac8c7c3b92560206000a350505b565b61021c338261036c565b80548085111561022c5760006000fd5b8481038255505061023e838383610244565b5050505b565b8115156102515760006000fd5b6110008181018054808611156102675760006000fd5b85810382555050828101905061027e8482546103ac565b8155508260005281817fddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef60206000a35050505b565b60008060051b602481013610156102c8578182fd5b80600401359150506bffffffffffffffffffffffff60a01b81161515156102ef5760006000fd5b5b90565b60006102fd610322565b90506bffffffffffffffffffffffff60a01b811615151561031e5760006000fd5b5b90565b60006044361015610331578081fd5b60243590505b90565b60006064361015610349578081fd5b60443590505b90565b8060005260206000f3505b565b600160005260206000f35b565b600081611000018152826020526040812090505b92915050565b600081611000015490505b919050565b60006103a2838361036c565b5490505b92915050565b6000828201905082811082821017156103c55760006000fd5b5b92915050565b8015156103d95760006000fd5b505b565b";
            address yul;
            assembly {
                yul := create(0, add(code, 32), mload(code))
            }
            zxx = ZXX(yul);
        }
        
        u1 = new User();
        u2 = new User();
        u3 = new User();
        u4 = new User();
    }

    function test_total_supply() public {
        zxx.mint(address(this), 100_000_000e18);
        assertEq(zxx.totalSupply(), 100_000_000e18);
        assertEq(zxx.balanceOf(address(this)), zxx.totalSupply());
    }

    function test_transfer() public {
        zxx.mint(address(this), 100_000_000e18);
        uint256 amount = 1 ether;

        zxx.transfer(address(0x1), amount);
        
        assertEq(zxx.balanceOf(address(this)), zxx.totalSupply() - amount);
        assertEq(zxx.balanceOf(address(0x1)), amount);
    }

    function test_transfer_From() public {
        zxx.mint(address(this), 100_000_000e18);
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
        zxx.mint(address(this), 100_000_000e18);
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

    function test_transferFrom_gas_usage() public {
        zxx.mint(address(this), 100_000_000e18);
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

    function prove_transfer(uint supply, address usr, uint amt) public {
        if (usr == address(0)) return; // no transfer to address 0
        if (amt > supply) return; // no underflow

        zxx.mint(address(this), supply);

        uint prebal = zxx.balanceOf(usr);
        zxx.transfer(usr, amt);
        uint postbal = zxx.balanceOf(usr);

        uint expected = usr == address(this)
                        ? 0    // self transfer is a noop
                        : amt; // otherwise `amt` has been transfered to `usr`
        assertEq(expected, postbal - prebal);
    }

    function prove_balance(address usr, uint amt) public {
        assertEq(0, zxx.balanceOf(usr));
        zxx.mint(usr, amt);
        assertEq(amt, zxx.balanceOf(usr));
    }

    function prove_supply(uint supply) public {
        zxx.mint(address(0x1), supply);
        uint actual = zxx.totalSupply();
        assertEq(supply, actual);
    }
}
