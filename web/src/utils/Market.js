import { ethers } from 'ethers';
import ABI from '../contracts/Market.json';

let provider = new ethers.BrowserProvider(window.ethereum)
const contractAddress = "0xCF14278d799431dd31261019af422A1A2Aa5B75D";
const contract = new ethers.Contract(contractAddress, ABI, await provider.getSigner());

// payable方法
export async function buy(seller, shopAddr, _id, _price, _CardAddr, TransNum, _signature) {
    contract.buy(seller, shopAddr, _id, _price, _CardAddr, TransNum, _signature);
    console.log()
}


export async function mintCard(){
    //todo
    
}

export async function getCharge(amount){
    console.log("charge",charge);
    const charge = contract.getCharge(amount);
    return charge;
}


