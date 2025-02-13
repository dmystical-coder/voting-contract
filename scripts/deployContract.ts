import { ethers } from "hardhat";


async function deployContract() {

    const voting = await ethers.deployContract("Voting", ["0x43cBf70b97001C8d888409746490B7917eab6B8d", "0x2cf12dc6cc58d416e58fcfebd2e4799f3c31728d5327a3dacf12170f8511336c"]);

    await voting.waitForDeployment();

    console.log("Voting Contract deployed to:", voting.target);
}


deployContract().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});