import { Space, Button, Card } from 'antd'
import './index.css'
import CardLogo from '@/assets/card-logo.jpg';

const Market = () => {
  const arr = [
    {id: 12, name: 'Super Wash', symbol: "SWH"},
    {id: 33, name: 'Music Car', symbol: "MSC"},
    {id: 66, name: 'Fresh Fruit', symbol: "FF"},
    {id: 99, name: 'Beauty', symbol: "BEA"},
    {id: 101, name: 'Tea', symbol: "TEA"},
    {id: 102, name: 'Gym', symbol: "Gym"},
  ]

  return(
    <div className="market-box">
      <h1 className='market-title'>Card Market</h1>
      <div className='card-box'>
        {
          arr.map((item, index) => {
            return <div key={item.id} style={{marginRight: '32px'}}>
              <Card title={`Cards for sale ${index + 1}`} style={{ width: 400, marginBottom: '32px' }} type="inner" >
                <div className="info-item">
                  <div className="label">Merchant ID</div>
                  <div className="value">{item.id}</div>
                </div>
                <div className="info-item">
                  <div className="label">Series Name</div>
                  <div className="value">{item.name}</div>
                </div>
                <div className="info-item">
                  <div className="label">Series Symbol</div>
                  <div className="value">{item.symbol}</div>
                </div>
                <img src={CardLogo} alt="CardLogo" className='logo-img' />
                <Space align="center">
                  <Button style={{width: "60px"}} type="primary">Buy</Button>
                  <Button danger>Details</Button>
                </Space>
              </Card>
            </div>
          })
        }
      </div>
    </div>
  )  
}

export default Market