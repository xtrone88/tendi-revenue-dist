// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./KILLAzInterface.sol";

contract Revenue is Ownable {
    // 0x21850dcfe24874382b12d05c5b189f5a2acf0e5b
    address private immutable KILLAz;
    // 0xe4d0e33021476ca05ab22c8bf992d3b013752b80
    address private immutable LadyKILLAz;

    uint256 private startTime;
    uint256 private endTime;

    mapping(uint256 => uint256) private usedMales;
    mapping(uint256 => uint256) private usedFeMales;
    mapping(address => uint256) private revenues;

    constructor(address _KILLAz, address _LadyKILLAz) {
        KILLAz = _KILLAz;
        LadyKILLAz = _LadyKILLAz;
    }

    event Claimed(uint256 share, uint256 amount);
    event Withrawn(uint256 amount, uint256 balance);

    /**
     * Set the pre-determined period in seconds since right now when you are owner.
     */
    function setStart(uint256 inSeconds) public onlyOwner {
        startTime = block.timestamp;
        endTime = block.timestamp + inSeconds;
    }

    /**
     * Claim the share proportional to the total of supplied male and female tokens according to the restricted condition
     */
    function claimShare() public {
        require(endTime >= block.timestamp, "Revenue period isn't started");

        // get available male tokens
        (uint256 malesT, uint256 males, uint256[] memory maleIds) = getPairsOf(
            KILLAz,
            msg.sender
        );
        require(males > 0, "You don't have any token pairs");

        // get available female tokens
        (
            uint256 femalesT,
            uint256 females,
            uint256[] memory femaleIds
        ) = getPairsOf(LadyKILLAz, msg.sender);
        require(females > 0, "You don't have any token pairs");

        // choose less value between male and female's count as pairs
        uint256 pairsT = malesT > femalesT ? femalesT : malesT;
        uint256 pairs = males > females ? females : males;

        // calculate share and amount proportional to the total pairs
        uint256 share = (pairs * 10000000000) / pairsT;
        uint256 amount = (address(this).balance * share) / 10000000000;
        
        // set the timestamp when NFT is used as a pair in this period
        while (pairs > 0) {
            pairs--;
            usedMales[maleIds[pairs]] = block.timestamp;
            usedFeMales[femaleIds[pairs]] = block.timestamp;
        }
        revenues[msg.sender] += amount;

        emit Claimed(share, amount);
    }

    function getPairsOf(address nft, address from)
        public
        view
        returns (
            uint256,
            uint256,
            uint256[] memory
        )
    {
        uint256 balance = KILLAzInterface(nft).balanceOf(from);
        require(balance > 0, "You don't have any token pairs");

        uint256[] memory tokenIds = new uint256[](balance);
        uint256 total = KILLAzInterface(nft).totalSupply();
        uint256 length = 0;

        while (balance > 0) {
            balance--;
            uint256 tokenId = KILLAzInterface(nft).tokenOfOwnerByIndex(
                from,
                balance
            );
            // check if it is approved to other's
            if (KILLAzInterface(nft).getApproved(tokenId) != address(0)) {
                continue;
            }
            // check if it is used in the past in this period
            if (nft == KILLAz && usedMales[tokenId] > startTime) {
                continue;
            }
            if (nft == LadyKILLAz && usedFeMales[tokenId] > startTime) {
                continue;
            }
            tokenIds[length] = tokenId;
            length++;
        }

        return (total, length, tokenIds);
    }

    /**
     * get the revenue's balance of account
     */
    function balanceOf(address from) public view returns (uint256) {
        return revenues[from];
    }

    /**
     * withraw revenue of argumented amount
     */
    function withrawShare(uint256 amount) public {
        require(
            address(this).balance >= amount && revenues[msg.sender] >= amount,
            "Requested amount exceeds the balance"
        );
        revenues[msg.sender] -= amount;
        payable(msg.sender).transfer(amount);

        emit Withrawn(amount, revenues[msg.sender]);
    }

    receive() external payable {}
}
