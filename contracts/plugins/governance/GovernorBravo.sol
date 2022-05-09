// SPDX-License-Identifier: BlueOak-1.0.0
pragma solidity 0.8.9;

import "@openzeppelin/contracts/governance/compatibility/GovernorCompatibilityBravo.sol";
import "@openzeppelin/contracts/governance/extensions/GovernorTimelockControl.sol";
import "@openzeppelin/contracts/governance/extensions/GovernorVotes.sol";
import "@openzeppelin/contracts/governance/extensions/GovernorVotesQuorumFraction.sol";
import "@openzeppelin/contracts/governance/Governor.sol";

/*
 * @title Governance
 * @dev Decentralized Governance for the Reserve Protocol.
 */
contract Governance is
    Governor,
    GovernorVotes,
    GovernorVotesQuorumFraction,
    GovernorCompatibilityBravo,
    GovernorTimelockControl
{
    uint256 public immutable _votingDelay;
    uint256 public immutable _votingPeriod;

    // TODO: Swap out ERC20Votes with our own custom InsurancePoolVotes. It should contain the
    // functionality for both GovernorVotes + GovernorVotesQuorumFraction, and intimately
    // the details of the InsurancePool.
    constructor(
        IVotes token_,
        TimelockController timelock_,
        uint256 votingDelay_, // in blocks
        uint256 votingPeriod_, // in blocks
        uint256 quorumPercent // e.g 4 for 4%
    )
        Governor("MyGovernor")
        GovernorVotes(token_)
        GovernorVotesQuorumFraction(quorumPercent)
        GovernorTimelockControl(timelock_)
    {
        _votingDelay = votingDelay_;
        _votingPeriod = votingPeriod_;
    }

    function votingDelay() public view override returns (uint256) {
        return _votingDelay;
    }

    function votingPeriod() public view override returns (uint256) {
        return _votingPeriod;
    }

    // Do we want a proposal threshold?
    // function proposalThreshold() public pure override returns (uint256) {
    //     // TODO: Integrate with InsurancePoolVotes
    //     return 0e18;
    // }

    function state(uint256 proposalId)
        public
        view
        override(IGovernor, Governor, GovernorTimelockControl)
        returns (ProposalState)
    {
        return GovernorTimelockControl.state(proposalId);
    }

    function propose(
        address[] memory targets,
        uint256[] memory values,
        bytes[] memory calldatas,
        string memory description
    ) public override(IGovernor, Governor, GovernorCompatibilityBravo) returns (uint256) {
        return GovernorCompatibilityBravo.propose(targets, values, calldatas, description);
    }

    function _execute(
        uint256 proposalId,
        address[] memory targets,
        uint256[] memory values,
        bytes[] memory calldatas,
        bytes32 descriptionHash
    ) internal override(Governor, GovernorTimelockControl) {
        // TODO: Maybe require sufficient stake here too?
        GovernorTimelockControl._execute(proposalId, targets, values, calldatas, descriptionHash);
    }

    function _cancel(
        address[] memory targets,
        uint256[] memory values,
        bytes[] memory calldatas,
        bytes32 descriptionHash
    ) internal override(Governor, GovernorTimelockControl) returns (uint256) {
        return GovernorTimelockControl._cancel(targets, values, calldatas, descriptionHash);
    }

    function _executor()
        internal
        view
        override(Governor, GovernorTimelockControl)
        returns (address)
    {
        return GovernorTimelockControl._executor();
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(Governor, IERC165, GovernorTimelockControl)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}