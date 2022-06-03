# Ethereum Pet Shop Tutorial

- [공식문서](https://trufflesuite.com/guides/pet-shop/) 예제를 따라 만든 튜토리얼
- [LeeSeungYun1020/ethereum-pet-shop-tutorial](https://github.com/LeeSeungYun1020/ethereum-pet-shop-tutorial)의 한글 번역 참고

![petshop](https://user-images.githubusercontent.com/54584063/171804813-34261b09-e51c-4adf-aefa-844b3e5be53a.png)

## Background

## Setting up the development environment

- **prerequisite**

  - node.js : ^8.0.0
  - git
  - Ganache

- Install

  ```bash
  npm install -g truffle
  ```

  <br/>

## Steps

### 1. Create Truffle Project using Truffle Box

`pet-shop`이라고 불리는 Truffle Box를 만든다.
해당 Truffle Box는 project의 기본구조와 user interface 코드를 포함하고 있다.

```bash
truffle unbox pet-shop
```

<details>
<summary>For Empty Truffle Project</summary>
아래 명령어를 통해서 비어있는 Truffle 프로젝트를 만들 수 있다.
- [참고 문서](https://trufflesuite.com/docs/truffle/getting-started/creating-a-project/)
```
truffle init
```
</details>

<br/>

### 2. Add `Adoption` smart contract

- `contracts/Adoption.sol`

  ```sol
  pragma solidity ^0.5.16;

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
  ```

  <br/>

### 3. Compile & Migrate

- Compilation

  ```bash
  truffle compile
  ```

  ```bash
  Compiling your contracts...
  ===========================
  > Compiling ./contracts/Adiotion.sol
  > Compiling ./contracts/Migrations.sol
  > Artifacts written to /Users/choijeonghye/Desktop/JH_CODING/side-project/pet-shop/build/contracts
  > Compiled successfully using:
    - solc: 0.5.16+commit.9c3226ce.Emscripten.clang
  ```

- Migration

  - `migrations/2_deploy_contracts.js`

    ```js
    var Adoption = artifacts.require('Adoption');

    module.exports = function (deployer) {
      deployer.deploy(Adoption);
    };
    ```

  - Ganache 켜기

  - migrate

        ```bash
        truffle migrate
        ```

        ```
        Compiling your contracts...
        ===========================
        > Compiling ./contracts/Adiotion.sol
        > Artifacts written to /Users/choijeonghye/Desktop/JH_CODING/side-project/pet-shop/build/contracts
        > Compiled successfully using:
          - solc: 0.5.16+commit.9c3226ce.Emscripten.clang


        Starting migrations...
        ======================
        > Network name:    'development'
        > Network id:      5777
        > Block gas limit: 6721975 (0x6691b7)


        1_initial_migration.js
        ======================

          Deploying 'Migrations'
          ----------------------
          > transaction hash:    0x5e9c66ebaf66bfc916737f00e594af74f1e06fe02f878713deea55cb36ddf16e
          > Blocks: 0            Seconds: 0
          > contract address:    0xE5b7Bbdd46319A6C3fa25cFBA04237C05Bc9bfBa
          > block number:        1
          > block timestamp:     1654231070
          > account:             [계정 주소]
          > balance:             99.99616114
          > gas used:            191943 (0x2edc7)
          > gas price:           20 gwei
          > value sent:          0 ETH
          > total cost:          0.00383886 ETH

          > Saving migration to chain.
          > Saving artifacts
          -------------------------------------
          > Total cost:          0.00383886 ETH


        2_deploy_contracts.js
        =====================

          Deploying 'Adoption'
          --------------------
          > transaction hash:    0x892d53c2045fd9ea5ab5d68a9bc5b6269dcf93fcc51f5f0602fdab911f01d640
          > Blocks: 0            Seconds: 0
          > contract address:    0xB1ff1CA0251A48ae39594c01d6AdD3C753c8ce86
          > block number:        3
          > block timestamp:     1654231070
          > account:             [계정 주소]
          > balance:             99.99123784
          > gas used:            203827 (0x31c33)
          > gas price:           20 gwei
          > value sent:          0 ETH
          > total cost:          0.00407654 ETH

          > Saving migration to chain.
          > Saving artifacts
          -------------------------------------
          > Total cost:          0.00407654 ETH

        Summary
        =======
        > Total deployments:   2
        > Final cost:          0.0079154 ETH
        ```

    <br/>

  ### 4. Test smart contract

  - use Solidity

    - `test/TestAdoption.sol`

      ```sol
      pragma solidity ^0.5.0;

      import "truffle/Assert.sol";
      import "truffle/DeployedAddresses.sol";
      import "../contracts/Adoption.sol";

      contract TestAdoption {
        // The address of the adoption contract to be tested
        Adoption adoption = Adoption(DeployedAddresses.Adoption());

        // The id of the pet that will be used for testing
        uint expectedPetId = 8;

        //The expected owner of adopted pet is this contract
        address expectedAdopter = address(this);


        // Testing the adopt() function
        function testUserCanAdoptPet() public {
          uint returnedId = adoption.adopt(expectedPetId);

          Assert.equal(returnedId, expectedPetId, "Adoption of the expected pet should match what is returned.");
        }

        // Testing retrieval of a single pet's owner
        function testGetAdopterAddressByPetId() public {
          address adopter = adoption.adopters(expectedPetId);

          Assert.equal(adopter, expectedAdopter, "Owner of the expected pet should be this contract");
        }

        // Testing retrieval of all pet owners
        function testGetAdopterAddressByPetIdInArray() public {
          // Store adopters in memory rather than contract's storage
          address[16] memory adopters = adoption.getAdopters();

          Assert.equal(adopters[expectedPetId], expectedAdopter, "Owner of the expected pet should be this contract");
        }
      }
      ```

- use JavaScript

  - `test/testAdoption.test.js`

    ```js
    const Adoption = artifacts.require('Adoption');

    contract('Adoption', (accounts) => {
      let adoption;
      let expectedPetId;

      before(async () => {
        adoption = await Adoption.deployed();
      });

      describe('adopting a pet and retrieving account addresses', async () => {
        before('adopt a pet using accounts[0]', async () => {
          await adoption.adopt(8, { from: accounts[0] });
          expectedAdopter = accounts[0];
        });

        it('can fetch the address of an owner by pet id', async () => {
          const adopter = await adoption.adopters(8);
          assert.equal(
            adopter,
            expectedAdopter,
            'The owner of the adopted pet should be the first account.'
          );
        });

        it("can fetch the collection of all pet owners' addresses", async () => {
          const adopters = await adoption.getAdopters();
          assert.equal(
            adopters[8],
            expectedAdopter,
            'The owner of the adopted pet should be in the collection.'
          );
        });
      });
    });
    ```

- Run Tests

  ```bash
  truffle test
  ```

  ```bash
  Compiling your contracts...
  ===========================
  > Compiling ./contracts/Adoption.sol
  > Compiling ./test/TestAdoption.sol
  > Artifacts written to /var/folders/tt/qm2yjjzd0f394twn6j855z4r0000gn/T/test--88863-oFqbdB18x4NQ
  > Compiled successfully using:
    - solc: 0.5.16+commit.9c3226ce.Emscripten.clang


    TestAdoption
      ✔ testUserCanAdoptPet (131ms)
      ✔ testGetAdopterAddressByPetId (143ms)
      ✔ testGetAdopterAddressByPetIdInArray (160ms)

    Contract: Adoption
      adopting a pet and retrieving account addresses
        ✔ can fetch the address of an owner by pet id
        ✔ can fetch the collection of all pet owners' addresses (38ms)


    5 passing (8s)

  ```

<br/>

### 5. Creat user interface to interact with the smart contract

**`/src/js/app.js`**

- `initWeb3`

  ```js
  // Modern dapp browsers...
  if (window.ethereum) {
    App.web3Provider = window.ethereum;
    try {
      // Request account access
      await window.ethereum.enable();
    } catch (error) {
      // User denied account access...
      console.error('User denied account access');
    }
  }
  // Legacy dapp browsers...
  else if (window.web3) {
    App.web3Provider = window.web3.currentProvider;
  }
  // If no injected web3 instance is detected, fall back to Ganache
  else {
    App.web3Provider = new Web3.providers.HttpProvider('http://localhost:7545');
  }
  web3 = new Web3(App.web3Provider);
  ```

- `initContract`

  ```js
  $.getJSON('Adoption.json', function (data) {
    // Get the necessary contract artifact file and instantiate it with @truffle/contract
    var AdoptionArtifact = data;
    App.contracts.Adoption = TruffleContract(AdoptionArtifact);

    // Set the provider for our contract
    App.contracts.Adoption.setProvider(App.web3Provider);

    // Use our contract to retrieve and mark the adopted pets
    return App.markAdopted();
  });
  ```

- `markAdopted`

  ```js
  var adoptionInstance;

  App.contracts.Adoption.deployed()
    .then(function (instance) {
      adoptionInstance = instance;

      return adoptionInstance.getAdopters.call();
    })
    .then(function (adopters) {
      for (i = 0; i < adopters.length; i++) {
        if (adopters[i] !== '0x0000000000000000000000000000000000000000') {
          $('.panel-pet')
            .eq(i)
            .find('button')
            .text('Success')
            .attr('disabled', true);
        }
      }
    })
    .catch(function (err) {
      console.log(err.message);
    });
  ```

- `handleAdopt`

  ```js
  var adoptionInstance;

  web3.eth.getAccounts(function (error, accounts) {
    if (error) {
      console.log(error);
    }

    var account = accounts[0];

    App.contracts.Adoption.deployed()
      .then(function (instance) {
        adoptionInstance = instance;

        // Execute adopt as a transaction by sending account
        return adoptionInstance.adopt(petId, { from: account });
      })
      .then(function (result) {
        return App.markAdopted();
      })
      .catch(function (err) {
        console.log(err.message);
      });
  });
  ```

  <br/>

### 6. Add Ganache network to Metamask

- 브라우저에 MetaMask 설치

- New Network 추가

<br/>

### 7. serve

using the `lite-server` library to serve our static files

- `bs-config.json`

  ```json
  {
    "server": {
      "baseDir": ["./src", "./build/contracts"]
    }
  }
  ```

- `package.json`

  ```json
  "scripts": {
    "dev": "lite-server",
    "test": "echo \"Error: no test specified\" && exit 1"
  },
  ```

- start local web server

  ```bash
  npm run dev
  ```

<br/>

### 8. Adopt!

- 메타마스크를 통해 계정 연결 허가. `연결` 버튼을 눌러 dapp과 연결.

- **Adopt** 버튼을 통해 펫 입양!

- 확인 대기 요청 중인 요청(트랜잭션)으로 팝업이 뜨면 `확인` 버튼!

- 버튼이 `Sucess`가 되었다.(입양 성공!)
