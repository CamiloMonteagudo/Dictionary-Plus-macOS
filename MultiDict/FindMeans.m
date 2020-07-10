//==================================================================================================================================================================
//  FindDesMeans.m
//  MultiDict
//
//  Created by Camilo Monteagudo Peña on 7/24/17.
//  Copyright © 2017 BigXSoft. All rights reserved.
//==================================================================================================================================================================

#import "FindMeans.h"
#import "CronoTime.h"

extern NSArray<NSString*>* GetMeansInData( NSString* Datos );
extern NSString* ClearMean( NSString* mean );

//==================================================================================================================================================================
/// Grupo de fucnciones para buscar significados de forma independiente
//-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
// Busca los indices de la palabra 'sWrd' para el diccionario Src-Des
EntryIndex *FindIndexsForWord( NSString* sWrd, int src, int des)
  {
  // Prepara la palabra para buscarla
  NSString*  wrd = QuitaAcentos( [sWrd lowercaseString], src );
  NSString* fWrd = [NSString stringWithFormat:@"\n%@\\", wrd ];

  // Lee el contenido del diccionario de indices
  NSString *DicPath = PathForDict( IndexDictName(src, des) );
  NSString *Txt = [NSString stringWithContentsOfFile:DicPath usedEncoding:nil error:nil];
  if( Txt == nil ) return nil;

  // Busca la palabra en el contenido del diccionatio de indices
  NSRange rg = [Txt rangeOfString:fWrd];
  if( rg.location == NSNotFound ) return nil;

  // Extrae la información de los indices
  NSInteger pos = rg.location + rg.length;
  NSRange rgFind = NSMakeRange(pos, Txt.length-pos);

  NSUInteger EndDat = [Txt rangeOfCharacterFromSet:lnSep options:0 range:rgFind ].location;

  NSRange  rgDat = NSMakeRange(pos, EndDat-pos);
  NSString* sDat = [Txt substringWithRange:rgDat];

  // Retorna un objeto con los indices
  return [EntryIndex EntryFromDatos:sDat];
  }

//---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
// De todos las entradas donde esta a la palabra, encuentra la de la palabra sola
EntryDict* FindWordEntry( EntryIndex* WrdData, int src, int des )
  {
  // Lee el diccionatio desde fichero
  NSString *DicPath = PathForDict( MainDictName(src, des) );
  NSString *Txt = [NSString stringWithContentsOfFile:DicPath usedEncoding:nil error:nil];
  if( Txt == nil ) return nil;                            // No pudo cargar el diccionario

  // Divide el texto en líneas
  NSArray<NSString*> *Lines = [Txt componentsSeparatedByCharactersInSet:lnSep];

  // Recorre todas las entradas donde esta la palabra
  for( int i=0; i<WrdData.Count; ++i)
    {
    int pos = WrdData.Pos[i];                                 // Posición de la palabra dentro de la entrada 'i'

    if( pos==0 )                                              // Si es la primera palabra de la entrada
      {
      int idx = WrdData.Entrys[i];                            // Indice a la entrada donde esta la palabra

      NSArray<NSString*> *Parts = [Lines[idx] componentsSeparatedByCharactersInSet:kySep];  // Divide la entrada en partes

      if( Parts.count>2 && [Parts[2] isEqualToString:@"1"] )  // Si el número de palabras de la entrada es 1
        return [EntryDict EntryWithParts: Parts];             // Retorna la entrada
      }
    }

  return nil;                                                  // No encontro una entrada para la palabra sola
  }

//---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
// Encuentra los significados de la palabra 'wrd' si existe en el diccionario
NSArray<NSString*>* FindMeansOf( NSString* wrd )
  {
  wrd = QuitaAcentos( [wrd lowercaseString], LGSrc );     // Pasa la palabra a minusculas y le quita los acentos

  EntryIndex* WrdData = DictIdx.Words[wrd];               // Obtiene todas las entradas donde esta la palabra

  if( WrdData==nil ) return [NSArray<NSString*> new];     // No esta en el diccionario de indices de palabras

  for( int i=0; i<WrdData.Count; ++i)                     // Recorre todas las entradas donde esta la palabra
    {
    int pos = WrdData.Pos[i];                             // Posición de la palabra dentro de la entrada 'i'

    if( pos==0 )                                          // Si es la primera palabra de la entrada
      {
      int idx = WrdData.Entrys[i];                        // Indice a la entrada donde esta la palabra

      EntryDict* entry = [Dict getDataAt:idx];            // Obtine la entrada completa
      if( entry.nWrds == 1 )                              // Si tiene una sola palabra
        return GetMeansInData( entry.Datos );             // Obtiene los significados y los retorna
      }
    }

  return [NSArray<NSString*> new];                        // Retorna lista de significados vacia
  }

//---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
// Obtiene una lista de todos los significados dentro de 'Datos'
NSArray<NSString*>* GetMeansInData( NSString* Datos )
  {
  NSMutableArray<NSString*>* lstMeans = [NSMutableArray<NSString*> new];
  NSMutableSet<NSString*>* setMeans = [NSMutableSet<NSString*> new];

  NSArray<NSString*> *Tipos = [Datos componentsSeparatedByCharactersInSet:TypeSep];

  for(int i=0; i<Tipos.count; ++i )
    {
    NSArray<NSString*> *Means = [Tipos[i] componentsSeparatedByCharactersInSet:MeanSep];

    for(int j=0; j<Means.count; ++j )
      {
      NSString* mean = ClearMean( Means[j] );

      if( ![setMeans containsObject:mean] )
        {
        [lstMeans addObject:mean];
        [setMeans addObject:mean];
        }
      }
    }

  return lstMeans;
  }

//---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
// Limpia el significado de los atributos que pueda tener
NSString* ClearMean( NSString* mean )
  {
  mean = [mean stringByTrimmingCharactersInSet:TrimSpc];

  NSInteger idx = 0;
  NSInteger len = mean.length;

  for(;;)
    {
    NSRange rg = NSMakeRange(idx, len-idx);

    NSInteger iFind = [mean rangeOfCharacterFromSet:PntOrSpc options:0 range:rg].location;

    if( iFind == NSNotFound ) break;

    unichar c = [mean characterAtIndex:iFind];
    if( c ==' ' ) break;

    idx = iFind;

    if( c=='(' )
      {
      for(; idx<len && [mean characterAtIndex:idx]!=')'; ++idx );

      if( idx<len ) ++idx;
      }

    for(; idx<len; ++idx )
      {
      c = [mean characterAtIndex:idx];
      if( c!='.' && c!=' ' ) break;
      }
    }

  if( idx==0 ) return mean;
  else         return [mean substringFromIndex:idx];
  }

//==================================================================================================================================================================
