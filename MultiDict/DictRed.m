//==================================================================================================================================================================
//  DictRed.m
//  MultiDict
//
//  Created by Camilo Monteagudo Peña on 7/16/17.
//  Copyright © 2017 BigXSoft. All rights reserved.
//==================================================================================================================================================================

#import "DictRed.h"
#import "CronoTime.h"
#import "AppData.h"

static DictRed* NowDictRed;

#define T_VERB    0x01
#define T_VERB_A  0x02
#define T_BE      0x04
#define T_ADJ     0x08
#define T_ADJ_I   0x10
#define T_PRON    0x20
#define T_ADV     0x40
#define T_ART     0x80
#define T_SUST    0x100

//==================================================================================================================================================================
// Implementa el manejo del diccionario para palabras de reducción
@interface DictRed()
  {
  int lng;                                        // Idioma del diccionario
  NSMutableDictionary<NSString*,  NSNumber*> *Words;
  }
@end

//==================================================================================================================================================================
@implementation DictRed

//-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
// Obtiene el diccionario de palabras para la reducción
+ (DictRed*) GetForLang:(int)lang
  {
  if( NowDictRed!=nil && NowDictRed->lng==lang )
    return NowDictRed;

  CronoTime* crono = [CronoTime new];
  [crono Start];

  NowDictRed = [DictRed new];

  if( ![NowDictRed LoadWithLang:lang ] )
    NowDictRed = nil;

  //NSLog(@"REDUCCION: Tiempo de carga = %lf", [crono GetTime]);

  return NowDictRed;
  }

//-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
// Carga el diccionario de palabras para la reducción
- (BOOL) LoadWithLang:(int)lang
  {
  lng = lang;
  Words = [NSMutableDictionary<NSString*,  NSNumber*> new];

  NSStringEncoding Enc;
  NSError          *Err;

  NSString *DicPath = [self GetFilePath];
  NSString *Txt = [NSString stringWithContentsOfFile:DicPath usedEncoding:&Enc error:&Err];
  if( Txt == nil ) return FALSE;

  NSArray<NSString*> *Lines = [Txt componentsSeparatedByCharactersInSet:lnSep];

  for(int i=0; i<Lines.count; ++i )
    {
    NSString* ln = Lines[i];
    int      lst = (int)ln.length-1;

    NSString* wrd  = [ln substringToIndex:lst];
    NSNumber* typs = [NSNumber numberWithInt: HexDigit(lst, ln ) ];

    Words[wrd] = typs;
    }
  
  return TRUE;
  }

//-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
// Obtiene el nombre y el camino completo del diccionario
- (NSString*) GetFilePath
  {
  NSString *Path = [NSBundle mainBundle].resourcePath ;
  Path = [Path stringByAppendingPathComponent: @"Datos"];

  NSString* file = [NSString stringWithFormat:@"%@RedS.rwd", LGAbrv(lng) ];

  return [Path stringByAppendingPathComponent:file ];
  }

//-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
// Busca si la palabra 'wrd' esta en el diccionario
- (int) FindWord:(const char*) wrd
  {
  NSString* str = [NSString stringWithCString:wrd encoding:NSISOLatin1StringEncoding ];

  NSNumber* typs = Words[str];
  if( typs==nil ) return -1;

  return typs.intValue;
  }

//-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
//
- (BOOL) IsTypeVerb:(int) typs
  {
  return ((typs & T_VERB) != 0);
  }

//-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
//
- (BOOL) IsTypeVerbAux:(int) typs
  {
  return ((typs & T_VERB_A) != 0);
  }

//-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
//
- (BOOL) IsTypeBeOrHa:(int) typs
  {
  return ((typs & T_BE) != 0);
  }

//-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
//
- (BOOL) IsTypeAdjetive:(int) typs
  {
  return ((typs & T_ADJ) != 0);
  }

//-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
//
- (BOOL) IsTypeAdjetiveInmovil:(int) typs
  {
  return ((typs & T_ADJ_I) != 0);
  }

//-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
//
- (BOOL) IsTypeProname:(int) typs
  {
  return ((typs & T_PRON) != 0);
  }

//-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
//
- (BOOL) IsTypeAdvervio:(int) typs
  {
  return ((typs & T_ADV) != 0);
  }

//-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
//
- (BOOL) IsTypeArticle:(int) typs
  {
  return ((typs & T_ART) != 0);
  }

//-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
//
- (BOOL) IsTypeSustantive:(int) typs
  {
  return ((typs & T_SUST) != 0);
  }

@end
//==================================================================================================================================================================
