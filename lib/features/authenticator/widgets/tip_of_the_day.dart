import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gruene_auth_app/app/theme/custom_colors.dart';
import 'package:gruene_auth_app/features/authenticator/models/authenticator_model.dart';
import 'package:provider/provider.dart';

class TipOfTheDay extends StatelessWidget {
  const TipOfTheDay({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthenticatorModel>(
      builder: (context, model, child) => Stack(
        children: [
          const Positioned(
            top: 8,
            right: 8,
            child: Text(
              "Grüner IT-Tip",
              style: TextStyle(
                fontStyle: FontStyle.italic,
                fontSize: 11,
                letterSpacing: 0.4,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: CustomColors.klee.shade200.withOpacity(0.3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
              child: Column(
                children: [
                  Text(
                    model.tipOfTheDay.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (model.tipOfTheDay.iconPath != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: SvgPicture.asset(
                        model.tipOfTheDay.iconPath!,
                        height: 120,
                      ),
                    ),
                  Text(
                    model.tipOfTheDay.text,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 13,
                      wordSpacing: 1,
                      letterSpacing: 0.8,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  if (model.tipOfTheDay.url?.isNotEmpty ?? false)
                    Padding(
                      padding: const EdgeInsets.only(top: 12.0),
                      child: TextButton(
                        child: Text(model.tipOfTheDay.buttonText ?? 'Ansehen',
                            style: const TextStyle(
                              fontStyle: FontStyle.italic,
                            )),
                        onPressed: () => (),
                      ),
                    ),
                  // Container(
                  //   height: 45,
                  //   width: 130,
                  //   decoration: BoxDecoration(
                  //     gradient: LinearGradient(
                  //       colors: [
                  //         CustomColors.klee.shade400,
                  //         CustomColors.klee.shade600,
                  //       ],
                  //     ),
                  //     borderRadius: BorderRadius.circular(50),
                  //   ),
                  //   child: const Center(
                  //     child: Text('View',
                  //         style: TextStyle(
                  //           color: true ? Colors.white : Color(0xffC58BF2),
                  //           fontWeight: FontWeight.w600,
                  //           fontSize: 14,
                  //         )),
                  //   ),
                  // ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
