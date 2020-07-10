//===================================================================================================================================================
//  ConjSimple.m
//  MultiDict
//
//  Created by Camilo Monteagudo Peña on 7/15/17.
//  Copyright © 2017 BigXSoft. All rights reserved.
//===================================================================================================================================================

#import "ConjSimple.h"
#include "ConjCore.h"
#include "AppData.h"

//===================================================================================================================================================
@interface ConjSimple()
  {
  NSTableView* Table;
  NSTextField* TxtView;
  NSSearchField* FindConj;

  NSArray<NSString*>* lstWrds;
  }

@end

//===================================================================================================================================================
@implementation ConjSimple

//--------------------------------------------------------------------------------------------------------------------------------------------------------
+(ConjSimple*)CreateForTable:(NSTableView*) tb Query:(NSTextField*) txtView FindConj:(NSSearchField*)findConj
  {
  [ConjCore initConjCore];                                      // Inicializa modulo de conjugación

  ConjSimple* obj = [ConjSimple new];

  obj->Table     = tb;
  obj->TxtView   = txtView;
  obj->FindConj  = findConj;
  obj->_ConjLang = -1;

  obj.ConjLang = LGSrc;

  tb.delegate = obj;
  tb.dataSource = obj;

  findConj.target = obj;
  findConj.action = @selector(OnFindConj:);

  return obj;
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
- (void) OnFindConj:(NSSearchField *)sender
  {
  _Verb = sender.stringValue;
  [self FindConjs];
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Trata de conjugar el primer verbo que encuentre en el query o la palabra seleccionada
- (BOOL) FindConjQuery:(TextQuery *) Query
  {
  [ConjCore LoadConjLang: LGSrc];                               // Carga la conjugación para el idioma actual
  self.ConjLang = LGSrc;

  for( int i=0; i<Query->Count; ++i )                           // Recorre palabras del query
    {
    if( Query.idxCnj >= Query->Count )                          // Comprueba que la palabra actual no este fuera de rango
      Query.idxCnj = 0;

    _Verb = Query->Words[Query.idxCnj];                         // Toma la palabra actual como verbo
    Query.idxCnj += 1;                                          // Actualiza la última palabra analizada

    if( ![ConjCore ConjVerb:_Verb ] ) continue;                 // Si no puede conjugar pasa a la proxima palabra

    self.Verb = _Verb;                                          // Muestra el verbo
    lstWrds = [ConjCore GetConjsList];                          // Obtiene la lista de palabras de la conjugacion

    [Table reloadData];                                         // Actualiza el contenido de la lista

    [self SelWord:Query];                                       // Selecciona la palabra en el query

    return TRUE;                                                // Termina OK
    }

  return FALSE;                                                 // No pudo conjugar
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Busca la palabra actual y la selecciona
- (void) SelWord:(TextQuery *) Query
  {
  NSUInteger idx = 0;

  for( int i=0; i<Query.idxCnj-1; ++i )                           // Recorre palabras del query
    idx += Query->Words[i].length + 1;

  NSString* txt = TxtView.stringValue;
  NSRange fRg = NSMakeRange(idx, txt.length-idx);

  NSRange sRg = [txt rangeOfString:_Verb options:0 range:fRg];

  [TxtView.window makeFirstResponder:TxtView];

  NSText *edTxt = [TxtView.window fieldEditor:true forObject:TxtView];

  edTxt.selectedRange = sRg;
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Busca todas las conjugaciones del verbo actual y las coloca en la lista
- (void) FindConjs
  {
  [ConjCore LoadConjLang: _ConjLang];                           // Carga la conjugación para el idioma actual

  if( [ConjCore ConjVerb:_Verb ] )                              // Si la palabra se puede conjugar
    {
    lstWrds = [ConjCore GetConjsList];                          // Obtiene la lista de palabras de la conjugacion
    }
  else
    {
    if( lstWrds.count == 0 ) return;                            // Si la lista de palabras ya estaba vacia, no hace nada

    lstWrds = [NSArray<NSString*> new];                         // Pone la lista vacia
    }

  [Table reloadData];                                           // Actualiza el contenido de la lista
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Cambia el verbo actual para conjugar
- (void)setVerb:(NSString *)Verb
  {
  _Verb = Verb;

  if( ![FindConj.stringValue isEqualToString:Verb] )
    FindConj.stringValue = Verb;
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Cambia el idioma de la conjugación
- (void)setConjLang:(int)ConjLang
  {
  if( _ConjLang == ConjLang ) return;                           // Si el idioma es la actual, no hace nada

  _ConjLang = ConjLang;                                         // Cambia idioma actual para aconjugaciones

  NSSearchFieldCell* cell = FindConj.cell;                      // Obtiene la celda del campo de buscar conjugaciones

  [cell resetSearchButtonCell];                                 // Reaestablece sus valores

  NSButtonCell *btn = cell.searchButtonCell;                    // Obtiene el boton para icono de buscar

  btn.type = NSTextCellType;                                    // Lo pone del tipo texto
  btn.imagePosition = NSNoImage;                                // No tiene imagenes

  btn.title = LGFlag(ConjLang);                                 // Pone la bandera del idioma
  btn.tag   = ConjLang;                                         // Pone una etiqueta del idioma al boton

  btn.target = self;                                            // Pone metodo a ejecutar cuando se hace click sobre él
  btn.action = @selector(OnSelConjLang:);
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Se llama oprime el la bandera que aparece en el campo de encontrar conjugaciones
- (void)OnSelConjLang:(id) sender
  {
  NSMenu* Mnu = [[NSMenu alloc] init];                                  // Crea el menu
  [Mnu addItem: [NSMenuItem separatorItem]];                            // Para Pulls Down menu, el primer item se ignora

  for( int i=0; i<CNJCount(); ++i )                                     // Recorre todas las conjugaciones instaladas
    {
    NSMenuItem* Item = [[NSMenuItem alloc] init ];                      // Crea un item de menu

    Item.title  = CNJTitle(i);                                          // Pone el nombre del items
    Item.target = self;                                                 // Pone objeto donde se atiende la accion
    Item.action = @selector(OnSelectLang:);                             // Pone procedimiento para atender la accion
    Item.tag = i;                                                       // Marca el item con el idioma que representa

    if( CNJLang(i)==_ConjLang ) [Item setState:1];                      // Si es el idioma actual le pone un checkmark

    [Mnu addItem:Item];                                                 // Adiciona el item al menu
    }

  NSPopUpButtonCell* cel = [[NSPopUpButtonCell alloc] initTextCell:@"" pullsDown:YES];    // Crea un PopUp
  cel.menu = Mnu;                                                                         // La asocia el menú

  NSSize szBtn = FindConj.frame.size;
  NSRect rc = NSMakeRect(0, 0, szBtn.width, szBtn.height);              // Calcula la ubicación

  [cel performClickWithFrame:rc inView:FindConj];                       // Lo manda a mostrar
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Se llama cuando se selecciona un idioma
- (void)OnSelectLang:(NSMenuItem*) Item
  {
  self.ConjLang = CNJLang((int)Item.tag);

  [self FindConjs];
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Informa la cantidad de palabras resultado de la conjugación
- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
  {
  return lstWrds.count;
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Se llama para conecer la palabra que se corresponde con la fila 'row'
- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
  {
  NSTableCellView* cel = [tableView makeViewWithIdentifier:@"WrdConj" owner:tableView];


  cel.textField.stringValue = lstWrds[row];

  if( [FindConj.stringValue isEqualToString:lstWrds[row]] )
    [cel.textField setBackgroundColor:[NSColor redColor]];

  return cel;
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Se llama cuando cambia la selección
- (void)tableViewSelectionDidChange:(NSNotification *)aNotification
  {
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------

@end
//===================================================================================================================================================
