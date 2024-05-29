import 'package:d_info/d_info.dart';
import 'package:d_input/d_input.dart';
import 'package:d_view/d_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grouped_list/grouped_list.dart';

import '../../config/app_constants.dart';
import '../../config/app_format.dart';
import '../../config/app_response.dart';
import '../../config/app_session.dart';
import '../../config/failure.dart';
import '../../config/nav.dart';
import '../../datasources/laundry_datasource.dart';
import '../../models/laundry_model.dart';
import '../../models/user_model.dart';
import '../../providers/my_laundry_provider.dart';
import '../../widgets/error_background.dart';
import '../detail_laundry_page.dart';

class MyLaundryView extends ConsumerStatefulWidget {
  const MyLaundryView({super.key});

  @override
  ConsumerState<MyLaundryView> createState() => _MyLaundryViewState();
}

class _MyLaundryViewState extends ConsumerState<MyLaundryView> {
  late UserModel user;

  getMyLaundry() {
    LaundryDatasource.readByUser(user.id).then((value) {
      value.fold(
        (failure) {
          switch (failure.runtimeType) {
            case ServerFailure:
              setMyLaundryStatus(ref, 'Server Error');
              break;
            case NotFoundFailure:
              setMyLaundryStatus(ref, 'Not Found');
              break;
            case ForbiddenFailure:
              setMyLaundryStatus(ref, 'You don\'t have access');
              break;
            case BadRequestFailure:
              setMyLaundryStatus(ref, 'Bad request');
              break;
            case UnauthorisedFailure:
              setMyLaundryStatus(ref, 'Unauthorised');
              break;
            default:
              setMyLaundryStatus(ref, 'Request Error');
              break;
          }
        },
        (result) {
          setMyLaundryStatus(ref, 'Success');
          List data = result['data'];
          List<LaundryModel> laundries =
              data.map((e) => LaundryModel.fromJson(e)).toList();
          ref.read(myLaundryListProvider.notifier).setData(laundries);
        },
      );
    });
  }

  dialogClaim() {
    final edtLaundryID = TextEditingController();
    final edtClaimCode = TextEditingController();
    final formKey = GlobalKey<FormState>();
    showDialog(
      context: context,
      builder: (context) {
        return Form(
          key: formKey,
          child: SimpleDialog(
            titlePadding: const EdgeInsets.all(16),
            contentPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            title: const Text('Claim Laundry'),
            children: [
              DInput(
                controller: edtLaundryID,
                title: 'Laundry ID',
                radius: BorderRadius.circular(10),
                validator: (input) => input == '' ? "Don't empty" : null,
                inputType: TextInputType.number,
              ),
              DView.spaceHeight(),
              DInput(
                controller: edtClaimCode,
                title: 'Claim Code',
                radius: BorderRadius.circular(10),
                validator: (input) => input == '' ? "Don't empty" : null,
              ),
              DView.spaceHeight(20),
              ElevatedButton(
                onPressed: () {
                  if (formKey.currentState!.validate()) {
                    Navigator.pop(context);
                    claimNow(edtLaundryID.text, edtClaimCode.text);
                  }
                },
                child: const Text('Claim Now'),
              ),
              DView.spaceHeight(8),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
            ],
          ),
        );
      },
    );
  }

  claimNow(String id, String claimCode) {
    LaundryDatasource.claim(id, claimCode).then((value) {
      value.fold(
        (failure) {
          switch (failure.runtimeType) {
            case ServerFailure:
              DInfo.toastError('Server Error');
              break;
            case NotFoundFailure:
              DInfo.toastError('Not Found');
              break;
            case ForbiddenFailure:
              DInfo.toastError('You don\'t have access');
              break;
            case BadRequestFailure:
              DInfo.toastError('Laundry has been claimed');
              break;
            case InvalidInputFailure:
              AppResponse.invalidInput(context, failure.message ?? '{}');
              break;
            case UnauthorisedFailure:
              DInfo.toastError('Unauthorised');
              break;
            default:
              DInfo.toastError('Request Error');
              break;
          }
        },
        (result) {
          DInfo.toastSuccess('Claim Success');
          getMyLaundry();
        },
      );
    });
  }

  @override
  void initState() {
    AppSession.getUser().then((value) {
      user = value!;
      getMyLaundry();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        header(),
        categories(),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async => getMyLaundry(),
            child: Consumer(
              builder: (_, wiRef, __) {
                String statusList = wiRef.watch(myLaundryStatusProvider);
                String statusCategory = wiRef.watch(myLaundryCategoryProvider);
                List<LaundryModel> listBackup =
                    wiRef.watch(myLaundryListProvider);

                if (statusList == '') return DView.loadingCircle();
                if (statusList != 'Success') {
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(30, 0, 30, 80),
                    child: ErrorBackground(
                      ratio: 16 / 9,
                      message: statusList,
                    ),
                  );
                }

                List<LaundryModel> list = [];
                if (statusCategory == 'All') {
                  list = List.from(listBackup);
                } else {
                  list = listBackup
                      .where((element) => element.status == statusCategory)
                      .toList();
                }

                if (list.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(30, 30, 30, 80),
                    child: Stack(
                      children: [
                        const ErrorBackground(
                          ratio: 16 / 9,
                          message: 'Empty',
                        ),
                        IconButton(
                          onPressed: () => getMyLaundry(),
                          icon: const Icon(Icons.refresh, color: Colors.white),
                        ),
                      ],
                    ),
                  );
                }

                return GroupedListView<LaundryModel, String>(
                  padding: const EdgeInsets.fromLTRB(30, 0, 30, 80),
                  elements: list,
                  groupBy: (element) => AppFormat.justDate(element.createdAt),
                  order: GroupedListOrder.DESC,
                  itemComparator: (element1, element2) {
                    return element1.createdAt.compareTo(element2.createdAt);
                  },
                  groupSeparatorBuilder: (value) => Align(
                    alignment: Alignment.topLeft,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: Colors.grey[400]!),
                      ),
                      margin: const EdgeInsets.only(top: 24, bottom: 20),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      child: Text(
                        AppFormat.shortDate(value),
                      ),
                    ),
                  ),
                  itemBuilder: (context, laundry) {
                    return GestureDetector(
                      onTap: () {
                        Nav.push(context, DetailLaundryPage(laundry: laundry));
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 20),
                        decoration: BoxDecoration(
                          color: Colors.green[50],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    laundry.shop.name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                ),
                                DView.spaceWidth(),
                                Text(
                                  AppFormat.longPrice(laundry.total),
                                  textAlign: TextAlign.end,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 18,
                                  ),
                                ),
                              ],
                            ),
                            DView.spaceHeight(12),
                            Row(
                              children: [
                                if (laundry.withPickup)
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Colors.green,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    margin: const EdgeInsets.only(right: 8),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    child: const Text(
                                      'Pickup',
                                      style: TextStyle(
                                          color: Colors.white, height: 1),
                                    ),
                                  ),
                                if (laundry.withDelivery)
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Colors.green,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    margin: const EdgeInsets.only(right: 8),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    child: const Text(
                                      'Delivery',
                                      style: TextStyle(
                                          color: Colors.white, height: 1),
                                    ),
                                  ),
                                Expanded(
                                  child: Text(
                                    '${laundry.weight}kg',
                                    textAlign: TextAlign.end,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w300,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Consumer categories() {
    return Consumer(
      builder: (_, wiRef, __) {
        String categorySelected = wiRef.watch(myLaundryCategoryProvider);
        return SizedBox(
          height: 30,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: AppConstants.laundryStatusCategory.length,
            itemBuilder: (context, index) {
              String category = AppConstants.laundryStatusCategory[index];
              return Padding(
                padding: EdgeInsets.only(
                  left: index == 0 ? 30 : 8,
                  right: index == AppConstants.laundryStatusCategory.length - 1
                      ? 30
                      : 8,
                ),
                child: InkWell(
                  onTap: () {
                    setMyLaundryCategory(ref, category);
                  },
                  borderRadius: BorderRadius.circular(30),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: category == categorySelected
                            ? Colors.green
                            : Colors.grey[400]!,
                      ),
                      color: category == categorySelected
                          ? Colors.green
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    alignment: Alignment.center,
                    child: Text(
                      category,
                      style: TextStyle(
                        height: 1,
                        color: category == categorySelected
                            ? Colors.white
                            : Colors.black,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Padding header() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(30, 60, 30, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'My Laundry',
            style: GoogleFonts.montserrat(
              fontSize: 24,
              color: Colors.green,
              fontWeight: FontWeight.w600,
            ),
          ),
          Transform.translate(
            offset: const Offset(0, -8),
            child: OutlinedButton.icon(
              onPressed: () => dialogClaim(),
              icon: const Icon(Icons.add),
              label: const Text(
                'Claim',
                style: TextStyle(height: 1),
              ),
              style: ButtonStyle(
                shape: MaterialStatePropertyAll(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                padding: const MaterialStatePropertyAll(
                  EdgeInsets.fromLTRB(8, 2, 16, 2),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
