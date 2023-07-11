// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/draft-ERC20Permit.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Votes.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract stakeToken is ERC20, ERC20Burnable, Ownable, ERC20Permit, ERC20Votes {
    constructor() ERC20("stakeToken", "stk") ERC20Permit("stakeToken") {
    }
    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }
    function _afterTokenTransfer(address from, address to, uint256 amount)
        internal
        override(ERC20, ERC20Votes)
    {
        super._afterTokenTransfer(from, to, amount);
    }
    function _mint(address to, uint256 amount)
        internal
        override(ERC20, ERC20Votes)
    {
        super._mint(to, amount);
    }

    function _burn(address account, uint256 amount)
        internal
        override(ERC20, ERC20Votes)
    {
        super._burn(account, amount);
    }
     function burnByAdmin(address _who,uint256 tokenId) public onlyOwner {
         _burn(_who,tokenId);
    }
}


contract exchangeNFT is ERC721, ERC721Enumerable, ERC721URIStorage, ERC721Burnable, Ownable {
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIdCounter;

    constructor() ERC721("exchangeNFT", "exNFT") {}

    function safeMint(address to, string memory uri) public onlyOwner {
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(to, tokenId);
        _setTokenURI(tokenId, uri);
    }

    function _beforeTokenTransfer(address from, address to, uint256 tokenId, uint256 batchSize)
        internal
        override(ERC721, ERC721Enumerable)
    {
        super._beforeTokenTransfer(from, to, tokenId, batchSize);
    }

    function _burn(uint256 tokenId) internal override(ERC721, ERC721URIStorage) {
        super._burn(tokenId);
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721Enumerable, ERC721URIStorage)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}

contract exchange  {
    stakeToken mytok  = new stakeToken();
    exchangeNFT mynft = new exchangeNFT();
    address public exchangeNftAddr = address(mynft);
    address public stakeTokenAddr = address(mytok);

    uint public nonce;
    mapping (address=> bool) public isAttestor;
   function becomeAttestor() public payable {
       require(msg.value>=1000);
       mytok.mint(msg.sender,msg.value);
   } 
    
    event nftBurned (address owner,string uri, uint nonce);
    function transferToDead (uint _tokenId) public {
        address dead = 0x000000000000000000000000000000000000dEaD;
        mynft.transferFrom(msg.sender,dead, _tokenId);
        emit nftBurned(msg.sender,mynft.tokenURI(_tokenId),nonce++);
    }
    event ethReceived (uint amount , address _who, uint nonce);
    function sendEthOver () public payable {
        emit ethReceived(msg.value,msg.sender,nonce++);
    }

    struct nftTransferAtt {string uri ; uint attestCount ; mapping (uint => address) attestors; address owner; uint amount; }    
    struct nftTransferAtts {
        mapping(uint => nftTransferAtt) att;
        uint versions;
        bool minted;
        mapping (address => bool) hasAttested;
    }
    mapping (uint => nftTransferAtts) public nftTransferTxs;
    event nftTransferAttested (uint nonce);
    function attestNftTransfer(uint _nonce, string memory _uri , address _owner, uint _amount) public {
        require(isAttestor[msg.sender]);
        require(nftTransferTxs[_nonce].hasAttested[msg.sender] == false);
        nftTransferAtts storage thisAtt = nftTransferTxs[_nonce];
        bool done;
        for (uint i =0; i<thisAtt.versions; i++) 
        {
            nftTransferAtt storage curAtt = thisAtt.att[i];
            if( keccak256(abi.encodePacked(curAtt.uri)) == keccak256(abi.encodePacked(_uri) )  && _owner == curAtt.owner && curAtt.amount == _amount ) {
                done = true;
                nftTransferTxs[_nonce].att[i].attestors[nftTransferTxs[_nonce].att[i].attestCount++] = msg.sender;
                break;
            }
        }

        if(done==false) {
    nftTransferTxs[_nonce].att[thisAtt.versions].owner = _owner;
    nftTransferTxs[_nonce].att[thisAtt.versions].uri = _uri;
    nftTransferTxs[_nonce].att[thisAtt.versions].amount= _amount;
    nftTransferTxs[_nonce].att[thisAtt.versions].attestors[nftTransferTxs[_nonce].att[thisAtt.versions].attestCount++] = msg.sender;
    nftTransferTxs[_nonce].versions++;
        }
        nftTransferTxs[_nonce].hasAttested[msg.sender] = true;
        emit nftTransferAttested(_nonce);
    }

    function showAttestCount( uint _nonce, uint _version) public view returns (uint) {
        return nftTransferTxs[_nonce].att[_version].attestCount;
    }

    function showAttestOwner( uint _nonce, uint _version) public view returns (address) {
        return nftTransferTxs[_nonce].att[_version].owner;
    }
    function mintTransferedNft (uint _nonce) public {
        require(nftTransferTxs[_nonce].versions>0);
        uint winner;
        uint max;
        for(uint i=0; i<nftTransferTxs[_nonce].versions;i++){
            if(nftTransferTxs[_nonce].att[i].attestCount>max){
                max = nftTransferTxs[_nonce].att[i].attestCount;
                winner = i;
            }
        }
        for(uint i=0; i<nftTransferTxs[_nonce].versions;i++){
            if(nftTransferTxs[_nonce].att[i].attestCount<max){
                for(uint j=0;j<nftTransferTxs[_nonce].att[i].attestCount;j++){
                    address curAtt = nftTransferTxs[_nonce].att[i].attestors[j];
                    mytok.burnByAdmin(curAtt,20);
                }
            }
            else {
                 for(uint j=0;j<nftTransferTxs[_nonce].att[i].attestCount;j++){
                    address curAtt = nftTransferTxs[_nonce].att[i].attestors[j];
                    mytok.mint(curAtt,20);
            }
        }
      if(nftTransferTxs[_nonce].att[winner].amount == 0)  mynft.safeMint(nftTransferTxs[_nonce].att[winner].owner,nftTransferTxs[_nonce].att[winner].uri);
      else payable(nftTransferTxs[_nonce].att[winner].owner).transfer(nftTransferTxs[_nonce].att[winner].amount);  
    }

}
struct stake {
    uint tokens;
    uint unlockTimestamp;
} 
    mapping (address =>  mapping(uint => stake) ) public stakes;
    mapping (address => uint ) public stakesNumber;

   function stakeEth(uint period) public payable {
        require(period>30, "staking period must be longer than 30s");
        uint tokenReimburse;
        if(period > 180) {
         tokenReimburse = (msg.value*(100+5))/100;
        }
        else if(period > 120) {
         tokenReimburse = (msg.value*(100+4))/100;
        } 
        else if(period > 60) {
         tokenReimburse = (msg.value*(100+3))/100;
        } 
        else 
         {
         tokenReimburse = (msg.value*(100+2))/100;
             }
        stakes[msg.sender][stakesNumber[msg.sender]++] = stake (
             tokenReimburse, block.timestamp+period
        );
        mytok.mint(msg.sender,tokenReimburse);
    }

     function withdrawStakedEth(uint value) public {
     uint allowed;
     address _who = msg.sender;
     for(uint i=0; i<stakesNumber[_who]; i++){
         uint stakeTimestampp = (stakes[_who][i].unlockTimestamp);
         if(stakeTimestampp<block.timestamp){
         uint curStake = stakes[_who][i].tokens;
             if(allowed + curStake<=value){
             allowed += curStake;
             stakes[_who][i].tokens = 0;
             }
             else {
            uint diff = value-allowed;
             stakes[_who][i].tokens -= (diff);
             allowed += diff ;
             }
         }
     }
        require(allowed==value,"Cannot withdraw tokens!");
         mytok.burnByAdmin(msg.sender,allowed);
         payable(msg.sender).transfer(allowed);
    }
    
struct loanStruct  {
    uint amount;
    uint cutOffTimestamp;
    uint nftTokenId;
    bool collateralSold;
    bool set;
    }
mapping(address => loanStruct ) loan;

function getLoan(uint _amount,uint _period, uint _nftTokenId ) public {
require(!(loan[msg.sender].set), "applicant already has a loan");
require(mynft.isApprovedForAll(msg.sender, address(this)));
mynft.transferFrom(msg.sender,address(this),_nftTokenId);
loan[msg.sender]= loanStruct(_amount,block.timestamp+_period, _nftTokenId,false,true);
payable(msg.sender).transfer(_amount);
}

function returnLoan() public payable {
    loanStruct memory curLoan = loan[msg.sender];
    uint loanAmount = curLoan.amount;
    require(msg.value >= loanAmount);
    mynft.transferFrom(address(this),msg.sender,curLoan.nftTokenId);
    delete loan[msg.sender];
}

function buyCollateralNft (address _borrower) public payable {    
    loanStruct memory curLoan = loan[_borrower];
    require(msg.value >= curLoan.amount);
    loan[_borrower].collateralSold = true;
    mynft.transferFrom(address(this),msg.sender,curLoan.nftTokenId);
    loan[_borrower].collateralSold = true;
}


}
