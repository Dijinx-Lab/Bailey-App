import 'package:bailey/keys/routes/route_keys.dart';
import 'package:bailey/style/type/type_style.dart';
import 'package:bailey/utility/pref/pref_util.dart';
import 'package:bailey/widgets/buttons/rounded_button/m_rounded_button.dart';
import 'package:flutter/material.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Column(
            children: [
              const SizedBox(
                height: 20,
              ),
              Center(
                child: Image.asset(
                  'assets/icons/ic_logo_white.png',
                  width: 95,
                ),
              ),
              const SizedBox(
                height: 30,
              ),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    'assets/images/onboarding_image.png',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(
                height: 30,
              ),
              Text('Introduction', style: TypeStyle.h1),
              const SizedBox(
                height: 10,
              ),
              Text(
                  'Case read they must it of cold that. Speaking trifling an to unpacked moderate debating learning. An particular contrasted he excellence favourable on',
                  textAlign: TextAlign.center,
                  style: TypeStyle.body),
              const SizedBox(
                height: 20,
              ),
              SizedBox(
                height: 50,
                width: double.infinity,
                child: MRoundedButton(
                  'Next',
                  () {
                    PrefUtil().isOnboarded = true;
                    Navigator.of(context).pushReplacementNamed(signinRoute);
                  },
                ),
              ),
              const SizedBox(
                height: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
