//===================================================================================================================================================
//  DatosView.m
//  MultiDict
//
//  Created by Camilo Monteagudo Peña on 3/1/17.
//  Copyright © 2017 BigXSoft. All rights reserved.
//===================================================================================================================================================

//#import "DatosView.h"
#import "ZoneDatosView.h"
#import "BuyMsgView.h"
#import "BtnsData.h"

#define WBTN_BUY  100
#define HBTN_BUY  36

//===================================================================================================================================================
// Vista para mostrar los datos de una entrada en el diccionario
@interface BuyMsgView()
  {
  int iDir;
  
  MyEdit*   lbMsg;
  MyButton* btnBuy;
  MyButton* btnDel;
  }

@end

//===================================================================================================================================================
// Vista donde se ponen los datos de una palabra
@implementation BuyMsgView

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Crea objeto con los datos de la entrada 'Idx'
+ (instancetype) BuyMsgWithWidth:(CGFloat) w
  {
  BuyMsgView* BuyMsg = [[BuyMsgView alloc] init];                  // Crea vista de datos nueva

  BuyMsg->iDir = DIRFromLangs(LGSrc, LGDes);
  
  [BuyMsg CreateMsgLabel];                                         // Crea el label con el mensaje
  [BuyMsg CreateBuyBtn];                                           // Crea un botón para poder realizar las compras
  [BuyMsg CreateBtnDel];                                           // Crea un botón para borra el dato de la lista
  
  [BuyMsg ResizeWithWidth:w];                                      // Dimensiona adecuadamente los controles

  return BuyMsg;
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Hace que el sistema de cordenada sea el normal
- (BOOL)isFlipped
  {
  return YES;
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Crea un label para poner el mensaje
-(void) CreateMsgLabel
  {
  lbMsg = [[MyEdit alloc] init];                                   // TextView para poner la descricción de los datos

  lbMsg.backgroundColor = [NSColor clearColor];                    // Pone color trasparente (Se usa el fondo de DatosView)
  lbMsg.editable = FALSE;                                          // Pone que el texto no se puede editar
  lbMsg.textColor = MsgTxtColor;
  
  [lbMsg.textStorage setAttributedString: MsgForDir(@"DictBuyMsg2", iDir) ];  // Le pone el contenido al TextView

  [self addSubview:lbMsg];
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Crea el boton de compra
- (void) CreateBuyBtn
  {
  btnBuy = [[MyButton alloc] init];
  
  [btnBuy setButtonType: NSMomentaryPushInButton];
  btnBuy.bezelStyle = NSRoundedBezelStyle;
  btnBuy.toolTip  = NSLocalizedString(@"BuyTooltip", nil);
  
  btnBuy.title = NSLocalizedString( @"BtnComprar", nil);
  
  btnBuy.target = self;
  btnBuy.action = @selector(OnBuyDict:);
  
  [self addSubview:btnBuy];
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Crea el boton para borrar los datos de la lista
- (void) CreateBtnDel
  {
  btnDel = [[MyButton alloc] init];
  
  [btnDel setButtonType: NSMomentaryPushInButton];
  
  btnDel.bordered = FALSE;
  btnDel.toolTip  = NSLocalizedString(@"TTipBtnDelDato", nil);
  
  btnDel.image = [NSImage imageNamed:@"DelMean"];
//  btnDel.title = @"";

  btnDel.target = self;
  btnDel.action = @selector(OnRemoveDatos:);
  
  [self addSubview:btnDel];
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Se llama cuando se oprime el boton para comprar el diccionario
- (void)OnBuyDict:(NSButton *)sender
  {
  [Ctrller ShowPurchsesForDir:iDir ];
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Se llama cuando se oprime el boton de borrar los dato se una entrada
- (void) OnRemoveDatos:(NSButton *)sender
  {
  [Ctrller DelEntry];
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Reorganiza todas las subvistas dentro de la zona de datos
- (CGFloat) ResizeWithWidth:(CGFloat) w
  {
  w -= (2*SEP);

  CGFloat wMsg = w-(2*SEP);
  CGFloat y = SEP;                                          // Altura donde va la proxima vista

  lbMsg.frame = NSMakeRect(SEP, y, wMsg, 40 );              // Inicial del texto

  [lbMsg sizeToFit];                                       // Determina el tamaño real del texto
  int hMsg = (int)(lbMsg.frame.size.height+0.5);           // Calcula la altura real del texto
  y += (hMsg + SEP);
  
  CGFloat x = (w-WBTN_BUY)/2;
  
  btnBuy.frame = NSMakeRect( x, y, WBTN_BUY, HBTN_BUY );
  
  y += (HBTN_BUY + SEP );
  self.frame = NSMakeRect(SEP, 0, w, y);                    // Rectangulo para el recuadro de datos
  
  btnDel.frame = NSMakeRect( w-WBTNS-SEP-SEP, y-WBTNS-SEP-SEP, WBTNS, WBTNS );
  
  return y;
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
- (void)mouseDown:(NSEvent *)theEvent
  {
  [ZoneDatosView SelectDatos:self];
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Se llama cuando los datos son seleccionados
- (void) SelectedDatos
  {
  btnDel.hidden = FALSE;
  self.needsDisplay = TRUE;
  [self.superview resizeWithOldSuperviewSize: NSMakeSize(0, 0)];
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Se llama cuando los datos son deseleccionados los seleccionados
- (void) UnSelectedDatos
  {
  btnDel.hidden = TRUE;
  self.needsDisplay = TRUE;
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Se llama cuando cambia la forma de los datos
//- (void)layout
//  {
//  [self.superview resizeWithOldSuperviewSize: NSMakeSize(0, 0)];
//  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------
// Dibuja el fondo de la zona
- (void)drawRect:(NSRect)dirtyRect
  {
  [super drawRect:dirtyRect];

  NSRect rc = self.bounds;
  rc.size.height -= SEP;

  [[NSColor darkGrayColor] set];
  [[NSBezierPath bezierPathWithRoundedRect:rc xRadius:10 yRadius:10 ] fill];

  rc = NSInsetRect(rc, 1, 1);

  if( self == [ZoneDatosView SelectedDatos] ) [MsgSelColor set];
  else                                        [MsgBkgColor set];
  
  [[NSBezierPath bezierPathWithRoundedRect:rc xRadius:9 yRadius:9 ] fill];
  }

//--------------------------------------------------------------------------------------------------------------------------------------------------------

@end

//===================================================================================================================================================
