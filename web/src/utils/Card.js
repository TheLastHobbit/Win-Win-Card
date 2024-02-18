import { ethers } from 'ethers';
import ABI from '../contracts/Market.json';

let provider = new ethers.BrowserProvider(window.ethereum)
const contractAddress = "0xCF14278d799431dd31261019af422A1A2Aa5B75D";
const contract = new ethers.Contract(contractAddress, ABI, await provider.getSigner());



