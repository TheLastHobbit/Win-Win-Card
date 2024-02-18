import { Link } from 'react-router-dom'
import { Card, Space, Button } from 'antd';
import './home.css';
import Profile from 'components/profile';
import { checkRegisteredMerchant } from '../../utils/Market'
import { useEffect } from 'react';
import { useAccount, useReadContracts, useSignTypedData } from 'wagmi'

const HomePage = () => {
  const onHandleCard =(type) => {

  }
  const { address: account  } = useAccount()


  useEffect(() => {
    checkRegisteredMerchant(account).then((res) => {
      console.log('checkRegisteredMerchant', res);
    })
  }, [account])


  return(
    <div className='home'>
      <h1 className='home-title'>WIN-WIN Card System</h1>
      <div className='home-content'>
        <Space align="center" size="large">
          <Link to="/merchant">
            <Button className="entry-button" size="large" ghost type="primary">
              Merchant
            </Button>
          </Link>
          <Link to="/buyer">
            <Button className="entry-button" size="large" ghost type="primary">
              Buyer/Seller
            </Button>
          </Link>
        </Space>
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