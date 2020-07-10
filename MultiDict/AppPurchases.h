//=========================================================================================================================================================
//  PurchasesView.h
//  TrdSuite
//
//  Created by Camilo on 05/10/15.
//  Copyright (c) 2015 Softlingo. All rights reserved.
//=========================================================================================================================================================

#import <StoreKit/StoreKit.h>

//=========================================================================================================================================
@protocol ShowPurchaseUI
  - (void) UpdatePurchaseInfo;
  - (void) PurchaseCompleted;
  - (void) PurchaseError:(NSString*) locMsg;
@end

//=========================================================================================================================================================
@interface Purchases : NSObject <SKPaymentTransactionObserver, SKProductsRequestDelegate>

  +(void) Initialize;
  +(BOOL) RequestProdInfo;
  +(BOOL) PurchaseProd:(NSString *) idProd;
  +(void) RestorePurchases;
  +(BOOL) IsProdInfo;

  +(void) Remove;
  +(void) SetNotify:(id<ShowPurchaseUI>) Notify;

  @property (nonatomic) id<ShowPurchaseUI> PurchaseNotify;

@end

//=========================================================================================================================================================
