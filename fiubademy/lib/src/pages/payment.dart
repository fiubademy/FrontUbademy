import 'dart:math';

import 'package:fiubademy/src/services/auth.dart';
import 'package:fiubademy/src/services/server.dart';
import 'package:fiubademy/src/services/user.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class Wallet {
  final String _address;

  Wallet.fromMap(Map<String, dynamic> walletData)
      : _address = walletData['address'];

  String get address => _address;
}

class PaymentPage extends StatefulWidget {
  const PaymentPage({Key? key}) : super(key: key);

  @override
  _PaymentPageState createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  Wallet? _wallet;

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
        const SizedBox(height: 8.0),
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
            'We have deposited 0.001 ETH into your virtual wallet for you to use freely.',
            style: Theme.of(context).textTheme.subtitle1,
          ),
        ),
        const SizedBox(height: 16.0),
        Align(
          alignment: Alignment.centerRight,
          child: Text('- Ubademy Team',
              style: Theme.of(context).textTheme.subtitle1),
        ),
        const SizedBox(height: 8.0),
      ],
    );
  }

  Widget _buildBalance(context) {
    return FutureBuilder(
      future: Server.getWalletBalance(_wallet!.address),
      builder: (context, AsyncSnapshot<double?> snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.waiting:
            return const SizedBox.shrink();
          default:
            if (snapshot.hasError) {
              return const SizedBox.shrink();
            }
            if (snapshot.data == null) {
              return const SizedBox.shrink();
            }

            double balance = snapshot.data!;

            return Column(children: [
              const SizedBox(height: 24.0),
              const Text('MY BALANCE',
                  style: TextStyle(color: Colors.black54, fontSize: 20)),
              const SizedBox(height: 16.0),
              Center(
                child: Text(
                  '$balance'.substring(0, min('$balance'.length, 8)) + ' ETH',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.secondaryVariant,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
              ),
              const SizedBox(height: 16.0),
            ]);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
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
                  return Center(
                    child: Column(
                      children: [
                        const Text('Failed to load user wallet'),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {});
                          },
                          child: const Text('TRY AGAIN'),
                        ),
                      ],
                    ),
                  );
                }
                return ListView(
                  padding: const EdgeInsets.fromLTRB(16.0, 24.0, 16.0, 16.0),
                  children: [
                    WalletCard(wallet: _wallet!),
                    _buildBalance(context),
                    const Divider(),
                    _buildGiftMessage(context),
                    const Divider(),
                    const SizedBox(height: 8.0),
                    SubscriptionPayment(onPay: () => setState(() {})),
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
            ),
          ],
        ),
      );
    });
  }
}

class SubscriptionPayment extends StatefulWidget {
  final VoidCallback onPay;

  const SubscriptionPayment({Key? key, required this.onPay}) : super(key: key);

  @override
  _SubscriptionPaymentState createState() => _SubscriptionPaymentState();
}

class _SubscriptionPaymentState extends State<SubscriptionPayment> {
  bool _isLoading = false;

  void _paySubscription(int subscriptionLevel) async {
    setState(() {
      _isLoading = true;
    });
    Auth auth = Provider.of<Auth>(context, listen: false);
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    String? result = await Server.paySubscription(auth, subscriptionLevel);

    if (!mounted) return;
    if (result != null) {
      final snackBar = SnackBar(
        content: Text(result),
      );
      scaffoldMessenger.showSnackBar(snackBar);
    } else {
      await _updateSubscription(subscriptionLevel);
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _updateSubscription(int subscriptionLevel) async {
    Auth auth = Provider.of<Auth>(context, listen: false);
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    String? result = await Server.updateSubscription(auth, subscriptionLevel);

    if (!mounted) return;
    if (result != null) {
      const snackBar = SnackBar(
        content: Text(
            'Failed to update subscription level. Please contact with the Ubademy developers'),
      );
      scaffoldMessenger.showSnackBar(snackBar);
    } else {
      Provider.of<User>(context, listen: false).subscriptionLevel =
          subscriptionLevel;
      Provider.of<User>(context, listen: false).subscriptionExpirationDate =
          DateTime.now().add(const Duration(days: 30));
      widget.onPay();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<User>(builder: (context, user, child) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Subscriptions', style: Theme.of(context).textTheme.headline6),
          ListTile(
            contentPadding: const EdgeInsets.all(0),
            title: user.subscriptionLevel == 0
                ? const Text('No subscription active')
                : Text(user.subscriptionName),
            subtitle: user.subscriptionLevel == 0
                ? null
                : Text(
                    'Expires on ${user.expirationDay} ${user.expirationMonthName} ${user.expirationYear}'),
          ),
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : LayoutBuilder(
                  builder: (context, constraints) {
                    return IntrinsicHeight(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          if (user.subscriptionLevel < 1)
                            SizedBox(
                              width: constraints.maxWidth / 2.2,
                              child: AspectRatio(
                                aspectRatio: 1.0,
                                child: Container(
                                  child: ClipRect(
                                    child: Stack(
                                      alignment: const Alignment(0, -0.30),
                                      children: [
                                        IconButton(
                                          iconSize: constraints.maxWidth / 5,
                                          onPressed: () {
                                            showDialog<String>(
                                              context: context,
                                              builder: (context) => AlertDialog(
                                                  title: const Text(
                                                      'Buy Standard Subscription'),
                                                  content:
                                                      const SingleChildScrollView(
                                                    child: Text(
                                                        'Are you sure you want to buy 30 days of a Standard Subscription? Price: 0.0001 ETH'
                                                        '\n\n'
                                                        'By doing so, you will gain access to all Standard Subscription courses.'
                                                        'In the scenario that your subscription ends, don\'t worry, your progress is saved for the next time you meet the course requirements.'
                                                        'But you can also pay in advance before the subscription ends to add 30 days more on top of your current subscription end date.'
                                                        '\n\n'
                                                        'Your subscription is at any moment the most expensive one with still time left. Be careful with buying both Premium and Standard Subscriptions, since you might lose days worth of them.'),
                                                  ),
                                                  actions: [
                                                    TextButton(
                                                      onPressed: () {
                                                        Navigator.pop(context);
                                                      },
                                                      child:
                                                          const Text('CANCEL'),
                                                    ),
                                                    ElevatedButton(
                                                      onPressed: () {
                                                        _paySubscription(1);
                                                        Navigator.pop(context);
                                                      },
                                                      child: const Text('BUY'),
                                                    ),
                                                  ]),
                                            );
                                          },
                                          icon: Icon(
                                              Icons.monetization_on_outlined,
                                              color: Colors.grey[400]),
                                        ),
                                        Align(
                                          alignment: const Alignment(0, 0.8),
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
                          if (user.subscriptionLevel < 1)
                            Container(
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 8),
                                height: constraints.maxWidth / 2.5,
                                width: 1,
                                color: Colors.black12),
                          if (user.subscriptionLevel < 2)
                            SizedBox(
                              width: constraints.maxWidth / 2.2,
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
                                            onPressed: () {
                                              showDialog<String>(
                                                context: context,
                                                builder: (context) =>
                                                    AlertDialog(
                                                        title: const Text(
                                                            'Buy Premium Subscription'),
                                                        content:
                                                            const SingleChildScrollView(
                                                          child: Text(
                                                              'Are you sure you want to buy 30 days of a Premium Subscription? Price: 0.00015 ETH'
                                                              '\n\n'
                                                              'By doing so, you will gain access to all Premium Subscription courses.'
                                                              'In the scenario that your subscription ends, don\'t worry, your progress is saved for the next time you meet the course requirements.'
                                                              'But you can also pay in advance before the subscription ends to add 30 days more on top of your current subscription end date.'
                                                              '\n\n'
                                                              'Your subscription is at any moment the most expensive one with still time left. Be careful with buying both Premium and Standard Subscriptions, since you might lose days worth of them.'),
                                                        ),
                                                        actions: [
                                                      TextButton(
                                                        onPressed: () {
                                                          Navigator.pop(
                                                              context);
                                                        },
                                                        child: const Text(
                                                            'CANCEL'),
                                                      ),
                                                      ElevatedButton(
                                                        onPressed: () {
                                                          _paySubscription(2);
                                                          Navigator.pop(
                                                              context);
                                                        },
                                                        child:
                                                            const Text('BUY'),
                                                      ),
                                                    ]),
                                              );
                                            },
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
                  },
                ),
        ],
      );
    });
  }
}
