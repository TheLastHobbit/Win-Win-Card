import { Button, Space, Card, Form, Input } from 'antd';
import './index.css';

const Buyer = () => {
  return (
    <div className='card-box'>
      <Card title="Card Name" style={{ width: 400 }} type="inner" >
        <div className="info-item">
          <div className="label">Merchant ID</div>
          <div className="value">12</div>
        </div>
        <div className="info-item">
          <div className="label">Series Name</div>
          <div className="value">VIP88</div>
        </div>
        <div className="info-item">
          <div className="label">Series Symbol</div>
          <div className="value">XB</div>
        </div>
        <Space align="center">
          <Button style={{width: "60px"}} type="primary">List</Button>
          <Button danger>Delist</Button>
        </Space>
      </Card>
    </div>
  )
}

export default Buyer