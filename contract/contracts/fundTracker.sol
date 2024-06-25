// SPDX-License-Identifier: MIT
// Contract deployed at: 0x4ffA1214E86aAf79B73a31f0c9037728c8167eC9
pragma solidity ^0.8.0;

contract GovernmentFundTracking {
    address public governmentAgency;
    address public auditor;

    enum ProposalStatus { Pending, Approved, Rejected }

    struct Project {
        string name;
        uint totalAllocated;
    }

    struct Proposal {
        uint id;
        address payable implementingAgency;
        uint amountRequested;
        ProposalStatus status;
    }

    uint public projectCount;
    uint public proposalCount;

    mapping(uint => Project) public projects;
    mapping(uint => Proposal) public proposals;

    modifier onlyGovernmentAgency() {
        require(msg.sender == governmentAgency, "Only the government agency can perform this action");
        _;
    }

    modifier onlyAuditor() {
        require(msg.sender == auditor, "Only the auditor can perform this action");
        _;
    }

    event ProjectInitiated(uint projectId, string name);
    event ProposalSubmitted(uint proposalId, uint projectId, address implementingAgency, uint amountRequested);
    event ProposalReviewed(uint proposalId, ProposalStatus status);
    event FundsAllocated(uint proposalId, uint amountAllocated);

    constructor() {
        governmentAgency = msg.sender;
    }

    function setAuditor(address _auditor) external onlyGovernmentAgency {
        auditor = _auditor;
    }

    function initiateProject(string memory _name) external onlyGovernmentAgency {
        projectCount++;
        projects[projectCount] = Project(_name, 0);
        emit ProjectInitiated(projectCount, _name);
    }

    function submitProposal(uint _projectId, uint _amountRequested) external {
        require(_projectId > 0 && _projectId <= projectCount, "Invalid project ID");
        proposalCount++;
        proposals[proposalCount] = Proposal(_projectId, payable(msg.sender), _amountRequested, ProposalStatus.Pending);
        emit ProposalSubmitted(proposalCount, _projectId, msg.sender, _amountRequested);
    }

    function reviewProposal(uint _proposalId, ProposalStatus _status) external onlyGovernmentAgency {
        Proposal storage proposal = proposals[_proposalId];
        require(proposal.status == ProposalStatus.Pending, "Proposal already reviewed");
        proposal.status = _status;
        emit ProposalReviewed(_proposalId, _status);
    }

    function allocateFunds(uint _proposalId) external onlyGovernmentAgency {
        Proposal storage proposal = proposals[_proposalId];
        require(proposal.status == ProposalStatus.Approved, "Proposal not approved");
        Project storage project = projects[proposal.id];
        project.totalAllocated += proposal.amountRequested;
        proposal.implementingAgency.transfer(proposal.amountRequested);
        emit FundsAllocated(_proposalId, proposal.amountRequested);
    }

    function viewProposal(uint _proposalId) external view returns (Proposal memory) {
        return proposals[_proposalId];
    }

    function viewTransactionRecords(uint _projectId) external view onlyAuditor returns (Project memory) {
        return projects[_projectId];
    }
}
