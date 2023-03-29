<template>
  <a-row justify="center" style="margin-top:200px">
    <a-col :span="7">
      <a-form :model="form" :rules="rules" style="border: 1px solid gainsboro; padding: 20px 20px 0 20px; margin-bottom: 15px;">
        <a-form-item label="代币合约地址">
          <a-input v-model:value="form.tokenAddr"></a-input>
        </a-form-item>
        <a-form-item label="金库合约地址">
          <a-input v-model:value="form.vaultAddr"></a-input>
        </a-form-item>
        <a-form-item label="账户地址">
          <div>{{ form.userAddr }}</div>
        </a-form-item>
        <a-form-item label="拥有代币">
          <div>{{ form.amount }}</div>
        </a-form-item>
        <a-form-item label="当前存款">
          <div>{{ form.deposit }}</div>
        </a-form-item>
        <a-form-item label="存款金额">
          <a-input-number v-model:value="form.value"></a-input-number>
        </a-form-item>
      </a-form>
    </a-col>
  </a-row>
  <a-row justify="center">
    <a-col>
      <a-space>
          <a-button type="primary" :disabled="isWalletConnected" @click="connect">连接钱包</a-button>
          <a-button type="primary" :disabled="!isWalletConnected" @click="deposit">存款</a-button>
          <a-button type="primary" :disabled="!isWalletConnected" @click="withdraw">提取全部</a-button>
      </a-space>
    </a-col>
  </a-row>
</template>

<script setup>
import { ref, reactive } from 'vue';
import { ethers } from "ethers";
import MyERC20Info from '../../contract-proj/artifacts/contracts/Vault.sol/MyERC20.json'
import VaultInfo from '../../contract-proj/artifacts/contracts/Vault.sol/Vault.json'

const isWalletConnected = ref(false)
const form = reactive({
  tokenAddr: '',
  vaultAddr: '',
  userAddr: '',
  amount: 0,
  deposit: 0,
  value: 0,
})

const rules = {
  deposit: { required: true, message: '金额不能为空'}
}

// Provider（提供者）是一个用于连接以太坊网络的抽象类，提供了只读形式来访问区块链网络和获取链上状态
let provider;
let chainId;
async function initProvider() {
  if (window.ethereum) {
    provider = new ethers.providers.Web3Provider(window.ethereum)
    const network = await provider.getNetwork()
    chainId = network.chainId
    console.log('chainId', chainId)
  } else {
    alert('请安装MetaMask!')
  }
}

// Signer（签名器）通常是以某种方式直接或间接访问私钥，可以签名消息和在已授权网络中管理你账户中的以太币来进行交易
let signer;
let accounts;
async function initAccount() {
  try {
    accounts = await provider.send("eth_requestAccounts", [])
    console.log('Got accounts', accounts)
    form.userAddr = accounts[0]
    signer = provider.getSigner()
  } catch (error) {
    alert('Access user account error!')
  }
}

// Contract（合约）是一个运行在以太坊网络上表示现实中特定合约的抽象，应用可以像使用JavaScript对象一样使用它
let MyERC20, Vault
async function initContract() {
  MyERC20 = new ethers.Contract(form.tokenAddr, MyERC20Info.abi, signer)
  Vault = new ethers.Contract(form.vaultAddr, VaultInfo.abi, signer)
}

async function getDeposit() {
  form.amount = await MyERC20.balanceOf(form.userAddr)
  form.amount = ethers.utils.formatUnits(form.amount, 18)
  form.deposit = await Vault.getDeposit()
  form.deposit = ethers.utils.formatUnits(form.deposit, 18)
}

async function connect() {
  if (form.tokenAddr == '') {
    alert('请输入代币合约地址')
    return
  }
  if (form.vaultAddr == '') {
    alert('请输入金库合约地址')
    return
  }
  await initProvider()
  await initAccount()
  await initContract()
  await getDeposit()
  isWalletConnected.value = true
}

async function deposit() {
  // 离线签名
  let nonce = await MyERC20.nonces(form.userAddr);

  const deadline = Math.ceil(Date.now() / 1000) + parseInt(20 * 60);
  
  let amount =  ethers.utils.parseUnits(form.value.toString()).toString();

  const domain = {
      name: 'ERC2612',
      version: '1',
      chainId: chainId,
      verifyingContract: form.tokenAddr
  }
  const types = {
      Permit: [
        {name: "owner", type: "address"},
        {name: "spender", type: "address"},
        {name: "value", type: "uint256"},
        {name: "nonce", type: "uint256"},
        {name: "deadline", type: "uint256"}
      ]
  }
  const message = {
      owner: form.userAddr,
      spender: form.vaultAddr,
      value: amount,
      nonce: nonce,
      deadline: deadline
  }
  console.log(domain, types, message);

  const signature = await signer._signTypedData(domain, types, message);

  const {v, r, s} = ethers.utils.splitSignature(signature);

  let tx = await Vault.permitDeposit(amount, deadline, v, r, s)
  let receipt = await tx.wait();

  console.log('receipt:', receipt)

  await getDeposit()
}

async function withdraw() {
  await Vault.withdraw()
}

</script>
