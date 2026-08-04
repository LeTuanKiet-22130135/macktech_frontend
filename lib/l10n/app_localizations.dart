import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_vi.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('vi'),
  ];

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @vietnamese.
  ///
  /// In en, this message translates to:
  /// **'Vietnamese'**
  String get vietnamese;

  /// No description provided for @userProfile.
  ///
  /// In en, this message translates to:
  /// **'User Profile'**
  String get userProfile;

  /// No description provided for @aboutShoppe.
  ///
  /// In en, this message translates to:
  /// **'About Shoppe'**
  String get aboutShoppe;

  /// No description provided for @ifYouNeedHelpOrYouHaveAnyQuest.
  ///
  /// In en, this message translates to:
  /// **'If you need help or you have any questions, feel free to contact me by email.'**
  String get ifYouNeedHelpOrYouHaveAnyQuest;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @setAsDefaultAddress.
  ///
  /// In en, this message translates to:
  /// **'Set as Default Address'**
  String get setAsDefaultAddress;

  /// No description provided for @pinpointLocation.
  ///
  /// In en, this message translates to:
  /// **'Pinpoint Location'**
  String get pinpointLocation;

  /// No description provided for @usePinLocation.
  ///
  /// In en, this message translates to:
  /// **'Use Pin Location'**
  String get usePinLocation;

  /// No description provided for @shippingAddresses.
  ///
  /// In en, this message translates to:
  /// **'Shipping Addresses'**
  String get shippingAddresses;

  /// No description provided for @noAddressesFound.
  ///
  /// In en, this message translates to:
  /// **'No addresses found.'**
  String get noAddressesFound;

  /// No description provided for @addNew.
  ///
  /// In en, this message translates to:
  /// **'Add New'**
  String get addNew;

  /// No description provided for @defaultText.
  ///
  /// In en, this message translates to:
  /// **'Default'**
  String get defaultText;

  /// No description provided for @setAsDefault.
  ///
  /// In en, this message translates to:
  /// **'Set as Default'**
  String get setAsDefault;

  /// No description provided for @deleteAddress.
  ///
  /// In en, this message translates to:
  /// **'Delete Address'**
  String get deleteAddress;

  /// No description provided for @areYouSureYouWantToDeleteThisA.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this address?'**
  String get areYouSureYouWantToDeleteThisA;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @pleaseSelectARating.
  ///
  /// In en, this message translates to:
  /// **'Please select a rating.'**
  String get pleaseSelectARating;

  /// No description provided for @pleaseWriteAReview.
  ///
  /// In en, this message translates to:
  /// **'Please write a review.'**
  String get pleaseWriteAReview;

  /// No description provided for @failedToSubmitReviewYouMayHave.
  ///
  /// In en, this message translates to:
  /// **'Failed to submit review. You may have already reviewed this product.'**
  String get failedToSubmitReviewYouMayHave;

  /// No description provided for @anErrorOccurred.
  ///
  /// In en, this message translates to:
  /// **'An error occurred.'**
  String get anErrorOccurred;

  /// No description provided for @rating.
  ///
  /// In en, this message translates to:
  /// **'Rating'**
  String get rating;

  /// No description provided for @howWasYourExperience.
  ///
  /// In en, this message translates to:
  /// **'How was your experience?'**
  String get howWasYourExperience;

  /// No description provided for @pleaseSelectACategory.
  ///
  /// In en, this message translates to:
  /// **'Please select a category'**
  String get pleaseSelectACategory;

  /// No description provided for @productCreatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Product created successfully'**
  String get productCreatedSuccessfully;

  /// No description provided for @addNewProduct.
  ///
  /// In en, this message translates to:
  /// **'Add new product'**
  String get addNewProduct;

  /// No description provided for @productInformation.
  ///
  /// In en, this message translates to:
  /// **'Product Information'**
  String get productInformation;

  /// No description provided for @selectCategory.
  ///
  /// In en, this message translates to:
  /// **'Select Category'**
  String get selectCategory;

  /// No description provided for @clearAll.
  ///
  /// In en, this message translates to:
  /// **'Clear All'**
  String get clearAll;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @promoCodeCreated.
  ///
  /// In en, this message translates to:
  /// **'Promo Code Created'**
  String get promoCodeCreated;

  /// No description provided for @createPromoCode.
  ///
  /// In en, this message translates to:
  /// **'Create Promo Code'**
  String get createPromoCode;

  /// No description provided for @codeString.
  ///
  /// In en, this message translates to:
  /// **'Code String'**
  String get codeString;

  /// No description provided for @discountType.
  ///
  /// In en, this message translates to:
  /// **'Discount Type'**
  String get discountType;

  /// No description provided for @percentage.
  ///
  /// In en, this message translates to:
  /// **'Percentage'**
  String get percentage;

  /// No description provided for @fixedAmount.
  ///
  /// In en, this message translates to:
  /// **'Fixed Amount'**
  String get fixedAmount;

  /// No description provided for @value.
  ///
  /// In en, this message translates to:
  /// **'Value'**
  String get value;

  /// No description provided for @minimumOrderValue.
  ///
  /// In en, this message translates to:
  /// **'Minimum Order Value'**
  String get minimumOrderValue;

  /// No description provided for @validFrom.
  ///
  /// In en, this message translates to:
  /// **'Valid From'**
  String get validFrom;

  /// No description provided for @validUntil.
  ///
  /// In en, this message translates to:
  /// **'Valid Until'**
  String get validUntil;

  /// No description provided for @usageLimitOptional.
  ///
  /// In en, this message translates to:
  /// **'Usage Limit (Optional)'**
  String get usageLimitOptional;

  /// No description provided for @isActive.
  ///
  /// In en, this message translates to:
  /// **'Is Active'**
  String get isActive;

  /// No description provided for @savePromoCode.
  ///
  /// In en, this message translates to:
  /// **'SAVE PROMO CODE'**
  String get savePromoCode;

  /// No description provided for @noProductsFound.
  ///
  /// In en, this message translates to:
  /// **'No products found.'**
  String get noProductsFound;

  /// No description provided for @searchProducts.
  ///
  /// In en, this message translates to:
  /// **'Search products...'**
  String get searchProducts;

  /// No description provided for @revenueAnalytics.
  ///
  /// In en, this message translates to:
  /// **'Revenue Analytics'**
  String get revenueAnalytics;

  /// No description provided for @noChartDataAvailable.
  ///
  /// In en, this message translates to:
  /// **'No chart data available.'**
  String get noChartDataAvailable;

  /// No description provided for @recentOrders.
  ///
  /// In en, this message translates to:
  /// **'Recent Orders'**
  String get recentOrders;

  /// No description provided for @noRecentOrders.
  ///
  /// In en, this message translates to:
  /// **'No recent orders.'**
  String get noRecentOrders;

  /// No description provided for @topSellingProducts.
  ///
  /// In en, this message translates to:
  /// **'Top Selling Products'**
  String get topSellingProducts;

  /// No description provided for @noTopProducts.
  ///
  /// In en, this message translates to:
  /// **'No top products.'**
  String get noTopProducts;

  /// No description provided for @productUpdatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Product updated successfully'**
  String get productUpdatedSuccessfully;

  /// No description provided for @deleteProduct.
  ///
  /// In en, this message translates to:
  /// **'Delete Product'**
  String get deleteProduct;

  /// No description provided for @areYouSureYouWantToDeleteThisP.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this product?'**
  String get areYouSureYouWantToDeleteThisP;

  /// No description provided for @productDeleted.
  ///
  /// In en, this message translates to:
  /// **'Product deleted'**
  String get productDeleted;

  /// No description provided for @editProduct.
  ///
  /// In en, this message translates to:
  /// **'Edit Product'**
  String get editProduct;

  /// No description provided for @change.
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get change;

  /// No description provided for @update.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get update;

  /// No description provided for @promoCodeUpdated.
  ///
  /// In en, this message translates to:
  /// **'Promo Code Updated'**
  String get promoCodeUpdated;

  /// No description provided for @deletePromoCode.
  ///
  /// In en, this message translates to:
  /// **'Delete Promo Code?'**
  String get deletePromoCode;

  /// No description provided for @areYouSureYouWantToPermanently.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to permanently delete this promo code?'**
  String get areYouSureYouWantToPermanently;

  /// No description provided for @promoCodeDeleted.
  ///
  /// In en, this message translates to:
  /// **'Promo Code Deleted'**
  String get promoCodeDeleted;

  /// No description provided for @editPromoCode.
  ///
  /// In en, this message translates to:
  /// **'Edit Promo Code'**
  String get editPromoCode;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'SAVE CHANGES'**
  String get saveChanges;

  /// No description provided for @macktechMobiles.
  ///
  /// In en, this message translates to:
  /// **'Macktech Mobiles'**
  String get macktechMobiles;

  /// No description provided for @admin.
  ///
  /// In en, this message translates to:
  /// **'Admin'**
  String get admin;

  /// No description provided for @changePassword.
  ///
  /// In en, this message translates to:
  /// **'CHANGE PASSWORD'**
  String get changePassword;

  /// No description provided for @logOut.
  ///
  /// In en, this message translates to:
  /// **'LOG OUT'**
  String get logOut;

  /// No description provided for @categories.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get categories;

  /// No description provided for @noOrdersFound.
  ///
  /// In en, this message translates to:
  /// **'No orders found.'**
  String get noOrdersFound;

  /// No description provided for @orderDate.
  ///
  /// In en, this message translates to:
  /// **'Order Date'**
  String get orderDate;

  /// No description provided for @discountCodes.
  ///
  /// In en, this message translates to:
  /// **'Discount Codes'**
  String get discountCodes;

  /// No description provided for @managePromotionsAndProductspec.
  ///
  /// In en, this message translates to:
  /// **'Manage promotions and product-specific limits.'**
  String get managePromotionsAndProductspec;

  /// No description provided for @noPromoCodesFound.
  ///
  /// In en, this message translates to:
  /// **'No promo codes found.'**
  String get noPromoCodesFound;

  /// No description provided for @newCode.
  ///
  /// In en, this message translates to:
  /// **'New Code'**
  String get newCode;

  /// No description provided for @userManagement.
  ///
  /// In en, this message translates to:
  /// **'User Management'**
  String get userManagement;

  /// No description provided for @viewAndManageCustomerAndAdminA.
  ///
  /// In en, this message translates to:
  /// **'View and manage customer and admin accounts.'**
  String get viewAndManageCustomerAndAdminA;

  /// No description provided for @noUsersFound.
  ///
  /// In en, this message translates to:
  /// **'No users found.'**
  String get noUsersFound;

  /// No description provided for @profileUpdatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Profile updated successfully'**
  String get profileUpdatedSuccessfully;

  /// No description provided for @failedToUpdateProfile.
  ///
  /// In en, this message translates to:
  /// **'Failed to update profile'**
  String get failedToUpdateProfile;

  /// No description provided for @passwordChangedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Password changed successfully'**
  String get passwordChangedSuccessfully;

  /// No description provided for @failedToChangePassword.
  ///
  /// In en, this message translates to:
  /// **'Failed to change password'**
  String get failedToChangePassword;

  /// No description provided for @deleteUser.
  ///
  /// In en, this message translates to:
  /// **'Delete User?'**
  String get deleteUser;

  /// No description provided for @thisActionIsIrreversibleAreYou.
  ///
  /// In en, this message translates to:
  /// **'This action is irreversible. Are you sure you want to delete this user?'**
  String get thisActionIsIrreversibleAreYou;

  /// No description provided for @userDeleted.
  ///
  /// In en, this message translates to:
  /// **'User deleted'**
  String get userDeleted;

  /// No description provided for @failedToDeleteUser.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete user'**
  String get failedToDeleteUser;

  /// No description provided for @userDetails.
  ///
  /// In en, this message translates to:
  /// **'User Details'**
  String get userDetails;

  /// No description provided for @userNotFound.
  ///
  /// In en, this message translates to:
  /// **'User not found.'**
  String get userNotFound;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullName;

  /// No description provided for @phoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phoneNumber;

  /// No description provided for @address.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get address;

  /// No description provided for @newPassword.
  ///
  /// In en, this message translates to:
  /// **'New Password'**
  String get newPassword;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// No description provided for @customerMessages.
  ///
  /// In en, this message translates to:
  /// **'Customer Messages'**
  String get customerMessages;

  /// No description provided for @noTicketsAssignedYet.
  ///
  /// In en, this message translates to:
  /// **'No tickets assigned yet.'**
  String get noTicketsAssignedYet;

  /// No description provided for @allTickets.
  ///
  /// In en, this message translates to:
  /// **'All Tickets'**
  String get allTickets;

  /// No description provided for @status.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get status;

  /// No description provided for @supportAgentPortal.
  ///
  /// In en, this message translates to:
  /// **'Support Agent Portal'**
  String get supportAgentPortal;

  /// No description provided for @agent.
  ///
  /// In en, this message translates to:
  /// **'Agent'**
  String get agent;

  /// No description provided for @customerInformation.
  ///
  /// In en, this message translates to:
  /// **'Customer Information'**
  String get customerInformation;

  /// No description provided for @ticketTypeCategory.
  ///
  /// In en, this message translates to:
  /// **'Ticket Type / Category'**
  String get ticketTypeCategory;

  /// No description provided for @issue.
  ///
  /// In en, this message translates to:
  /// **'Issue'**
  String get issue;

  /// No description provided for @updateStatus.
  ///
  /// In en, this message translates to:
  /// **'Update Status'**
  String get updateStatus;

  /// No description provided for @errorUpdatingStatus.
  ///
  /// In en, this message translates to:
  /// **'Error updating status'**
  String get errorUpdatingStatus;

  /// No description provided for @chatWithCustomer.
  ///
  /// In en, this message translates to:
  /// **'Chat with Customer'**
  String get chatWithCustomer;

  /// No description provided for @cart.
  ///
  /// In en, this message translates to:
  /// **'Cart'**
  String get cart;

  /// No description provided for @failedToLoadCart.
  ///
  /// In en, this message translates to:
  /// **'Failed to load cart'**
  String get failedToLoadCart;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @yourCartIsEmpty.
  ///
  /// In en, this message translates to:
  /// **'Your cart is empty'**
  String get yourCartIsEmpty;

  /// No description provided for @orderInfo.
  ///
  /// In en, this message translates to:
  /// **'Order Info'**
  String get orderInfo;

  /// No description provided for @placeOrder.
  ///
  /// In en, this message translates to:
  /// **'Place Order'**
  String get placeOrder;

  /// No description provided for @pleaseFillInAllFields.
  ///
  /// In en, this message translates to:
  /// **'Please fill in all fields'**
  String get pleaseFillInAllFields;

  /// No description provided for @newPasswordMustBeAtLeast6Chara.
  ///
  /// In en, this message translates to:
  /// **'New password must be at least 6 characters'**
  String get newPasswordMustBeAtLeast6Chara;

  /// No description provided for @newPasswordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'New passwords do not match'**
  String get newPasswordsDoNotMatch;

  /// No description provided for @oldPassword.
  ///
  /// In en, this message translates to:
  /// **'Old Password'**
  String get oldPassword;

  /// No description provided for @reenterNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Re-enter New Password'**
  String get reenterNewPassword;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @emptyKey.
  ///
  /// In en, this message translates to:
  /// **'***********'**
  String get emptyKey;

  /// No description provided for @typeAMessage.
  ///
  /// In en, this message translates to:
  /// **'Type a message...'**
  String get typeAMessage;

  /// No description provided for @cardOwner.
  ///
  /// In en, this message translates to:
  /// **'Card Owner'**
  String get cardOwner;

  /// No description provided for @cardNumber.
  ///
  /// In en, this message translates to:
  /// **'Card Number'**
  String get cardNumber;

  /// No description provided for @exp.
  ///
  /// In en, this message translates to:
  /// **'EXP'**
  String get exp;

  /// No description provided for @cvv.
  ///
  /// In en, this message translates to:
  /// **'CVV'**
  String get cvv;

  /// No description provided for @saveCardInfo.
  ///
  /// In en, this message translates to:
  /// **'Save card info'**
  String get saveCardInfo;

  /// No description provided for @saveCard.
  ///
  /// In en, this message translates to:
  /// **'Save Card'**
  String get saveCard;

  /// No description provided for @pleaseAddYourPhoneNumberInYour.
  ///
  /// In en, this message translates to:
  /// **'Please add your phone number in your profile before checking out.'**
  String get pleaseAddYourPhoneNumberInYour;

  /// No description provided for @failedToResolveDistrictId.
  ///
  /// In en, this message translates to:
  /// **'Failed to resolve district ID.'**
  String get failedToResolveDistrictId;

  /// No description provided for @failedToResolveWardCode.
  ///
  /// In en, this message translates to:
  /// **'Failed to resolve ward code.'**
  String get failedToResolveWardCode;

  /// No description provided for @paymentFailedOrCancelled.
  ///
  /// In en, this message translates to:
  /// **'Payment failed or cancelled.'**
  String get paymentFailedOrCancelled;

  /// No description provided for @failedToCreateOrder.
  ///
  /// In en, this message translates to:
  /// **'Failed to create order.'**
  String get failedToCreateOrder;

  /// No description provided for @checkout.
  ///
  /// In en, this message translates to:
  /// **'Checkout'**
  String get checkout;

  /// No description provided for @customerDetails.
  ///
  /// In en, this message translates to:
  /// **'Customer details'**
  String get customerDetails;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @contactInformation.
  ///
  /// In en, this message translates to:
  /// **'Contact information'**
  String get contactInformation;

  /// No description provided for @shippingAddress.
  ///
  /// In en, this message translates to:
  /// **'Shipping address'**
  String get shippingAddress;

  /// No description provided for @noAddressSelected.
  ///
  /// In en, this message translates to:
  /// **'No address selected'**
  String get noAddressSelected;

  /// No description provided for @items.
  ///
  /// In en, this message translates to:
  /// **'Items'**
  String get items;

  /// No description provided for @colorBlueStorage512Gb.
  ///
  /// In en, this message translates to:
  /// **'Color: Blue  ·  Storage: 512 GB'**
  String get colorBlueStorage512Gb;

  /// No description provided for @paymentMethod.
  ///
  /// In en, this message translates to:
  /// **'Payment Method'**
  String get paymentMethod;

  /// No description provided for @addCard.
  ///
  /// In en, this message translates to:
  /// **'Add Card'**
  String get addCard;

  /// No description provided for @discountCode.
  ///
  /// In en, this message translates to:
  /// **'Discount Code'**
  String get discountCode;

  /// No description provided for @apply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get apply;

  /// No description provided for @remove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get remove;

  /// No description provided for @cardHolder.
  ///
  /// In en, this message translates to:
  /// **'Card Holder'**
  String get cardHolder;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name : '**
  String get name;

  /// No description provided for @number.
  ///
  /// In en, this message translates to:
  /// **'Number : '**
  String get number;

  /// No description provided for @emailAddress.
  ///
  /// In en, this message translates to:
  /// **'Email Address'**
  String get emailAddress;

  /// No description provided for @enterCodeEgSave10.
  ///
  /// In en, this message translates to:
  /// **'Enter code (e.g. SAVE10)'**
  String get enterCodeEgSave10;

  /// No description provided for @messages.
  ///
  /// In en, this message translates to:
  /// **'Messages'**
  String get messages;

  /// No description provided for @chatHistory.
  ///
  /// In en, this message translates to:
  /// **'Chat History'**
  String get chatHistory;

  /// No description provided for @customerSupportMock.
  ///
  /// In en, this message translates to:
  /// **'Customer Support (Mock)'**
  String get customerSupportMock;

  /// No description provided for @pleaseFillInAllRequiredFields.
  ///
  /// In en, this message translates to:
  /// **'Please fill in all required fields.'**
  String get pleaseFillInAllRequiredFields;

  /// No description provided for @passwordMustBeAtLeast6Characte.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters long.'**
  String get passwordMustBeAtLeast6Characte;

  /// No description provided for @checkYourEmailForALinkToVerify.
  ///
  /// In en, this message translates to:
  /// **'Check your email for a link to verify your account before logging in.'**
  String get checkYourEmailForALinkToVerify;

  /// No description provided for @alreadyHaveAnAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an Account ?'**
  String get alreadyHaveAnAccount;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @noAddressesFoundPleaseAddANewA.
  ///
  /// In en, this message translates to:
  /// **'No addresses found. Please add a new address.'**
  String get noAddressesFoundPleaseAddANewA;

  /// No description provided for @customerSupport.
  ///
  /// In en, this message translates to:
  /// **'Customer Support'**
  String get customerSupport;

  /// No description provided for @raisedTicketHistory.
  ///
  /// In en, this message translates to:
  /// **'Raised ticket history'**
  String get raisedTicketHistory;

  /// No description provided for @noTicketsRaisedYet.
  ///
  /// In en, this message translates to:
  /// **'No tickets raised yet.'**
  String get noTicketsRaisedYet;

  /// No description provided for @raiseANewTicket.
  ///
  /// In en, this message translates to:
  /// **'Raise a new ticket'**
  String get raiseANewTicket;

  /// No description provided for @confirmYourPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Your Password'**
  String get confirmYourPassword;

  /// No description provided for @pleaseEnterYourPassword.
  ///
  /// In en, this message translates to:
  /// **'Please enter your password'**
  String get pleaseEnterYourPassword;

  /// No description provided for @accountSuccessfullyDeleted.
  ///
  /// In en, this message translates to:
  /// **'Account successfully deleted'**
  String get accountSuccessfullyDeleted;

  /// No description provided for @deleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get deleteAccount;

  /// No description provided for @deleteYourAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete Your Account'**
  String get deleteYourAccount;

  /// No description provided for @iUnderstand.
  ///
  /// In en, this message translates to:
  /// **'I understand'**
  String get iUnderstand;

  /// No description provided for @enterYourPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get enterYourPassword;

  /// No description provided for @filter.
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get filter;

  /// No description provided for @noCategoriesAvailable.
  ///
  /// In en, this message translates to:
  /// **'No categories available'**
  String get noCategoriesAvailable;

  /// No description provided for @noBrandsAvailable.
  ///
  /// In en, this message translates to:
  /// **'No brands available'**
  String get noBrandsAvailable;

  /// No description provided for @searchAnyProduct.
  ///
  /// In en, this message translates to:
  /// **'Search any Product..'**
  String get searchAnyProduct;

  /// No description provided for @latestPromotions.
  ///
  /// In en, this message translates to:
  /// **'Latest Promotions'**
  String get latestPromotions;

  /// No description provided for @viewAllPromotions.
  ///
  /// In en, this message translates to:
  /// **'View all promotions'**
  String get viewAllPromotions;

  /// No description provided for @suggestedForYou.
  ///
  /// In en, this message translates to:
  /// **'Suggested for You'**
  String get suggestedForYou;

  /// No description provided for @viewAll.
  ///
  /// In en, this message translates to:
  /// **'View All'**
  String get viewAll;

  /// No description provided for @failedToLoadRecommendations.
  ///
  /// In en, this message translates to:
  /// **'Failed to load recommendations'**
  String get failedToLoadRecommendations;

  /// No description provided for @noRecommendationsAvailable.
  ///
  /// In en, this message translates to:
  /// **'No recommendations available'**
  String get noRecommendationsAvailable;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @pleaseEnterBothEmailAndPasswor.
  ///
  /// In en, this message translates to:
  /// **'Please enter both email and password.'**
  String get pleaseEnterBothEmailAndPasswor;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @forgotYourPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot your password?'**
  String get forgotYourPassword;

  /// No description provided for @orLoginWith.
  ///
  /// In en, this message translates to:
  /// **'Or login with'**
  String get orLoginWith;

  /// No description provided for @google.
  ///
  /// In en, this message translates to:
  /// **'Google'**
  String get google;

  /// No description provided for @facebook.
  ///
  /// In en, this message translates to:
  /// **'Facebook'**
  String get facebook;

  /// No description provided for @techUpgradesMadeEasy.
  ///
  /// In en, this message translates to:
  /// **'Tech Upgrades Made Easy'**
  String get techUpgradesMadeEasy;

  /// No description provided for @shopPhonesAccessoriesAndExclus.
  ///
  /// In en, this message translates to:
  /// **'Shop phones, accessories, and exclusive student deals in a tap !'**
  String get shopPhonesAccessoriesAndExclus;

  /// No description provided for @orderDetails.
  ///
  /// In en, this message translates to:
  /// **'Order Details'**
  String get orderDetails;

  /// No description provided for @shippingDetails.
  ///
  /// In en, this message translates to:
  /// **'Shipping Details'**
  String get shippingDetails;

  /// No description provided for @paymentSummary.
  ///
  /// In en, this message translates to:
  /// **'Payment Summary'**
  String get paymentSummary;

  /// No description provided for @success.
  ///
  /// In en, this message translates to:
  /// **'Success!'**
  String get success;

  /// No description provided for @continueShopping.
  ///
  /// In en, this message translates to:
  /// **'CONTINUE SHOPPING'**
  String get continueShopping;

  /// No description provided for @help.
  ///
  /// In en, this message translates to:
  /// **'Help'**
  String get help;

  /// No description provided for @passwordRecovery.
  ///
  /// In en, this message translates to:
  /// **'Password Recovery'**
  String get passwordRecovery;

  /// No description provided for @sendAgain.
  ///
  /// In en, this message translates to:
  /// **'Send Again'**
  String get sendAgain;

  /// No description provided for @pleaseEnterA4digitCode.
  ///
  /// In en, this message translates to:
  /// **'Please enter a 4-digit code'**
  String get pleaseEnterA4digitCode;

  /// No description provided for @pleaseEnterAnEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter an email'**
  String get pleaseEnterAnEmail;

  /// No description provided for @pleaseEnterYourPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Please enter your phone number'**
  String get pleaseEnterYourPhoneNumber;

  /// No description provided for @phoneNumberNotFoundInOurRecord.
  ///
  /// In en, this message translates to:
  /// **'Phone number not found in our records.'**
  String get phoneNumberNotFoundInOurRecord;

  /// No description provided for @enterYourPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter your phone number'**
  String get enterYourPhoneNumber;

  /// No description provided for @pleaseEnterThe6digitCode.
  ///
  /// In en, this message translates to:
  /// **'Please enter the 6-digit code'**
  String get pleaseEnterThe6digitCode;

  /// No description provided for @setupNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Setup New Password'**
  String get setupNewPassword;

  /// No description provided for @pleaseFillAllFields.
  ///
  /// In en, this message translates to:
  /// **'Please fill all fields'**
  String get pleaseFillAllFields;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsDoNotMatch;

  /// No description provided for @passwordUpdatedSuccessfullyPle.
  ///
  /// In en, this message translates to:
  /// **'Password updated successfully. Please login.'**
  String get passwordUpdatedSuccessfullyPle;

  /// No description provided for @nameAndEmailAreRequired.
  ///
  /// In en, this message translates to:
  /// **'Name and Email are required.'**
  String get nameAndEmailAreRequired;

  /// No description provided for @personalDetails.
  ///
  /// In en, this message translates to:
  /// **'Personal Details'**
  String get personalDetails;

  /// No description provided for @enterYourName.
  ///
  /// In en, this message translates to:
  /// **'Enter your name'**
  String get enterYourName;

  /// No description provided for @enterYourEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter your email'**
  String get enterYourEmail;

  /// No description provided for @failedToLoadProductDetails.
  ///
  /// In en, this message translates to:
  /// **'Failed to load product details'**
  String get failedToLoadProductDetails;

  /// No description provided for @totalPrice.
  ///
  /// In en, this message translates to:
  /// **'Total Price'**
  String get totalPrice;

  /// No description provided for @availableColors.
  ///
  /// In en, this message translates to:
  /// **'Available Colors'**
  String get availableColors;

  /// No description provided for @keyFeatures.
  ///
  /// In en, this message translates to:
  /// **'Key Features'**
  String get keyFeatures;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @reviews.
  ///
  /// In en, this message translates to:
  /// **'Reviews'**
  String get reviews;

  /// No description provided for @noReviewsYet.
  ///
  /// In en, this message translates to:
  /// **'No reviews yet.'**
  String get noReviewsYet;

  /// No description provided for @similarProducts.
  ///
  /// In en, this message translates to:
  /// **'Similar Products'**
  String get similarProducts;

  /// No description provided for @addedToCart.
  ///
  /// In en, this message translates to:
  /// **'Added to cart !'**
  String get addedToCart;

  /// No description provided for @avatarUpdatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Avatar updated successfully'**
  String get avatarUpdatedSuccessfully;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @sureYouWantToLogout.
  ///
  /// In en, this message translates to:
  /// **'Sure you want to Log-out ?'**
  String get sureYouWantToLogout;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @cancelOrder.
  ///
  /// In en, this message translates to:
  /// **'Cancel Order'**
  String get cancelOrder;

  /// No description provided for @areYouSureYouWantToCancelThisO.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to cancel this order? This action cannot be undone.'**
  String get areYouSureYouWantToCancelThisO;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @yesCancel.
  ///
  /// In en, this message translates to:
  /// **'Yes, Cancel'**
  String get yesCancel;

  /// No description provided for @orderCancelledSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Order cancelled successfully.'**
  String get orderCancelledSuccessfully;

  /// No description provided for @failedToCancelOrder.
  ///
  /// In en, this message translates to:
  /// **'Failed to cancel order.'**
  String get failedToCancelOrder;

  /// No description provided for @purchaseHistory.
  ///
  /// In en, this message translates to:
  /// **'Purchase History'**
  String get purchaseHistory;

  /// No description provided for @totalPayment.
  ///
  /// In en, this message translates to:
  /// **'Total Payment'**
  String get totalPayment;

  /// No description provided for @ongoing.
  ///
  /// In en, this message translates to:
  /// **'Ongoing'**
  String get ongoing;

  /// No description provided for @completed.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completed;

  /// No description provided for @canceled.
  ///
  /// In en, this message translates to:
  /// **'Canceled'**
  String get canceled;

  /// No description provided for @uploadImage.
  ///
  /// In en, this message translates to:
  /// **'Upload Image'**
  String get uploadImage;

  /// No description provided for @tapToAttachAnImage.
  ///
  /// In en, this message translates to:
  /// **'Tap to attach an image'**
  String get tapToAttachAnImage;

  /// No description provided for @removeAllAnswers.
  ///
  /// In en, this message translates to:
  /// **'Remove all answers'**
  String get removeAllAnswers;

  /// No description provided for @send.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get send;

  /// No description provided for @pleaseSelectATicketType.
  ///
  /// In en, this message translates to:
  /// **'Please select a ticket type'**
  String get pleaseSelectATicketType;

  /// No description provided for @pleaseDescribeTheIssue.
  ///
  /// In en, this message translates to:
  /// **'Please describe the issue'**
  String get pleaseDescribeTheIssue;

  /// No description provided for @ticketSubmittedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Ticket submitted successfully!'**
  String get ticketSubmittedSuccessfully;

  /// No description provided for @failedToSubmitTicket.
  ///
  /// In en, this message translates to:
  /// **'Failed to submit ticket.'**
  String get failedToSubmitTicket;

  /// No description provided for @typeHere.
  ///
  /// In en, this message translates to:
  /// **'Type here ...'**
  String get typeHere;

  /// No description provided for @addReview.
  ///
  /// In en, this message translates to:
  /// **'Add Review'**
  String get addReview;

  /// No description provided for @noReviewsYetBeTheFirstToReview.
  ///
  /// In en, this message translates to:
  /// **'No reviews yet. Be the first to review!'**
  String get noReviewsYetBeTheFirstToReview;

  /// No description provided for @sortBy.
  ///
  /// In en, this message translates to:
  /// **'Sort By'**
  String get sortBy;

  /// No description provided for @failedToLoadProducts.
  ///
  /// In en, this message translates to:
  /// **'Failed to load products'**
  String get failedToLoadProducts;

  /// No description provided for @tryADifferentSearchTerm.
  ///
  /// In en, this message translates to:
  /// **'Try a different search term'**
  String get tryADifferentSearchTerm;

  /// No description provided for @securityAndPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Security and Privacy'**
  String get securityAndPrivacy;

  /// No description provided for @yourAccountIsProtected.
  ///
  /// In en, this message translates to:
  /// **'Your account is protected'**
  String get yourAccountIsProtected;

  /// No description provided for @macktechMobileAppProtectsYourP.
  ///
  /// In en, this message translates to:
  /// **'Macktech mobile app protects your personal information and keeps it private , safe and secure .'**
  String get macktechMobileAppProtectsYourP;

  /// No description provided for @attachments.
  ///
  /// In en, this message translates to:
  /// **'Attachments'**
  String get attachments;

  /// No description provided for @imageAttached.
  ///
  /// In en, this message translates to:
  /// **'Image attached'**
  String get imageAttached;

  /// No description provided for @chatWithSupport.
  ///
  /// In en, this message translates to:
  /// **'Chat with Support'**
  String get chatWithSupport;

  /// No description provided for @iAlreadyHaveAnAccount.
  ///
  /// In en, this message translates to:
  /// **'I already have an account'**
  String get iAlreadyHaveAnAccount;

  /// No description provided for @wishlist.
  ///
  /// In en, this message translates to:
  /// **'Wishlist'**
  String get wishlist;

  /// No description provided for @failedToLoadWishlist.
  ///
  /// In en, this message translates to:
  /// **'Failed to load wishlist'**
  String get failedToLoadWishlist;

  /// No description provided for @yourWishlistIsEmpty.
  ///
  /// In en, this message translates to:
  /// **'Your wishlist is empty'**
  String get yourWishlistIsEmpty;

  /// No description provided for @addToCart.
  ///
  /// In en, this message translates to:
  /// **'Add to Cart'**
  String get addToCart;

  /// No description provided for @dashboard.
  ///
  /// In en, this message translates to:
  /// **'DASHBOARD'**
  String get dashboard;

  /// No description provided for @allProducts.
  ///
  /// In en, this message translates to:
  /// **'ALL PRODUCTS'**
  String get allProducts;

  /// No description provided for @orderList.
  ///
  /// In en, this message translates to:
  /// **'ORDER LIST'**
  String get orderList;

  /// No description provided for @pleaseEnterTheOtpOnetimePasswo.
  ///
  /// In en, this message translates to:
  /// **'Please enter the OTP (One-Time Password) sent to your registered email/phone number to complete your verification.'**
  String get pleaseEnterTheOtpOnetimePasswo;

  /// No description provided for @verify.
  ///
  /// In en, this message translates to:
  /// **'Verify'**
  String get verify;

  /// No description provided for @expires.
  ///
  /// In en, this message translates to:
  /// **'Expires'**
  String get expires;

  /// No description provided for @deleteReview.
  ///
  /// In en, this message translates to:
  /// **'Delete Review'**
  String get deleteReview;

  /// No description provided for @areYouSureYouWantToDeleteThisR.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this review?'**
  String get areYouSureYouWantToDeleteThisR;

  /// No description provided for @failedToDeleteReview.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete review'**
  String get failedToDeleteReview;

  /// No description provided for @accountSecurity.
  ///
  /// In en, this message translates to:
  /// **'Account security'**
  String get accountSecurity;

  /// No description provided for @privacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy'**
  String get privacy;

  /// No description provided for @permissions.
  ///
  /// In en, this message translates to:
  /// **'Permissions'**
  String get permissions;

  /// No description provided for @safetyCenter.
  ///
  /// In en, this message translates to:
  /// **'Safety center'**
  String get safetyCenter;

  /// No description provided for @youHaveAnOngoingOrder.
  ///
  /// In en, this message translates to:
  /// **'You have an ongoing order'**
  String get youHaveAnOngoingOrder;

  /// No description provided for @getCustomerSupport.
  ///
  /// In en, this message translates to:
  /// **'Get Customer Support'**
  String get getCustomerSupport;

  /// No description provided for @raiseAnyConcerns.
  ///
  /// In en, this message translates to:
  /// **'Raise any concerns about a product/s'**
  String get raiseAnyConcerns;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @sort.
  ///
  /// In en, this message translates to:
  /// **'Sort'**
  String get sort;

  /// No description provided for @relevance.
  ///
  /// In en, this message translates to:
  /// **'Relevance'**
  String get relevance;

  /// No description provided for @priceLowToHigh.
  ///
  /// In en, this message translates to:
  /// **'Price: Low -> High'**
  String get priceLowToHigh;

  /// No description provided for @priceHighToLow.
  ///
  /// In en, this message translates to:
  /// **'Price: High -> Low'**
  String get priceHighToLow;

  /// No description provided for @nameAToZ.
  ///
  /// In en, this message translates to:
  /// **'Name: A -> Z'**
  String get nameAToZ;

  /// No description provided for @nameZToA.
  ///
  /// In en, this message translates to:
  /// **'Name: Z -> A'**
  String get nameZToA;

  /// No description provided for @productsText.
  ///
  /// In en, this message translates to:
  /// **'products'**
  String get productsText;

  /// No description provided for @resultsFor.
  ///
  /// In en, this message translates to:
  /// **'results for'**
  String get resultsFor;

  /// No description provided for @deleteAccountWarningMsg.
  ///
  /// In en, this message translates to:
  /// **'This will permanently erase your profile, order history, and saved payment methods. You\'ll lose access to all MACKTECH MOBILES app benefits.'**
  String get deleteAccountWarningMsg;

  /// No description provided for @inStock.
  ///
  /// In en, this message translates to:
  /// **'In Stock'**
  String get inStock;

  /// No description provided for @outOfStock.
  ///
  /// In en, this message translates to:
  /// **'Out of Stock'**
  String get outOfStock;

  /// No description provided for @sku.
  ///
  /// In en, this message translates to:
  /// **'SKU:'**
  String get sku;

  /// No description provided for @ticketNo.
  ///
  /// In en, this message translates to:
  /// **'Ticket no.'**
  String get ticketNo;

  /// No description provided for @customerName.
  ///
  /// In en, this message translates to:
  /// **'Customer Name'**
  String get customerName;

  /// No description provided for @statusOpen.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get statusOpen;

  /// No description provided for @statusClosed.
  ///
  /// In en, this message translates to:
  /// **'Closed'**
  String get statusClosed;

  /// No description provided for @statusResolved.
  ///
  /// In en, this message translates to:
  /// **'Resolved'**
  String get statusResolved;

  /// No description provided for @statusInProgress.
  ///
  /// In en, this message translates to:
  /// **'In Progress'**
  String get statusInProgress;

  /// No description provided for @promotions.
  ///
  /// In en, this message translates to:
  /// **'Promotions'**
  String get promotions;

  /// No description provided for @revenue.
  ///
  /// In en, this message translates to:
  /// **'Revenue'**
  String get revenue;

  /// No description provided for @orders.
  ///
  /// In en, this message translates to:
  /// **'Orders'**
  String get orders;

  /// No description provided for @products.
  ///
  /// In en, this message translates to:
  /// **'Products'**
  String get products;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'vi'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'vi':
      return AppLocalizationsVi();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
