//===================================================================================================================================================
//  MngMarks.h
//  MultiDict
//
//  Created by Camilo Monteagudo Peña on 6/30/17.
//  Copyright © 2017 BigXSoft. All rights reserved.
//===================================================================================================================================================

#import <Foundation/Foundation.h>

//===================================================================================================================================================
@interface MarkDatos : NSObject

  @property (nonatomic) NSString* Desc;                     // Descripción de la marca (siempre en el idioma español)

  @property (nonatomic) NSString* Es;                       // Cadena para mostrar la marca cuando los datos son en Español
  @property (nonatomic) NSString* En;                       // Cadena para mostrar la marca cuando los datos son en Inglés
  @property (nonatomic) NSString* It;                       // Cadena para mostrar la marca cuando los datos son en Italiano
  @property (nonatomic) NSString* Fr;                       // Cadena para mostrar la marca cuando los datos son en Francés

+(MarkDatos*) InfoFromArray:(NSArray<NSString*> *) datos;

-(NSString*) StringForLang:(int) lng;

@end

//===================================================================================================================================================
@interface MngMarks : NSObject

  @property (nonatomic) NSMutableDictionary<NSString*, MarkDatos*> *Marks;   // Diccionario para obtener la información con el código de la marca

  @property (nonatomic) NSMutableDictionary<NSString*, NSString*> *EsSust;   // Diccionario para obtener el código de la marca, con la cadena de sustitución en Español
  @property (nonatomic) NSMutableDictionary<NSString*, NSString*> *EnSust;   // Diccionario para obtener el código de la marca, con la cadena de sustitución en Inglés
  @property (nonatomic) NSMutableDictionary<NSString*, NSString*> *ItSust;   // Diccionario para obtener el código de la marca, con la cadena de sustitución en Italiano
  @property (nonatomic) NSMutableDictionary<NSString*, NSString*> *FrSust;   // Diccionario para obtener el código de la marca, con la cadena de sustitución en Francés

+(MngMarks*) Get;

-(NSString*) CodeFromText:(NSString*) Txt In:(int) lng;
-(BOOL) Exist:(NSString*) code;
-(MarkDatos*) Info:(NSString*) code;

@end
//===================================================================================================================================================
