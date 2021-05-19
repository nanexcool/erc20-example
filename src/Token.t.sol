pragma solidity ^0.6.7;

import "ds-test/test.sol";

import "./Token.sol";

contract TokenTest is DSTest {
    Token token;

    function setUp() public {
        token = new Token();
    }

    function testFail_basic_sanity() public {
        assertTrue(false);
    }

    function test_basic_sanity() public {
        assertTrue(true);
    }
}
