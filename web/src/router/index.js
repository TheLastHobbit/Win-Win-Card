import { createBrowserRouter } from "react-router-dom";
import Home from "pages/home";
import Merchant from "pages/merchant";
import Buyer from "pages/buyer";

const routes = createBrowserRouter([
  {
    path: "/",
    Component: Home,
  },
  {
    path: "/merchant",
    Component: Merchant,
  },
  {
    path: "/buyer",
    Component: Buyer,
  },
]);

export default routes;
