async function main(){
    const [deployer] = await ethers.getSigners()
    console.log("Deploying contracts with the account:", deployer.address);

    console.log("Account balance:", (await deployer.provider.getBalance(deployer.address)).toString());

    const Token = await ethers.getContractFactory("CELEVENT");
    const token = await Token.deploy();
    console.log("Deployment transaction:", token.deployTransaction);
    
    await token.deployed(); // Ensure the contract is deployed before trying to access its address.
    console.log("Token address:", token.address);
}

main().then(()=>process.exit(0)).catch((error)=>{
    console.error(error);
    process.exit(1);
})