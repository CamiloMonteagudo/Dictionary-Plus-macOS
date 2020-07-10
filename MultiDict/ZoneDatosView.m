//===================================================================================================================================================
//  ZoneDatosView.m
//  MultiDict
//
//  Created by Camilo Monteagudo Peña on 3/1/17.
//  Copyright © 2017 BigXSoft. All rights reserved.
//===================================================================================================================================================

#import "ZoneDatosView.h"
#import "AppData.h"

static DatosView* DatosSel;

//===================================================================================================================================================
// Zona donde se muestran los datos de las palabras
@implementation ZoneDatosView

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Hace que el sistema de cordenada sea el normal
- (BOOL)isFlipped
  {
  return YES;
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Retorna la cantidad de datos que hay en la zona
- (int)Count
  {
  return (int)self.subviews.count;
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Adiciona los datos de la palabra 'Idx' en la parte superior de la zona de datos de palabras
- (void) AddDatosAtIndex:(NSInteger)Idx
  {
  CGFloat     w = self.superview.bounds.size.width;                  // Ancho del contenido del scroll
  DatosView* Datos = [DatosView DatosForIndex:Idx With:w];           // Crea vista de datos nueva

  Ctrller.btnDelAllDatos.hidden  = FALSE;                            // Habilita el botón para borrar los datos
  Ctrller.btnDelAllDatos.enabled = TRUE;      

  [ZoneDatosView SelectDatos:Datos];

  [self addSubview:Datos];                                           // Adiciona vista de datos nueva
  [self LayoutDataViews];
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Inserta los datos de la entrada suministrada después de la vista seleccionada
- (void) AddAfterSelDatos:(EntryDict*) entry Src:(int)src Des:(int)des
  {
  CGFloat     w = self.superview.bounds.size.width;                             // Ancho del contenido del scroll
  DatosView* Datos = [DatosView DatosForEntry:entry Src:src Des:des With:w];    // Crea vista de datos nueva

  [self addSubview:Datos positioned:NSWindowBelow relativeTo:DatosSel];         // Adiciona vista de datos nueva
  [self LayoutDataViews];
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Reposiciona todos las vistas de datos aduadamente
- (void) LayoutDataViews
  {
  CGFloat w = self.superview.bounds.size.width;                       // Ancho del contenido del scroll
  CGFloat h = 5;

  NSInteger n = self.subviews.count;
  for( NSInteger i=n-1; i>=0; --i)
    {
    DatosView* Sub  = self.subviews[i];

    CGFloat hSub = [Sub ResizeWithWidth:w];

    [Sub setFrameOrigin: NSMakePoint( 4, h)];

    h += hSub;
    }

  self.frame = NSMakeRect(0, 0, w, h);                                // Redimensiona la zona de datos
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Reposiciona todos las vistas de datos aduadamente
- (void) ClearDatos
  {
  NSInteger n = self.subviews.count;
  for( NSInteger i=n-1; i>=0; --i)
    [self.subviews[i] removeFromSuperview];

  CGFloat w = self.superview.bounds.size.width;                       // Ancho del contenido del scroll
  self.frame = NSMakeRect(0, 0, w, 20);                               // Redimensiona la zona de datos
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Obtiene el alto de todas las vistas de datos existentes
- (NSInteger) HeightDatos
  {
  NSInteger h = 5;
  NSInteger n = self.subviews.count;
  for( NSInteger i=0; i<n; ++i)
    {
    NSView* sub = self.subviews[i];
    h += sub.frame.size.height;
    }

  return h;
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Inserta la altura 'h' en la parte superior de todas las subvistas
- (NSInteger) InsertInTopHeight:(CGFloat) h
  {
  NSInteger n = self.subviews.count;
  for( NSInteger i=0; i<n; ++i)
    {
    NSView* sub = self.subviews[i];

    NSRect rc = sub.frame;
    rc.origin.y += h;
    sub.frame = rc;
    }

  return h;
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Redimensiona todos los controles de datos cada vez que cambia el tamaño del scroll
- (void) resizeWithOldSuperviewSize:(NSSize)oldSize
  {
  [self LayoutDataViews];
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Pone los datos identificados por 'view' como datos seleccionados
+(void) SelectDatos:(DatosView*) view
  {
  DatosSel = view;

  if( view!=nil ) [view SelectedDatos];
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Retorna la vista de los datos seleccionados
+(DatosView*) SelectedDatos
  {
  return DatosSel;
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Borra los datos seleccionados
- (void) DeleteSelectedDatos
  {
  NSInteger n = self.subviews.count;
  DatosView* next = nil;

  for( NSInteger i=0; i<n; ++i)
    {
    DatosView* sub = self.subviews[i];
    if( sub==DatosSel )
      {
      if( i>0      ) next = self.subviews[i-1];
      else if( n>1 ) next = self.subviews[i+1];
      }
    }

  [DatosSel removeFromSuperview];

  [ZoneDatosView SelectDatos:next];

  [self resizeWithOldSuperviewSize: NSMakeSize(0, 0)];

  if( n<2 ) Ctrller.btnDelAllDatos.hidden = TRUE;                             // Quita el botón para borrar los datos
  }

@end
//===================================================================================================================================================
