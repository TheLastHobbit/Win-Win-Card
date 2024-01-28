import { newMockEvent } from "matchstick-as"
import { ethereum, Address, BigInt } from "@graphprotocol/graph-ts"
import {
  CancelOrder,
  ChangePrice,
  Deal,
  NewOrder
} from "../generated/CardMarket/CardMarket"

export function createCancelOrderEvent(
  seller: Address,
  busName: string,
  tokenId: BigInt
): CancelOrder {
  let cancelOrderEvent = changetype<CancelOrder>(newMockEvent())

  cancelOrderEvent.parameters = new Array()

  cancelOrderEvent.parameters.push(
    new ethereum.EventParam("seller", ethereum.Value.fromAddress(seller))
  )
  cancelOrderEvent.parameters.push(
    new ethereum.EventParam("busName", ethereum.Value.fromString(busName))
  )
  cancelOrderEvent.parameters.push(
    new ethereum.EventParam(
      "tokenId",
      ethereum.Value.fromUnsignedBigInt(tokenId)
    )
  )

  return cancelOrderEvent
}

export function createChangePriceEvent(
  seller: Address,
  busName: string,
  tokenId: BigInt,
  previousPrice: BigInt,
  price: BigInt
): ChangePrice {
  let changePriceEvent = changetype<ChangePrice>(newMockEvent())

  changePriceEvent.parameters = new Array()

  changePriceEvent.parameters.push(
    new ethereum.EventParam("seller", ethereum.Value.fromAddress(seller))
  )
  changePriceEvent.parameters.push(
    new ethereum.EventParam("busName", ethereum.Value.fromString(busName))
  )
  changePriceEvent.parameters.push(
    new ethereum.EventParam(
      "tokenId",
      ethereum.Value.fromUnsignedBigInt(tokenId)
    )
  )
  changePriceEvent.parameters.push(
    new ethereum.EventParam(
      "previousPrice",
      ethereum.Value.fromUnsignedBigInt(previousPrice)
    )
  )
  changePriceEvent.parameters.push(
    new ethereum.EventParam("price", ethereum.Value.fromUnsignedBigInt(price))
  )

  return changePriceEvent
}

export function createDealEvent(
  buyer: Address,
  seller: Address,
  busName: string,
  tokenId: BigInt,
  price: BigInt
): Deal {
  let dealEvent = changetype<Deal>(newMockEvent())

  dealEvent.parameters = new Array()

  dealEvent.parameters.push(
    new ethereum.EventParam("buyer", ethereum.Value.fromAddress(buyer))
  )
  dealEvent.parameters.push(
    new ethereum.EventParam("seller", ethereum.Value.fromAddress(seller))
  )
  dealEvent.parameters.push(
    new ethereum.EventParam("busName", ethereum.Value.fromString(busName))
  )
  dealEvent.parameters.push(
    new ethereum.EventParam(
      "tokenId",
      ethereum.Value.fromUnsignedBigInt(tokenId)
    )
  )
  dealEvent.parameters.push(
    new ethereum.EventParam("price", ethereum.Value.fromUnsignedBigInt(price))
  )

  return dealEvent
}

export function createNewOrderEvent(
  seller: Address,
  busName: string,
  tokenId: BigInt,
  price: BigInt
): NewOrder {
  let newOrderEvent = changetype<NewOrder>(newMockEvent())

  newOrderEvent.parameters = new Array()

  newOrderEvent.parameters.push(
    new ethereum.EventParam("seller", ethereum.Value.fromAddress(seller))
  )
  newOrderEvent.parameters.push(
    new ethereum.EventParam("busName", ethereum.Value.fromString(busName))
  )
  newOrderEvent.parameters.push(
    new ethereum.EventParam(
      "tokenId",
      ethereum.Value.fromUnsignedBigInt(tokenId)
    )
  )
  newOrderEvent.parameters.push(
    new ethereum.EventParam("price", ethereum.Value.fromUnsignedBigInt(price))
  )

  return newOrderEvent
}
