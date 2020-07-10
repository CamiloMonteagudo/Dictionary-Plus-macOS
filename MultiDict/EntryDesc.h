//===================================================================================================================================================
//  EntryDesc.h
//  MultiDict
//
//  Created by Camilo Monteagudo Peña on 7/2/17.
//  Copyright © 2017 BigXSoft. All rights reserved.
//===================================================================================================================================================

#import <Foundation/Foundation.h>
#import "EntryDict.h"

//===================================================================================================================================================
// Mantiene la información de una marca dentro de la entrada
@interface InfoMark : NSObject

  @property (nonatomic) NSString* Code;             // Código de la marca de sustitución
  @property (nonatomic) NSString* Txt;              // Texto de la marca de sustitución

  @property (nonatomic) NSUInteger Pos;             // Posición donde esta la marca de sustitución
  @property (nonatomic) NSUInteger Len;             // Número de caracteres de la marca de sustitución

  +(InfoMark*) InfoWithText:(NSString*) Txt InLang:(int) lng AndPos:(NSUInteger) pos;

@end

//===================================================================================================================================================
// Maneja de descripcion de los datos de una entrada
@interface EntryDesc : NSObject

  @property (nonatomic) NSInteger nMarks;          // Número de marcas  que tiene la entrada

  +(EntryDesc*) DescWithEntry:(EntryDict*) entry Src:(int)src Des:(int)des;

  - (NSAttributedString*) getAttrString;
  - (InfoMark*) MarkAtIndex:(int) idx;

  - (NSString*) TextInKeyForMark:(NSString*) code;
  - (NSString*) TextInDataForMark:(NSString*) code;

  - (void) ResplaceMark:(NSString*) code TextSrc:(NSString*) srcTxt TextDes:(NSString*) desTxt;

  - (NSInteger) IndexTrdInString:(NSString*) txt;

@end
//===================================================================================================================================================
