// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract MyToken is ERC20, Ownable {
    constructor() ERC20("OzToken", "TOZ") {
        _mint(msg.sender, 1000 * 10 ** decimals());
    }
}

contract MyNFT is ERC721, Ownable {
    uint256 public tokenCounter;

    constructor() ERC721("OzNFT", "NOZ") Ownable() {
        tokenCounter = 0;
    }

    function mintNFT(address to) public onlyOwner returns (uint256) {
        uint256 newTokenId = tokenCounter;
        _safeMint(to, newTokenId);
        tokenCounter += 1;
        return newTokenId;
    }
}

contract TokenManager is Ownable {
    MyToken public erc20Token;
    MyNFT public erc721Token;
    uint256 public constant MINT_THRESHOLD = 5 * 10 ** 18; // 5 tokens (considerando 18 casas decimais padrão)

    event ERC20Received(address from, uint256 amount);
    event ERC721Minted(address to, uint256 tokenId);

    constructor(address _erc20Token, address _erc721Token) {
        erc20Token = MyToken(_erc20Token);
        erc721Token = MyNFT(_erc721Token);
    }

    function onERC20Received(address from, uint256 amount) external {
        require(msg.sender == address(erc20Token), "Only ERC20 token contract can call this function");
        require(amount >= MINT_THRESHOLD, "Insufficient ERC20 tokens sent");

        // Mint new ERC721 token and transfer to the sender
        uint256 newTokenId = erc721Token.mintNFT(from);
        emit ERC721Minted(from, newTokenId);
    }

    function transferERC20ToContract(uint256 amount) external {
        require(amount >= MINT_THRESHOLD, "Minimum 5 ERC20 tokens required");
        erc20Token.transferFrom(msg.sender, address(this), amount);
        onERC20Received(msg.sender, amount);
    }
}
