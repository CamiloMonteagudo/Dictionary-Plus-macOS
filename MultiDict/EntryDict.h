//===================================================================================================================================================
//  DictEntry.h
//  MultiDict
//
//  Created by Camilo Monteagudo Preña on 2/23/17.
//  Copyright © 2017 BigXSoft. All rights reserved.
//===================================================================================================================================================

#import <Foundation/Foundation.h>

//===================================================================================================================================================

@interface EntryDict : NSObject

@property (nonatomic) NSString*  Key;               // Llave para la entrada al diccionario
@property (nonatomic) NSString*  Datos;             // Datos de la entrada en el diccionario
@property (nonatomic) NSUInteger nWrds;             // Número de palabras de la entrada
@property (nonatomic) NSString*  InfoMarks;         // Información sobre las marcas de sustitución

+(EntryDict*) EntryWithParts:(NSArray<NSString*> *)Parts;

@end
//===================================================================================================================================================
