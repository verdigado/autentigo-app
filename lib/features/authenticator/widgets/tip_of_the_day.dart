import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:authenticator_app/app/theme/custom_colors.dart';
import 'package:authenticator_app/features/authenticator/models/tip_of_the_day_model.dart';
import 'package:provider/provider.dart';

class TipOfTheDay extends StatelessWidget {
  const TipOfTheDay({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<TipOfTheDayModel>(
      builder: (context, model, child) => model.current != null
          ? _renderTip(model)
          : const SizedBox(height: 240),
    );
  }

  Widget _renderTip(TipOfTheDayModel model) {
    return GestureDetector(
      onTap: () {
        model.next();
      },
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              color: CustomColors.tanne.shade300,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Text(
                    model.current!.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (model.current!.iconPath != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: SvgPicture.asset(
                        model.current!.iconPath!,
                        height: 120,
                      ),
                    ),
                  Text(
                    model.current!.text,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 13,
                      wordSpacing: 1,
                      letterSpacing: 0.8,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  // if (model.current!.url?.isNotEmpty ?? false)
                  //   Padding(
                  //     padding: const EdgeInsets.only(top: 12.0),
                  //     child: TextButton(
                  //       child: Text(model.current!.buttonText ?? 'Ansehen',
                  //           style: const TextStyle(
                  //             fontStyle: FontStyle.italic,
                  //           )),
                  //       onPressed: () => (),
                  //     ),
                  //   ),
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
        ],
      ),
    );
  }
}
