//SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;
contract Score {
    mapping(address => uint8) scores;
    address teacher;

    constructor(address _teacher) {
        teacher = _teacher;
    }

    modifier onlyTeacher() {
        require(msg.sender == teacher);
        _;
    }

    // error可以减少gas的使用
    error ScoreOutOfRange();

    function setScore(address _studentAddr, uint8 _score) external onlyTeacher {
        if (_score>100) {
            revert ScoreOutOfRange();
        }
        scores[_studentAddr] = _score;
    }

    function getScore(address _studentAddr) external view returns (uint8) {
        return scores[_studentAddr];
    }
}

interface IScore {
    function setScore(address _studentAddr, uint8 _score) external;
}

contract Teacher {
    function setStudentScore(address _scoreAddr, address _studentAddr, uint8 _score) public {
        IScore(_scoreAddr).setScore(_studentAddr, _score);
    }
}

contract NotTeacher {
    function setStudentScore(address _scoreAddr, address _studentAddr, uint8 _score) public {
        IScore(_scoreAddr).setScore(_studentAddr, _score);
    }
}