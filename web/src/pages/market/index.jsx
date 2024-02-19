import { useState } from 'react'
import { Spin, Space, Button, Card, Modal, Input } from 'antd'
import './index.css'
import CardLogo from '@/assets/card-logo.jpg';

const Market = () => {
  const [id, setId] = useState(103)
  const [spinning, setSpinning] = useState(false);
  const arr = [
    {id: 12, name: 'Super Wash', symbol: "SWH"},
    {id: 33, name: 'Music Car', symbol: "MSC"},
    {id: 66, name: 'Fresh Fruit', symbol: "FF"},
    {id: 99, name: 'Beauty', symbol: "BEA"},
    {id: 101, name: 'Tea', symbol: "TEA"},
    {id: 102, name: 'Gym', symbol: "Gym"},
  ]
  const [open, setOpen] = useState(false);
  const [cardList, setCardList] = useState(arr)

  const handleOk = () => {
    setOpen(false)
    setSpinning(true)
    setTimeout(() => {
      setSpinning(false)
      setId(id + 1)
      setCardList([{
        id, name: 'Win-WIn Card', symbol: "WC"
      }, ...cardList])
    }, 1000);
  }

  return(
    <div className="market-box">
      <h1 className='market-title'>Card Market</h1>
      <Button onClick={() => setOpen(true)} type="primary" ghost className="list-card">List Card</Button>
      <Spin spinning={spinning} tip="Loading...">
        <div className='card-box'>
          {
            cardList.map((item, index) => {
              return <div key={item.id} style={{marginRight: '32px'}}>
                <Card title={`Card for sale ${index + 1}`} style={{ width: 400, marginBottom: '32px' }} type="inner" >
                  <div className="info-item">
                    <div className="label">Merchant ID</div>
                    <div style={{color: '#1677ff', fontWeight: 'bold', fontSize: "16px"}} className="value">{item.id}</div>
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
      </Spin>
      <Modal
        title="List Card"
        open={open}
        onOk={handleOk}
        onCancel={() => setOpen(false)}
      >
        <div className='info-item'>
          <div style={{width: '120px'}} className="label">Merchant ID: </div>
          <Input />
        </div>
        <div className='info-item'>
          <div style={{width: '120px'}} className="label">Series ID: </div>
          <Input  />
        </div>
        <div className='info-item'>
          <div style={{width: '120px'}} className="label">Price: </div>
          <Input  />
        </div>
      </Modal>
    </div>
  )  
}

export default Market

