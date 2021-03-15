import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:web3dart/web3dart.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Contract',
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int balance = 0, totalDeposits = 0, installmentAmount = 3;

  Client httpClient;
  Web3Client ethClient;
  String rpcUrl = 'http://0.0.0.0:7545';

  String privateKey =
      '26462ae4803020c6d5101f7f409888bed0c8153ea262a9479a8aabbcda03bd2c';
  Credentials credentials;
  EthereumAddress myAddress;

  String abi;
  EthereumAddress contractAddress;

  DeployedContract contract;
  ContractFunction getBalanceAmount,
      getDepositAmount,
      addDepositAmount,
      withdrawBalance;

  @override
  void initState() {
    initialSetup();
    super.initState();
  }

  Future<void> initialSetup() async {
    httpClient = Client();
    ethClient = Web3Client(rpcUrl, httpClient);

    await getCredentials();
    await getDeployedContract();
    await getContractFunctions();
  }

  Future<void> getCredentials() async {
    credentials = await ethClient.credentialsFromPrivateKey(privateKey);
    myAddress = await credentials.extractAddress();
  }

  Future<void> getDeployedContract() async {
    String abiString = await rootBundle.loadString('src/abis/Investment.json');
    var abiJson = jsonDecode(abiString);
    abi = jsonEncode(abiJson['abi']);

    contractAddress =
        EthereumAddress.fromHex(abiJson['networks']['5777']['address']);
  }

  Future<void> getContractFunctions() async {
    contract = DeployedContract(
        ContractAbi.fromJson(abi, "Investment"), contractAddress);

    getBalanceAmount = contract.function('getBalanceAmount');
    getDepositAmount = contract.function('getDepositAmount');
    addDepositAmount = contract.function('addDepositAmount');
    withdrawBalance = contract.function('withdrawBalance');
  }

  Future<List<dynamic>> readContract(
    ContractFunction functionName,
    List<dynamic> functionArgs,
  ) async {
    var queryResult = await ethClient.call(
      contract: contract,
      function: functionName,
      params: functionArgs,
    );

    return queryResult;
  }

  Future<void> writeContract(
    ContractFunction functionName,
    List<dynamic> functionArgs,
  ) async {
    await ethClient.sendTransaction(
      credentials,
      Transaction.callContract(
        contract: contract,
        function: functionName,
        parameters: functionArgs,
      ),
    );
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
                      var result = await readContract(getBalanceAmount, []);
                      balance = result?.first?.toInt();
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
                      var result = await readContract(getDepositAmount, []);
                      totalDeposits = result?.first?.toInt();
                      setState(() {});
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
                          await writeContract(addDepositAmount,
                              [BigInt.from(installmentAmount)]);
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
                          await writeContract(withdrawBalance, []);
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
