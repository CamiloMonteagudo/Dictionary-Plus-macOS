//===================================================================================================================================================
//  AppData.h
//  PruTranslate
//
//  Created by Camilo on 31/12/14.
//  Copyright (c) 2014 Softlingo. All rights reserved.
//===================================================================================================================================================

#import <Cocoa/Cocoa.h>
#import <StoreKit/StoreKit.h>

//===================================================================================================================================================
// Difine los identificadores de los items que se pueden comprar
#define DIR_ENES   0
#define DIR_ENIT   1
#define DIR_ENFR   2
#define DIR_ESEN   3
#define DIR_ESIT   4
#define DIR_ESFR   5
#define DIR_ITES   6
#define DIR_ITEN   7
#define DIR_ITFR   8
#define DIR_FRES   9
#define DIR_FREN   10
#define DIR_FRIT   11

#define PROD_ALL    0
#define PROD_ES     1
#define PROD_EN     2
#define PROD_IT     3
#define PROD_FR     4
#define PROD_ENES   5
#define PROD_ENIT   6
#define PROD_ENFR   7
#define PROD_ESIT   8
#define PROD_ESFR   9
#define PROD_ITFR   10

#define ID_PROD_ALL    @"com.bigxsoft.ProdDictMacAll"
#define ID_PROD_ES     @"com.bigxsoft.ProdDictMacEn"
#define ID_PROD_EN     @"com.bigxsoft.ProdDictMacEs"
#define ID_PROD_IT     @"com.bigxsoft.ProdDictMacIt"
#define ID_PROD_FR     @"com.bigxsoft.ProdDictMacFr"
#define ID_PROD_ENES   @"com.bigxsoft.ProdDictMacEnEs"
#define ID_PROD_ENIT   @"com.bigxsoft.ProdDictMacEnIt"
#define ID_PROD_ENFR   @"com.bigxsoft.ProdDictMacEnFr"
#define ID_PROD_ESIT   @"com.bigxsoft.ProdDictMacEsIt"
#define ID_PROD_ESFR   @"com.bigxsoft.ProdDictMacEsFr"
#define ID_PROD_ITFR   @"com.bigxsoft.ProdDictMacItFr"

#define SEGS_DAY   (60*60*24)

#define SINCOMPAR   0
#define ENPROCESO   1
#define COMPRADO    2

extern NSSet* GetAppStoreProdList();

extern void       setProductInfo( SKProduct* Prod );
extern int        getProductIndex( NSString* idProd );
extern SKProduct* getProdObject( NSString* idProd );
extern void       setProdState( NSString* idProd, int state );
extern NSString*  getIdProdAt( int idxPod );

extern int ProdWithDirAndPos( int Dir, int idx );
extern BOOL IsAllPurchases();
extern BOOL IsBuyDir( int dir );

extern void PurchaseProd( int idxProd );
extern void ReadAppData();
extern int  GetDayCount();

extern void PurchaseAndSaveProd( NSString* idProd );
extern void ClearPurchase();

extern NSMutableAttributedString* GetProdDesc( int idxProd );
extern NSString* GetPrecio( int idxProd );

//===================================================================================================================================================
