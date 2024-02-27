import { useState, useRef } from 'react';
import { Link } from 'react-router-dom'
import { Card, Space, Button } from 'antd';
import './home.css';
import { checkRegisteredMerchant } from '../../utils/Market'
import { useEffect } from 'react';
import { useAccount, useReadContracts, useSignTypedData } from 'wagmi'
import { MerchantRegistration } from 'utils/Market'
import lifashi from '@/assets/lifashi.svg';
import custom from '@/assets/custom.svg';
import Carousel from 'components/carousel'

const HomePage = () => {
  const [isRegister, setIsRegister] = useState(false)
  const { address: account  } = useAccount()
  const [animatelLeft, setAnimateLeft] = useState('')
  const [animatelRight, setAnimateRight] = useState('')
  const homeRef = useRef('')

  useEffect(() => {
    checkRegisteredMerchant(account).then((res) => {
      setIsRegister(res)
    })
  }, [account])

  const onRegister = () => {
    console.log('isRegister', isRegister);
    if (!isRegister) {
      MerchantRegistration().then(() => {
       console.log("merchantRegistration success!")
     }).catch(err => {
       console.log("merchantRegistration failed!", err)
     })
    }
  }
  
  
  useEffect(() => {
	const homeRefEl = homeRef.current
	let observer = new IntersectionObserver((entries) => {
		entries.forEach((entry) => {
			if (entry.isIntersecting) {
				setAnimateLeft('animate__slideInLeft')
				setAnimateRight('animate__slideInRight')
			}
		});
	});
    observer.observe(homeRefEl)
    return () => {
		observer.unobserve(homeRefEl)
    };
  }, [])

  return(
    <div className='home'>
      <h1 className="animate__animated animate__zoomIn home-title">WIN-WIN Card System</h1>
      <Carousel></Carousel>
      <div className='home-content' ref={homeRef}>
        <img className={`animate__animated ${animatelLeft} lifashi`} src={lifashi}  />
        <Space align="center" size="large">
          <Link to="/merchant">
            <Button onClick={onRegister} className="entry-button" size="large" ghost>
              Merchant
            </Button>
          </Link>
          <Link to="/buyer">
            <Button className="entry-button" size="large" ghost>
              Buyer/Seller
            </Button>
          </Link>
        </Space>
        <img className={`animate__animated ${animatelRight} custom`} src={custom}  />
      </div>
      <h1 className='about-us'>About US</h1>
    </div>
  )
}

export default HomePage