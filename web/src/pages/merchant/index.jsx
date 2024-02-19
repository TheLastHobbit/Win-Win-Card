import { useState, useEffect } from 'react'
import { Modal, Card, Button, Spin, Space, Form, Input } from 'antd';
import { useAccount, useReadContracts } from 'wagmi'
import { parseUnits } from 'viem'
import { writeMarket, mintCardByWagmi, getAddrMerchantId } from 'utils/Market'
import './index.css';
import TokenABI from '../../contracts/Token.json'
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
  const [reward, setReward] = useState(0);
  const [spinning, setSpinning] = useState(false);
  const [showEdit, setShowEdit] = useState(false);
  const { address: account  } = useAccount()
  const [merechantID, setMerechantID] = useState('123123')
  const [cardList, setCardList] = useState([{
    _merchantId: 1,
    _seriesName: "Win-Win Card",
    _seriesSymbol: "WC",
    _maxSupply: 50000
  }]);
  const [mintObj, setMintObj] = useState({
    price: 0,
    addressTo: ''
  });
  const [open, setOpen] = useState(false);
  
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
    
    const args = [1, values._seriesName, values._seriesSymbol, '500']
    // CreateNewCardSeries(id, values._seriesName, values._seriesSymbol, maxSupply)
    setSpinning(true)
    writeMarket(account, ...args).then(res => {
      console.log('CreateNewCardSeries success', res); 
      setTimeout(() => {
        setSpinning(false)
        setShowEdit([{
          _merchantId: 1,
          _seriesName: "Win-Win Card",
          _seriesSymbol: "WC",
          _maxSupply: 50000
        }])
      }, 2000)
    }).catch(err => {
      console.log('CreateNewCardSeries failed', err);
    })
  }

  const handleOk = () => {
    // const cardAddress = '0x285687f242ec4aa6e6be1c1f5cb9728f9bb1f9795f9b08839767737cf9862bee'
    // const _merchantId = 1
    // const _seriesName = 'Win-Win Card'
    // const _seriesSymbol = 'WC'
    // const _maxSupply = 5000
    // mintCardByWagmi(account, cardAddress, [_merchantId, _seriesName, _seriesSymbol, _maxSupply]).then(res => {
    //   console.log('mintCardByWagmi res', res);
    // })
    setSpinning(true)
    setOpen(false);
    setTimeout(() => {
      setSpinning(false)
      setReward(reward + 100)
    }, 1000);
  };

  const handleCancel = () => {
    console.log('Clicked cancel button');
    setOpen(false);
  };

  return <Spin wrapperClassName="merchant-box" spinning={spinning} tip="Loading...">
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
        <div className="value" style={{fontWeight: 'bold', color: 'red'}}>{reward + Number(balance)}</div>
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
                  <Button onClick={() => setOpen(true)} style={{marginTop: '12px'}} type="primary">Mint Card</Button>
                </div>
              </Card>
          })
        }
      </div>
      <img className='lifashi' src={lifashi} />
      <Modal
        title="Mint Card"
        open={open}
        onOk={handleOk}
        onCancel={handleCancel}
      >
        <div className='info-item'>
          <div style={{width: '120px'}} className="label">Address To: </div>
          <Input onChange={(e) => setMintObj({...mintObj, addressTo: e.target.value})} />
        </div>
        <div className='info-item'>
          <div style={{width: '120px'}} className="label">Price: </div>
          <Input onChange={(e) => setMintObj({...mintObj, price: e.target.value})} />
        </div>
      </Modal>
    </div>
  </Spin>
}

export default Merchant