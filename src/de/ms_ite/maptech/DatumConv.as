
// Conversion of WGS84 lat and lon to DHDN- (Deutsches Haupt-Dreiecksnetz),
// aka "Potsdam-Datum" and R &amp; H (Gauss-Krueger Rechtswert and Hochwert).

// reverse conv form gk to llh (wgs84) does not work yet.

package de.ms_ite.maptech {
	
	public class DatumConv {
	
		protected static var Pi:Number = 3.1415926535897932384626433832795028841971693993751058209749445923078164;

		protected static var RHO:Number = 180.0/Pi;
		protected static var GRAD:Number = 5;

		protected static var awgs:Number = 6378137.0;        // WGS84 Semi-Major Axis = Equatorial Radius in meters
		protected static var bwgs:Number = 6356752.314;      // WGS84 Semi-Minor Axis = Polar Radius in meters
		protected static var abes:Number = 6377397.155;      // Bessel Semi-Major Axis = Equatorial Radius in meters
		protected static var bbes:Number = 6356078.962;      // Bessel Semi-Minor Axis = Polar Radius in meters
		protected static var cbes:Number = 111120.6196;      // Bessel latitude to Gauss-Krueger meters
		protected static var dx:Number   = -585.7;           // Translation Parameter 1
		protected static var dy:Number   = -87.0;            // Translation Parameter 2 
		protected static var dz:Number   = -409.2;           // Translation Parameter 3
		protected static var rotx:Number = 2.540423689E-6;   // Rotation Parameter 1
		protected static var roty:Number = 7.514612057E-7;   // Rotation Parameter 2
		protected static var rotz:Number = -1.368144208E-5;  // Rotation Parameter 3
		// const double sc   = 1/0.99999122;     // Scaling Factor wrong!
		// Maik Stoeckmann reported this error on Nov 12th 2002. Thank you, Maik!
		protected static var sc:Number   = 0.99999122;       // Scaling Factor
		protected static var eq_:Number	= 0;
		protected static var a:Number = 0;
		protected static var b:Number = 0;
			
		public function DatumConv() { 
		}
	
		static protected function debug( txt:String):void {
			trace( "DBG DCONV: "+txt);
		}
	
		public static function llhwgs84_to_gk( b1:Number, l1:Number, h1:Number):Object {
			eq_ = 0;
			a = 0;
			b = 0;
			
			debug( "conv from wgs: "+b1+","+l1+","+h1);
			l1 = Pi *l1/180;
			b1 = Pi *b1/180;
		
			a = awgs; 
			b = bwgs;
		  
			eq_ = (a*a - b*b)/(a*a);
			var N:Number = a / Math.sqrt( 1 - eq_ * Math.sin(b1) * Math.sin(b1));
			var Xq:Number = ( N + h1) * Math.cos(b1) * Math.cos(l1);
			var Yq:Number = ( N + h1) * Math.cos(b1) * Math.sin(l1);
			var Zq:Number = (( 1 - eq_) * N + h1) * Math.sin(b1);
		
			var helm:Object = HelmertTransformation(Xq,Yq,Zq);
			
			debug( "helmert: "+helm.xo+","+helm.yo+","+helm.zo);
		  
			a = abes;
			b = bbes;
		
			eq_ = ( a*a - b*b) / ( a*a);
		
			var rau:Object = BLRauenberg( helm.xo, helm.yo, helm.zo);
		  
			var bes:Object = BesselBLnachGaussKrueger( rau.b, rau.l);
		  
			rau.b = rau.b *180/ Pi;
			rau.l = rau.l *180/ Pi;
		
			debug("Potsdam-Breite: "+rau.b);
			debug("Potsdam-Laenge: "+rau.l);
			debug("Potsdam-Hoehe: "+rau.h);
		
			debug("Gauss-Krueger Koordinaten:");
			debug("conv to   GK:  "+bes.R+","+bes.H);
			debug("\n");
			
			return bes;
		}
		
		protected static function HelmertTransformation( x:Number, y:Number, z:Number):Object
		{
			var h:Object = new Object();
			h.xo = dx +( sc *( 1 *x +rotz *y -roty *z));
			h.yo = dy +( sc *( -rotz *x +1 *y +rotx *z));
			h.zo = dz +( sc *( roty *x -rotx *y +1 *z));
			
			return h;
		}                            
		
		protected static function BesselBLnachGaussKrueger( b:Number, ll:Number):Object {
		  var l:Number;
		  var l0:Number;
		  var bg:Number;
		  var lng:Number;
		  var Ng:Number;
		  var k:Number;
		  var t:Number;
		  var eq_:Number;
		  var Vq:Number;
		  var v:Number;
		  var nk:Number;
		  var X:Number;
		  var gg:Number;
		  var SS:Number;
		  var Y:Number;
		  var kk:Number;
		  var Pii:Number;
		  var RVV:Number;
		
		  var bess:Object = new Object();
		  
		  bg	= 180*b/Pi;
		  lng	= 180*ll/Pi;
		  l0	= 12;	//3*Math.round((180*ll/Pi)/3);
		//  debug( " lo: (3*"+((180*ll/Pi)/3)+") = "+l0);
		  l0	= Pi *l0/ 180;
		  l		= ll-l0;
		//  debug( " rnd: "+ll+" - "+l0+" = "+l);
		  k		= Math.cos(b);
		  t		= Math.sin(b)/k;
		  eq_	= (abes*abes-bbes*bbes)/(bbes*bbes);
		  Vq	= 1 +eq_ *k*k;
		  v		= Math.sqrt(Vq);
		  Ng	= abes*abes/(bbes*v);
		  nk	= (abes-bbes)/(abes+bbes);
		  X		= ((Ng*t*k*k*l*l)/2)+((Ng*t*(9*Vq-t*t-4)*k*k*k*k*l*l*l*l)/24);
		
		  gg	= b +(((-3*nk/2) +(9*nk*nk*nk/16))*Math.sin(2*b) +15*nk*nk*Math.sin(4*b)/16- 35*nk*nk*nk*Math.sin(6*b)/48);
		//  debug( " begg: "+b+" , "+nk+" = "+gg);
		  SS	= gg*180*cbes/Pi;
		//  debug( " beSS: "+gg+" * 180 *"+cbes+" / "+Pi+" = "+SS);
		  bess.H= (SS+ X);
		//  debug( " besH: "+SS+" + "+X+" = "+bess.H);
		  
		//  debug( " "+Ng+" *"+k+" *"+l+" +"+Ng+" *( "+Vq+" -"+t+"*"+t+") *"+k+"*"+k+"*"+k+" *"+l+"*"+l+"*"+l+" /6 + "+Ng+" *(5-18 *"+t+"*"+t+" +"+t+"*"+t+"*"+t+"*"+t+") *"+k+"*"+k+"*"+k+"*"+k+"*"+k+" *"+l+"*"+l+"*"+l+"*"+l+"*"+l+" /120");
		  Y		= Ng *k *l +Ng *( Vq -t*t) *k*k*k *l*l*l /6 + Ng *(5-18 *t*t +t*t*t*t) *k*k*k*k*k *l*l*l*l*l /120;
		  kk	= 500000;
		  Pii	= Pi;
		  RVV	= 4;	//Math.round(( 180 *ll /Pii) /3);
		  bess.R= RVV *1000000 +kk +Y;
		//  debug(" bes:"+RVV+"("+(( 180 *ll /Pii) /3)+") * "+1000000+" + "+kk+" + "+Y+" = "+bess.R);
		  
		  return bess;
		}
		
		protected static function BLRauenberg( x:Number, y:Number, z:Number):Object {
		  var f:Number;
		  var f1:Number;
		  var f2:Number;
		  var ft:Number;
		  var p:Number;
		
		  var rau:Object = new Object();
		  
		  f = Pi * 50 /180;
		  p = z / Math.sqrt( x*x + y*y);
		  
		//  debug("  2rauen: "+z+".");
		  do
		  {
			f1 = neuF(f,x,y,p);
			f2 = f;
			f = f1;
			ft = 180 *f1 /Pi;
		  }
		  while(!(Math.abs(f2-f1) < 10E-10));
		  
		  rau.b = f;
		  rau.l = Math.atan(y/x);
		  rau.h = Math.sqrt(x*x+y*y) /Math.cos(f1) -a /Math.sqrt( 1 -eq_ *Math.sin(f1) *Math.sin(f1));
		  
		//debug( " 2rauen: "+f+"="+rau.b+","+rau.l+","+rau.h);
		  return rau;
		}
		
		protected static function neuF( f:Number, x:Number, y:Number, p:Number):Number {
		  var zw:Number;
		  var nnq:Number;
		
		  zw = a /Math.sqrt( 1 -eq_ *Math.sin(f) *Math.sin(f));
		  nnq= 1 -eq_ *zw /(Math.sqrt( x*x + y*y) /Math.cos(f));
		  
		//  debug( "  neuF: "+f+","+x+","+y+","+p+".");
		  return( Math.atan(p/nnq));
		}
		
		protected static function round( src:Number):Number {
		  var theInteger:Number;
		  var theFraction:Number;
		  var criterion:Number = 0.5;
		
	//	  theFraction = modf(src, theInteger);
		
		  if (!(theFraction < criterion))
		  {
			theInteger += 1; 
		  } 
		
		  return theInteger;
		}
/*		
		protected static function gk2ll( i:Number, j:Number):Object {
			var location:Object = new Object();
			
			var k:Number = i / 0x186a0;
			var d:Number = (i - (k * 0x186a0 + 50000)) * 10;
			var d1:Number = ( j / 111120.61960000001) * 10;
			var d2:Number = d1 + 0.14388535799999999 *
				Math.sin(2 * d1 * 0.017453291999999999) +
				0.00021079000000000001 *
				Math.sin(4 * d1 * 0.017453291999999999) +
				4.2300000000000002E-007 *
				Math.sin(6 * d1 * 0.017453291999999999);
			var d3:Number = Math.tan(d2 * 0.017453291999999999);
			var d4:Number = Math.sqrt(1.0 + 0.0067192190000000002 *
				Math.cos(d2 * 0.017453291999999999) *
				Math.cos(d2 * 0.017453291999999999));
			var d5:Number = (d * d4) / 6398786.8499999996;
			location.lat = d2 - d5 * d5 * 57.295769999999997 * d3 *
				d4 * d4 * (0.5 - (d5 * d5 *
				(4.9699999999999998 - 3 * d3 * d3)) / 24);
			var d6:Number = ((d5 * 57.295769999999997) /
				Math.cos(d2 * 0.017453291999999999)) *
				(1.0 - ((d5 * d5) / 6) * ((d4 * d4 + 2 * d3 * d3) - d5 * d5 *
				(0.59999999999999998 + 1.1000000000000001 * d3 * d3) *
				(0.59999999999999998 + 1.1000000000000001 * d3 * d3)));
			location.lon = (k * 3) + d6;
			
			return location;
		}
		
		protected static function molodensky( location:Object):Object {
			var trans:Object = new Object();
			var d17:Number = 6377397.1550000003;
			var d18:Number = 6378137;
			var d19:Number = 0.003342773181750189;
			var d20:Number = 0.0033528106647474805;
			var d21:Number = 2 * d19 - d19 * d19;
			var d22:Number = 606;
			var d23:Number = 23;
			var d24:Number = 413;
			var d11:Number = (location.lat / 180) * Pi;
			var d12:Number = (location.lon / 180) * Pi;
			var d3:Number = Math.sin(d11);
			var d4:Number = d3 * d3;
			var d5:Number = Math.cos(d11);
			var d6:Number = Math.sin(d12);
			var d7:Number = Math.cos(d12);
			var d8:Number = 1.0 - d19;
			var d13:Number = d18 - d17;
			var d14:Number = d20 - d19;
			var d9:Number = d17 / Math.sqrt(1.0 - d21 * d4);
			var d10:Number = d17 * ((1.0 - d21) / Math.pow(1.0 - d21 * d4, 1.0));
			var d:Number = (-d22 * d3 * d7 - d23 * d3 * d6) + d24 * d5;
			var d1:Number = d13 * ((d9 * d21 * d3 * d5) / d17);
			var d2:Number = d14 * (d10 / d8 + d9 * d8) * d3 * d5;
			var d15:Number = (d + d1 + d2) / d10;
			var d16:Number = (-d22 * d6 + d23 * d7) / (d9 * d5);
			trans.lat = ((d11 + d15) * 180) / Pi;
			trans.lon = ((d12 + d16) * 180) / Pi;
		
			return trans;
		}
		
		public static function gk_to_llWGS84( hochwert:Number, rechtswert:Number):Object {
			return molodensky( gk2ll( hochwert, rechtswert ));
		}
*/		
		
		//*****************************************************************************************
		
		protected static function Vektor(n:int):Array {
		   	var arrRet:Array = new Array(n);
		   	for ( var i:int=0; i<n; i++){ 
		   		arrRet[i] = 0;
		   		}
		   	return arrRet;
		}
		
		
		protected static function Matrix(n:int,m:int):Array {
		   return Vektor(n*m);
		}
		
		
		protected static function ele( zeile:int, spalte:int, m:int):Number {
		   return zeile*m+spalte;
		}
		
		protected static function mult( matrix:Array, vektor:Array,n:int,m:int):Array {
		   var vek:Array = Vektor(n);
		   for ( var i:int=0; i<n; i++) {
		      for ( var j:int=0; j<m; j++) {
		         vek[i] += matrix[ele(i,j,m)]*vektor[j];
		      }
		   }
		   return vek;
		}
		
		protected static function toRad( grad:Number):Number {
		   return grad/RHO;
		}
		
		   
		protected static function Ellips( nr:int, typ:int):Number {
		   var ell:Number = 0;
		   if (nr == 0) {
		      if (typ == 0) { ell = 6378137.000; }
		      if (typ == 1) { ell = 6356752.314; }
		   }
		   if (nr == 1) {
		      if (typ == 0) { ell = 6377397.155; }
		      if (typ == 1) { ell = 6356078.962; }
		   }
		   if (nr == 2) {
		      if (typ == 0) { ell = 6378388.000; }
		      if (typ == 1) { ell = 6356911.946; }
		   }
		   if (nr == 3) {
		      if (typ == 0) { ell = 6378245.000; }
		      if (typ == 1) { ell = 6356863.019; }
		   }
		   return ell;
		}
		   
		protected static function fak( zahl:int):int {
		   var f:int = 1;
		   if ( zahl > 0) {
		      for ( var i:int=1; i<=zahl; i++) { f *= i; }
		   }
		   return f;
		}
		
		protected static function vorz( d:Number):int {
		   var v:int = 0;
		   if ( d != 0.0) { v = d / Math.abs(d); }
		   return v;
		}
		
		protected static function binom( o:int, u:int, typ:int):int {
		   var bi:int = 1;
		   if (typ == 0) {
		      var diff:int = o-u;
		      if (diff > 0) { bi = fak(o)/fak(u)/fak(diff); }
		   } else {
		      bi = o;
		      if (u > 0) {
		         for ( var i:int=1; i<u; i++) { bi *= o-i; }
		      }
		      bi /= fak(u);
		   }
		   return bi;
		}
		
		
		protected static function getKoeffB():Array {
		   var b:Array = Matrix(3,4);
		   b[ele(0,0,4)] = 3.0/8.0;
		   b[ele(0,1,4)] = -3.0/16.0;
		   b[ele(0,2,4)] = 213.0/2048.0;
		   b[ele(0,3,4)] = -255.0/4096.0;
		   b[ele(1,1,4)] = 21.0/256.0;
		   b[ele(1,2,4)] = -b[ele(1,1,4)];
		   b[ele(1,3,4)] = 533.0/8192.0;
		   b[ele(2,2,4)] = 151.0/6144.0;
		   b[ele(2,3,4)] = -453.0/12288.0;
		   return b;
		}
		
		protected static function getKoeffG( c:Number, e22:Number, bf:Number):Array {
		   var co:Number = Math.cos(bf);
		   var ta:Number = Math.tan(bf);
		   var ta2:Number = ta*ta;
		   var v:Number = Math.sqrt( 1.0 + e22 * co * co);
		   var r1:Number = v/c;
		   var r12:Number = r1*r1;
		   var g:Array = Matrix(2,5);
		   g[ele(1,0,5)] = r1*co*(1.0+ta2);
		   g[ele(0,1,5)] = -v*v*r12*ta/2.0;
		   g[ele(1,2,5)] = -r12*r1*co*(1.0+ta2)*(v*v+2.0*ta2)/6.0;
		   g[ele(0,3,5)] = -r12*r12*ta*(1.0-6.0*v*v-3.0*(3.0-2.0*v*v)*ta2)/24.0;
		   g[ele(1,4,5)] = r12*r12*r1*co*(1.0+ta2)*(5.0+28.0*ta2+24.0*ta2*ta2)/120.0;
		   
		   return g;
		}
		
		protected static function Bf( N:Number, m0:Number, c:Number, e22:Number):Number {   // Breite Fusspunkt
		   var a:Number = c;
		   var e2:Number = Math.sqrt(e22);
		   for ( var i:int=1; i<=GRAD+2; i++) {
		      var ab:Number = Math.pow(e2/2.0,2*i)*binom(-1.5,i,1);
		      a += c*ab*binom(2*i,i,0);
		   }
		
		   var q:Array = getKoeffB();
		   var arg:Array = Vektor(4);
		   for ( i=0; i<4; i++) {
		   		arg[i] = Math.pow(e22,i+1);
		   }
		   var b:Array = mult(q,arg,3,4);
		   var b0:Number = N/m0/a;
		   var bf:Number = b0;
		    
		
		   for ( i=1; i<=3; i++) {
		   		bf += b[i-1] * Math.sin(2*i*b0);
		   }
		   return bf;
		}
		
		
		protected static function KonfToGeog( ENh:Array, L0:Number, m0:Number, c:Number, e22:Number):Array {
		
		   var geog:Array = Vektor(3);
		   var dy:Number = (ENh[0]-500000.0)/m0;
		   var bf:Number = Bf(ENh[1],m0,c,e22);
		   var q:Array = getKoeffG(c,e22,bf);
		   var arg:Array = Vektor(5);
		   for ( var i:int=0; i<5; i++)  
		   		arg[i] = Math.pow(dy,i+1);
		   geog = mult(q,arg,2,5);
		   geog[0] += bf;
		   geog[1] += L0;

		   return geog;
		}
		
		
		protected static function helmert_transf( latlon:Array, corr:Object):Array {
			// Algorithmus ist dem Excel-File http://www.geoclub.de/files/GPS_nach_GK.xls nachempfunden
			
			
			// add zero height if height isn´t given
			if ( latlon.length == 2)
				latlon[2]=0;
				
			var Lat:Number = latlon[0];
			var Lon:Number = latlon[1];
			var h:Number = latlon[2];	
			
			// Bessel-Ellipsoid
			var bessel_a:Number = 6377397.155;
			var bessel_b:Number = 6356078.962;
			var bessel_e_sqr:Number = ( Math.pow(bessel_a,2)-Math.pow(bessel_b,2))/Math.pow(bessel_a,2);
			
			// WGS84-Ellipsoid
			var wgs84_a:Number = 6378137.0;
			var wgs84_b:Number = 6356752.314;
			var wgs84_e_sqr:Number = (Math.pow(wgs84_a,2)-Math.pow(wgs84_b,2))/Math.pow(wgs84_a,2);
			
			// Tabellenblatt 3
		
			var N:Number = bessel_a/Math.sqrt(1-bessel_e_sqr*Math.pow(Math.sin(Lat/180*Pi),2));
			var x:Number = (N+h)*Math.cos(Lat/180*Pi)*Math.cos(Lon/180*Pi);
			var y:Number = (N+h)*Math.cos(Lat/180*Pi)*Math.sin(Lon/180*Pi);
			var z:Number = (N*Math.pow(bessel_b,2)/Math.pow(bessel_a,2)+h)*Math.sin(Lat/180*Pi);
			
			//echo "e^2=bessel_e_sqr<br>N=N<br>x=x<br>y=y<br>z=z";die();
		
			
			// Tabellenblatt 4
		
			var vBasis:Array = Vektor(3);
			var vRotiert:Array = Vektor(3);
			var vTransliert:Array = Vektor(3);
			
			vBasis[0] = x;
			vBasis[1] = y;
			vBasis[2] = z;
			
			var ex_korr:Number = corr.ex * Pi / (3600*180);
			var ey_korr:Number = corr.ey * Pi / (3600*180);
			var ez_korr:Number = corr.ez * Pi / (3600*180);
			var m_korr:Number = 1 - corr.m * 1E-6;
			
			//die("ex_korr=ex_korr<br>ey_korr=ey_korr<br>ez_korr=ez_korr<br>m_korr=m_korr");
			
			var dm:Array = Matrix(3,3); // Drehmatrix
			
			dm[ele(0,0,3)] = 1;
			dm[ele(0,1,3)] = ez_korr;
			dm[ele(0,2,3)] = -1* ey_korr;
		
			dm[ele(1,0,3)] = -1 * ez_korr;
			dm[ele(1,1,3)] = 1;
			dm[ele(1,2,3)] = ex_korr;
			
			dm[ele(2,0,3)] = ey_korr;
			dm[ele(2,1,3)] = -1 * ex_korr;
			dm[ele(2,2,3)] = 1;
			
			vRotiert = mult(dm,vBasis,3,3);
			
			/* echo "<pre>vBasis=" ;var_dump(vBasis);echo("</pre>");
			echo "<pre>dm=" ;var_dump(dm);echo("</pre>");
			echo "<pre>" ;var_dump(vRotiert);die("</pre>"); */
			
			// Massstab korrigieren und Translation anwenden
			vTransliert[0] = m_korr * vRotiert[0] + corr.dx;
			vTransliert[1] = m_korr * vRotiert[1] + corr.dy;
			vTransliert[2] = m_korr * vRotiert[2] + corr.dz;
			//echo "vTransliert=<pre>" ;var_dump(vTransliert);die("</pre>"); 
			
			// Tabellenblatt 6 (auf Blatt 5 sind lediglich Parametersätze)
			var s:Number = Math.sqrt( Math.pow(vTransliert[0],2)+Math.pow(vTransliert[1],2));
			var T:Number = Math.atan(vTransliert[2] * wgs84_a / (s * wgs84_b)); 
			var B:Number = Math.atan((vTransliert[2]+wgs84_e_sqr*Math.pow(wgs84_a,2)/wgs84_b*Math.pow(Math.sin(T),3))/(s-wgs84_e_sqr*wgs84_a*Math.pow(Math.cos(T),3)));
			var L:Number = Math.atan(vTransliert[1]/vTransliert[0]);
			N = wgs84_a/Math.sqrt(1-wgs84_e_sqr*Math.pow(Math.sin(B),2));
			h = s/Math.cos(B)-N;
			
			var latlon_transf:Array = new Array();
			latlon_transf[0] = B*180/Pi;
			latlon_transf[1] = L*180/Pi;
			latlon_transf[2] = h;
			
			return(latlon_transf);
		}
		
		public static function gk2ll( rw:Number, hw:Number):Array {
		     var rw_first:String = (''+rw).substr( 0,1);
		     var rw_rest:String = (''+rw).substr( 1);
		     
		     var l0:Number = 1;
		     switch( rw_first) {
		     	case '2': l0=6; break;
		     	case '3': l0=9; break;
		     	case '4': l0=12; break;
		     	case '5': l0=15; break;
		     }
		     
		     var vers:Number = 0;
		     var ENh:Array = Vektor(3);
		     var BLh:Array = Vektor(3);
		     var XYZ:Array = Vektor(3);
		     var xyz:Array = Vektor(3);
		
		     ENh[0] = rw_rest ;
		     ENh[1] = hw ;
		 
		   var m0:Number = 1;
		   
		   // ell = document.kform.Ell.options.selectedIndex;
		   var ell:Number = 1;
		
		   var a:Number = Ellips(ell,0);
		   var b:Number = Ellips(ell,1);
		   var c:Number = a*a/b;
		   var e22:Number = (a*a-b*b)/b/b;
		   // ---------------------------
		
		   var L0:Number = toRad( l0 );
		   
		   BLh = KonfToGeog(ENh,L0,m0,c,e22);
			
			var latlon:Array = new Array();
		   latlon[0] = BLh[0]*RHO;	
		   latlon[1] = BLh[1]*RHO;
		   
		   //           dx     dy     dz       ex       ey      ez      m
		   // Dsued = 597,1  71,4  412,1   -0,894   -0,068   1,563  7,580
		   var DeuSued:Object = new Object();
		   DeuSued.dx = 597.1;
		   DeuSued.dy = 71.4;
		   DeuSued.dz = 412.1;
		   DeuSued.ex = -0.894;
		   DeuSued.ey = -0.068;
		   DeuSued.ez = 1.563;
		   DeuSued.m = 7.580;
		
		   var latlon_korr:Array = helmert_transf( latlon, DeuSued);
		   
//		   trace ( "conv. "+rw+","+hw+" => "+latlon_korr[1]+','+latlon_korr[0]);
		   return latlon_korr;
		
		}		
	}
}
//=================================================================================