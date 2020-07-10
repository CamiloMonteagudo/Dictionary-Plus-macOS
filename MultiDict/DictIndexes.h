//===================================================================================================================================================
//  WordsIndex.h
//  MultiDict
//
//  Created by Camilo Monteagudo Preña on 2/23/17.
//  Copyright © 2017 BigXSoft. All rights reserved.
//===================================================================================================================================================

#import <Foundation/Foundation.h>
#import "EntryIndex.h"

@interface DictIndexes : NSObject

@property (nonatomic) NSMutableDictionary<NSString*, EntryIndex*>* Words;                            // Conjunto de todas las palabras indexadas

+ (BOOL) LoadWithSrc:(int) src AndDes:(int) des;

- (void) Free;

@end
//===================================================================================================================================================
