// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./KILLAzInterface.sol";

contract Revenue is Ownable {

  // 0x21850dcfe24874382b12d05c5b189f5a2acf0e5b
  ERC721 private immutable KILLAz;
  // 0xe4d0e33021476ca05ab22c8bf992d3b013752b80
  ERC721 private immutable LadyKILLAz;

  address private immutable OpenSea;

  uint256 private startTime;
  uint256 private endTime;

  mapping(uint256 => uint256) private usedMales;
  mapping(uint256 => uint256) private usedFeMales;
  mapping(address => uint256) private revenues;

  constructor(address _KILLAz, address _LadyKILLAz, address _OpenSea) {
    KILLAz = ERC721(_KILLAz);
    LadyKILLAz = ERC721(_LadyKILLAz);
    OpenSea = _OpenSea;
  }

  function setPeriod(uint256 inSeconds) public onlyOwner {
    startTime = block.timestamp;
    endTime = block.timestamp + inSeconds;
  }

  function claimShare() public returns (uint256, uint256) {
    (uint256 malesT, uint256 males, uint256[] memory maleIds) = getPairsOf(KILLAz, msg.sender);
    require(males > 0, "You don't have any token pairs");

    (uint256 femalesT, uint256 females, uint256[] memory femaleIds) = getPairsOf(LadyKILLAz, msg.sender);
    require(females > 0, "You don't have any token pairs");

    uint256 pairsT = malesT > femalesT ? femalesT : malesT;
    uint256 pairs = males > females ? females : males;
    
    while (pairs > 0) {
      pairs--;
      usedMales[maleIds[pairs]] = block.timestamp;
      usedFeMales[femaleIds[pairs]] = block.timestamp;
    }
    
    uint256 share = pairs / pairsT * 100;
    uint256 amount = address(this).balance / 100 * share;
    revenues[msg.sender] += amount;
    return (share, amount);
  }

  function getPairsOf(ERC721 nft, address from) private view returns (uint256, uint256, uint256[] memory) {
    uint256 balance = nft.balanceOf(from);
    require(balance > 0, "You don't have any token pairs");

    uint256[] memory tokenIds = new uint256[](balance);
    uint256 total = 0;
    uint256 index = 0;

    for (uint256 tokenId = 1; tokenId < nft.totalSupply(); tokenId++) {
      if (nft.getApproved(tokenId) == OpenSea) {
        continue;
      }
      total++;
      if (nft.ownerOf(tokenId) == msg.sender) {
        if (nft == KILLAz && usedMales[tokenId] > startTime) {
          continue;
        }
        if (nft == LadyKILLAz && usedFeMales[tokenId] > startTime) {
          continue;
        }
        tokenIds[index] = tokenId;
        index++;
      }
    }

    return (total, index, tokenIds);
  }

  function withrawShare(uint256 amount) public returns (bool) {
    require(address(this).balance > amount && revenues[msg.sender] > amount, "Requested amount exceeds the balance");
    revenues[msg.sender] -= amount;
    payable(msg.sender).transfer(amount);
    return true;
  }
}
