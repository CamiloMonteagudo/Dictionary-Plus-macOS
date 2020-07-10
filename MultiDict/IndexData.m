//
//  IndexData.m
//  MultiDict
//
//  Created by Camilo Monteagudo Peña on 6/9/17.
//  Copyright © 2017 BigXSoft. All rights reserved.
//

//#import "IndexData.h"
//
//@implementation IndexData
//
/////-----------------------------------------------------------------------------------------------------------------------------------
///// Obtiene los datos de los indices para una palabra, con el formato de tamaño fijo de 6 caracteres hexagecimal </summary>
//+ (IndexData*) FromStrHex:(NSString*) sData
//  {
//  IndexData* idxDat =[IndexData new];
//
//  int len = (int)sData.length;
//  int ini = 0;
//
//  for(;;)
//    {
//    if( ini+6>len ) break;
//
//    NSString* sIdxOra = [sData substringWithRange:NSMakeRange(ini, 5) ];
//    char      cWrdPos = [sData characterAtIndex:ini+5];
//    WrdIdx*   wrdIdx  = [WrdIdx FromStringHex:sIdxOra AndCharPos:cWrdPos];
//
//    [idxDat->Entries addObject:wrdIdx];
//
//    ini += 6;
//
//    while( ini<len && [ sData characterAtIndex:ini ]=='\'' )
//      ini +=2;
//    }
//
//  return idxDat;
//  }
//
//@end
//
/////===================================================================================================================================
///// <summary> Maneja los datos de cada ocurrecia de una palabra en una oracion o frase </summary>
//@implementation WrdIdx
//
////--------------------------------------------------------------------------------------------------------------------------------------------------
//// Obtiene un objeto 'WrdIdx' con los valores decimales de la entrada y la posición de la palabra
//+(WrdIdx*) WrdIdxEntry:(int) idxEntry AndWrdPos:(int) WrdPos
//  {
//  WrdIdx* obj = [WrdIdx new];
//
//  obj->idxEntry = idxEntry;
//  obj->WrdPos = WrdPos;
//
//  return obj;
//  }
//
////--------------------------------------------------------------------------------------------------------------------------------------------------
//// Obtiene un objeto 'WrdIdx' con cadenas hexagesimales de la entrada y la posición de la palabra
//+(WrdIdx*) FromStringHex:(NSString*) sIdxEntry AndCharPos:(char) cWrdPos
//  {
//  int wrdPos = cWrdPos-'0';
//  int idxEntry = [WrdIdx ParseHexIndex:sIdxEntry];
//
//  return [WrdIdx WrdIdxEntry:idxEntry AndWrdPos:wrdPos];
//  }
//
////--------------------------------------------------------------------------------------------------------------------------------------------------
////                     0 1 2 3 4 5 6 7 8 9 : ; < = > ? @ A  B  C  D  E  F
//static int ToHex[] = { 0,1,2,3,4,5,6,7,8,9,0,0,0,0,0,0,0,10,11,12,13,14,15 };
////--------------------------------------------------------------------------------------------------------------------------------------------------
//// Obtiene el caracter hexagecimal de una cadena y retorna su valor en el sistema digtal
//+(int) HexDigit:(int) idx InString:(NSString*) str
//  {
//  int d = [str characterAtIndex:idx]-'0';
//  return ToHex[d];
//  }
//
////--------------------------------------------------------------------------------------------------------------------------------------------------
//// Parsea una cadena de 5 caracteres hexagesimales, con el valor de un indice a una entrada del diccionario
//+(int) ParseHexIndex:(NSString*) sIdx
//  {
//  int d1 = [self HexDigit:0 InString:sIdx] * 65536;       // Primer digito del indice a la entrada  (0xd 0000)
//  int d2 = [self HexDigit:1 InString:sIdx] * 4096;        // Segundo digito del indice a la entrada (0x0 d000)
//  int d3 = [self HexDigit:2 InString:sIdx] * 256;         // Tecer digito del indice a la entrada   (0x0 0d00)
//  int d4 = [self HexDigit:3 InString:sIdx] * 16;          // Cuarto digito del indice a la entrada  (0x0 00d0)
//  int d5 = [self HexDigit:4 InString:sIdx];               // Quinto digito del indice a la entrada  (0x0 000d)
//
//  return d1+d2+d3+d4+d5;                                  // retorna el valor
//  }
//
//@end
//
