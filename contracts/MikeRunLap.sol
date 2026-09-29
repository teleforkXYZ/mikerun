// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

interface IFeeManager {
    function collectFees(bytes32 poolId) external returns (uint128 fees0, uint128 fees1);
}

interface IERC20 {
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
}

/// Fee recipient for MIKERUN.
/// Name this contract at launch. It does not keep the fee.
/// Each collect is one lap, then the assets go to feeRecipient.
/// runLap is the free lap. It moves no money.
contract MikeRunLap {
    address public owner;
    address public feeRecipient;
    address public token;
    uint256 public laps;
    bool private pulling;

    event Lap(address indexed runner, uint256 laps, uint256 value);
    event Collected(address indexed runner, uint256 laps);
    event Tuned(address indexed token);
    event Recipient(address indexed feeRecipient);

    error NotOwner();
    error ZeroAddress();
    error TransferFailed();

    constructor() {
        owner = msg.sender;
        feeRecipient = msg.sender;
    }

    receive() external payable {
        if (pulling || msg.value == 0) return;
        laps += 1;
        emit Lap(msg.sender, laps, msg.value);
        _sendEth(msg.value);
    }

    function runLap() external {
        laps += 1;
        emit Lap(msg.sender, laps, 0);
    }

    function setToken(address next) external {
        if (msg.sender != owner) revert NotOwner();
        if (next == address(0)) revert ZeroAddress();
        token = next;
        emit Tuned(next);
    }

    function setFeeRecipient(address next) external {
        if (msg.sender != owner) revert NotOwner();
        if (next == address(0)) revert ZeroAddress();
        feeRecipient = next;
        emit Recipient(next);
    }

    /// This contract must already be the pool beneficiary.
    /// Pass address(0) for a native side. One pull, one lap, then the fee leaves.
    function collect(address manager, bytes32 poolId, address token0, address token1) external {
        if (manager == address(0)) revert ZeroAddress();

        uint256 ethBefore = address(this).balance;
        uint256 before0 = _balance(token0);
        uint256 before1 = token1 == token0 ? 0 : _balance(token1);

        pulling = true;
        IFeeManager(manager).collectFees(poolId);
        pulling = false;

        uint256 ethIn = address(this).balance - ethBefore;
        uint256 in0 = _gained(token0, before0);
        uint256 in1 = token1 == token0 ? 0 : _gained(token1, before1);
        if (ethIn == 0 && in0 == 0 && in1 == 0) return;

        laps += 1;
        emit Collected(msg.sender, laps);

        if (ethIn > 0) _sendEth(ethIn);
        if (in0 > 0) _sendToken(token0, in0);
        if (in1 > 0) _sendToken(token1, in1);
    }

    /// Owner rescue. Does not add a lap.
    function sweep(address asset) external {
        if (msg.sender != owner) revert NotOwner();
        if (asset == address(0)) {
            _sendEth(address(this).balance);
            return;
        }
        _sendToken(asset, IERC20(asset).balanceOf(address(this)));
    }

    function _balance(address asset) private view returns (uint256) {
        if (asset == address(0)) return 0;
        return IERC20(asset).balanceOf(address(this));
    }

    function _gained(address asset, uint256 beforeBal) private view returns (uint256) {
        if (asset == address(0)) return 0;
        uint256 nowBal = IERC20(asset).balanceOf(address(this));
        return nowBal > beforeBal ? nowBal - beforeBal : 0;
    }

    function _sendEth(uint256 amount) private {
        (bool ok,) = feeRecipient.call{value: amount}("");
        if (!ok) revert TransferFailed();
    }

    function _sendToken(address asset, uint256 amount) private {
        (bool ok, bytes memory data) =
            asset.call(abi.encodeWithSelector(IERC20.transfer.selector, feeRecipient, amount));
        if (!ok || (data.length != 0 && !abi.decode(data, (bool)))) revert TransferFailed();
    }
}
