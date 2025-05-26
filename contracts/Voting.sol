// SPDX-License-Identifier: MIT
// pragma solidity >=0.4.22 <0.9.0;

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Voting {
    // Struct to store voter information
    struct Voter {
        bool hasVoted; // Tracks if voter has cast a vote
        string voterId; // Hashed voter ID for anonymity
    }

    // Struct to store candidate information
    struct Candidate {
        string name;
        uint256 voteCount;
    }

    // State variables
    address public admin; // Election administrator
    mapping(string => Voter) public voters; // Maps voterId to Voter struct
    mapping(uint256 => Candidate) public candidates; // Maps candidate ID to Candidate
    uint256 public candidateCount; // Number of candidates
    bool public votingActive; // Election status

    // Events for logging
    event VoterRegistered(string voterId);
    event VoteCast(string voterId, uint256 candidateId);
    event CandidateAdded(uint256 candidateId, string name);
    event VotingStarted();
    event VotingEnded();

    // Modifier to restrict access to admin
    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can perform this action");
        _;
    }

    // Modifier to check if voting is active
    modifier votingIsActive() {
        require(votingActive, "Voting is not active");
        _;
    }

    // Constructor to initialize admin
    constructor() {
        admin = msg.sender;
        votingActive = false;
    }

    // Add a candidate (admin only)
    function addCandidate(string memory _name) public onlyAdmin {
        candidates[candidateCount] = Candidate(_name, 0);
        emit CandidateAdded(candidateCount, _name);
        candidateCount++;
    }

    // Register a voter
    function registerVoter(string memory _voterId) public onlyAdmin {
        require(!voters[_voterId].hasVoted, "Voter already registered");
        voters[_voterId] = Voter(false, _voterId);
        emit VoterRegistered(_voterId);
    }

    // Cast a vote
    function castVote(string memory _voterId, uint256 _candidateId) public votingIsActive {
        require(!voters[_voterId].hasVoted, "Voter has already voted");
        require(_candidateId < candidateCount, "Invalid candidate ID");
        
        voters[_voterId].hasVoted = true;
        candidates[_candidateId].voteCount++;
        
        emit VoteCast(_voterId, _candidateId);
    }

    // Start voting (admin only)
    function startVoting() public onlyAdmin {
        require(!votingActive, "Voting is already active");
        votingActive = true;
        emit VotingStarted();
    }

    // End voting (admin only)
    function endVoting() public onlyAdmin {
        require(votingActive, "Voting is not active");
        votingActive = false;
        emit VotingEnded();
    }

    // Get candidate details
    function getCandidate(uint256 _candidateId) public view returns (string memory name, uint256 voteCount) {
        require(_candidateId < candidateCount, "Invalid candidate ID");
        Candidate memory candidate = candidates[_candidateId];
        return (candidate.name, candidate.voteCount);
    }

    // Get election status
    function getVotingStatus() public view returns (bool) {
        return votingActive;
    }
}