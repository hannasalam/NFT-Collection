// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./IWhitelist.sol";

contract CryptoDevs is ERC721Enumerable, Ownable{

    string _baseTokenURI;
    IWhitelist whitelist;
    uint256 public maxNFT = 20;
    uint256 public currentNumberOfNFT;
    bool public presaleStarted;
    uint256 public presaleEndTime;
    uint256 public presaleRate = 0.005 ether;
    uint256 public normalRate = 0.01 ether;
    bool _paused;

    modifier onlyWhenNotPaused{
        require(!_paused,"Contract currently paused");
        _;
    }
    constructor( string memory baseURI, address whitelistContract) ERC721("Crypto Devs", "CD")
    {
        _baseTokenURI = baseURI;
        whitelist = IWhitelist(whitelistContract);
    }

    function startPresale() public onlyOwner{
        presaleStarted = true;
        presaleEndTime = block.timestamp+ 5 minutes;
    }

    function presaleMint() public payable onlyWhenNotPaused{
        require(presaleStarted && block.timestamp< presaleEndTime, "Presale has not started");
        require(whitelist.whitelistedAddresses(msg.sender),"You are not whitelisted");
        require(currentNumberOfNFT<maxNFT, "Exceeded maximum supply");
        require(msg.value>= presaleRate, "Not enough ethers");
        currentNumberOfNFT+=1;
        _safeMint(msg.sender, currentNumberOfNFT);
    }

    function mint() public payable onlyWhenNotPaused{
        require(presaleStarted && block.timestamp>=presaleEndTime, "Presale has not started");
        require(currentNumberOfNFT<maxNFT, "Exceeded maximum supply");
        require(msg.value>= normalRate, "Not enough ethers");
        currentNumberOfNFT+=1;
        _safeMint(msg.sender, currentNumberOfNFT);
    }
    function _baseURI() internal view virtual override returns(string memory){
        return _baseTokenURI;
    }

    function setPaused(bool val) public onlyOwner{
        _paused = val;
    }

    function withdraw() public onlyOwner{
        address _owner = owner();
        uint256 amount = address(this).balance;
        (bool sent, ) = _owner.call{value:amount}("");
        require(sent, "Failed to send Ether");
    }
    receive() external payable {}
    fallback() external payable {}
}