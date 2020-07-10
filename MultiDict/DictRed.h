//==================================================================================================================================================================
//  DictRed.h
//  MultiDict
//
//  Created by Camilo Monteagudo Peña on 7/16/17.
//  Copyright © 2017 BigXSoft. All rights reserved.
//==================================================================================================================================================================

#import <Foundation/Foundation.h>

//==================================================================================================================================================================
@interface DictRed : NSObject

+ (DictRed*) GetForLang:(int)lang;

- (int) FindWord:(const char*) wrd;

- (BOOL) IsTypeVerb:(int) typs;
- (BOOL) IsTypeVerbAux:(int) typs;
- (BOOL) IsTypeBeOrHa:(int) typs;
- (BOOL) IsTypeAdjetive:(int) typs;
- (BOOL) IsTypeAdjetiveInmovil:(int) typs;
- (BOOL) IsTypeProname:(int) typs;
- (BOOL) IsTypeAdvervio:(int) typs;
- (BOOL) IsTypeArticle:(int) typs;
- (BOOL) IsTypeSustantive:(int) typs;

@end
//==================================================================================================================================================================
