// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract EventXAirDrop is ERC721, ERC721Enumerable, Ownable {
    bool public _isActive;
    uint public nextTokenId;
    using Strings for uint256;
    // Optional mapping for token URIs
    mapping (uint256 => string) private _tokenURIs;
    // Base URI
    string private _baseURIextended;
    
    constructor() ERC721("EventX", "EVX") {
        _isActive = true;
    }

    modifier contractRunning() {
        require(_isActive == true);
        _;
    }

    function setBaseURI(string memory baseURI_) external onlyOwner() {
        _baseURIextended = baseURI_;
    }
    
    function _setTokenURI(uint256 tokenId, string memory _tokenURI) internal virtual {
        require(_exists(tokenId), "ERC721Metadata: URI set of nonexistent token");
        _tokenURIs[tokenId] = _tokenURI;
    }
    
    function _baseURI() internal view virtual override returns (string memory) {
        return _baseURIextended;
    }
    
    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");

        string memory _tokenURI = _tokenURIs[tokenId];
        string memory base = _baseURI();
        
        // If there is no base URI, return the token URI.
        if (bytes(base).length == 0) {
            return _tokenURI;
        }
        // If both are set, concatenate the baseURI and tokenURI (via abi.encodePacked).
        if (bytes(_tokenURI).length > 0) {
            return string(abi.encodePacked(base, _tokenURI));
        }
        // If there is a baseURI but no tokenURI, concatenate the tokenID to the baseURI.
        return string(abi.encodePacked(base, tokenId.toString()));
    }
    
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal override(ERC721, ERC721Enumerable) {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721Enumerable)
        returns (bool) {
        return super.supportsInterface(interfaceId);
    }

    function safeMint(address to, uint quantity, string[] memory tokenURI_) public onlyOwner contractRunning {
        for(uint i = 0; i < quantity; i++){
            _safeMint(to, nextTokenId);
            _setTokenURI(nextTokenId, tokenURI_[i]);
            nextTokenId++;
        }
    }
    
  
    function onOffSwitch() public onlyOwner {
        _isActive = !_isActive;
    }

    function getContractState() public view returns (bool) {
        return _isActive;
    }
}
