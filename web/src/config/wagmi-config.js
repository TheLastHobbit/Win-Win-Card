import { http, createConfig } from "wagmi";
import { avalancheFuji, mainnet, sepolia } from "wagmi/chains";

export const config = createConfig({
  chains: [mainnet, sepolia, avalancheFuji],
  transports: {
    [mainnet.id]: http(),
    [sepolia.id]: http(),
    [avalancheFuji.id]: http(),
  },
});

export const ContractConfig = {
  abi: "NFTAbi",
  address: "nftAddr",
};
