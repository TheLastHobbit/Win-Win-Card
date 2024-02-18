import { ethers } from 'ethers';
import ABI from '../contracts/Token.json';

let provider = new ethers.BrowserProvider(window.ethereum)
const contractAddress = "0x17f6eda70e4A7289e9CD57865a0DfC69313EcF58";
const contract = new ethers.Contract(contractAddress, ABI, await provider.getSigner());

export async function approve(spender, amount) {
    const result = await contract.approve(spender, amount);
    console.log("tokenApproveHash:",result.hash);
  }

export async function getTokenbalance(account){
    const balance = contract.balanceOf(account);
    return balance;
}

export async function getAllowance(owner, spender) {
    const contract = new ethers.Contract(contractAddress, ABI, await provider.getSigner());
    const result = await contract.allowance(owner, spender);
    return Number(result);
}


