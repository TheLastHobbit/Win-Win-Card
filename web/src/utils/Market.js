import { ethers } from "ethers";
import ABI from "../contracts/Market.json";

let provider = new ethers.BrowserProvider(window.ethereum)
const contractAddress = "0x8Fa2DA0F0982303701272cdc6b491b5C6C99705f";
const contract = new ethers.Contract(contractAddress, ABI, await provider.getSigner());

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
  console.log(_merchantId, "mint", _id, "to", _to, "custom successful!");
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
  console.log(_merchantId, "create", _seriesName, "success!");
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
   console.log("merchantRegistration success!")
   return merchantId;
}

export async function getAddrMerchantId() {
  const merchantid = contract.getMerchantsId();
  return merchantid;
}
