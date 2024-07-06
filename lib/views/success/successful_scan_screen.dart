import 'package:bailey/keys/routes/route_keys.dart';
import 'package:bailey/style/type/type_style.dart';
import 'package:bailey/widgets/buttons/rounded_button/m_rounded_button.dart';
import 'package:flutter/material.dart';

class SuccessfulScanScreen extends StatefulWidget {
  const SuccessfulScanScreen({super.key});

  @override
  State<SuccessfulScanScreen> createState() => _SuccessfulScanScreenState();
}

class _SuccessfulScanScreenState extends State<SuccessfulScanScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            children: [
              const Spacer(),
              Center(
                child: SizedBox(
                  width: (MediaQuery.of(context).size.width / 2 - 50),
                  child: Image.asset(
                    'assets/images/print_image.png',
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Successfully Completed',
                style: TypeStyle.h1,
              ),
              const SizedBox(height: 20),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: SizedBox(
                  height: 50,
                  width: double.infinity,
                  child: MRoundedButton(
                    'Continue',
                    () {
                      Navigator.of(context)
                          .pushNamedAndRemoveUntil(baseRoute, (route) => false);
                    },
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
