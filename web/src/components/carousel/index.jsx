import { Component } from "react";
import ReactCardCarousel from "react-card-carousel";
import './index.css'
import photo1 from '@/assets/photo-1.jpeg';
import photo2 from '@/assets/photo-2.jpeg';
import photo3 from '@/assets/photo-3.jpeg';
import photo4 from '@/assets/photo-4.jpeg';

class MyCarousel extends Component {
 
  render() {
    return (
      <div className="carousel-wrapper">
        <ReactCardCarousel autoplay={true} autoplay_speed={2000}>
          <img className="card-img" src={photo1} />
          <img className="card-img" src={photo2} />
          <img className="card-img" src={photo3} />
          <img className="card-img" src={photo4} />
        </ReactCardCarousel>
      </div>
    );
  }
}
export default MyCarousel