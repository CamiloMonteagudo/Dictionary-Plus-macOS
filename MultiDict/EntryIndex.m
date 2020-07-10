//===================================================================================================================================================
//  IndexEntry.m
//  MultiDict
//
//  Created by Camilo Monteagudo Preña on 2/23/17.
//  Copyright © 2017 BigXSoft. All rights reserved.
//===================================================================================================================================================

#import "EntryIndex.h"
#import "AppData.h"

//===================================================================================================================================================
// Implementa el manejo de diccionario de indices de palabras
@interface EntryIndex()
@end

//===================================================================================================================================================
@implementation EntryIndex

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Inicializa una entrada de indices para una palabra
+(EntryIndex*) EntryFromDatos:(NSString*) sDat
  {
  EntryIndex* Entry = [EntryIndex new];

  [Entry ParseDatos:sDat];
  return Entry;
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// libera los datos de la entrada
-(void) Free
  {
  free(_Entrys);
  free(_Pos);
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Parsea los datos de los indices de una palabra
-(void) ParseDatos:(NSString*) sDat
  {
  int len = (int)sDat.length;                                 // Longitud de la cadena que contiene los datos
  int n   = len/6;                                            // Número de entradas en los datos (aproximadas por exceso)

  _Entrys = (int *)malloc( n*sizeof(int) );                   // Reserva memoria para las entradas
  _Pos    = (int *)malloc( n*sizeof(int) );                   // Reserva memoria para las posiciones en la entrada

  _Count = 0;
  for( int i=0; i<len; )                                      // Recorre todos los caracteres de los datos
    {
    int d1 = HexDigit(i++, sDat) * 65536;                     // Primer digito del indice a la entrada  (0xd 0000)
    int d2 = HexDigit(i++, sDat) * 4096;                      // Segundo digito del indice a la entrada (0x0 d000)
    int d3 = HexDigit(i++, sDat) * 256;                       // Tecer digito del indice a la entrada   (0x0 0d00)
    int d4 = HexDigit(i++, sDat) * 16;                        // Cuarto digito del indice a la entrada  (0x0 00d0)
    int d5 = HexDigit(i++, sDat);                             // Quinto digito del indice a la entrada  (0x0 000d)

    _Entrys[_Count] = d1+d2+d3+d4+d5;                         // Guarda el indice a la entrada
    _Pos   [_Count] = [sDat characterAtIndex:i++]-'0';        // Guarda la posición de la palabra dentro de la entrada

    while( i<len &&  [sDat characterAtIndex:i]=='\'' )        // Si hay más posicion de la palabra en la entrada
      i += 2;                                                 // Las ignora, salta digito de marcador y de posición

    ++_Count;
    }
  }

@end
//===================================================================================================================================================
