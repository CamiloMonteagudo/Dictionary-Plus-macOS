//===================================================================================================================================================
//  ViewController.h
//  MultiDict
//
//  Created by Camilo Monteagudo on 1/12/17.
//  Copyright © 2017 BigXSoft. All rights reserved.
//===================================================================================================================================================

#import <Cocoa/Cocoa.h>
#import "TextQueryPlus.h"

@interface ViewController : NSViewController

@property (weak) IBOutlet NSSearchField *txtFrase;
@property (weak) IBOutlet NSTableView *tableFrases;

- (void) EnableBtns:(int) sw;
- (void) DisenableBtns:(int) sw;
- (void) ShowMsg:(NSString*) msg WithTitle:(NSString*) title;

- (void) FindFrasesWithQuery:(TextQueryPlus*) query Options:(int) sw;

@end
//===================================================================================================================================================

