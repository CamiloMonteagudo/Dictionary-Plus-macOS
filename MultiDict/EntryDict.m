//===================================================================================================================================================
//  DictEntry.m
//  MultiDict
//
//  Created by Camilo Monteagudo Preña on 2/23/17.
//  Copyright © 2017 BigXSoft. All rights reserved.
//===================================================================================================================================================

#import "EntryDict.h"
#import "AppData.h"
#import "MngMarks.h"

//===================================================================================================================================================
// Representa una entrada en el diccionario principal
@implementation EntryDict

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Crea un objeto EntryDict con las partes de una entrada del diccionario
+(EntryDict*) EntryWithParts:(NSArray<NSString*> *)Parts
  {
  EntryDict* Entry = [EntryDict new];

  Entry->_Key   = Parts[0];
  Entry->_Datos = Parts[1];
  Entry->_nWrds = [Parts[2] characterAtIndex:0] - '0';

  if( Parts.count>3 ) Entry->_InfoMarks = Parts[3];
  else                Entry->_InfoMarks = @"";

  return Entry;
  }


//--------------------------------------------------------------------------------------------------------------------------------------------------------


@end

//===================================================================================================================================================
