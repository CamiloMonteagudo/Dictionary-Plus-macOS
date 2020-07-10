//
//  BtnsData.h
//  Translation Dictionary Spanish
//
//  Created by Admin on 5/1/18.
//  Copyright © 2018 BigXSoft. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "DatosView.h"

@interface BtnsData : NSView

+(BtnsData*) BtnsDataForView:(DatosView*) parent;

+(NSButton*) BtnFindWord;
+(NSButton*) BtnSustMarks;
+(NSButton*) BtnConjWord;

+(void) HideButtons;

@end
