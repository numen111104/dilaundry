import 'package:d_view/d_view.dart';
import 'package:flutter/material.dart';

import '../config/app_assets.dart';
import '../config/app_colors.dart';
import '../config/app_format.dart';
import '../config/nav.dart';
import '../models/laundry_model.dart';
import 'detail_shop_page.dart';

class DetailLaundryPage extends StatelessWidget {
  const DetailLaundryPage({super.key, required this.laundry});
  final LaundryModel laundry;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(0),
        children: [
          headerCover(context),
          DView.spaceHeight(10),
          Center(
            child: Container(
              width: 90,
              height: 4,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                color: Colors.grey,
              ),
            ),
          ),
          DView.spaceHeight(),
          itemInfo(Icons.sell, AppFormat.longPrice(laundry.total)),
          divider(),
          itemInfo(Icons.event, AppFormat.fullDate(laundry.createdAt)),
          divider(),
          InkWell(
            onTap: () {
              Nav.push(context, DetailShopPage(shop: laundry.shop));
            },
            child: itemInfo(Icons.store, laundry.shop.name),
          ),
          divider(),
          itemInfo(Icons.shopping_basket, '${laundry.weight}kg'),
          divider(),
          if (laundry.withPickup) itemInfo(Icons.shopping_bag, 'Pickup'),
          if (laundry.withPickup) itemDescription(laundry.pickupAddress),
          if (laundry.withPickup) divider(),
          if (laundry.withDelivery) itemInfo(Icons.local_shipping, 'Delivery'),
          if (laundry.withDelivery) itemDescription(laundry.deliveryAddress),
          if (laundry.withDelivery) divider(),
          itemInfo(Icons.description, 'Description'),
          itemDescription(laundry.description),
          divider(),
        ],
      ),
    );
  }

  Divider divider() {
    return Divider(
      indent: 30,
      endIndent: 30,
      color: Colors.grey[400],
    );
  }

  Widget itemInfo(IconData icon, String info) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary),
          DView.spaceWidth(10),
          Text(info),
        ],
      ),
    );
  }

  Widget itemDescription(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Row(
        children: [
          const Icon(Icons.abc, color: Colors.transparent),
          DView.spaceWidth(10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: Colors.black54),
            ),
          ),
        ],
      ),
    );
  }

  Padding headerCover(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: AspectRatio(
        aspectRatio: 1,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(
                AppAssets.emptyBG,
                fit: BoxFit.cover,
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: AspectRatio(
                  aspectRatio: 2,
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Colors.black,
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.center,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 60,
                    vertical: 30,
                  ),
                  child: Text(
                    laundry.status,
                    style: const TextStyle(
                      color: Colors.black87,
                      fontSize: 40,
                      height: 1,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 36,
                left: 16,
                right: 16,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'ID: ${laundry.id}',
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        height: 1,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(
                            blurRadius: 6,
                            color: Colors.black87,
                          ),
                        ],
                      ),
                    ),
                    FloatingActionButton.small(
                      heroTag: 'fab-back',
                      onPressed: () => Navigator.pop(context),
                      backgroundColor: Colors.white,
                      child: const Icon(Icons.arrow_back),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
