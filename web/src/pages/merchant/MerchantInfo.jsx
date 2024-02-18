import { Card, Space } from 'antd';
import './MerchantInfo.css';

const MerchantInfo = () => {
  return(
    <Space className="merchant-info" align="vertical">
      <Card title="My Card Info" style={{ width: 400 }} type="inner" >
        <div className="info-item">
          <div className="label">Merchant ID</div>
          <div className="value">1233123</div>
        </div>
        <div className="info-item">
          <div className="label">Series Name</div>
          <div className="value">Vip99</div>
        </div>
        <div className="info-item">
          <div className="label">Series Symbol</div>
          <div className="value">WCB</div>
        </div>
      </Card>
      <Card title="Earnings" style={{ width: 400 }} type="inner" >
        <div className="info-item">
          <div className="label">Service Charge</div>
          <div className="value">99WCB</div>
        </div>
        <div className="info-item">
          <div className="label">Reward Token</div>
          <div className="value">12 WCB</div>
        </div>
      </Card>
    </Space>
  )
}

export default MerchantInfo