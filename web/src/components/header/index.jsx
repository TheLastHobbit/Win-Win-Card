import { useNavigate } from 'react-router-dom'
import ConnectButton from 'components/connect-button'
import './index.css'
import Logo from 'assets/logo.svg';

const Header = () => {
  const navigate = useNavigate()
  const toHome =() => {
    navigate('/')
  }

  return (
    <div className="header">
      <div className="left">
        <img src={Logo} className='logo' alt="logo" onClick={toHome} />
        {
          // <h3 className='title'>Win-Win Card</h3>
        }
      </div>
      <div className='login'>
        <ConnectButton></ConnectButton>
      </div>
    </div>
  )
}

export default Header