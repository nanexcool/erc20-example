// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./IERC20.sol";

contract ZXX is IERC20 {
    // string constant public name = "Enzo Nicolas Perez Token";
    // string constant public symbol = "ENP";
    // uint8 constant public decimals = 18;

    address owner;

    uint256 public override totalSupply;

    mapping (address => uint256) public override balanceOf;
    mapping (address => mapping (address => uint256)) public override allowance;


    constructor() {
        owner = msg.sender;
    }

    function approve(address spender, uint256 amount) external override returns (bool) {
        require(spender != address(0), "nope");
        allowance[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function transfer(address to, uint256 amount) external override returns (bool) {
        require(to != address(0), "nope");
        balanceOf[msg.sender] -= amount;
        balanceOf[to] += amount;
        emit Transfer(msg.sender, to, amount);
        return true;
    }

    function transferFrom(address from, address to, uint256 amount) external override returns (bool) {
        require(to != address(0), "nope");
        allowance[from][msg.sender] -= amount;
        balanceOf[from] -= amount;
        balanceOf[to] += amount;
        emit Transfer(from, to, amount);
        return true;
    }

    function mint(address to, uint256 amount) external override returns (bool) {
        require(msg.sender == owner, "minter not authorized");
        balanceOf[to] += amount;
        totalSupply += amount;
        emit Transfer(address(0), to, amount);
        return true;
    }
}
