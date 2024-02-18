import { useState } from 'react'
import { Button, Space, Form, Input } from 'antd';
import { useAccount, useReadContracts, useSignTypedData } from 'wagmi'
import MerchantInfo from './MerchantInfo'
import './index.css';

const rules = {
  merchantId: [{ required: true, message: 'Please input Merchant-ID!', },],
  seriesName: [{ required: true, message: 'Please input Series-Name!', },],
  seriesSymbol: [{ required: true, message: 'Please input Series-Symbol!', },]
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
  abi: '',
  address: ''
}

const Merchant = () => {
  const [form] = Form.useForm();
  const [showEdit, setShowEdit] = useState(false);
  
  const { address: account  } = useAccount()
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

  const onFinish = (values) => {
    const readConfig = {
      abi: '',
      
    }
  };
  const onFinishFailed = (errorInfo) => {
    console.log('Failed:', errorInfo);
  };
  const onReset = () => {
    form.resetFields();
  };


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
          onFinish={onFinish}
          onReset={onReset}
          onFinishFailed={onFinishFailed}>
            <Form.Item label="Merchant ID" name="merchantId" rules={rules.merchantId}>
              <Input />
            </Form.Item>
            <Form.Item label="Series Name" name="seriesName" rules={rules.seriesName}>
              <Input />
            </Form.Item>
            <Form.Item label="Series Symbol" name="seriesSymbol" rules={rules.seriesSymbol}>
              <Input />
            </Form.Item>
            <Form.Item {...tailLayout}>
              <Space size="large" align="center">
                <Button type="primary" htmlType="submit">
                  Create Card
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
        <div className="label">Balance(wUSD): </div>
        <div className="value">31</div>
      </div>
      <div className='info-item'>
        <div className="label">Balance(wUSD): </div>
        <div className="value">1231</div>
      </div>
      {
        // <MerchantInfo></MerchantInfo>
      }
    </div>
  </div>
}

export default Merchant