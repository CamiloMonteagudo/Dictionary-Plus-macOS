//===================================================================================================================================================
//  MainDict.m
//  MultiDict
//
//  Created by Camilo Monteagudo Preña on 2/22/17.
//  Copyright © 2017 BigXSoft. All rights reserved.
//===================================================================================================================================================

#import "DictMain.h"
#import "CronoTime.h"
#import "AppData.h"

//===================================================================================================================================================
// Implementa el manejo del diccionario principal de palabras y frases
@interface DictMain()
  {
  int Src;                                        // Primer idioma
  int Des;                                        // Segundo idioma
  }
@end

//===================================================================================================================================================
@implementation DictMain

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Carga el diccionario de palabras y frases
+ (BOOL) LoadWithSrc:(int)src AndDes:(int)des
  {
  CronoTime* crono = [CronoTime new];
  [crono Start];

  if( Dict ) [Dict Free];
  Dict = [DictMain new];

  BOOL ret = [Dict LoadWithSrc:src AndDes:des];

  //NSLog(@"ENTRADAS: Tiempo de carga = %lf", [crono GetTime]);

  return ret;
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Carga el diccionario completo en memoria
- (BOOL) LoadWithSrc:(int)src AndDes:(int)des
  {
  _Items = [NSMutableArray new];
  Src = src;
  Des = des;

  NSStringEncoding Enc;
  NSError          *Err;

  NSString *DicPath = PathForDict( MainDictName(src, des) );
  NSString *Txt = [NSString stringWithContentsOfFile:DicPath usedEncoding:&Enc error:&Err];
  if( Txt == nil ) return FALSE;

  NSArray<NSString*> *Lines = [Txt componentsSeparatedByCharactersInSet:lnSep];

  for(int i=0; i<Lines.count; ++i )
    {
    NSArray<NSString*> *Parts = [Lines[i] componentsSeparatedByCharactersInSet:kySep];

    if( Parts.count>2 )
      [_Items addObject: [EntryDict EntryWithParts: Parts] ];
    }

  return TRUE;
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Libera todos los recursos del diccionario
- (void) Free
  {
  [_Items removeAllObjects];
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Obtiene la entrada 'idx' del diccionario
- (EntryDict*) getDataAt:(NSInteger) idx
  {
  if( idx<0 || idx>=_Items.count ) return nil;

  return _Items[idx];
  }

@end
//===================================================================================================================================================

