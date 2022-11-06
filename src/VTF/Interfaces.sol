//SPDX-License-Identifier:MIT
pragma solidity ^0.8.13;

import {IERC20} from "openzeppelin-contracts/Interfaces/IERC20.sol";

interface IVTF is IERC20 {
    function updateUserBalance(address _user) external;
}

interface IDPPOracle {
    function flashLoan(
        uint256 baseAmount,
        uint256 quoteAmount,
        address assetTo,
        bytes calldata data
    ) external;

    function getVaultReserve()
        external
        view
        returns (uint256 baseReserve, uint256 quoteReserve);
}

interface IP2ERouter {
    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
}
