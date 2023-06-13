import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../components/container.dart';
import '../components/scroll_view.dart';
import '../constants.dart';
import '../customer_io.dart';
import '../data/user.dart';
import '../random.dart';
import '../theme/sizes.dart';
import '../widgets/app_footer.dart';

class SignInScreen extends StatefulWidget {
  final ValueChanged<User> onSignIn;

  const SignInScreen({
    required this.onSignIn,
    super.key,
  });

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();

  String? _userAgent;
  AutovalidateMode? _autoValidateMode;

  @override
  void initState() {
    CustomerIOSDKInstance.get()
        .getBuildInfo()
        .then((value) => setState(() => _userAgent = value));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final Sizes sizes = Theme.of(context).extension<Sizes>()!;

    return AppContainer(
      appBar: AppBar(
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Open SDK Configurations',
            onPressed: () {
              context.push(URLPath.settings);
            },
          ),
        ],
      ),
      body: FullScreenScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Center(
              child: Text(
                'Flutter Ami App',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ),
            const Spacer(),
            Form(
              key: _formKey,
              autovalidateMode: _autoValidateMode,
              child: Container(
                constraints: BoxConstraints.loose(sizes.inputFieldDefault()),
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    TextFormField(
                      controller: _fullNameController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'First Name',
                      ),
                      keyboardType: TextInputType.name,
                      textCapitalization: TextCapitalization.words,
                      textInputAction: TextInputAction.next,
                      validator: (value) => value?.isNotEmpty == true
                          ? null
                          : 'Name cannot be empty',
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 16.0),
                      child: TextFormField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Email',
                        ),
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.done,
                        validator: (value) =>
                            EmailValidator.validate(value ?? '')
                                ? null
                                : 'Please enter valid email',
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 48.0),
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                          minimumSize: sizes.buttonDefault(),
                        ),
                        onPressed: () async {
                          _autoValidateMode =
                              AutovalidateMode.onUserInteraction;
                          if (_formKey.currentState!.validate()) {
                            widget.onSignIn(User(
                              displayName: _fullNameController.value.text,
                              email: _emailController.value.text,
                              isGuest: false,
                            ));
                          }
                        },
                        child: Text(
                          'Login'.toUpperCase(),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 16.0),
                      child: TextButton(
                        style: FilledButton.styleFrom(
                          minimumSize: sizes.buttonDefault(),
                        ),
                        onPressed: () async {
                          final randomValues = RandomValues();
                          widget.onSignIn(User(
                            displayName: randomValues.getFullName(),
                            email: randomValues.getEmail(),
                            isGuest: true,
                          ));
                        },
                        child: const Text(
                          'Generate Random Login',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Spacer(),
            TextFooter(text: _userAgent ?? ''),
          ],
        ),
      ),
    );
  }
}
