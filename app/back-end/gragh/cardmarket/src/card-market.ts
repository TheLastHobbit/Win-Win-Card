import {
  CancelOrder as CancelOrderEvent,
  ChangePrice as ChangePriceEvent,
  Deal as DealEvent,
  NewOrder as NewOrderEvent
} from "../generated/CardMarket/CardMarket"
import { CancelOrder, ChangePrice, Deal, NewOrder } from "../generated/schema"

export function handleCancelOrder(event: CancelOrderEvent): void {
  let entity = new CancelOrder(
    event.transaction.hash.concatI32(event.logIndex.toI32())
  )
  entity.seller = event.params.seller
  entity.busName = event.params.busName
  entity.tokenId = event.params.tokenId

  entity.blockNumber = event.block.number
  entity.blockTimestamp = event.block.timestamp
  entity.transactionHash = event.transaction.hash

  entity.save()
}

export function handleChangePrice(event: ChangePriceEvent): void {
  let entity = new ChangePrice(
    event.transaction.hash.concatI32(event.logIndex.toI32())
  )
  entity.seller = event.params.seller
  entity.busName = event.params.busName
  entity.tokenId = event.params.tokenId
  entity.previousPrice = event.params.previousPrice
  entity.price = event.params.price

  entity.blockNumber = event.block.number
  entity.blockTimestamp = event.block.timestamp
  entity.transactionHash = event.transaction.hash

  entity.save()
}

export function handleDeal(event: DealEvent): void {
  let entity = new Deal(
    event.transaction.hash.concatI32(event.logIndex.toI32())
  )
  entity.buyer = event.params.buyer
  entity.seller = event.params.seller
  entity.busName = event.params.busName
  entity.tokenId = event.params.tokenId
  entity.price = event.params.price

  entity.blockNumber = event.block.number
  entity.blockTimestamp = event.block.timestamp
  entity.transactionHash = event.transaction.hash

  entity.save()
}

export function handleNewOrder(event: NewOrderEvent): void {
  let entity = new NewOrder(
    event.transaction.hash.concatI32(event.logIndex.toI32())
  )
  entity.seller = event.params.seller
  entity.busName = event.params.busName
  entity.tokenId = event.params.tokenId
  entity.price = event.params.price

  entity.blockNumber = event.block.number
  entity.blockTimestamp = event.block.timestamp
  entity.transactionHash = event.transaction.hash

  entity.save()
}
