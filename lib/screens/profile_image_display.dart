import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class ProfileImageHero extends StatefulWidget {
  ProfileImageHero({super.key, required this.purl});
  String purl;

  @override
  State<ProfileImageHero> createState() => _ProfileImageState();
}

class _ProfileImageState extends State<ProfileImageHero> {
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Dismissible(
      resizeDuration: const Duration(microseconds: 1),
      direction: DismissDirection.vertical,
      key: const Key('key'),
      onDismissed: (_) => Navigator.of(context).pop(),
      child: SizedBox(
        width: width,
        child: Hero(
          tag: "profile",
          child: CachedNetworkImage(
            imageUrl: widget.purl,
            placeholder: (context, url) => const SpinKitPulse(
              color: Colors.purpleAccent,
              size: 50.0,
            ),
          ),
        ),
      ),
    );
  }
}
