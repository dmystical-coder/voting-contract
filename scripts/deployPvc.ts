import { ethers } from "hardhat";

async function deployPvc() {
    const pvc = await ethers.deployContract("Pvc");


    await pvc.waitForDeployment();

    console.log("PVC token Contract deployed to:", pvc.target);

}

deployPvc().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});