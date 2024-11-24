import 'package:chatter/constants/colors.dart';
import 'package:chatter/controller/country_selector.dart';
import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

void selectCountryCode(BuildContext context) {
  var ctr = Get.put(CountrySelectorController());
  showCountryPicker(
      context: context,
      countryListTheme: CountryListThemeData(
        searchTextStyle: Theme.of(context)
            .textTheme
            .bodyMedium
            ?.copyWith(color: AppColors.darkColor),
        textStyle: Theme.of(context)
            .textTheme
            .bodyMedium
            ?.copyWith(color: AppColors.darkColor),
        flagSize: 25,
        backgroundColor: AppColors.whiteColor,

        bottomSheetHeight: 500,

        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.0),
          topRight: Radius.circular(20.0),
        ),

        //Optional. Styles the search field.
        inputDecoration: InputDecoration(
          hintStyle: Theme.of(context)
              .textTheme
              .bodyLarge
              ?.copyWith(fontWeight: FontWeight.normal),
          hintText: 'Start typing to search',
          prefixIcon: Icon(
            Icons.search,
            color: AppColors.darkColor,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4),
            borderSide: BorderSide(
              color: AppColors.greyColor,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4),
            // borderSide: BorderSide(
            //   color: AppColors.borderGrey,
            // ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4),
            // borderSide: BorderSide(
            //   color: AppColors.borderGrey,
            // ),
          ),
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4),
            // borderSide: BorderSide(
            //   color: AppColors.borderGrey,
            // ),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4),
            // borderSide: BorderSide(
            //   color: AppColors.borderGrey,
            // ),
          ),
        ),
      ),
      showPhoneCode: true,
      onSelect: (Country country) {
        // print('Select country: ${country.phoneCode}');
        ctr.onSelectedCountry(country.phoneCode);
      });
}

class CountryCodeSelectorWidget extends StatelessWidget {
  const CountryCodeSelectorWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    var ctr = Get.put(CountrySelectorController());
    return GestureDetector(
      onTap: () {
        selectCountryCode(context);
      },
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: (3.w), vertical: (7.h)),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              border: Border.all(
                width: 0.2,
                color: AppColors.primaryColor,
              ),
              borderRadius: BorderRadius.circular(7),
            ),
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.add,
                        size: 13,
                        color: AppColors.darkColor,
                      ),
                      Obx(() {
                        return Text(
                          ctr.selectedCountry.value,
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: AppColors.darkColor,
                                  ),
                        );
                      }),
                    ],
                  ),
                  Icon(Icons.keyboard_arrow_down_rounded,
                      size: 20, color: AppColors.darkColor)
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
