import 'package:flutter/material.dart';

class CardsCarouselLoaderWidget extends StatelessWidget {
  const CardsCarouselLoaderWidget({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    MediaQueryData mediadata = MediaQuery.of(context);
    return Container(
      height: mediadata.size.height - 300,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 3,
        itemBuilder: (context, index) {
          return Container(
            width: mediadata.size.width - 100,
            margin: EdgeInsets.only(left: 20, right: 20, top: 15, bottom: 20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(10)),
              boxShadow: [
                BoxShadow(
                    color: Theme.of(context).focusColor.withOpacity(0.1),
                    blurRadius: 15,
                    offset: Offset(0, 5)),
              ],
            ),
            child: Image.asset('assets/loading.gif', fit: BoxFit.fill),
          );
        },
      ),
    );
  }
}
