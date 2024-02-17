import { Button, Space, Form, Input } from 'antd';
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

const Merchant = () => {
  const [form] = Form.useForm();

  const onFinish = (values) => {
    console.log('Success:', values);
  };
  const onFinishFailed = (errorInfo) => {
    console.log('Failed:', errorInfo);
  };
  const onReset = () => {
    form.resetFields();
  };

  return <div className="merchant-box">
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
              New Card
            </Button>
            <Button htmlType="button" onClick={onReset}>
              Reset
            </Button>
          </Space>
        </Form.Item>
    </Form>
    <MerchantInfo></MerchantInfo>
  </div>
}

export default Merchant