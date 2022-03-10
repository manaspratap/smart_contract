import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:web3dart/web3dart.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int totalDeposits = 0, installmentAmount = 3;
  double? balance = 0;

  late Client httpClient;
  late Web3Client? ethClient;
  // JSON-RPC is a remote procedure call protocol encoded in JSON
  // Remote Procedure Call (RPC) is about executing a block of code on another server
  String rpcUrl = 'http://0.0.0.0:7545';

  int? myBalance;

  @override
  void initState() {
    initialSetup();
    super.initState();
  }

  Future<void> initialSetup() async {
    /// This will start a client that connects to a JSON RPC API, available at RPC URL.
    /// The httpClient will be used to send requests to the [RPC server].
    httpClient = Client();

    /// It connects to an Ethereum [node] to send transactions, interact with smart contracts, and much more!
    ethClient = Web3Client(rpcUrl, httpClient);

    await getCredentials();
    await getDeployedContract();
    await getContractFunctions();
  }

  /// This will construct [credentials] with the provided [privateKey]
  /// and load the Ethereum address in [myAdderess] specified by these credentials.
  String privateKey =
      '1bbb13ba812d93b4ef0835b4fff8005d73c213d01e123e4ed952444ccca506d4';
  // Credentials? credentials;
  // EthereumAddress? myAddress;

  Future<void> getCredentials() async {
    // credentials = await ethClient?.credentialsFromPrivateKey(privateKey);
    // myAddress = await credentials?.extractAddress();
  }

  /// This will parse an Ethereum address of the contract in [contractAddress]
  /// from the hexadecimal representation present inside the [ABI]
  String? abi;
  EthereumAddress? contractAddress;

  Future<void> getDeployedContract() async {
    String abiString = await rootBundle.loadString('src/abis/Investment.json');
    var abiJson = jsonDecode(abiString);
    abi = jsonEncode(abiJson['abi']);

    contractAddress =
        EthereumAddress.fromHex(abiJson['networks']['5777']['address']);
  }

  /// This will help us to find all the [public functions] defined by the [contract]
  DeployedContract? contract;
  ContractFunction? getBalanceAmount,
      getDepositAmount,
      addDepositAmount,
      withdrawBalance;

  Future<void> getContractFunctions() async {

    if (abi != null && contractAddress != null ) {
      contract =
          DeployedContract(ContractAbi.fromJson(abi ?? "", "Investment"), contractAddress!);
    }


    getBalanceAmount = contract?.function('getBalanceAmount');
    getDepositAmount = contract?.function('getDepositAmount');
    addDepositAmount = contract?.function('addDepositAmount');
    withdrawBalance = contract?.function('withdrawBalance');
  }

  /// This will call a [functionName] with [functionArgs] as parameters
  /// defined in the [contract] and returns its result
  Future<List<dynamic>?> readContract(
      ContractFunction functionName,
      List<dynamic> functionArgs,
      ) async {

    // if (contract != null) {
    //   return await ethClient?.call(
    //     sender: myAddress,
    //     contract: contract!,
    //     function: functionName,
    //     params: functionArgs,
    //   );
    // }
    return null;
  }

  /// Signs the given transaction using the keys supplied in the [credentials] object
  /// to upload it to the client so that it can be executed
  Future<void> writeContract(
      ContractFunction functionName,
      List<dynamic> functionArgs,
      ) async {

    // if (credentials != null && contract != null) {
    //   await ethClient?.sendTransaction(
    //     credentials!,
    //     Transaction.callContract(
    //       contract: contract!,
    //       function: functionName,
    //       parameters: functionArgs,
    //     ),
    //   );
    // }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [Colors.red, Colors.yellow],
            ),
          ),
          child: Column(
            children: [
              Expanded(
                child: Align(
                  alignment: Alignment.center,
                  child: Text(
                    'SMART CONTRACT',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              // show balance
              Expanded(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Text(
                    '₹ $balance',
                    style: TextStyle(
                      fontSize: 80,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              // update balance
              Expanded(
                child: Align(
                  alignment: Alignment.topCenter,
                  child: FloatingActionButton.extended(
                    heroTag: 'check_balance',
                    onPressed: () async {
                      var contractBalance = await ethClient?.
                      getBalance(EthereumAddress.fromHex('0xF860A2953f79cF00e18e168A438C0d796D543B4e'));
                      balance = contractBalance?.getInEther.toDouble() ?? 0;
                      setState(() {});
                    },
                    label: Text('Check Balance'),
                    icon: Icon(Icons.refresh),
                    backgroundColor: Colors.pink,
                  ),
                ),
              ),
              // show deposits
              Expanded(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Text(
                    '₹ $totalDeposits',
                    style: TextStyle(
                      fontSize: 80,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              // update deposits
              Expanded(
                child: Align(
                  alignment: Alignment.topCenter,
                  child: FloatingActionButton.extended(
                    heroTag: 'check_deposits',
                    onPressed: () async {
                      if (getDepositAmount != null ) {
                        var result = await readContract(getDepositAmount!, []);
                        totalDeposits = result?.first?.toInt();
                        setState(() {});
                      }
                    },
                    label: Text('Check Deposits'),
                    icon: Icon(Icons.refresh),
                    backgroundColor: Colors.pink,
                  ),
                ),
              ),
              // deposit amount
              Expanded(
                child: Align(
                  alignment: Alignment.center,
                  child: SizedBox(
                    height: 100,
                    width: 250,
                    child: FittedBox(
                      fit: BoxFit.contain,
                      child: FloatingActionButton.extended(
                        heroTag: 'deposit_amount',
                        onPressed: () async {
                          if (addDepositAmount != null) {
                            await writeContract(addDepositAmount!,
                                [BigInt.from(installmentAmount)]);
                          }
                        },
                        label: Text('Deposit ₹ 3'),
                        icon: Icon(Icons.add_circle),
                        backgroundColor: Colors.green,
                      ),
                    ),
                  ),
                ),
              ),
              // withdraw balance
              Expanded(
                child: Align(
                  alignment: Alignment.center,
                  child: SizedBox(
                    height: 100,
                    width: 350,
                    child: FittedBox(
                      fit: BoxFit.contain,
                      child: FloatingActionButton.extended(
                        heroTag: 'withdraw_balance',
                        onPressed: () async {
                          if ( withdrawBalance != null ) {
                            await writeContract(withdrawBalance!, []);
                          }
                        },
                        label: Text('Withdraw Balance'),
                        icon: Icon(Icons.remove_circle),
                        backgroundColor: Colors.red,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}