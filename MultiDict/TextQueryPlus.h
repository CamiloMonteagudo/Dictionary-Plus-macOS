///=============================================================================================================================================================
//  TextQueryPlus.h
//  MultiDict
//
//  Created by Camilo Monteagudo Peña on 7/30/17.
//  Copyright © 2017 BigXSoft. All rights reserved.
///=============================================================================================================================================================

#import <Foundation/Foundation.h>

#define INT_LIST      NSMutableArray<NSNumber*>
#define FOUNDS_ENTRY  NSMutableDictionary<NSNumber*,  INT_LIST*>

///=============================================================================================================================================================
@interface WrdQuery : NSObject
  {
  @public NSMutableArray<NSString*> *Words;        // Listado de palabras similares

  @public NSRange Pos;                             // Posición de la primera palabra que aparece en el query

  @public NSMutableSet<NSNumber*>* Entries;        // Conjunto de entradas donde se encuentra una de las palabras
  }

+(WrdQuery*) WithWrd:(NSString*) wrd AndRange:(NSRange) rg;

@end

///=============================================================================================================================================================
@interface TextQueryPlus : NSObject
  {
  @public NSMutableArray<WrdQuery*> *Items;

  @public NSInteger idxSel;
  }

+(TextQueryPlus*) QueryWithText:(NSString*) sQuery;
+(TextQueryPlus*) QuerySimpleWithText:(NSString*) sQuery;

+(void) Reset;

- (FOUNDS_ENTRY*) FindWords;

@end
///=============================================================================================================================================================
