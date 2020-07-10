///=============================================================================================================================================================
//  SortedIndexs.h
//  MultiDict
//
//  Created by Camilo Monteagudo Peña on 6/9/17.
//  Copyright © 2017 BigXSoft. All rights reserved.
///=============================================================================================================================================================

#import <Foundation/Foundation.h>
#import "TextQuery.h"
#import "TextQueryPlus.h"

///=============================================================================================================================================================
// Informacion de una entrada ordenada por su ranking
@interface EntrySort : NSObject
  {
  @public int Index;
  @public int Rank;
  @public NSArray<NSNumber*>* WrdsPos;
  }

+(EntrySort*) EntryWihtInfo:(int) idx Rank:(int) rank WithPos:(INT_LIST*) WrdsPos;

@end

///=============================================================================================================================================================
// Maneja los indices a las palabras o frases encontradas, organizadas por ranking
@interface SortedIndexs : NSObject
  {
  @public NSMutableArray<EntrySort*> *Entries;                // Indice a las entradas ordenadas por ranking
  }

+(SortedIndexs*) Empty;
+(SortedIndexs*) SortEntries:(FOUNDS_ENTRY*) foundEntries Query:(TextQuery*) query;
+(SortedIndexs*) SortEntries:(FOUNDS_ENTRY*) foundEntries QueryPlus:(TextQueryPlus *) query Options:(int) sw;

-(int) Count;

@end
///=============================================================================================================================================================
