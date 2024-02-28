import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/svg.dart';
import 'package:goal_quester/screens/profile_image_display.dart';

class ProfileImage extends StatelessWidget {
  ProfileImage(
      {super.key,
      required this.purl,
      required this.gender,
      required this.height,
      required this.width,
      required this.borderRadius});
  String purl;
  String gender;
  double height;
  double width;
  double borderRadius;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: purl == ''
            ? gender == 'Female'
                ? SvgPicture.asset(
                    'assets/profile_female.svg',
                    height: height,
                    width: width,
                  )
                : SvgPicture.asset(
                    'assets/profile_male.svg',
                    height: height,
                    width: width,
                  )
            : Hero(
                tag: purl,
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: ((context) =>
                              ProfileImageHero(purl: purl))));
                    },
                    child: CachedNetworkImage(
                      imageUrl: purl,
                      height: height,
                      width: width,
                      placeholder: (context, url) => const SpinKitPulse(
                        color: Colors.purpleAccent,
                        size: 50.0,
                      ),
                    ),
                  ),
                ),
              ));
  }
}
