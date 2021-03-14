pragma solidity ^0.4.0;
contract Ballot {

    struct Voter {
        uint weight;
        bool voted;
        uint8 vote;
       // address delegate;
    }
    struct Proposal {
        uint voteCount; // could add other data about proposal
    }
    
    enum Stage {init, reg, vote, done}
    Stage public stage= Stage.init;
    
    uint startTime;

    address chairperson;
    mapping(address => Voter) voters;
    Proposal[] proposals;
    string public msgg ;
    
    modifier validStage(Stage reqStage){
        require(stage == reqStage);
        _;
    }
    
    

    /// Create a new ballot with $(_numProposals) different proposals.
    function Ballot(uint8 _numProposals) public {
        chairperson = msg.sender;
        voters[chairperson].weight = 1;
        proposals.length = _numProposals; 
        stage= Stage.reg;
        startTime=now;
        
    }

    /// Give $(toVoter) the right to vote on this ballot.
    /// May only be called by $(chairperson).
    function register(address toVoter) public validStage(Stage.reg) returns(string) {
         if (now > (startTime + 20 seconds)) {
            stage = Stage.vote;
            startTime=now;
            msgg="Time exccedd for register!";
            return msgg;
        }
       
       // if (stage != Stage.reg){return ;}
        if (msg.sender != chairperson || voters[toVoter].voted) return;
        voters[toVoter].weight = 1;
        voters[toVoter].voted = false;
        
       
    }

    /// Give a single vote to proposal $(toProposal).
    function vote(uint8 toProposal) public validStage(Stage.vote) {
       // if (stage != Stage.vote){return;}
        Voter storage sender = voters[msg.sender];
        if (sender.voted || toProposal >= proposals.length) return;
        sender.voted = true;
        sender.vote = toProposal;
        proposals[toProposal].voteCount += sender.weight;
        
        if (now > (startTime + 10 seconds)) {
            stage = Stage.done;
            startTime=now;
        }
    }

    function winningProposal() public validStage(Stage.done) constant returns (uint8 _winningProposal) {
        //if (stage != Stage.done){return;}
        uint256 winningVoteCount = 0;
        for (uint8 prop = 0; prop < proposals.length; prop++)
            if (proposals[prop].voteCount > winningVoteCount) {
                winningVoteCount = proposals[prop].voteCount;
                _winningProposal = prop;
                assert (_winningProposal>0);
            }
    }
}
 
