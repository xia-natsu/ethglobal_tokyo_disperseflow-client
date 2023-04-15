const getWeb3 = async () => {
  return new Promise(async (resolve, reject) => {
    const web3 = new Web3(window.ethereum);
    try {
      await window.ethereum.request({ method: "eth_requestAccounts" });
      resolve(web3);
    } catch (error) {
      reject(error);
    }
  });
};
window.addEventListener('load', async () => {


if (window.ethereum) {
				window.web3 = new Web3(window.ethereum);
				await window.ethereum.enable();
			} else if (window.web3) {
				window.web3 = new Web3(window.web3.currentProvider);
			} else {
				console.log('Non-Ethereum browser detected. You should consider trying MetaMask!');
			}
  
});


document.addEventListener("DOMContentLoaded", () => {
     const connectButton = document.getElementById("connectBtn");
const updateButton = (wallet_connected) => {
      if (wallet_connected) {
        connectButton.innerText = "Connected to Metamask";
        connectButton.style.backgroundColor = "#4CAF50";
        connectButton.style.color = "white";
      } else {
        connectButton.innerText = "Connect to Metamask";
        connectButton.style.backgroundColor = "#f44336";
        connectButton.style.color = "white";
      }
    };
    
  document.getElementById("connectBtn").addEventListener("click", async({ target }) => {
    const web3 = await getWeb3()
    const accounts = await web3.eth.getAccounts();
    const walletAddress = await web3.eth.requestAccounts();
    const wallet_connected = accounts.length > 0;
    const walletBalanceInWei = await web3.eth.getBalance(walletAddress[0]);
    const walletBalanceInEth = Math.round(Web3.utils.fromWei(walletBalanceInWei) * 1000) / 1000;
    
    <!-- target.setAttribute("hidden", "hidden") -->
     
    document.getElementById("wallet_address").innerText = walletAddress
    document.getElementById("wallet_balance").innerText = walletBalanceInEth
    document.getElementById("wallet_info").removeAttribute("hidden")
    
    updateButton(wallet_connected);

  })
});

const getContract = async (web3) => {
  const data = await $.getJSON("./contracts/DisperseFlow.json");
  const addr = '0xe474dC7bDae1BF2c0d7739483Db25D32a927A598'
  const flow = new web3.eth.Contract(
    data.abi,addr
  );
  return flow;
};


const registerUser = async (contract, accounts) => {
  let input;
  $("#input").on("change", (e) => {
    input = e.target.value;
  });
  $("#form_register").on("submit", async (e) => {
    console.log('registering:' +input)
    e.preventDefault();
    await contract.methods
      .register(input)
      .send({ from: accounts[0], gas: 10000000 });
  });
};

const createUserFlow = async (contract, accounts) => {
  let input;
  $("#input_create_userflow").on("change", (e) => {
    input = e.target.value;
  });
  $("#form_create_userflow").on("submit", async (e) => {
    console.log('Create flow:' +input)
    e.preventDefault();
    await contract.methods
      .disperseTokenByAccount('0x96B82B65ACF7072eFEb00502F45757F254c2a0D4', [input], [10])
      .send({ from: accounts[0], gas: 500000000 });
  });
};
async function greetingApp() {
  const web3 = await getWeb3();
  const accounts = await web3.eth.getAccounts();
  const contract = await getContract(web3);
  console.log('Contract loaded')

  registerUser(contract, accounts);
  createUserFlow(contract, accounts);
}

greetingApp();

