// SPDX-License-Identifier:MIT
pragma solidity ^0.8.13;

import {IERC20} from "openzeppelin-contracts/interfaces/IERC20.sol";

interface IYSwap {
    function exchange_underlying(
        int128 i,
        int128 j,
        uint256 dx,
        uint256 min_dy
    ) external;

    function balances(int128) external view returns (uint256);
}

interface IHarvestVault {
    function deposit(uint256 amountWei) external;

    function withdraw(uint256 numberOfShares) external;

    function balanceOf(address account) external view returns (uint256);
}

interface IUniswapV2Pair {
    function factory() external view returns (address);

    function token0() external view returns (address);

    function token1() external view returns (address);

    function getReserves()
        external
        view
        returns (
            uint112 reserve0,
            uint112 reserve1,
            uint32 blockTimestampLast
        );

    function swap(
        uint256 amount0Out,
        uint256 amount1Out,
        address to,
        bytes calldata data
    ) external;
}

interface IUSDT {
    function approve(address _spender, uint256 _value) external;

    function balanceOf(address owner) external view returns (uint256);

    function transfer(address _to, uint256 _value) external;

    function allowance(address owner, address spender)
        external
        returns (uint256);
}
