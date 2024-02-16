import { useAccount, useEnsName } from 'wagmi'

function Profile() {
  const { address } = useAccount()
  return <div>{ address }</div>
}

export default Profile