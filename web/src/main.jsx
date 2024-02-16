import { WalletEntryPosition } from '@particle-network/auth';
import { BNBChain, BNBChainTestnet, Ethereum, EthereumGoerli, EthereumSepolia, AvalancheTestnet } from '@particle-network/chains';
import { evmWallets } from '@particle-network/connect';
import { ModalProvider } from '@particle-network/connect-react-ui';
import { WagmiProvider } from 'wagmi' 
import { QueryClient, QueryClientProvider } from '@tanstack/react-query' 

import React from 'react';
import ReactDOM from 'react-dom/client';
import App from './App';
import './index.css';
import '@particle-network/connect-react-ui/dist/index.css';
import { config } from './config/wagmi-config' 

const queryClient = new QueryClient() 
const root = ReactDOM.createRoot(document.getElementById('root'));
root.render(
    <React.StrictMode>
      <WagmiProvider config={config}>
        <QueryClientProvider client={queryClient}> 
          <ModalProvider
              walletSort={['Particle Auth', 'Wallet']}
              particleAuthSort={[
                  'email',
                  'phone',
                  'google',
                  'apple',
                  'twitter',
                  'twitch',
                  'facebook',
                  'microsoft',
                  'linkedin',
                  'github',
                  'discord',
              ]}
              //TODO: get particle config from https://dashboard.particle.network/
              options={{
                  projectId: "12d69394-54ef-40de-9c0a-cbd2f53d2f8a",
                  clientKey: "cnweIBh2jg32r7KalU91z1j2Xh41Q3BxmnMxAbxW",
                  appId: "xxb759e723-a325-4507-8751-325d1f14d0f6x",
                  chains: [Ethereum, EthereumGoerli, EthereumSepolia, AvalancheTestnet, BNBChain, BNBChainTestnet],
                  particleWalletEntry: {
                      displayWalletEntry: true,
                      defaultWalletEntryPosition: WalletEntryPosition.BR,
                  },
                  wallets: [
                      ...evmWallets({
                          projectId: "6211caeb5ac9b0d369664cb674c64d73",
                          showQrModal: false,
                      }),
                  ],
              }}
              language="en"
              theme={'light'}
          >
              <App />
          </ModalProvider>
        </QueryClientProvider> 
      </WagmiProvider>
    </React.StrictMode>
);
