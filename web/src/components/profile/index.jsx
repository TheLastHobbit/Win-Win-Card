import { useAccount } from 'wagmi'

function Profile() {
  const { address } = useAccount()
  return <div>{ address }</div>
}

export default Profile