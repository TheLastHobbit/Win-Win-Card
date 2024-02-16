import { createBrowserRouter } from "react-router-dom";
import Home from "pages/home";

const routes = createBrowserRouter([
  {
    path: "/",
    Component: Home,
  },
]);

export default routes;
