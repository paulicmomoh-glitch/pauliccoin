import { describe, expect, it } from "vitest";
import { Cl } from "@stacks/transactions";

const accounts = simnet.getAccounts();
const deployer = accounts.get("deployer")!;
const wallet1 = accounts.get("wallet_1")!;
const wallet2 = accounts.get("wallet_2")!;
const wallet3 = accounts.get("wallet_3")!;

const contractName = "pauliccoin";

describe("PaulicCoin Token Contract Tests", () => {
  
  it("ensures contract is deployed and not initialized", () => {
    expect(simnet.blockHeight).toBeDefined();
    
    // Check that contract is not initialized yet
    const result = simnet.callReadOnlyFn(
      contractName,
      "is-initialized",
      [],
      deployer
    );
    expect(result.result).toEqual(Cl.ok(Cl.bool(false)));
  });

  it("can initialize the contract", () => {
    // Initialize the contract
    const initResult = simnet.callPublicFn(
      contractName,
      "initialize",
      [],
      deployer
    );
    expect(initResult.result).toEqual(Cl.ok(Cl.bool(true)));
    
    // Check that contract is now initialized
    const isInitialized = simnet.callReadOnlyFn(
      contractName,
      "is-initialized",
      [],
      deployer
    );
    expect(isInitialized.result).toEqual(Cl.ok(Cl.bool(true)));
    
    // Check deployer has the total supply
    const balance = simnet.callReadOnlyFn(
      contractName,
      "get-balance",
      [Cl.principal(deployer)],
      deployer
    );
    expect(balance.result).toEqual(Cl.ok(Cl.uint(100000000000000)));
  });

  it("prevents double initialization", () => {
    // Try to initialize again - should fail
    const initResult = simnet.callPublicFn(
      contractName,
      "initialize",
      [],
      deployer
    );
    expect(initResult.result).toEqual(Cl.err(Cl.uint(104))); // err-already-initialized
  });

  it("returns correct token metadata", () => {
    const name = simnet.callReadOnlyFn(
      contractName,
      "get-name",
      [],
      deployer
    );
    expect(name.result).toEqual(Cl.ok(Cl.stringAscii("PaulicCoin")));
    
    const symbol = simnet.callReadOnlyFn(
      contractName,
      "get-symbol",
      [],
      deployer
    );
    expect(symbol.result).toEqual(Cl.ok(Cl.stringAscii("PLIC")));
    
    const decimals = simnet.callReadOnlyFn(
      contractName,
      "get-decimals",
      [],
      deployer
    );
    expect(decimals.result).toEqual(Cl.ok(Cl.uint(8)));
    
    const totalSupply = simnet.callReadOnlyFn(
      contractName,
      "get-total-supply",
      [],
      deployer
    );
    expect(totalSupply.result).toEqual(Cl.ok(Cl.uint(100000000000000)));
  });

  it("can transfer tokens", () => {
    const transferAmount = 1000000000; // 10 PLIC (with 8 decimals)
    
    // Transfer from deployer to wallet1
    const transferResult = simnet.callPublicFn(
      contractName,
      "transfer",
      [Cl.uint(transferAmount), Cl.principal(wallet1)],
      deployer
    );
    expect(transferResult.result).toEqual(Cl.ok(Cl.bool(true)));
    
    // Check balances
    const wallet1Balance = simnet.callReadOnlyFn(
      contractName,
      "get-balance",
      [Cl.principal(wallet1)],
      deployer
    );
    expect(wallet1Balance.result).toEqual(Cl.ok(Cl.uint(transferAmount)));
    
    const deployerBalance = simnet.callReadOnlyFn(
      contractName,
      "get-balance",
      [Cl.principal(deployer)],
      deployer
    );
    expect(deployerBalance.result).toEqual(Cl.ok(Cl.uint(100000000000000 - transferAmount)));
  });

  it("prevents transfer with insufficient balance", () => {
    const largeAmount = 200000000000000; // More than total supply
    
    const transferResult = simnet.callPublicFn(
      contractName,
      "transfer",
      [Cl.uint(largeAmount), Cl.principal(wallet2)],
      wallet1
    );
    expect(transferResult.result).toEqual(Cl.err(Cl.uint(101))); // err-insufficient-balance
  });

  it("prevents transfer of zero amount", () => {
    const transferResult = simnet.callPublicFn(
      contractName,
      "transfer",
      [Cl.uint(0), Cl.principal(wallet2)],
      deployer
    );
    expect(transferResult.result).toEqual(Cl.err(Cl.uint(102))); // err-invalid-amount
  });

  it("can approve and use allowances", () => {
    const allowanceAmount = 500000000; // 5 PLIC
    
    // Deployer approves wallet2 to spend from their account
    const approveResult = simnet.callPublicFn(
      contractName,
      "approve",
      [Cl.principal(wallet2), Cl.uint(allowanceAmount)],
      deployer
    );
    expect(approveResult.result).toEqual(Cl.ok(Cl.bool(true)));
    
    // Check allowance
    const allowance = simnet.callReadOnlyFn(
      contractName,
      "get-allowance",
      [Cl.principal(deployer), Cl.principal(wallet2)],
      deployer
    );
    expect(allowance.result).toEqual(Cl.ok(Cl.uint(allowanceAmount)));
    
    // wallet2 can now transfer from deployer to wallet3
    const transferFromResult = simnet.callPublicFn(
      contractName,
      "transfer-from",
      [Cl.principal(deployer), Cl.principal(wallet3), Cl.uint(allowanceAmount)],
      wallet2
    );
    expect(transferFromResult.result).toEqual(Cl.ok(Cl.bool(true)));
    
    // Check that allowance is now zero
    const newAllowance = simnet.callReadOnlyFn(
      contractName,
      "get-allowance",
      [Cl.principal(deployer), Cl.principal(wallet2)],
      deployer
    );
    expect(newAllowance.result).toEqual(Cl.ok(Cl.uint(0)));
    
    // Check wallet3 received the tokens
    const wallet3Balance = simnet.callReadOnlyFn(
      contractName,
      "get-balance",
      [Cl.principal(wallet3)],
      deployer
    );
    expect(wallet3Balance.result).toEqual(Cl.ok(Cl.uint(allowanceAmount)));
  });

  it("prevents transfer-from without sufficient allowance", () => {
    const transferAmount = 1000000000; // 10 PLIC
    
    // wallet1 tries to transfer from deployer without allowance
    const transferFromResult = simnet.callPublicFn(
      contractName,
      "transfer-from",
      [Cl.principal(deployer), Cl.principal(wallet1), Cl.uint(transferAmount)],
      wallet1
    );
    expect(transferFromResult.result).toEqual(Cl.err(Cl.uint(103))); // err-unauthorized
  });

  it("only owner can mint tokens", () => {
    const mintAmount = 1000000000; // 10 PLIC
    
    // Non-owner tries to mint - should fail
    const mintResult1 = simnet.callPublicFn(
      contractName,
      "mint",
      [Cl.uint(mintAmount), Cl.principal(wallet1)],
      wallet1
    );
    expect(mintResult1.result).toEqual(Cl.err(Cl.uint(100))); // err-owner-only
    
    // Owner mints successfully
    const mintResult2 = simnet.callPublicFn(
      contractName,
      "mint",
      [Cl.uint(mintAmount), Cl.principal(wallet1)],
      deployer
    );
    expect(mintResult2.result).toEqual(Cl.ok(Cl.bool(true)));
    
    // Check that tokens in circulation increased
    const circulation = simnet.callReadOnlyFn(
      contractName,
      "get-tokens-in-circulation",
      [],
      deployer
    );
    expect(circulation.result).toEqual(Cl.ok(Cl.uint(100000000000000 + mintAmount)));
  });

  it("can burn tokens from own balance", () => {
    const burnAmount = 500000000; // 5 PLIC
    
    // Get wallet1 balance before burn
    const balanceBefore = simnet.callReadOnlyFn(
      contractName,
      "get-balance",
      [Cl.principal(wallet1)],
      deployer
    );
    
    // wallet1 burns some tokens
    const burnResult = simnet.callPublicFn(
      contractName,
      "burn",
      [Cl.uint(burnAmount)],
      wallet1
    );
    expect(burnResult.result).toEqual(Cl.ok(Cl.bool(true)));
    
    // Check that balance decreased
    const balanceAfter = simnet.callReadOnlyFn(
      contractName,
      "get-balance",
      [Cl.principal(wallet1)],
      deployer
    );
    
    const beforeValue = balanceBefore.result as any;
    const afterValue = balanceAfter.result as any;
    expect(afterValue.value.value).toEqual(beforeValue.value.value - burnAmount);
    
    // Check that tokens in circulation decreased
    const circulation = simnet.callReadOnlyFn(
      contractName,
      "get-tokens-in-circulation",
      [],
      deployer
    );
    expect(circulation.result).toEqual(Cl.ok(Cl.uint(100000000000000 + 1000000000 - burnAmount)));
  });

  it("prevents burning more tokens than balance", () => {
    const largeAmount = 200000000000000; // More than any wallet has
    
    const burnResult = simnet.callPublicFn(
      contractName,
      "burn",
      [Cl.uint(largeAmount)],
      wallet2
    );
    expect(burnResult.result).toEqual(Cl.err(Cl.uint(101))); // err-insufficient-balance
  });

  it("returns correct contract owner", () => {
    const owner = simnet.callReadOnlyFn(
      contractName,
      "get-contract-owner",
      [],
      deployer
    );
    expect(owner.result).toEqual(Cl.ok(Cl.principal(deployer)));
  });
});
