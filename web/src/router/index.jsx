import { Routes, Route, Link } from "react-router-dom";
import Home from "pages/home";
import Merchant from "pages/merchant";
import Buyer from "pages/buyer";
import Market from "pages/market";

const RoutesApp = () => {
  return (
    <Routes>
      <Route path="/" element={<Home />} />
      <Route path="/merchant" element={<Merchant />} />
      <Route path="/buyer" element={<Buyer />} />
      <Route path="/market" element={<Market />} />
      <Route path="*" element={<NoMatch />} />
    </Routes>
  );
};

function NoMatch() {
  return (
    <div>
      <h2>Nothing to see here!</h2>
      <p>
        <Link to="/">Go to the home page</Link>
      </p>
    </div>
  );
}

export default RoutesApp;
