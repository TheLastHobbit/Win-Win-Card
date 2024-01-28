import {
  assert,
  describe,
  test,
  clearStore,
  beforeAll,
  afterAll
} from "matchstick-as/assembly/index"
import { Address, BigInt } from "@graphprotocol/graph-ts"
import { CancelOrder } from "../generated/schema"
import { CancelOrder as CancelOrderEvent } from "../generated/CardMarket/CardMarket"
import { handleCancelOrder } from "../src/card-market"
import { createCancelOrderEvent } from "./card-market-utils"

// Tests structure (matchstick-as >=0.5.0)
// https://thegraph.com/docs/en/developer/matchstick/#tests-structure-0-5-0

describe("Describe entity assertions", () => {
  beforeAll(() => {
    let seller = Address.fromString(
      "0x0000000000000000000000000000000000000001"
    )
    let busName = "Example string value"
    let tokenId = BigInt.fromI32(234)
    let newCancelOrderEvent = createCancelOrderEvent(seller, busName, tokenId)
    handleCancelOrder(newCancelOrderEvent)
  })

  afterAll(() => {
    clearStore()
  })

  // For more test scenarios, see:
  // https://thegraph.com/docs/en/developer/matchstick/#write-a-unit-test

  test("CancelOrder created and stored", () => {
    assert.entityCount("CancelOrder", 1)

    // 0xa16081f360e3847006db660bae1c6d1b2e17ec2a is the default address used in newMockEvent() function
    assert.fieldEquals(
      "CancelOrder",
      "0xa16081f360e3847006db660bae1c6d1b2e17ec2a-1",
      "seller",
      "0x0000000000000000000000000000000000000001"
    )
    assert.fieldEquals(
      "CancelOrder",
      "0xa16081f360e3847006db660bae1c6d1b2e17ec2a-1",
      "busName",
      "Example string value"
    )
    assert.fieldEquals(
      "CancelOrder",
      "0xa16081f360e3847006db660bae1c6d1b2e17ec2a-1",
      "tokenId",
      "234"
    )

    // More assert options:
    // https://thegraph.com/docs/en/developer/matchstick/#asserts
  })
})
