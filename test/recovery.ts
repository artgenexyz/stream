import { ethers } from "hardhat";

// NOT USED - just for reference

// impersonate buildship deployer
// deploy stream factory
// run recover()
// test that tx returned success
// check gas usage

const deployer_address = "0xb00919B963c5668c5eB526C034b3c3eA92FB3bB9";
const streamReceiverAddress = "0x98cde40f98e7c77507820c0caef055cc3cc3fa79";
const streamFactoryAddress = "0x1C4663902A55A8346B5bD1131d7405A3513944fD";

async function main() {

    const key = process.env.MAINNET_PRIVATE_KEY as string;
    const deployer = new ethers.Wallet(process.env.MAINNET_PRIVATE_KEY, ethers.provider);

    if (await deployer.getTransactionCount() != 4) {
        // let count = await deployer.getTransactionCount();
        // console.log('count', count);

        // // send 0 eth to itself until count is 3
        // while (count != 3) {
        //     await deployer.sendTransaction({
        //         to: deployer_address,
        //         value: 0,
        //         gasPrice: 300e9,
        //     });

        //     count++;
        // }

        if (await deployer.getTransactionCount() != 3) {
            throw new Error("nonce is not 3");
        }

        const fac = await ethers.getContractFactory("Factory");

        // predict address for Factory contract
        const factoryAddress = ethers.utils.getContractAddress({
            from: deployer_address,
            nonce: 3,
        });

        if (factoryAddress != streamFactoryAddress) {
            throw new Error("factory address mismatch: " + factoryAddress + " != " + streamFactoryAddress);
        }

        await fac.connect(deployer).deploy(); // nonce = 3

        // check that deployer nonce == 4
        const nonce = await deployer.getTransactionCount();
        console.log("nonce", nonce);

        if (nonce != 4) {
            throw new Error("nonce is not 4");
        }

    } else {
        console.log("nonce is 4");
    }

    // check that 0x1C4663902A55A8346B5bD1131d7405A3513944fD has code
    const code = await ethers.provider.getCode(streamFactoryAddress);

    if (code == "0x") {
        throw new Error("code is empty");
    }

    // check that streamReceiver balance is not zero
    const streamReceiverBalance = await ethers.provider.getBalance(streamReceiverAddress);

    if (streamReceiverBalance.eq(0)) {
        // throw new Error("streamReceiverBalance is zero");
    }

    const rec = await ethers.getContractFactory("Recovery");
    const recovery = await rec.connect(deployer).deploy();
    await recovery.deployed();

    const tx = await recovery.recover({ value: 1 /* wei */ });

    const receipt = await tx.wait();

    // print gas usage
    console.log("gas used", receipt.gasUsed.toString());

}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});

