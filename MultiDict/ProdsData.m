//===================================================================================================================================================
//  AppData.m
//  PruTranslate
//
//  Created by Camilo on 31/12/14.
//
// Maneja todos los datos relacionados con los productos que pueden ser comprados dentro de la aplicaión (InApp Purchase)
//===================================================================================================================================================

#import "ProdsData.h"
#import "AppData.h"

//=========================================================================================================================================================
//                       EnEs, EnIt, EnFr, EsEn, EsIt, EsFr, ItEs, ItEn, ItFr, FrEs, FrEn, FrIt
static int _BuyDir [] = {   0,    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,    0 };

NSTimeInterval IniDate  = 0;                  // Fecha de primera corrida del programa

struct ProdsByDir                             // Productos que de pueden descargar para una direccion
  {
  int Prods[4];
  };

struct ProdInfo                               // Guarda información sobre un productos de InApp Purchase
  {
  int state;                                  // Estado del producto 0-Sin comprar, 1-En proceso, 2-Comprado
  int nDict;                                  // Número de diccionarios que incluye el product
  SKProduct* Prod;                            // Objeto que define el producto en AppStore
  NSString *idProd;                           // Identificador del produto en App Store
  NSString *Precio;                           // Precio del item
  NSString *locName;                          // Cadena para localizar el nombre del producto
  
  int Dicts[12];                              // Lista de diccionarios que incluye el producto
  };

//=========================================================================================================================================================
// Almacena los datos relacionado con un item

ProdsByDir DirProds[] = {
  {PROD_ALL, PROD_EN, PROD_ES, PROD_ENES},           // EnEs
  {PROD_ALL, PROD_EN, PROD_IT, PROD_ENIT},           // EnIt
  {PROD_ALL, PROD_EN, PROD_FR, PROD_ENFR},           // EnFr
  {PROD_ALL, PROD_ES, PROD_EN, PROD_ENES},           // EsEn
  {PROD_ALL, PROD_ES, PROD_IT, PROD_ESIT},           // EsIt
  {PROD_ALL, PROD_ES, PROD_FR, PROD_ESFR},           // EsFr
  {PROD_ALL, PROD_IT, PROD_ES, PROD_ESIT},           // ItEs
  {PROD_ALL, PROD_IT, PROD_EN, PROD_ENIT},           // ItEn
  {PROD_ALL, PROD_IT, PROD_FR, PROD_ITFR},           // ItFr
  {PROD_ALL, PROD_FR, PROD_ES, PROD_ESFR},           // FrEs
  {PROD_ALL, PROD_FR, PROD_EN, PROD_ENFR},           // FrEn
  {PROD_ALL, PROD_FR, PROD_IT, PROD_ITFR},           // FrIt
  };

ProdInfo ProdsInfo[] = {
  0,12,0,ID_PROD_ALL , @"", @"ProdAll", {DIR_ENES, DIR_ESEN, DIR_ENIT, DIR_ITEN, DIR_ENFR, DIR_FREN, DIR_ESIT, DIR_ITES, DIR_ESFR, DIR_FRES, DIR_ITFR, DIR_FRIT},   // Todos los dicionarios
  0,6 ,0,ID_PROD_ES  , @"", @"PackEs" , {DIR_ESEN, DIR_ENES, DIR_ESIT, DIR_ITES, DIR_ESFR, DIR_FRES                                                            },   // Paquete de Inglés
  0,6 ,0,ID_PROD_EN  , @"", @"PackEn" , {DIR_ENES, DIR_ESEN, DIR_ENIT, DIR_ITEN, DIR_ENFR, DIR_FREN                                                            },   // Paquete de Espanol
  0,6 ,0,ID_PROD_IT  , @"", @"PackIt" , {DIR_ITEN, DIR_ENIT, DIR_ITES, DIR_ESIT, DIR_ITFR, DIR_FRIT                                                            },   // Paquete de Italiano
  0,6 ,0,ID_PROD_FR  , @"", @"PackFr" , {DIR_FREN, DIR_ENFR, DIR_FRES, DIR_ESFR, DIR_FRIT, DIR_ITFR                                                            },   // Paquete de Francés
  0,2 ,0,ID_PROD_ENES, @"", @"ParEnEs", {DIR_ENES, DIR_ESEN                                                                                                    },   // Par Inglés-Espanol
  0,2 ,0,ID_PROD_ENIT, @"", @"ParEnIt", {DIR_ENIT, DIR_ITEN                                                                                                    },   // Par Inglés-Italiano
  0,2 ,0,ID_PROD_ENFR, @"", @"ParEnFr", {DIR_ENFR, DIR_FREN                                                                                                    },   // Par Inglés-Francés
  0,2 ,0,ID_PROD_ESIT, @"", @"ParEsIt", {DIR_ESIT, DIR_ITES                                                                                                    },   // Par Espanol-Italiano
  0,2 ,0,ID_PROD_ESFR, @"", @"ParEsFr", {DIR_ESFR, DIR_FRES                                                                                                    },   // Par Espanol-Francés
  0,2 ,0,ID_PROD_ITFR, @"", @"ParItFr", {DIR_ITFR, DIR_FRIT                                                                                                    },   // Par Italiano-Francés
 };

#define PRODS_COUNT    (sizeof(ProdsInfo)/sizeof(ProdsInfo[0]))

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Obtiene el conjunto de productos para pedirtle información a App Store
NSSet* GetAppStoreProdList()
  {
  NSMutableSet* ProdList = [NSMutableSet new];
  
  for (int i=0; i<PRODS_COUNT; ++i )
    [ProdList addObject:ProdsInfo[i].idProd];
  
  return ProdList;
  }

//-----------------------------------------------------------------------------------------------------------------------------------------
// Asocia el Item con indice 'idx' con el producto 'prod'
NSString * GetLocPriceForProd( SKProduct* prod)
  {
  if( prod == nil ) return @"";
  
  NSLocale* loc          = prod.priceLocale;
  NSDecimalNumber* price = prod.price;
  
  NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
  
  [numberFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
  [numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
  [numberFormatter setLocale:loc];

  return [numberFormatter stringFromNumber:price];
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Pone la información obtenida de la App Store a un producto
void setProductInfo( SKProduct* Prod )
  {
  NSString* idProd = Prod.productIdentifier;
  for (int i=0; i<PRODS_COUNT; ++i )
    if( [ProdsInfo[i].idProd  isEqualToString: idProd] )
      {
      ProdsInfo[i].Prod = Prod;
      ProdsInfo[i].Precio = GetLocPriceForProd( Prod );
      return;
      }
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Cambia el estado del producto identificado como 'idProd'
void setProdState( NSString* idProd, int state )
  {
  int idxPod = getProductIndex( idProd );
  if( idxPod != -1 )
    ProdsInfo[ idxPod ].state = state;
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Obtiene la información de un producto con ID de AppStore dado
SKProduct* getProdObject( NSString* idProd )
  {
  int idxPod = getProductIndex( idProd );
  if( idxPod != -1 )
    return ProdsInfo[ idxPod ].Prod;
  
  return nil;
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Obtiene el identificador del producto, conociendo su indice en el arreglo de definición
NSString* getIdProdAt( int idxPod )
  {
  if( idxPod<0 || idxPod>=PRODS_COUNT )
    return @"";
  
  return ProdsInfo[idxPod].idProd;
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Obtiene la información de un producto con ID de AppStore dado
int getProductIndex( NSString* idProd )
  {
  for (int i=0; i<PRODS_COUNT; ++i )
    if( [ProdsInfo[i].idProd  isEqualToString: idProd] )
      return i;
  
  return -1;
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Obtiene el indice al producto, teniendo la dirección y indice del producto para ese dirección
int ProdWithDirAndPos( int Dir, int idx )
  {
  if( Dir<0 || Dir>= (sizeof(DirProds)/sizeof(DirProds[0])) )
    return -1;
    
  ProdsByDir Prods = DirProds[Dir];
  return Prods.Prods[idx];
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
static CGFloat FontSize   = [NSFont systemFontSize];                            // Tamaño de la letras estandard del sistema

static NSFont* fontTitle = [NSFont boldSystemFontOfSize: 1.5*FontSize];
static NSFont* fontText  = [NSFont boldSystemFontOfSize: 1.2*FontSize];
static NSFont* fontDicts = [NSFont systemFontOfSize    :     FontSize];

static NSColor* colTitle = [NSColor colorWithRed:0.06 green:0.43 blue:0.06 alpha:1.00];

static NSDictionary* attrTitle = @{ NSFontAttributeName:fontTitle, NSForegroundColorAttributeName:colTitle  };
static NSDictionary* attrText  = @{ NSFontAttributeName:fontText  };
static NSDictionary* attrDicts = @{ NSFontAttributeName:fontDicts };

//---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
// Obtiene la descripción del producto identificado con 'idxProd'
NSMutableAttributedString* GetProdDesc( int idxProd )
  {
  if( idxProd<0 || idxProd>=PRODS_COUNT )
    return [NSMutableAttributedString new];
  
  ProdInfo prodInfo = ProdsInfo[ idxProd ];
  
  NSString *prodName = NSLocalizedString( prodInfo.locName, nil);
  NSString *txtIncl  = NSLocalizedString(@"DictsInclud", nil);
  
  NSMutableString* langs = [NSMutableString new];
  for( int i=0; i<prodInfo.nDict; i+=2 )
    {
    NSString* dName1 = DIRName( prodInfo.Dicts[i]  , TRUE, FALSE );
    NSString* dName2 = DIRName( prodInfo.Dicts[i+1], TRUE, FALSE );
    
    [langs appendFormat:@"%@, %@\n", dName1, dName2];
    }
  
  NSString* Desc = [NSString stringWithFormat:@"%@\n%@\n%@", prodName, txtIncl, langs];
  
  NSMutableAttributedString* Txt = [[NSMutableAttributedString alloc] initWithString:Desc attributes:attrDicts  ];
  
  NSUInteger l1 = prodName.length;
  NSUInteger l2 = txtIncl.length;
  
  [Txt setAttributes:attrTitle range: NSMakeRange( 0   , l1 )];
  [Txt setAttributes:attrText  range: NSMakeRange( l1+1, l2 )];
  
  return Txt;
  }

//---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
// Obtiene el precio del producto identificado con 'idxProd'
NSString* GetPrecio( int idxProd )
  {
  if( idxProd<0 || idxProd>=PRODS_COUNT ) return @"";
  
  ProdInfo prodInfo = ProdsInfo[ idxProd ];
  return prodInfo.Precio;
  }

//---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
// Determina si ya se realizaron todas las compras
BOOL IsAllPurchases()
  {
  for (int i=0; i< sizeof(_BuyDir)/sizeof(_BuyDir[0]); ++i )
    if( _BuyDir[i] == 0 ) return FALSE;
  
  return TRUE;
  }

//---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
// Determina si ya se realizaron todas las compras
BOOL IsBuyDir( int dir )
  {
  return ( _BuyDir[dir] != 0 );
  }

//---------------------------------------------------------------------------------------------------------------------------------------------------------------------------

static const char *chars1 = "ektspfuanomljgcb";
static const char *chars2 = "1<7q3wr.'zxvh468`";
  
//---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
// Códifica todos los items comprados en una cadena de texto
NSString* EncodeData()
  {
  char code[ 2*PRODS_COUNT+1 ];
  for (int i=0; i< PRODS_COUNT; ++i )
    {
    ProdInfo prodInfo = ProdsInfo[i];
    if( prodInfo.state == COMPRADO )
      {
      code[i            ] = chars1[i];
      code[i+PRODS_COUNT] = chars2[i];
      }
    else
      {
      code[i            ] = chars2[i];
      code[i+PRODS_COUNT] = chars1[i];
      }
    }
  
  code[2*PRODS_COUNT] = '\0';
  
  return [NSString stringWithUTF8String:code];
  }

//---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
// Decodifica una cadena de texto para obtener la información de los items comprados
void DecodeData( NSString* sData)
  {
  for( NSUInteger i=0; i<PRODS_COUNT; ++i )
    {
    char c1 = [sData characterAtIndex:i];
    char c2 = [sData characterAtIndex:i+PRODS_COUNT];
    
         if( chars1[i]==c1 && chars2[i]==c2 ) PurchaseProd( (int)i );
    else if( chars1[i]==c2 && chars2[i]==c1 ) ProdsInfo[i].state = SINCOMPAR;
    else
      {
      for( NSUInteger j=0; j<PRODS_COUNT; ++j ) ProdsInfo[j].state = SINCOMPAR;
      break;
      }
    }
  }

//---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
// Códifica un intervalos de tiempo en una cadena de caracteres
NSString* EncodeTime( NSTimeInterval tm )
  {
  NSString* sTime = [NSString stringWithFormat:@"%.0f", tm];
  
  int  nChar = (int)sTime.length;
  char code[ nChar+1 ];
  
  for (int i=0; i< nChar; ++i )
    {
    switch( [sTime characterAtIndex:i] )
      {
      case '0': code[i] = 'd'; break;
      case '1': code[i] = 'f'; break;
      case '2': code[i] = 'h'; break;
      case '3': code[i] = '9'; break;
      case '4': code[i] = 'v'; break;
      case '5': code[i] = 'm'; break;
      case '6': code[i] = 'q'; break;
      case '7': code[i] = 'r'; break;
      case '8': code[i] = 'u'; break;
      case '9': code[i] = 'o'; break;
      case '-': code[i] = '4'; break;
      }
    }
  
  code[nChar] = '\0';
  
  return [NSString stringWithUTF8String:code];
  }

//---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
// Códifica una cadena de caracteres en un intervalo de tiempo
NSTimeInterval DecodeTime( NSString* sCode )
  {
  int  nChar = (int)sCode.length;
  char code[ nChar+1 ];
  
  for (int i=0; i< nChar; ++i )
    {
    switch( [sCode characterAtIndex:i] )
      {
      case 'd': code[i] = '0'; break;
      case 'f': code[i] = '1'; break;
      case 'h': code[i] = '2'; break;
      case '9': code[i] = '3'; break;
      case 'v': code[i] = '4'; break;
      case 'm': code[i] = '5'; break;
      case 'q': code[i] = '6'; break;
      case 'r': code[i] = '7'; break;
      case 'u': code[i] = '8'; break;
      case 'o': code[i] = '9'; break;
      case '4': code[i] = '-'; break;
      }
    }
  
  code[nChar] = '\0';
  NSString* sTime = [NSString stringWithUTF8String:code];
  
  return [sTime doubleValue];
  }
//---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
// Obtiene la fecha actual y la guarda
void SaveBuyData()
  {
  NSUserDefaults* UserDef = [NSUserDefaults standardUserDefaults];
  
  NSString* cData = EncodeData();
  NSString* cTime = EncodeTime(IniDate);
  
  NSString* sData = [cTime stringByAppendingString:cData];
  [UserDef setObject:sData forKey:@"Data1"];
  }

//---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
// Obtiene la fecha actual y la guarda
void SetIniDate( BOOL reset=FALSE )
  {
  NSUserDefaults* UserDef = [NSUserDefaults standardUserDefaults];
  
  if( reset ) IniDate = 0;
  else        IniDate = [NSDate date].timeIntervalSinceReferenceDate;
  
  NSString* sTime = [NSString stringWithFormat:@"%.0f", IniDate];
  
  [UserDef setObject:sTime forKey:@"Data2"];
  [UserDef setObject:sTime forKey:@"Data3"];
  
  SaveBuyData();
  }

//---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
// Obtine la cantidad de dias trascurridos desde la instalación
int GetDayCount()
  {
  NSUserDefaults* UserDef = [NSUserDefaults standardUserDefaults];
  NSTimeInterval nowDate  = [NSDate date].timeIntervalSinceReferenceDate;   // Toma la fecha actual
  
  NSString* sLastDate = [UserDef objectForKey:@"Data3"];                    // Obtiene la ultima fecha que se chequeo
  if( sLastDate==nil ) return DAYS_MAX;                                     // Si no esta, invalida dias de pruebas
  
  NSTimeInterval LastDate = [sLastDate doubleValue];                        // Valor de ultima fecha que se chequeo
  if( nowDate < LastDate ) return DAYS_MAX;                                 // Si mayor que la fecha actual, invalida dias de pruebas
  
  sLastDate = [NSString stringWithFormat:@"%f", nowDate];                   // Actualiza la ultima fecha de chequeo
  [UserDef setObject:sLastDate forKey:@"Data3"];
  
  int nDays = (int)((nowDate-IniDate)/SEGS_DAY);                            // Calcula el número de dias dede la fecha de instalación
  
  if( nDays>DAYS_MAX ) nDays = DAYS_MAX;
  return nDays;
  }

//---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
// Pone un producto como camprado
void PurchaseProd( int idxProd )
  {
  ProdInfo prodInfo = ProdsInfo[idxProd];
  
  for( int i=0; i<prodInfo.nDict; ++i )
    _BuyDir[ prodInfo.Dicts[i] ] = 1;

  ProdsInfo[idxProd].state = COMPRADO;
  }

//---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
// Lee los datos guardado por la aplicación
void ReadAppData()
  {
  NSUserDefaults* UserDef = [NSUserDefaults standardUserDefaults];
  NSString* sTime = [UserDef objectForKey:@"Data2"];                  // Obtiene datos de la fecha de instalación
  
  if( sTime == nil )                                                  // Si es la primera vez la inicializa
    SetIniDate();                                                     // Crea Data2 (Fecha instalación) y Data3 (Ultimo acceso)
  else
    IniDate = [sTime doubleValue];                                    // En otro caso toma el valor

  NSString* sData = [UserDef objectForKey:@"Data1"];                  // Obtiene datos de los productos comprados
  
  NSString* cTime1 = EncodeTime(IniDate);                             // Codifica la fecha de instalación
  
  NSUInteger len  = cTime1.length;
  NSRange    rg1  = NSMakeRange(0, len);                              // Rango para datos de la fecha
  NSRange    rg2  = NSMakeRange(len, sData.length-len);               // Rango para datos de productos comprados
  
  NSString* cTime2 = [sData substringWithRange:rg1];                  // Cadena con el código para fecha de instalación
  NSString* cData  = [sData substringWithRange:rg2];                  // Cadena con el código para productos coprados
  
  if( ![cTime1 isEqualToString:cTime2] )                              // Si difiere el código de instalación
    {
    SetIniDate( TRUE );                                               // Resetea fecha de instalacion y quita los dias de prueba
    return;                                                           // Termina
    }
  
  DecodeData(cData);                                                  // Decodifica y actualiza productos comprados
  }

//---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
// Realiza la compra del producto con el identificador 'idProd'
void PurchaseAndSaveProd( NSString* idProd )
  {
  int idxProd = getProductIndex( idProd );
  if( idxProd==-1 ) return;
  
  PurchaseProd( idxProd );
  SaveBuyData();
  }

//---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
// Quita todas las compras que se hayan realizado
void ClearPurchase()
  {
  for (int i=0; i< sizeof(_BuyDir)/sizeof(_BuyDir[0]); ++i )
    _BuyDir[i] = 0;
  
  for (int i=0; i<PRODS_COUNT; ++i )
    ProdsInfo[i].state = SINCOMPAR;
  
   SaveBuyData();
  }

//===================================================================================================================================================
