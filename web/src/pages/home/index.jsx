import { Link } from 'react-router-dom'
import { Card, Space } from 'antd';
import './home.css';
import Profile from 'components/profile';

const HomePage = () => {
  const onHandleCard =(type) => {

  }

  return(
    <div className='home'>
      <Profile></Profile>
      <div className='home-content'>
        <Space align="center" size="large">
          <Card title="I am a merchant" style={{ width: 300 }} type="inner" >
            <Link to="/merchant">Release your Card</Link>
          </Card>
          <Card title="I am a buyer" style={{ width: 300 }} type="inner" >
            <Link to="/buyer">Transfer your Card</Link>
          </Card>
        </Space>
      </div>
    </div>
  )
}

export default HomePage