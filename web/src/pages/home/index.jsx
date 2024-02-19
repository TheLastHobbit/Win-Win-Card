import { Link } from 'react-router-dom'
import { Card, Space, Button } from 'antd';
import './home.css';
import Profile from 'components/profile';
import { checkRegisteredMerchant } from '../../utils/Market'
import { useEffect } from 'react';
import { useAccount, useReadContracts, useSignTypedData } from 'wagmi'
import { MerchantRegistration } from 'utils/Market'
import { useState } from 'react';
import lifashi from '@/assets/lifashi.svg';
import custom from '@/assets/custom.svg';

const HomePage = () => {
  const [isRegister, setIsRegister] = useState(false)
  const { address: account  } = useAccount()

  useEffect(() => {
    checkRegisteredMerchant(account).then((res) => {
      setIsRegister(true)
    })
  }, [account])

  const onRegister = () => {
    if (!isRegister) {
      MerchantRegistration().then(() => {
       console.log("merchantRegistration success!")
     }).catch(err => {
       console.log("merchantRegistration failed!", err)
     })
    }

  }

  return(
    <div className='home'>
      <h1 className='home-title'>WIN-WIN Card System</h1>
      <div className='home-content'>
        <img className='lifashi' src={lifashi}  />
        <Space align="center" size="large">
          <Link to="/merchant">
            <Button onClick={onRegister} className="entry-button" size="large" ghost type="primary">
              Merchant
            </Button>
          </Link>
          <Link to="/buyer">
            <Button className="entry-button" size="large" ghost type="primary">
              Buyer/Seller
            </Button>
          </Link>
        </Space>
        <img className='custom' src={custom}  />
       {
        //  <Space align="center" size="large">
        //    <Card title="Merchant" style={{ width: 300 }} type="inner" >
        //      <Link to="/merchant">Mint Card</Link>
        //    </Card>
        //    <Card title="Buyer/Seller" style={{ width: 300 }} type="inner" >
        //      <Link to="/buyer">Transfer Card</Link>
        //    </Card>
        //  </Space>
       }
        </div>
        <h1 className='about-us'>About US</h1>
    </div>
  )
}

export default HomePage