//===================================================================================================================================================
//  ConjSimple.h
//  MultiDict
//
//  Created by Camilo Monteagudo Peña on 7/15/17.
//  Copyright © 2017 BigXSoft. All rights reserved.
//===================================================================================================================================================

#import <Cocoa/Cocoa.h>
#import "TextQuery.h"

//===================================================================================================================================================
@interface ConjSimple : NSObject <NSTableViewDelegate, NSTableViewDataSource>

@property (nonatomic) NSString* Verb;
@property (nonatomic) int ConjLang;

+(ConjSimple*)CreateForTable:(NSTableView*) tb Query:(NSTextField*) txtView FindConj:(NSSearchField*)findConj;

- (BOOL) FindConjQuery:(TextQuery *) Query;
- (void) FindConjs;

@end
//===================================================================================================================================================
