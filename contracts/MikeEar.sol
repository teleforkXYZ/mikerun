// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/// Ear for Mike Run. Holds the token to watch, the public line, and the lap count.
/// The page does not need this to paint. Once deployed, Run a lap can call runLap.
contract MikeEar {
    address public owner;
    address public token;
    uint256 public laps;
    string public description;
    string public website;
    string public xHandle;

    event Tuned(address indexed token);
    event Described(string description, string website, string xHandle);
    event Lap(address indexed runner, uint256 laps);

    error NotOwner();

    constructor() {
        owner = msg.sender;
        description = "MIKERUN. He runs. Micron remembers. Anchored to MU. Not Tyson. Not Micron.";
        website = "https://mikerun.lol";
        xHandle = "mikerun_mu";
    }

    function setToken(address next) external {
        if (msg.sender != owner) revert NotOwner();
        token = next;
        emit Tuned(next);
    }

    function setSocials(string calldata nextDescription, string calldata nextWebsite, string calldata nextX) external {
        if (msg.sender != owner) revert NotOwner();
        description = nextDescription;
        website = nextWebsite;
        xHandle = nextX;
        emit Described(nextDescription, nextWebsite, nextX);
    }

    /// Anyone may add one lap. The real MICRUN token is set later with setToken.
    function runLap() external {
        laps += 1;
        emit Lap(msg.sender, laps);
    }
}
