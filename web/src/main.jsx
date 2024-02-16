import { WalletEntryPosition } from '@particle-network/auth';
import { BNBChain, BNBChainTestnet, Ethereum, EthereumGoerli, EthereumSepolia } from '@particle-network/chains';
import { evmWallets } from '@particle-network/connect';
import { ModalProvider, ConnectButton } from '@particle-network/connect-react-ui';
import React from 'react';
import ReactDOM from 'react-dom/client';
import App from './App';
import './index.css';
import '@particle-network/connect-react-ui/dist/index.css';


const root = ReactDOM.createRoot(document.getElementById('root'));
root.render(
    <React.StrictMode>
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
                chains: [Ethereum, EthereumGoerli, EthereumSepolia, BNBChain, BNBChainTestnet],
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
            <ConnectButton />
        </ModalProvider>
    </React.StrictMode>
);
