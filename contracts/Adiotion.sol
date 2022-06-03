// SPDX-License-Identifier: MIT
pragma solidity ^0.5.16; 
// pragma: PreCompiler
// pragma는 컴파일러에게 직접 명령을 내리는 지시자로서,
// 컴파일에게 그 뒤에오는 내용에 따라 어떤일을 하라는 전처리명령을 한다.


contract Adoption {
  address[16] public adopters;

  // Adopting a pet
  function adopt(uint petId) public returns (uint){
    require(petId >= 0 && petId <= 15);

    adopters[petId] = msg.sender;

    return petId;
  }

  // Retrieving the adopters
  function getAdopters() public view returns (address[16] memory){
    return adopters;
  }
}