///=============================================================================================================================================================
//  TextQuery.h
//  MultiDict
//
//  Created by Camilo Monteagudo Peña on 6/8/17.
//  Copyright © 2017 BigXSoft. All rights reserved.
///=============================================================================================================================================================

#import <Foundation/Foundation.h>
#import "AppData.h"

#define INT_LIST      NSMutableArray<NSNumber*>
#define FOUNDS_ENTRY  NSMutableDictionary<NSNumber*,  INT_LIST*>

///=============================================================================================================================================================
@interface TextQuery : NSObject
  {
  @public NSArray<NSString*> *Words;                       // Lista de palabras que forman el query
  @public NSUInteger Count;                                // Cantidad de palabras del query
  }

@property (nonatomic) int idxCnj;                         // Indice de la palabra que se esta conjugando

+(TextQuery*) QueryWithText:(NSString*) sQuery;
- (FOUNDS_ENTRY*) FindWords;
@end

///=============================================================================================================================================================
