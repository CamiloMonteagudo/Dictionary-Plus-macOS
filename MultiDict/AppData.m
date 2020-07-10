//===================================================================================================================================================
//  AppData.m
//  PruTranslate
//
//  Created by Camilo on 31/12/14.
//  Copyright (c) 2014 Softlingo. All rights reserved.
//===================================================================================================================================================

#import "AppData.h"

//===================================================================================================================================================
int LGSrc = -1;
int LGDes = -1;
int iUser = 0;

__strong DictMain*     Dict;
__strong DictIndexes*  DictIdx;

__strong ViewController* Ctrller;

//=========================================================================================================================================================

NSCharacterSet* lnSep = [NSCharacterSet characterSetWithCharactersInString:@"\n"];
NSCharacterSet* kySep = [NSCharacterSet characterSetWithCharactersInString:@"\\"];

NSCharacterSet* TypeSep = [NSCharacterSet characterSetWithCharactersInString:@"|"];
NSCharacterSet* MeanSep = [NSCharacterSet characterSetWithCharactersInString:@";"];

NSCharacterSet* PntOrSpc = [NSCharacterSet characterSetWithCharactersInString:@". ("];
NSCharacterSet* TrimSpc  = [NSCharacterSet characterSetWithCharactersInString:@" *"];

NSCharacterSet* wrdSep = [NSCharacterSet characterSetWithCharactersInString:@" -()\"¿?!¡$,/+*="];

NSColor* SelColor = [NSColor colorWithCalibratedRed:0.9 green:0.98 blue:1 alpha:1];

//===================================================================================================================================================
// Abreviatura de de los idiomas segun el codigo ISO
static NSString *_AbrvLng[] = { @"Es", @"En", @"It", @"Fr" };

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Nombre de los idiomas de traduccion segun la interfaz de usuario
static NSString * _LngNames[LGCount][LGCount] =
  {  //Español  , Ingles        , Italiano        , Frances
    {@"Español" , @"Inglés   "  , @"Italiano  "   , @"Francés "  },   // IUser Español
    {@"Spanish" , @"English "   , @"Italian   "   , @"French  "  },   // IUser Inglés
    {@"Spagnolo", @"Inglese   " , @"Italiano    " , @"Francese " },   // IUser Italiano
    {@"Espagnol", @"Anglais   " , @"Italien     " , @"Français " },   // IUser Francés
  };

//English-Spanish
//---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
// Banderas para representar los idiomas
static NSString * _LngFlags[LGCount] =  {@"🇪🇸", @"🇺🇸", @"🇮🇹", @"🇫🇷" };

//---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
// DEFINE LOS DICCIONARIOS Y CONJUGACIONES INSTALADOS

//                         EnEs, EnIt, EnFr, EsEn, EsIt, EsFr, ItEs, ItEn, ItFr, FrEs, FrEn, FrIt
//static int _InstSrc[] = {   1,    1,    1,    0,    0,    0,    2,    2,    2,    3,    3,    3 };
//static int _InstDes[] = {   0,    2,    3,    1,    2,    3,    0,    1,    3,    0,    1,    2 };

//                        EnEs, EsEn
static int _InstSrc[]  = {   1,    0 };
static int _InstDes[]  = {   0,    1 };

//                        Es, En, It, Fr
static int _InstConj[] = { 0, 1 };


//---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
int DIRCount()
  {
  return sizeof(_InstSrc)/sizeof(_InstSrc[0]);
  }

//---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
int CNJCount()
  {
  return sizeof(_InstConj)/sizeof(_InstConj[0]);
  }

//---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
int CNJLang( int idx )
  {
  return _InstConj[idx];
  }

//---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
NSString* CNJTitle( int idx )
  {
  int lng = _InstConj[idx];
  return [NSString stringWithFormat:@"%@ %@", LGFlag(lng), LGName(lng)];
  }

//---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
NSString* LGAbrv( int lng )
  {
  if( lng<0 || lng>LGCount ) return @"";

  return _AbrvLng[lng];
  }

//---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
// Obtiene el nombre del idioma 'lng'
NSString* LGName( int lng )
  {
  if( lng<0 || lng>LGCount ) return @"";

	return _LngNames[iUser][lng];
  }

//---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
// Obtiene el nombre de la dirección de traducción con indice 'iDir'
NSString* DIRName( int iDir )
  {
  if( iDir<0 || iDir>DIRCount() ) return @"";
  
  int iSrc = _InstSrc[iDir];
  int iDes = _InstDes[iDir];
  
  NSString* sSrc = _LngNames[iUser][iSrc];
  NSString* sDes = _LngNames[iUser][iDes];

  NSString* flgSrc = _LngFlags[iSrc];
  NSString* flgDes = _LngFlags[iDes];
  
  return [NSString stringWithFormat:@"%@ %@ ➔ %@ %@", flgSrc, sSrc, flgDes, sDes];
  }

//---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
// Obtiene el nombre de la dirección de traducción con indice 'iDir'
NSString* DIRAbrv( int src, int des )
  {
  static NSString* SentSufixes[LGCount][LGCount] =
    {
    //        Es    ,   En    ,   It    ,   Fr
    /*Es*/{ @""     , @"Es2En", @"Es2It", @"Es2Fr" },
    /*En*/{ @"En2Es", @""     , @"En2It", @"En2Fr" },
    /*It*/{ @"It2Es", @"It2En", @""     , @"It2Fr" },
    /*Fr*/{ @"Fr2Es", @"Fr2En", @"Fr2It", @""      }
    };

  return SentSufixes[src][des];
  }

//---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
// Determina el idioma fuente de la dirección 'iDir'
int DIRSrc( int iDir )
  {
  if( iDir<0 || iDir>DIRCount() ) return -1;
  
  return _InstSrc[iDir];
  }

//---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
// Determina el idioma destino de la dirección 'iDir'
int DIRDes( int iDir )
  {
  if( iDir<0 || iDir>DIRCount() ) return -1;
  
  return _InstDes[iDir];
  }

//---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
// Obtiene la dirección de traducción que esta compuesta por los dos idiomas dados
int DIRFromLangs(int src, int des)
  {
  for( int i=0; i<DIRCount(); ++i )
    if( _InstSrc[i]==src && _InstDes[i]==des )
      return i;
  
  return -1;
  }

//---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
// Obtiene la primera dirección de traduccion instalada y la pone activa
int DIRFirst()
  {
  LGSrc = _InstSrc[0];
  LGDes = _InstDes[0];
  
  return 0;
  }

//---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
NSString* LGFlag( int lng )
  {
  if( lng<0 || lng>LGCount ) return @"";

  return _LngFlags[lng];
  }

//---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
//                     0 1 2 3 4 5 6 7 8 9 : ; < = > ? @ A  B  C  D  E  F
static int ToHex[] = { 0,1,2,3,4,5,6,7,8,9,0,0,0,0,0,0,0,10,11,12,13,14,15 };
//---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
// Obtiene el caracter hexagecimal de una cadena y retorna su valor en el sistema digtal
int HexDigit(int idx, NSString* str )
  {
  int d = [str characterAtIndex:idx]-'0';
  return ToHex[d];
  }

//---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
NSCharacterSet* EsChars = [NSCharacterSet characterSetWithCharactersInString:@"áéíóú"];
NSCharacterSet* ItChars = [NSCharacterSet characterSetWithCharactersInString:@"éàèìòù"];
NSCharacterSet* FrChars = [NSCharacterSet characterSetWithCharactersInString:@"éàèùëïöüâêîôû"];

NSCharacterSet* Chars[] = { EsChars, nil, ItChars, FrChars };

//---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
// Quita los acentos de la palabra 'wrd' de acuerdo al idioma 'lng'
NSString* QuitaAcentos( NSString* wrd, int lng )
  {
  if( lng==1 ) return wrd;                                                    // En inglés no hay acentos, no hace nada

  NSCharacterSet* charSet = Chars[lng];                                       // Conjunto de caracteres acentuados según el idioma

  NSInteger idx = [wrd rangeOfCharacterFromSet:charSet].location;             // Busca alguno de los caracteres acentuados
  if( idx == NSNotFound ) return wrd;                                         // No hay ninguno, termina sin hacer nada

  NSInteger len = wrd.length;                                                 // Longitud de la palabra
  unichar chars[ len ];                                                       // Buffer para obtener todos los caracteres
  [wrd getCharacters:chars];                                                  // Obtiene todos los caracteres y los pone en el buffer

  for(;;)                                                                     // Proceso puede repetirse si se admite mas de un acento
    {
    switch( [wrd characterAtIndex:idx] )                                      // Obtiene el caracter encontrado
      {
      case 224: case 225: case 226: case 228: chars[idx]= 'a'; break;         // Si es àáâä lo sustituye por a
      case 232: case 233: case 234: case 235: chars[idx]= 'e'; break;         // Si es èéêë lo sustituye por e
      case 236: case 237: case 238: case 239: chars[idx]= 'i'; break;         // Si es ìíîï lo sustituye por i
      case 242: case 243: case 244: case 246: chars[idx]= 'o'; break;         // Si es òóôö lo sustituye por o
      case 249: case 250: case 251: case 252: chars[idx]= 'u'; break;         // Si es ùúûü lo sustituye por u
      }

    if( lng != 3 ) break;                                                     // Si no es francés termina (solo se admite un acento por palabra)

    NSRange rg = NSMakeRange(idx+1, len-idx-1);                               // Toma el rango de caracteres restantes

    idx = [wrd rangeOfCharacterFromSet:charSet options:0 range:rg].location;  // Busca alguno de los carecteres acentuados
    if( idx == NSNotFound ) break;                                            // Si no lo encuentra, termina la busqueda
    }

  return [NSString stringWithCharacters:chars length:len];                    // Crea una cadena con el buffer y la retorna
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Obtiene el nombre y el camino completo del diccionario
NSString* PathForDict(NSString* FName)
  {
  NSString *Path = [NSBundle mainBundle].resourcePath ;
  Path = [Path stringByAppendingPathComponent: @"Datos"];

  return [Path stringByAppendingPathComponent:FName];
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Obtiene el nombre del diccionario de indice de acuerdo a los idiomas
NSString* IndexDictName( int src, int des )
  {
  NSString* Sufix = DIRAbrv( src, des );
  return [Sufix stringByAppendingString:@"Idx.wrds"];
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Obtiene el nombre del diccionario principal de acuerdo a los idiomas
NSString* MainDictName( int src, int des )
  {
  NSString* Sufix = DIRAbrv( src, des );
  return [Sufix stringByAppendingString:@".dcv"];
  }


//===================================================================================================================================================
