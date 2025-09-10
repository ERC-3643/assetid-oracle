// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.30;

library UtilsLib {
    /// @notice Scale price from one decimal to another
    /// @param _price Price to scale
    /// @param _fromDecimals Decimal places of the price
    /// @param _toDecimals Decimal places of the result
    function scalePrice(uint256 _price, uint8 _fromDecimals, uint8 _toDecimals) internal pure returns (uint256) {
        if (_fromDecimals < _toDecimals) {
            return _price * 10 ** uint256(_toDecimals - _fromDecimals);
        }

        if (_fromDecimals > _toDecimals) {
            return _price / 10 ** uint256(_fromDecimals - _toDecimals);
        }

        return _price;
    }
}
