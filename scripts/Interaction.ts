// Deploy the contract and interact with it

import { ethers } from "hardhat";


const TOKEN_ADDRESS = "0x43cBf70b97001C8d888409746490B7917eab6B8d"




async function deployVotingContract() {

    const voting = await ethers.deployContract("Voting", [, 1000]);

    await voting.waitForDeployment();

    console.log("Voting Contract deployed to:", voting.target);
    return await ethers.getContractAt("Voting", voting.target);
}

// Main function to execute all operations in sequence
async function main() {
    try {
        console.log("Deploying PVC token to be used for voting...");
        const createHash = await deployPvc();

        console.log("Create Event Transaction Hash:", createHash);
        await new Promise(resolve => setTimeout(resolve, 5000));
        const registerHash = await registerEvent();
        console.log("Register Event Transaction Hash:", registerHash);
        await new Promise(resolve => setTimeout(resolve, 5000));
        const verifyHash = await verifyTicket();
        console.log("Verify Ticket Transaction Hash:", verifyHash);
        await new Promise(resolve => setTimeout(resolve, 5000));
        const withdrawHash = await withdrawEvent();
        console.log("Withdraw Event Transaction Hash:", withdrawHash);
        console.log("\nAll operations completed successfully!");
    } catch (error) {
        console.error("Error in execution:", error);
        throw error;
    }
}


main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});