import { useState } from 'react'
import { Button, Space, Form, Input } from 'antd';
import { useAccount, useReadContracts } from 'wagmi'
import { CreateNewCardSeries } from 'utils/Market'
import MerchantInfo from './MerchantInfo'
import './index.css';
import TokenABI from '../../contracts/Token.json'

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
console.log('TokenABI', TokenABI);
const tokenWagmiContract = {
  abi: TokenABI,
  address: '0x17f6eda70e4A7289e9CD57865a0DfC69313EcF58'
}

const Merchant = () => {
  const [form] = Form.useForm();
  const [showEdit, setShowEdit] = useState(false);
  const { address: account  } = useAccount()
  let balance = 0
  let token = ''
  console.log('account', account);
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
    console.log('values', values);
    CreateNewCardSeries(values).then(res => {
      console.log('CreateNewCardSeries success', res); 
    }).catch(err => {
      console.log('CreateNewCardSeries failed', err);
    })
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
            <Form.Item label="Merchant ID" name="_merchantId" rules={rules.merchantId}>
              <Input />
            </Form.Item>
            <Form.Item label="Series Name" name="_seriesName" rules={rules.seriesName}>
              <Input />
            </Form.Item>
            <Form.Item label="Series Symbol" name="_seriesSymbol" rules={rules.seriesSymbol}>
              <Input />
            </Form.Item>
            <Form.Item label="Series Supply" name="_maxSupply" rules={rules.seriesSymbol}>
              <Input />
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
    </div>
  </div>
}

export default Merchant