import { RouterProvider } from "react-router-dom";
import RouterApp from "./router";
import Header from 'components/header';
import { BrowserRouter } from "react-router-dom";

function App() {
  return (
    <BrowserRouter>
      <Header></Header>
      <RouterApp />
    </BrowserRouter>
  )
}

export default App
