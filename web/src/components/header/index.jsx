import ConnectButton from 'components/connect-button'
import './index.css'
import Logo from 'assets/logo.jpg';

const Header = () => {
  return (
    <div className="header">
      <div className="left">
        <img src={Logo} className='logo' alt="logo" />
        <h3 className='title'>Win-Win Card</h3>
      </div>
      <div className='login'>
        <ConnectButton></ConnectButton>
      </div>
    </div>
  )
}

export default Header