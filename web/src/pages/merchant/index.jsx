import { useState, useEffect } from 'react'
import { Card, Button, Space, Form, Input } from 'antd';
import { useAccount, useReadContracts } from 'wagmi'
import { parseUnits } from 'viem'
import { writeMarket } from 'utils/Market'
import './index.css';
import TokenABI from '../../contracts/Token.json'
import { getAddrMerchantId } from 'utils/Market'
import Logo from '@/assets/logo.jpg';
import lifashi from '@/assets/lifashi.svg';

const rules = {
  merchantId: [{ required: true, message: 'Please input Merchant-ID!', },],
  seriesName: [{ required: true, message: 'Please input Series-Name!', },],
  seriesSymbol: [{ required: true, message: 'Please input Series-Symbol!', },],
  seriesSupply: [{ required: true, message: 'Please input Series-Supply!', },]
}

const layout = {
  labelCol: {
    span: 8,
  },
  wrapperCol: {
    span: 16,
  },
};

const tailLayout = {
  wrapperCol: {
    offset: 8,
    span: 16,
  },
};

const tokenWagmiContract = {
  abi: TokenABI,
  address: '0x17f6eda70e4A7289e9CD57865a0DfC69313EcF58'
}

const Merchant = () => {
  const [form] = Form.useForm();
  const [showEdit, setShowEdit] = useState(false);
  const { address: account  } = useAccount()
  const [merechantID, setMerechantID] = useState('123123')
  const [cardList, setCardList] = useState([]);
  
  let balance = 0
  let token = ''

  const { data = [] } = useReadContracts({
    contracts: [
      {
        ...tokenWagmiContract,
        functionName: "balanceOf",
        args: [account],
      },
      {
        ...tokenWagmiContract,
        functionName: 'symbol',
      }
    ]
  })

  useEffect(() => {
    getAddrMerchantId().then(res => {
      setMerechantID(res.toString())
    }).catch(err => {
      console.log('getAddrMerchantId err', err);
    })
  }, [account])

  if (data && data.length === 2) {
    if (data[0].status === 'success') {
      balance = data[0].result
    }
    if (data[1].status === 'success') {
      token = data[1].result
    }
  }


  const onFinish = (values) => {
  };
  const onFinishFailed = (errorInfo) => {
    console.log('Failed:', errorInfo);
  };

  const onReset = () => {
    form.resetFields();
  };

  const onCreateCard = (values) => {
    const id = parseUnits(values._merchantId)
    const maxSupply = parseUnits(values._maxSupply)

    setCardList([...cardList, values])
    
    // const args = [id, values._seriesName, values._seriesSymbol, maxSupply]
    // writeMarket(account, args).then(res => {
    //   console.log('CreateNewCardSeries success', res); 
    // }).catch(err => {
    //   console.log('CreateNewCardSeries failed', err);
    // })
  }

  return <div className="merchant-box">
    <div className='merchant-left'>
      <div className='merchant-title'>
        Create your merchant Card
      </div>
      
      {
        !showEdit &&
        <div className='create-wrapper'>
          <Button onClick={() => setShowEdit(true)} className="create-btn" type="primary" ghost>Create Card</Button>
        </div>
      }

      {
        showEdit &&
        <Form 
          {...layout}
          className="deploy-my-card" 
          name="merchantform"
          form={form} 
          onFinish={onCreateCard}
          onReset={onReset}
          onFinishFailed={onFinishFailed}>
            <Form.Item label="Merchant ID" name="_merchantId" rules={rules.merchantId} initialValue={merechantID}>
              <Input disabled />
            </Form.Item>
            <Form.Item label="Series Name" name="_seriesName" rules={rules.seriesName}>
              <Input />
            </Form.Item>
            <Form.Item label="Series Symbol" name="_seriesSymbol" rules={rules.seriesSymbol}>
              <Input />
            </Form.Item>
            <Form.Item label="Series Supply" name="_maxSupply" rules={rules.seriesSymbol}>
              <Input type="number" />
            </Form.Item>
            <Form.Item {...tailLayout}>
              <Space size="large" align="center">
                <Button type="primary" htmlType="submit">
                  Create Card Series
                </Button>
                <Button htmlType="button" onClick={onReset}>
                  Reset
                </Button>
              </Space>
            </Form.Item>
        </Form>
      }
    </div>
    <div className='merchant-right'> 
      <div className='earning-title'>
        Earnings
      </div>
      <div className='info-item'>
        <div className="label">Balance Of Token {token}: </div>
        <div className="value" style={{fontWeight: 'bold', color: 'red'}}>{balance.toString()}</div>
      </div>
      <div className='card-list'>
        <h3>My Card List</h3>
        {
          cardList.map((item, index) => {
            return <Card 
              className="card-item"
              key={item.merchantId} 
              title={`My Card ${index + 1}`}
              style={{ width: 400 }}
              cover={
                <img
                  alt="example"
                  src={Logo}
                />}
              type="inner" >
                <div className='inner'>
                  <div className="card-info-item">
                    <span className="label">Merchant ID</span>
                    <span className="value">{item. _merchantId}</span>
                  </div>
                  <div className="card-info-item">
                    <span className="label">Series Name</span>
                    <span className="value">{item._seriesName}</span>
                  </div>
                  <div className="card-info-item">
                    <span className="label">Series Symbol</span>
                    <span className="value">{item._seriesSymbol}</span>
                  </div>
                  <div className="card-info-item">
                    <span className="label">Series Supply</span>
                    <span className="value">{item._maxSupply}</span>
                  </div>
                  <Button style={{marginTop: '12px'}} type="primary">Mint Card</Button>
                </div>
              </Card>
          })
        }
      </div>
      <img className='lifashi' src={lifashi} />
    </div>
  </div>
}

export default Merchant