import { custom, createWalletClient, createPublicClient, http } from "viem";
import { avalancheFuji } from "viem/chains";

export const publicClient = createPublicClient({
  chain: avalancheFuji,
  transport: http(),
});

export const walletClient = createWalletClient({
  chain: avalancheFuji,
  transport: custom(window.ethereum),
});
