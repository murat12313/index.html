// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title  SnakeLeaderboard
 * @notice On-chain top-10 leaderboard for Snake Neon Edition – Base Network
 * @dev    Deploy on Base Mainnet (chainId 8453) via Remix IDE
 */
contract SnakeLeaderboard {

    // ── Data ─────────────────────────────────────────────────────────────────
    struct ScoreEntry {
        address player;
        string  nickname;
        uint256 score;
        uint256 timestamp;
    }

    uint256 public constant MAX_ENTRIES = 10;

    ScoreEntry[] private _board;

    mapping(address => uint256) public bestScore;
    mapping(address => string)  public playerNickname;

    // ── Events ────────────────────────────────────────────────────────────────
    event ScoreSubmitted(address indexed player, string nickname, uint256 score);

    // ── Write ─────────────────────────────────────────────────────────────────
    /**
     * @notice Submit (or update) your high score.
     *         Reverts if the new score is not higher than your existing best.
     */
    function submitScore(string calldata nickname, uint256 score) external {
        require(score > 0,                                                "Score must be > 0");
        require(bytes(nickname).length >= 1 && bytes(nickname).length <= 20, "Nickname: 1-20 chars");
        require(score > bestScore[msg.sender],                            "Not a new high score");

        bestScore[msg.sender]      = score;
        playerNickname[msg.sender] = nickname;

        // Remove old entry for this player (if any)
        for (uint256 i = 0; i < _board.length; i++) {
            if (_board[i].player == msg.sender) {
                _board[i] = _board[_board.length - 1];
                _board.pop();
                break;
            }
        }

        // Append new entry
        _board.push(ScoreEntry(msg.sender, nickname, score, block.timestamp));

        // Bubble up to maintain descending order
        uint256 j = _board.length - 1;
        while (j > 0 && _board[j].score > _board[j - 1].score) {
            ScoreEntry memory tmp = _board[j];
            _board[j]     = _board[j - 1];
            _board[j - 1] = tmp;
            j--;
        }

        // Trim to MAX_ENTRIES
        if (_board.length > MAX_ENTRIES) _board.pop();

        emit ScoreSubmitted(msg.sender, nickname, score);
    }

    // ── Read ──────────────────────────────────────────────────────────────────
    function getLeaderboard() external view returns (ScoreEntry[] memory) {
        return _board;
    }

    function getLeaderboardLength() external view returns (uint256) {
        return _board.length;
    }
}
