// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

// Uncomment this line to use console.log
// import "hardhat/console.sol";

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

import "./Pvc.sol";

error InvalidState(string message);
error AlreadyRegistered();
error InvalidProof();
error AlreadyVoted();
error InvalidCandidateId();
error NoPVC();

contract Voting is Ownable(msg.sender) {
    Pvc public PVC;
    bytes32 public whiteListMerkleRoot;
    enum ElectionState {
        Registration,
        Voting,
        Ended
    }
    ElectionState public electionState;

    struct Candidate {
        string name;
        uint256 voteCount;
    }

    uint256 public candidatesCount;
    mapping(uint256 => Candidate) public candidates;

    mapping(address => bool) public hasVoted;
    mapping(uint256 => uint256) public votes; // Candidate ID -> Vote count

    event Voted(address indexed voter, uint256 candidateId);
    event VoteCast(address indexed voter, uint256 candidateId);
    event CandidateAdded(uint256 candidateId, string name);
    event ElectionStateChanged(ElectionState state);

    constructor(address _PVCContract, bytes32 _whiteListMerkleRoot) {
        PVC = Pvc(_PVCContract);
        PVC.updateOwner(address(this));
        whiteListMerkleRoot = _whiteListMerkleRoot;
    }

    function startRegistration() external onlyOwner {
        // use if statements instead of require to emit custom error messages
        if (electionState != ElectionState.Ended) {
            revert InvalidState("Election is not in the Ended state");
        }

        electionState = ElectionState.Registration;

        emit ElectionStateChanged(electionState);
    }

    function startVoting() external onlyOwner {
        // use if statements instead of require to emit custom error messages
        if (electionState != ElectionState.Registration) {
            revert InvalidState("Election is not in the Registration state");
        }

        electionState = ElectionState.Voting;

        emit ElectionStateChanged(electionState);
    }

    function endElection() external onlyOwner {
        // if statements instead of require to emit custom error messages
        if (electionState != ElectionState.Voting) {
            revert InvalidState("Election is not in the Voting state");
        }

        electionState = ElectionState.Ended;

        emit ElectionStateChanged(electionState);
    }

    function addCandidate(string memory _name) external onlyOwner {
        candidates[candidatesCount] = Candidate(_name, 0);
        emit CandidateAdded(candidatesCount, _name);
        candidatesCount++;
    }

    function register(bytes32[] memory _proof) public {
        // check if the election is in the Registration state
        if (electionState != ElectionState.Registration) {
            revert InvalidState("Election is not in the Registration state");
        }

        // check if the sender has not registered before
        if (PVC.balanceOf(msg.sender) != 0) {
            revert AlreadyRegistered();
        }

        // check if the proof is valid
        if (
            !MerkleProof.verify(
                _proof,
                whiteListMerkleRoot,
                keccak256(abi.encodePacked(msg.sender))
            )
        ) {
            revert InvalidProof();
        }

        PVC.issuePVC(msg.sender);
    }

    function vote(uint256 _candidateId, bytes32[] memory _proof) external {
        if (electionState != ElectionState.Voting) {
            revert InvalidState("Election is not in the Voting state");
        }
        if (hasVoted[msg.sender]) {
            revert AlreadyVoted();
        }
        if (PVC.balanceOf(msg.sender) == 0) {
            revert NoPVC();
        }
        if (_candidateId >= candidatesCount) {
            revert InvalidCandidateId();
        }

        if (
            !MerkleProof.verify(
                _proof,
                whiteListMerkleRoot,
                keccak256(abi.encodePacked(msg.sender))
            )
        ) {
            revert InvalidProof();
        }

        candidates[_candidateId].voteCount++;
        hasVoted[msg.sender] = true;

        emit Voted(msg.sender, _candidateId);
    }

    function showAllResults() external view returns (Candidate[] memory) {
        if (electionState != ElectionState.Ended) {
            revert InvalidState("Election is not in the Ended state");
        }

        Candidate[] memory results = new Candidate[](candidatesCount);
        for (uint256 i = 0; i < candidatesCount; i++) {
            results[i] = candidates[i];
        }
        return results;
    }

    function getResults(
        uint256 _candidateId
    ) external view returns (string memory, uint256) {
        if (_candidateId >= candidatesCount) {
            revert InvalidCandidateId();
        }
        if (electionState != ElectionState.Ended) {
            revert InvalidState("Election is not in the Ended state");
        }

        Candidate memory candidate = candidates[_candidateId];
        return (candidate.name, candidate.voteCount);
    }
}
