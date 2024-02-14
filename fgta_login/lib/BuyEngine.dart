import 'dart:async';
import 'dart:io';

import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_storekit/in_app_purchase_storekit.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';

class BuyEngin{

  StreamSubscription<List<PurchaseDetails>> _subscription;
  InAppPurchase _inAppPurchase;
  List<ProductDetails> _products; //内购的商品对象集合

  //初始化购买组件
  void initializeInAppPurchase() {

    // 初始化in_app_purchase插件
    _inAppPurchase = InAppPurchase.instance;

    //监听购买的事件
    final Stream<List<PurchaseDetails>> purchaseUpdated = _inAppPurchase.purchaseStream;
    _subscription = purchaseUpdated.listen((purchaseDetailsList) {
      _listenToPurchaseUpdated(purchaseDetailsList);
    }, onDone: () {
      _subscription.cancel();
    }, onError: (error) {
      error.printError();
      print("购买失败了");
    });
  }

  void resumePurchase(){
    _inAppPurchase.restorePurchases();
  }

  /// 加载全部的商品
  void buyProduct(String productId) async {

    print("请求商品id " + productId);

    List<String> _outProducts = [productId];

    final bool available = await _inAppPurchase.isAvailable();
    if (!available) {
      // ToastUtil.showToast("无法连接到商店");
      print("无法连接到商店");
      return;
    }

    //开始购买
    // ToastUtil.showToast("连接成功-开始查询全部商品");
    print("连接成功-开始查询全部商品");
    List<String> _kIds = _outProducts;

    final ProductDetailsResponse response = await _inAppPurchase.queryProductDetails(_kIds.toSet());
    print("商品获取结果  " + response.productDetails.toString());
    if (response.notFoundIDs.isNotEmpty) {
      // ToastUtil.showToast("无法找到指定的商品");
      print("无法找到指定的商品");
      // ToastUtil.showToast("无法找到指定的商品 数量 " + response.productDetails.length.toString());

      return;
    }

    // 处理查询到的商品列表
    List<ProductDetails> products = response.productDetails;
    print("products ==== " + products.length.toString());
    if (products.isNotEmpty) {
      //赋值内购商品集合
      _products = products;
    }

    print("全部商品加载完成了，可以启动购买了,总共商品数量为：${products.length}");

    //先恢复可重复购买
    // await _inAppPurchase. ();

    startPurchase(productId);
  }


  // 调用此函数以启动购买过程
  void startPurchase(String productId) async {

    print("购买的商品id为" + productId);
    if (_products != null && _products.isNotEmpty) {
      // ToastUtil.showToast("准备开始启动购买流程");
      try {
        ProductDetails productDetails = _getProduct(productId);

        print("一切正常，开始购买,信息如下：title: ${productDetails.title}  desc:${productDetails.description} "
            "price:${productDetails.price}  currencyCode:${productDetails.currencyCode}  currencySymbol:${productDetails.currencySymbol}");
        _inAppPurchase.buyConsumable(purchaseParam: PurchaseParam(productDetails: productDetails));
      } catch (e) {
        e.printError();
        print("购买失败了");
      }
    } else {
      print("当前没有商品无法调用购买逻辑");
    }
  }

  // 根据产品ID获取产品信息
  ProductDetails _getProduct(String productId) {
    return _products.firstWhere((product) => product.id == productId);
  }

  /// 内购的购买更新监听
  void _listenToPurchaseUpdated(List<PurchaseDetails> purchaseDetailsList) async {
    for (PurchaseDetails purchase in purchaseDetailsList) {
      if (purchase.status == PurchaseStatus.pending) {
        // 等待支付完成
        _handlePending();
      } else if (purchase.status == PurchaseStatus.canceled) {
        // 取消支付
        _handleCancel(purchase);
      } else if (purchase.status == PurchaseStatus.error) {
        // 购买失败
        _handleError(purchase.error);
      } else if (purchase.status == PurchaseStatus.purchased || purchase.status == PurchaseStatus.restored) {
        // ToastUtil.showToast(DataConfig.getShowName("Pay_Success_Tip"));
        //完成购买, 到服务器验证
        if (Platform.isAndroid) {
          var googleDetail = purchase as GooglePlayPurchaseDetails;
          checkAndroidPayInfo(googleDetail);
        } else if (Platform.isIOS) {
          var appstoreDetail = purchase as AppStorePurchaseDetails;
          checkApplePayInfo(appstoreDetail);
        }
      }
    }
  }

  /// 购买失败
  void _handleError(IAPError iapError) {
    // ToastUtil.showToast("${DataConfig.getShowName("Purchase_Failed")}：${iapError?.code} message${iapError?.message}");
  }

  /// 等待支付
  void _handlePending() {
    print("等待支付");
  }

  /// 取消支付
  void _handleCancel(PurchaseDetails purchase) {
    _inAppPurchase.completePurchase(purchase);
  }

  /// Android支付成功的校验
  void checkAndroidPayInfo(GooglePlayPurchaseDetails googleDetail) async {
    _inAppPurchase.completePurchase(googleDetail);
    print("安卓支付交易ID为" + googleDetail.purchaseID);
    print("安卓支付验证收据为" + googleDetail.verificationData.serverVerificationData);
  }

  /// Apple支付成功的校验
  void  checkApplePayInfo(AppStorePurchaseDetails appstoreDetail) async {
    _inAppPurchase.completePurchase(appstoreDetail);

    print("Apple支付交易ID为" + appstoreDetail.purchaseID);
    print("Apple支付验证收据为" + appstoreDetail.verificationData.serverVerificationData);
  }


  @override
  void onClose() {
    if (Platform.isIOS) {
      final InAppPurchaseStoreKitPlatformAddition iosPlatformAddition =
      _inAppPurchase.getPlatformAddition<InAppPurchaseStoreKitPlatformAddition>();
      iosPlatformAddition.setDelegate(null);
    }
    _subscription.cancel();
  }

}