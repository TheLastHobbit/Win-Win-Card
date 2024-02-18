import { RouterProvider } from "react-router-dom";
import routes from "./router";
import Header from 'components/header';

function App() {
  return (
    <div>
      <Header></Header>
      <RouterProvider router={routes} />
    </div>
  )
}

export default App
