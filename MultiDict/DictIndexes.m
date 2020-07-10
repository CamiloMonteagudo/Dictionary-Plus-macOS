//===================================================================================================================================================
//  WordsIndex.m
//  MultiDict
//
//  Created by Camilo Monteagudo Preña on 2/23/17.
//  Copyright © 2017 BigXSoft. All rights reserved.
//===================================================================================================================================================

#import "DictIndexes.h"
#import "CronoTime.h"
#import "AppData.h"

//===================================================================================================================================================
// Implementa el manejo del diccionario principal de palabras y frases
@interface DictIndexes()
  {
  int Src;                                        // Primer idioma
  int Des;                                        // Segundo idioma
  }

@end

//===================================================================================================================================================
@implementation DictIndexes

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Carga el diccionario de indices de palabras en el diccionario principal
+ (BOOL) LoadWithSrc:(int)src AndDes:(int)des
  {
  CronoTime* crono = [CronoTime new];
  [crono Start];

  if( DictIdx ) [DictIdx Free];
  DictIdx = [DictIndexes new];

  BOOL ret = [DictIdx LoadWithSrc:src AndDes:des];

 // NSLog(@"INDICE: tiempo de carga = %lf", [crono GetTime]);

  return ret;
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Carga el diccionario completo en memoria
- (BOOL) LoadWithSrc:(int)src AndDes:(int)des
  {
  _Words = [NSMutableDictionary new];
  Src = src;
  Des = des;

  NSStringEncoding Enc;
  NSError          *Err;

  NSString *DicPath = PathForDict( IndexDictName(src, des) );
  NSString *Txt = [NSString stringWithContentsOfFile:DicPath usedEncoding:&Enc error:&Err];
  if( Txt == nil ) return FALSE;

  NSUInteger len = Txt.length;

  for( NSUInteger Ini=0 ;; )
    {
    NSRange rgFind = NSMakeRange(Ini, len-Ini);

    NSUInteger EndKey = [Txt rangeOfCharacterFromSet:kySep options:0 range:rgFind].location;
    if( EndKey == NSNotFound ) break;

    rgFind = NSMakeRange(EndKey+1, len-EndKey-1);
    NSUInteger EndDat = [Txt rangeOfCharacterFromSet:lnSep options:0 range:rgFind ].location;

    NSRange rgKey = NSMakeRange(Ini     , EndKey-Ini  );
    NSRange rgDat = NSMakeRange(EndKey+1, EndDat-EndKey-1);

    NSString* sKey = [Txt substringWithRange:rgKey];
    NSString* sDat = [Txt substringWithRange:rgDat];

    _Words[sKey] = [EntryIndex EntryFromDatos:sDat];

    Ini = EndDat + 1;
    }
  
  return TRUE;
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Libera todos los recursos del diccionario
- (void) Free
  {
  for (NSString* Key in _Words)
    [_Words[Key] Free];

  [_Words removeAllObjects];
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------


@end
//===================================================================================================================================================
