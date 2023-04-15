// SPDX-License-Identifier: GPL-3.0
pragma solidity^0.8.14;

import {
    ISuperfluid, 
    ISuperToken, 
    ISuperApp
} from "@superfluid-finance/ethereum-contracts/contracts/interfaces/superfluid/ISuperfluid.sol";

import { SuperTokenV1Library } from "@superfluid-finance/ethereum-contracts/contracts/apps/SuperTokenV1Library.sol";

error Unauthorized();

contract DisperseFlow {

    address owner; 
    using SuperTokenV1Library for ISuperToken;
    //ISuperToken public token;
    // github->address
    mapping(string=>address) nick2addrs;
    
    constructor() {
        owner = msg.sender;
    }

    /// @notice Transfer ownership.
    /// @param _newOwner New owner account.
    function changeOwner(address _newOwner) external {
        if (msg.sender != owner) revert Unauthorized();

        owner = _newOwner;
    }
    modifier onlyOwner() {
        require(msg.sender == owner, "only owner can do");
        _;
    }

    /// @notice address's owner register his github account.
    /// @param _account owner's github account.
    function register(string memory _account) external {
        require(bytes(_account).length > 0, "account is null");
        require(nick2addrs[_account] == address(0), "account already exists");
        nick2addrs[_account] = msg.sender;
    }

    /// @notice batch airdrop by address.
    /// @param _token address for SuperToken.
    /// @param _recipients address list.
    /// @param _flowRates rate list.
    function disperseToken(ISuperToken _token, address[] memory _recipients, int96[] memory _flowRates) external onlyOwner {
        for (uint256 i = 0; i < _recipients.length; i++) {
            _token.createFlow(_recipients[i], _flowRates[i]);
        }
            
    }

    /// @notice batch airdrop by account.
    /// @param _token address for SuperToken.
    /// @param _recipients account list.
    /// @param _flowRates rate list.
    function disperseTokenByAccount(ISuperToken _token, string[] memory _recipients, int96[] memory _flowRates) external onlyOwner {
        for (uint256 i = 0; i < _recipients.length; i++) {
            address recipient = nick2addrs[_recipients[i]];
            if(address(0) != recipient) {
                _token.createFlow(recipient, _flowRates[i]);
            }
        }
            
    }

    /// @notice batch update flow by address.
    /// @param _token address for SuperToken.
    /// @param _recipients account list.
    /// @param _flowRates rate list.
    function batchUpdateFlow(ISuperToken _token, address[] memory _recipients, int96[] memory _flowRates) external onlyOwner {
        for (uint256 i = 0; i < _recipients.length; i++) {
            _token.updateFlow(_recipients[i], _flowRates[i]);
        }  
    }

    /// @notice batch update flow by account.
    /// @param _token address for SuperToken.
    /// @param _recipients account list.
    /// @param _flowRates rate list.
    function batchUpdateFlowbyAccount(ISuperToken _token, string[] memory _recipients, int96[] memory _flowRates) external onlyOwner {
        for (uint256 i = 0; i < _recipients.length; i++) {
            address recipient = nick2addrs[_recipients[i]];
            if(address(0) != recipient) {
                _token.updateFlow(recipient, _flowRates[i]);
            }
        }
            
    }

    /// @notice Update flow from contract to specified address.
    /// @param _token address for SuperToken.
    /// @param _receiver Receiver of stream.
    /// @param _flowRate Flow rate per second to stream.
    function updateFlow(
        ISuperToken _token, 
        address _receiver,
        int96 _flowRate
    ) external onlyOwner {

        _token.updateFlow(_receiver, _flowRate);
    }

    /// @notice Update flow from contract to specified address.
    /// @param _token address for SuperToken.
    /// @param _account Receiver of stream.
    /// @param _flowRate Flow rate per second to stream.
    function updateFlowByAccount(
        /// @param _token address for SuperToken.
        ISuperToken _token, 
        string memory _account,
        int96 _flowRate
    ) external onlyOwner {
        require(nick2addrs[_account] != address(0), "account does's exists");
        _token.updateFlow(nick2addrs[_account], _flowRate);
    }

    /// @notice Withdraw funds from the contract.
    /// @param _token address for SuperToken.
    /// @param amount Amount to withdraw.
    function withdrawFunds(ISuperToken _token, uint256 amount) external  {
        _token.transfer(owner, amount);
    }

    /// @notice Withdraw funds from the contract.
    /// @param _token address for SuperToken.
    function withdrawFunds(ISuperToken _token) external  {
        uint256 amount = _token.balanceOf(address(this));
        _token.transfer(owner, amount);
    }
}
