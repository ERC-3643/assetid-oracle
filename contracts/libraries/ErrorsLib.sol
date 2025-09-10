// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.30;

library ErrorsLib {
    error InvalidPriceFeed();
    error NoTopic(uint256 topicId);
    error Unauthorized();
    error ZeroAddress();
}
