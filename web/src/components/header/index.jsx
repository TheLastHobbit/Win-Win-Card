import { useState, useEffect } from "react";
import { useNavigate, Link } from "react-router-dom";
import ConnectButton from "components/connect-button";
import "./index.css";
import Logo from "assets/logo.svg";

const Header = () => {
  const navigate = useNavigate();
  const [position, setPosition] = useState(window.pageYOffset);
  const [visible, setVisible] = useState(true);
  useEffect(() => {
    const handleScroll = () => {
      let moving = window.pageYOffset;
      setVisible(position > moving);
      setPosition(moving);
    };
    window.addEventListener("scroll", handleScroll);
    return () => {
      window.removeEventListener("scroll", handleScroll);
    };
  });

  const cls = visible ? "visible" : "hidden";
  const toHome = () => {
    navigate("/");
  };

  return (
    <div className="header-box">
      <div className={`header ${cls}`}>
        <div className="left">
          <img
            src={Logo}
            className="logo"
            alt="logo"
            onClick={toHome}
          />
          <Link to="/market" className="market-link">
            Market
          </Link>
          {
            // <h3 className='title'>Win-Win Card</h3>
          }
        </div>
        <div className="login">
          <ConnectButton></ConnectButton>
        </div>
      </div>
    </div>
  );
};

export default Header;
