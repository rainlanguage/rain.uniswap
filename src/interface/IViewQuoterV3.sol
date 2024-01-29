// SPDX-License-Identifier: CAL
pragma solidity ^0.8.18;

/// IViewQuoterV3 is IQuoter but view
interface IViewQuoterV3 {
    /// This is on the Quoter contract even though it isn't in the upstream
    /// interface.
    function factory() external view returns (address);

    /// IQuoter.quoteExactInput but view
    function quoteExactInput(bytes memory path, uint256 amountIn)
        external
        view
        returns (
            uint256 amountOut,
            uint160[] memory sqrtPriceX96AfterList,
            uint32[] memory initializedTicksCrossedList,
            uint256 gasEstimate
        );

    struct QuoteExactInputSingleWithPoolParams {
        address tokenIn;
        address tokenOut;
        uint256 amountIn;
        address pool;
        uint24 fee;
        uint160 sqrtPriceLimitX96;
    }

    /// IQuoter.quoteExactInputSingleWithPool but view
    function quoteExactInputSingleWithPool(QuoteExactInputSingleWithPoolParams memory params)
        external
        view
        returns (uint256 amountOut, uint160 sqrtPriceX96After, uint32 initializedTicksCrossed, uint256 gasEstimate);

    struct QuoteExactInputSingleParams {
        address tokenIn;
        address tokenOut;
        uint256 amountIn;
        uint24 fee;
        uint160 sqrtPriceLimitX96;
    }

    /// IQuoter.quoteExactInputSingle but view
    function quoteExactInputSingle(QuoteExactInputSingleParams memory params)
        external
        view
        returns (uint256 amountOut, uint160 sqrtPriceX96After, uint32 initializedTicksCrossed, uint256 gasEstimate);

    struct QuoteExactOutputSingleWithPoolParams {
        address tokenIn;
        address tokenOut;
        uint256 amount;
        uint24 fee;
        address pool;
        uint160 sqrtPriceLimitX96;
    }

    /// IQuoter.quoteExactOutputSingleWithPool but view
    function quoteExactOutputSingleWithPool(QuoteExactOutputSingleWithPoolParams memory params)
        external
        view
        returns (uint256 amountIn, uint160 sqrtPriceX96After, uint32 initializedTicksCrossed, uint256 gasEstimate);

    struct QuoteExactOutputSingleParams {
        address tokenIn;
        address tokenOut;
        uint256 amount;
        uint24 fee;
        uint160 sqrtPriceLimitX96;
    }

    /// IQuoter.quoteExactOutputSingle but view
    function quoteExactOutputSingle(QuoteExactOutputSingleParams memory params)
        external
        view
        returns (uint256 amountIn, uint160 sqrtPriceX96After, uint32 initializedTicksCrossed, uint256 gasEstimate);

    /// IQuoter.quoteExactOutput but view
    function quoteExactOutput(bytes memory path, uint256 amountOut)
        external
        view
        returns (
            uint256 amountIn,
            uint160[] memory sqrtPriceX96AfterList,
            uint32[] memory initializedTicksCrossedList,
            uint256 gasEstimate
        );
}
