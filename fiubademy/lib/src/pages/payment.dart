import 'package:fiubademy/src/services/auth.dart';
import 'package:fiubademy/src/services/server.dart';
import 'package:fiubademy/src/services/user.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class Wallet {
  String _id;
  String _address;
  String _privateKey;

  Wallet.fromMap(Map<String, dynamic> walletData)
      : _id = walletData['_id'] ?? walletData['id'],
        _address = walletData['address'],
        _privateKey = walletData['privateKey'];

  String get address => _address;
}

class PaymentPage extends StatelessWidget {
  Wallet? _wallet;

  PaymentPage({Key? key}) : super(key: key);

  Future<void> _loadWallet(context) async {
    final _scaffoldMessenger = ScaffoldMessenger.of(context);
    Auth auth = Provider.of<Auth>(context, listen: false);
    Map<String, dynamic> result = await Server.getWallet(auth);

    if (result['error'] == null) {
      _wallet = Wallet.fromMap(result['content']);
    }

    if (result['error'] == 'Failed to get wallet. User has no wallet') {
      Map<String, dynamic> result = await Server.createWallet(auth);
      if (result['error'] != null) {
        _wallet = Wallet.fromMap(result['content']);
      }
    }

    if (_wallet == null) {
      final snackBar = SnackBar(content: Text(result['error']));
      _scaffoldMessenger.showSnackBar(snackBar);
      throw Exception('Failed to load user wallet');
    }
  }

  Widget _buildGiftMessage(context) {
    return Column(
      children: [
        const SizedBox(height: 16.0),
        const Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Merry Christmas!',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'We have deposited 0.0001 ETH into your virtual wallet for you to use freely.',
            style: Theme.of(context).textTheme.subtitle1,
          ),
        ),
        const SizedBox(height: 16.0),
        Align(
          alignment: Alignment.centerRight,
          child: Text('- Ubademy Team',
              style: Theme.of(context).textTheme.subtitle1),
        ),
        const SizedBox(height: 16.0),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    Auth auth = Provider.of<Auth>(context, listen: false);
    print(auth.userToken);
    return Scaffold(
      appBar: AppBar(title: const Text('Payment')),
      body: SafeArea(
        child: FutureBuilder(
          future: _loadWallet(context),
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.waiting:
                return const Center(child: CircularProgressIndicator());
              default:
                if (snapshot.hasError) {
                  return const Center(
                      child: Text('Failed to load user wallet'));
                }
                User user = Provider.of<User>(context, listen: false);
                return ListView(
                  padding: const EdgeInsets.fromLTRB(16.0, 24.0, 16.0, 16.0),
                  children: [
                    WalletCard(wallet: _wallet!),
                    const SizedBox(height: 16.0),
                    const Divider(),
                    _buildGiftMessage(context),
                    const Divider(),
                    const SizedBox(height: 8.0),
                    Text('Subscriptions',
                        style: Theme.of(context).textTheme.headline6),
                    Text('Current subscription: ${user.subscriptionName}'),
                    const SizedBox(height: 16.0),
                    LayoutBuilder(builder: (context, constraints) {
                      return IntrinsicHeight(
                        child: Row(
                          children: [
                            Expanded(
                              child: AspectRatio(
                                aspectRatio: 1.0,
                                child: Container(
                                  child: ClipRect(
                                    child: Stack(
                                      alignment: Alignment(0, -0.30),
                                      children: [
                                        IconButton(
                                          iconSize: constraints.maxWidth / 5,
                                          onPressed: () {},
                                          icon: Icon(
                                              Icons.monetization_on_outlined,
                                              color: Colors.grey[400]),
                                        ),
                                        Align(
                                          alignment: Alignment(0, 0.8),
                                          child: Text(
                                            'Standard',
                                            style: TextStyle(
                                              color: Colors.grey[700],
                                              fontWeight: FontWeight.bold,
                                              fontSize:
                                                  constraints.maxWidth / 12,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .secondaryVariant,
                                      width: 4,
                                    ),
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.5),
                                        spreadRadius: 2,
                                        blurRadius: 4,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Container(
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 8),
                                height: constraints.maxWidth / 2.5,
                                width: 1,
                                color: Colors.black12),
                            Expanded(
                              child: AspectRatio(
                                aspectRatio: 1.0,
                                child: Container(
                                  child: ClipRect(
                                    child: GestureDetector(
                                      onTap: () {},
                                      child: Stack(
                                        alignment: const Alignment(0, -0.30),
                                        children: [
                                          IconButton(
                                            iconSize: constraints.maxWidth / 5,
                                            onPressed: () {},
                                            icon: const Icon(
                                                Icons.monetization_on_outlined,
                                                color: Colors.amber),
                                          ),
                                          const Align(
                                            alignment: Alignment.topRight,
                                            child: Banner(
                                              color: Colors.green,
                                              location: BannerLocation.topEnd,
                                              message: '20% OFF',
                                            ),
                                          ),
                                          Align(
                                            alignment: const Alignment(0, 0.8),
                                            child: Text(
                                              'Premium',
                                              style: TextStyle(
                                                color: Colors.amber[700],
                                                fontWeight: FontWeight.bold,
                                                fontSize:
                                                    constraints.maxWidth / 12,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .secondaryVariant,
                                      width: 4,
                                    ),
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.5),
                                        spreadRadius: 2,
                                        blurRadius: 4,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    })
                  ],
                );
            }
          },
        ),
      ),
    );
  }
}

class WalletCard extends StatelessWidget {
  final Wallet wallet;

  const WalletCard({Key? key, required this.wallet}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      User user = Provider.of<User>(context, listen: false);
      return SizedBox(
        width: constraints.maxWidth,
        height: constraints.maxWidth * 0.6306075,
        child: Stack(
          children: [
            const Image(
              image: AssetImage('images/credit_card.png'),
            ),
            Align(
              alignment: const Alignment(1.05, -1.10),
              child: Image(
                height: constraints.maxWidth * 0.3,
                image: const AssetImage('images/ubademy_white.png'),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: ListTile(
                title: Text(
                  wallet.address,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                trailing: IconButton(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: wallet.address));
                    const snackBar = SnackBar(
                      content: Text('Wallet address copied to clipboard'),
                    );
                    ScaffoldMessenger.of(context).showSnackBar(snackBar);
                  },
                  icon: const Icon(Icons.copy, color: Colors.white),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.only(left: 16.0),
              width: constraints.maxWidth * 0.7,
              alignment: const Alignment(-1, -0.75),
              child: Text(
                user.username.toUpperCase(),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: 24,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.only(left: 16.0),
              width: constraints.maxWidth * 0.7,
              alignment: const Alignment(-1, -0.45),
              child: Text(
                user.email,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            )
          ],
        ),
      );
    });
  }
}
