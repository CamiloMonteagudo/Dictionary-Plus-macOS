///=============================================================================================================================================================
//  TextQuery.m
//  MultiDict
//
//  Created by Camilo Monteagudo Peña on 6/8/17.
//  Copyright © 2017 BigXSoft. All rights reserved.
///=============================================================================================================================================================

#import "TextQuery.h"

///=============================================================================================================================================================
@implementation TextQuery

///------------------------------------------------------------------------------------------------------------------------------------------------------------------
/// Crea un objeto, con la cadena de busqueda
+(TextQuery*) QueryWithText:(NSString*) sQuery
  {
  TextQuery* query = [TextQuery new];

  sQuery = [sQuery lowercaseString];                        // Lleva todas las palabras a minusculas

  query->Words = [sQuery componentsSeparatedByCharactersInSet:wrdSep];    // Separa las palabras

  query->Count = query->Words.count;

  return query;
  }

///------------------------------------------------------------------------------------------------------------------------------------------------------------------
/// Busca palabras del query usando el diccionario de indices 'dictIndexs'
- (FOUNDS_ENTRY*) FindWords
  {
  FOUNDS_ENTRY* EntrysPos = [FOUNDS_ENTRY new];

  for( int i=0; i<Count; ++i )                              // Recorre todas las palabras
    {
    NSString* wrd = QuitaAcentos(Words[i], LGSrc);          // Toma la palabra actual sin acentos

    EntryIndex* WrdData = DictIdx.Words[wrd];               // Obtiene todas las entradas donde esta la palabra

    if( WrdData==nil ) continue;                            // No esta en el diccionario de indices de palabras

    for( int j=0; j<WrdData.Count; ++j)
      {
      NSNumber* idx = GET_NUMBER(WrdData.Entrys[j] );       // Obtiene el indice de la entrada donde esta la palabra

      INT_LIST *WrdsPos = EntrysPos[idx];                   // Busca si la entrada ya existe

      if( WrdsPos==nil )                                    // Si no hay ninguna palabra en esa entrada
        {
        WrdsPos = [INT_LIST new];                           // Crea una nueva lista de posiciones de palabras
        EntrysPos[idx] = WrdsPos;                           // Adiciona la lista a diccionario de entradas
        }

      [WrdsPos addObject:GET_NUMBER(WrdData.Pos[j])];       // Adiciona la posición a la lista posiciones de entrada idx
      }
    }

  return EntrysPos;                                         // Retorna lista de entradas, con las posiciones de las palabras encontradas
  }

@end
///=============================================================================================================================================================
