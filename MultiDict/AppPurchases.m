//=========================================================================================================================================================
//  PurchasesView.m
//  TrdSuite
//
//  Created by Camilo on 05/10/15.
//  Copyright (c) 2015 Softlingo. All rights reserved.
//=========================================================================================================================================================

#import "AppPurchases.h"
#import "AppData.h"
#import "ProdsData.h"

//#define SIMULATE                          // Simula que se esta conectando a internet

//=========================================================================================================================================================

static Purchases*     _Purchases;                                   // Objeto para manejar las compras dentros de la aplicacion
static BOOL           InProcessRest;                                // Indica que la restauración de las compras esta en proceso
static int            RequestStatus;                                // Estado de la solicitud de productos a AppStore

//---------------------------------------------------------------------------------------------------------------------------------------------
// Posibles valores para 'RequestStatus'
#define REQUEST_NOSTART    0                                         // La solicitud no ha comenzado
#define REQUEST_INPROCESS  1                                         // La solicitud no esta en proceso
#define REQUEST_ENDED      2                                         // La solicitud termino satisfactoriamente

//---------------------------------------------------------------------------------------------------------------------------------------------
#ifdef DEBUG
void DebugMsg(NSString* msg)
  {
  NSLog(@"AppPurchases: %@",msg);
  }
#endif

//=========================================================================================================================================================
@implementation Purchases

//---------------------------------------------------------------------------------------------------------------------------------------------
// Inicializa los item que se pueden comprar y la comonicación con AppStore
+(void) Initialize
  {
  if( !_Purchases )
    _Purchases = [[Purchases alloc] init];                              // Crea el objeto que maneja las compras
  
  [[SKPaymentQueue defaultQueue] addTransactionObserver:_Purchases];    // Pone el objeto a recivir las notificaciones de pago
  
  [Purchases RequestProdInfo];                                          // Solicita información sobre los productos que hay en App Store
  }

//---------------------------------------------------------------------------------------------------------------------------------------------
// Quita el objeto que espera por las compras
+(void) Remove
  {
  if( _Purchases != nil )                                                 // Si se inicializo el objeto para manejar las compras
    [[SKPaymentQueue defaultQueue] removeTransactionObserver:_Purchases]; // Quita las notificacones del sistema a ese objeto
  }

//---------------------------------------------------------------------------------------------------------------------------------------------
// Estable cual es el objeto que hay que motificarle que la compra se realizo
+(void) SetNotify:(id<ShowPurchaseUI>) Notify
  {
   if( !_Purchases )
      _Purchases = [[Purchases alloc] init];                              // Crea el objeto que maneja las compras
   
  _Purchases.PurchaseNotify = Notify;                                     // Pone objeto que se debe modificar la actividad de las compras
  }

//---------------------------------------------------------------------------------------------------------------------------------------------
// Notifica que cambiaron los datos de compra, si hay un objeto establecido para eso
+(void) NotifyPurchase:(NSString*) msg
  {
#ifdef DEBUG
   NSString* info = [NSString stringWithFormat:@"Notificación: %@\n\r", msg];
   DebugMsg( info );
#endif

  if( _Purchases.PurchaseNotify )                                          // Si se espablecio el objeto que hay que modificar
    [_Purchases performSelectorOnMainThread:@selector(SelectorNotify:) withObject:msg waitUntilDone:NO];
  }

//---------------------------------------------------------------------------------------------------------------------------------------------
// Selector para ejecutar la notificación desde el thread principal
-(void) SelectorNotify:(NSString*) msg
  {
  if( [msg isEqualToString:@"INFO"] )
    [_Purchases.PurchaseNotify UpdatePurchaseInfo];                       // Lo notifica que se obtubo la informacion de los productos
  else if( [msg isEqualToString:@"BUY"] )
    [_Purchases.PurchaseNotify PurchaseCompleted];                        // Lo notifica que al menos una compra fue completada
  else
    [_Purchases.PurchaseNotify PurchaseError:msg];                        // Lo notifica que se produjo un error en el proceso de compra
  
  #ifdef DEBUG
    DebugMsg(@"Notificación desde el selector\n\r");
  #endif
  }

//---------------------------------------------------------------------------------------------------------------------------------------------
// Solicita la información sobre los productos a AppStore
+(BOOL) RequestProdInfo
  {
  if( IsAllPurchases() )                                                    // Si ya se realizaron todas las comprar
    RequestStatus = REQUEST_ENDED;                                          // Da la solicitud por terminada
  
  if( RequestStatus == REQUEST_ENDED     ) return TRUE;                     // Si ya se obtubo la información, retorna verdadero
  if( RequestStatus == REQUEST_INPROCESS ) return FALSE;                    // Si ya hay una solicitud en proceso, retorna falso
  
  NSSet * lstProds = GetAppStoreProdList();                                 // Obtiene la conjunto de identificadores de las compras
  
  SKProductsRequest* request = [[SKProductsRequest alloc] initWithProductIdentifiers:lstProds ];  // Crea objeto con todos los productos
  
  [request setDelegate:_Purchases];                                         // Pone objeto para la notificación de los resultados
  [request start];                                                          // Comienza el proceso de solicitud
  
  #ifdef DEBUG
    NSString* Info = @"SOLICITUD INFORMACIÓN DE PRODUCTOS: ";
  
    for( NSString* ProdId in lstProds )
      {
      Info = [Info stringByAppendingString:@"\r\n"];
      Info = [Info stringByAppendingString:ProdId ];
      }
  
    DebugMsg( Info );
  #endif
  
  RequestStatus = REQUEST_INPROCESS;                                        // Pone el estado como en proceso

  return FALSE;
  }

//---------------------------------------------------------------------------------------------------------------------------------------------
// Retorna si ya se tiene la información sobre los productos o no
+(BOOL) IsProdInfo
  {
  return (RequestStatus == REQUEST_ENDED);
  }

//---------------------------------------------------------------------------------------------------------------------------------------------
// Retorno desde AppStore de la información de los productos solicitados
- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
  {
  #ifdef DEBUG
    NSString* Info = [NSString stringWithFormat:@"RESPUESTA A SOLICITUD DE PRODUCTOS\r\n%d productos validos %d productos invalidos", (int)response.products.count, (int)response.invalidProductIdentifiers.count];

    Info = [Info stringByAppendingString:@"\r\nValidos"];
    for( SKProduct* Prod in response.products )
      {
      Info = [Info stringByAppendingString:@"\r\n"];
      Info = [Info stringByAppendingString:Prod.productIdentifier];
      }
  
    Info = [Info stringByAppendingString:@"\r\nNO VALIDOS"];
    for( NSString* Prod in response.invalidProductIdentifiers )
      {
      Info = [Info stringByAppendingString:@"\r\n"];
      Info = [Info stringByAppendingString:Prod];
      }
  
    DebugMsg( Info );
  #endif
  
  for( SKProduct* Prod in response.products )                   // Recorre todos los productos validos
    setProductInfo( Prod );                                     // Guarda la información retornada de App Store
  
  if( response.invalidProductIdentifiers.count == 0 )           // Si no hay ningún producto no valido
    {
    RequestStatus = REQUEST_ENDED;                              // Cambia el estado de la solicitud como terminada
    [Purchases NotifyPurchase:@"INFO"];                         // Notifica que se obtuvo la información de los productos
    }
  else                                                          // Si al menos hay un producto que no sea valido
    {
    RequestStatus = REQUEST_NOSTART;                            // Reseta el estado de la solicitud
    [Purchases NotifyPurchase:@"RequestInfoError"];             // Notifica que hubo un error al obtener la información de los productos
    }
  }

//---------------------------------------------------------------------------------------------------------------------------------------------
// Llamada cuando se produce un error en la solicitud de información de los productos
-(void)request:(SKRequest *)request didFailWithError:(NSError *)error
  {
  #ifdef DEBUG
    NSString* Info = [NSString stringWithFormat:@"FALLO LA SOLICITUD DE INFORMACIÓN\r\n%@", error.localizedDescription];
    DebugMsg( Info );
  #endif
  
  RequestStatus = REQUEST_NOSTART;                              // Resetea el estado de la solicitud
  [request cancel];                                             // Cancela la solicitud
  
  [Purchases NotifyPurchase:@"RequestInfoError"];               // Notifica que hubo un error al obtener la información de los productos
  }

//---------------------------------------------------------------------------------------------------------------------------------------------
// Esta función manda a restaurar todas las compras que se hicieron anteriormente
+ (void)RestorePurchases
  {
  if( InProcessRest ) return;                                   // Si ya esta restuarando las compras, no hace nada
  
  [[SKPaymentQueue defaultQueue] restoreCompletedTransactions]; // Manda a restaurar todos los productos comprados
  InProcessRest = TRUE;                                         // Cambia estado a restauracion en proceso
  
  #ifdef DEBUG
    DebugMsg( @"RESTAURANDO TODOS LOS PRODUCTOS COMPRADOS\r\n" );
  #endif
  }

//---------------------------------------------------------------------------------------------------------------------------------------------
// Se llama cuando se produce un error al tratar de restaurar las compras realizadas
- (void)paymentQueue:(SKPaymentQueue *)queue restoreCompletedTransactionsFailedWithError:(NSError *)error
  {
  #ifdef DEBUG
    NSString* Info = [NSString stringWithFormat:@"FALLO LA RESTAURACIÓN DE LAS COMPRAS\r\n%@", error.localizedDescription];
    DebugMsg( Info );
  #endif
  
  InProcessRest = FALSE;                                        // Resetea el estado del proceso de restauración
  
  [Purchases NotifyPurchase:@"TransError"];                     // Notifica error en la transación para restaurar los productos
  }

//---------------------------------------------------------------------------------------------------------------------------------------------
// Desencadena el proceso de compra de un producto
+ (BOOL) PurchaseProd:(NSString *) idProd
  {
  SKProduct* Prod = getProdObject( idProd );                    // Obtiene informacion del producto con identificador
  
  if( Prod == nil )                                             // No existe información del producto
    {
    [Purchases NotifyPurchase:@"RequestInfoError"];             // Pone cartel que no se ha conectado
    return FALSE;
    }
    
  #ifdef DEBUG
    NSString* Info = [NSString stringWithFormat:@"SE SOLICITO LA COMPRA DE: %@\r\n", idProd];
    DebugMsg( Info );
  #endif
  
  SKPayment* PayRequest = [SKPayment paymentWithProduct:Prod];  // Crea un pago con informacion del producto
  
   setProdState( idProd, ENPROCESO );                            // Pone el estado del item (en proceso de compra)
   
  [[SKPaymentQueue defaultQueue] addPayment:PayRequest];        // Envia el pago a App Store
  
  return TRUE;
  }

//---------------------------------------------------------------------------------------------------------------------------------------------
// Función que es llamada cuando una compra es completada
- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
  {
  for( SKPaymentTransaction* Transation in transactions )                               // Recorre todas la transaciones pendientes
    {
    if( Transation.transactionState == SKPaymentTransactionStatePurchasing ) continue;
    
    SKPayment * Pay = Transation.payment;
    NSString *idProd = Pay.productIdentifier;
    
    if( Transation.transactionState == SKPaymentTransactionStateFailed )                // Hubo un error en el poceso de pago
      {
      #ifdef DEBUG
        NSString* Info = [NSString stringWithFormat:@"FALLÓ LA COMPRA DE: %@\r\n", idProd];
        DebugMsg( Info );
      #endif
  
      [Purchases CancelPayment:Pay];
      [Purchases NotifyPurchase: @"TransError" ];
      }
    else if( Transation.transactionState == SKPaymentTransactionStatePurchased )        // El producto fue comprado satisfactoriamente
      {
      #ifdef DEBUG
        NSString* Info = [NSString stringWithFormat:@"TERMINO LA COMPRA DE: %@\r\n", idProd];
        DebugMsg( Info );
      #endif
  
      PurchaseAndSaveProd( idProd );
      [Purchases NotifyPurchase: @"BUY" ];
      }
    else if( Transation.transactionState == SKPaymentTransactionStateRestored  )        // El producto fue restaurado de una compra anterior
      {
      #ifdef DEBUG
        NSString* Info = [NSString stringWithFormat:@"SE RESTAURO EL PRODUCTO: %@\r\n", idProd];
        DebugMsg( Info );
      #endif
  
      PurchaseAndSaveProd( idProd );
      [Purchases NotifyPurchase: @"BUY" ];
      
      InProcessRest = FALSE;
      }
    else  // Estado de compra no considerado
      {
      #ifdef DEBUG
        NSString* Info = [NSString stringWithFormat:@"ESTADO NO ATENDIDO: %ld\r\n", (long)Transation.transactionState];
        DebugMsg( Info );
      #endif
      }
    
    [queue finishTransaction:Transation];                                               // Quita la transación de la cola
    }
  }

//---------------------------------------------------------------------------------------------------------------------------------------------
// Cancela el proceso de pago para un producto
+ (void) CancelPayment: (SKPayment *) Pay
  {
  setProdState( Pay.productIdentifier, SINCOMPAR );                            // Pone el estado del item (en proceso de compra)
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
@end

//=========================================================================================================================================================
