import { ethers } from "ethers";
import ABI from "../contracts/Market.json";
import { publicClient, walletClient } from "./client";

let provider = new ethers.BrowserProvider(window.ethereum);
const contractAddress = "0x03fEB8189b683cdD8eF291eD65e4a7E61182463d";
const contract = new ethers.Contract(
  contractAddress,
  ABI,
  await provider.getSigner()
);

export const writeMarket = async (
  account,
  _merchantId,
  _seriesName,
  _seriesSymbol,
  _maxSupply
) => {
  const { request } = await publicClient.simulateContract({
    account,
    address: contractAddress,
    abi: ABI,
    args: [_merchantId, _seriesName, _seriesSymbol, _maxSupply],
    functionName: "deployNewCardSeries",
  });
  return walletClient.writeContract(request);
};

export const mintCardByWagmi = async (account, mintAddress, args) => {
  const { request } = await publicClient.simulateContract({
    account,
    address: mintAddress,
    abi: ABI,
    args: args,
    functionName: "mintCard",
  });
  return walletClient.writeContract(request);
};

// payable方法
export async function buy(
  seller,
  shopAddr,
  _id,
  _price,
  _CardAddr,
  TransNum,
  _signature
) {
  contract.buy(seller, shopAddr, _id, _price, _CardAddr, TransNum, _signature);
  console.log();
}

export async function MintCard(
  _merchantId,
  _seriesId,
  _to,
  _tokenURI,
  _price,
  _deadline,
  _signature
) {
  contract.mintCard(
    _merchantId,
    _seriesId,
    _to,
    _tokenURI,
    _price,
    _deadline,
    _signature
  );
}

export async function CreateNewCardSeries(
  _merchantId,
  _seriesName,
  _seriesSymbol,
  _maxSupply
) {
  contract.deployNewCardSeries(
    _merchantId,
    _seriesName,
    _seriesSymbol,
    _maxSupply
  );
}

export async function getCharge(amount) {
  console.log("charge", charge);
  const charge = contract.getCharge(amount);
  return charge;
}

// 检查商家是否注册
export async function checkRegisteredMerchant(_account) {
  const bool = contract.checkIfRegisteredMerchant(_account);
  return bool;
}

//商家注册函数
export async function MerchantRegistration() {
  const merchantId = contract.merchantRegistration();
  console.log("merchantRegistration success!");
  return merchantId;
}

export async function getAddrMerchantId() {
  const merchantid = contract.getMerchantsId();
  return merchantid;
}
