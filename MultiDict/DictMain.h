//===================================================================================================================================================
//  MainDict.h
//  MultiDict
//
//  Created by Camilo Monteagudo Preña on 2/22/17.
//  Copyright © 2017 BigXSoft. All rights reserved.
//===================================================================================================================================================

#import <Foundation/Foundation.h>
#import "EntryDict.h"

//===================================================================================================================================================
@interface DictMain : NSObject

  @property (nonatomic) NSMutableArray<EntryDict*>* Items;                          // Conjunto de todas las entradas

  + (BOOL) LoadWithSrc:(int) src AndDes:(int) des;

  - (void) Free;
  - (EntryDict*) getDataAt:(NSInteger) idx;

@end
//===================================================================================================================================================
