import 'dart:math';

/*-----------------------------------------------------------------------------
*
*                           procedure dscom
*
*  this procedure provides deep space common items used by both the secular
*    and periodics subroutines. input is provided as shown. this routine
*    used to be called dpper, but the functions inside weren't well organized.
*
*  author        : david vallado                  719-573-2600   28 jun 2005
*
*  inputs        :
*    epoch       -
*    ep          - eccentricity
*    argpp       - argument of perigee
*    tc          -
*    inclp       - inclination
*    nodep       - right ascension of ascending node
*    np          - mean motion
*
*  outputs       :
*    sinim  , cosim  , sinomm , cosomm , snodm  , cnodm
*    day         -
*    e3          -
*    ee2         -
*    em          - eccentricity
*    emsq        - eccentricity squared
*    gam         -
*    peo         -
*    pgho        -
*    pho         -
*    pinco       -
*    plo         -
*    rtemsq      -
*    se2, se3         -
*    sgh2, sgh3, sgh4        -
*    sh2, sh3, si2, si3, sl2, sl3, sl4         -
*    s1, s2, s3, s4, s5, s6, s7          -
*    ss1, ss2, ss3, ss4, ss5, ss6, ss7, sz1, sz2, sz3         -
*    sz11, sz12, sz13, sz21, sz22, sz23, sz31, sz32, sz33        -
*    xgh2, xgh3, xgh4, xh2, xh3, xi2, xi3, xl2, xl3, xl4         -
*    nm          - mean motion
*    z1, z2, z3, z11, z12, z13, z21, z22, z23, z31, z32, z33         -
*    zmol        -
*    zmos        -
*
*  locals        :
*    a1, a2, a3, a4, a5, a6, a7, a8, a9, a10         -
*    betasq      -
*    cc          -
*    ctem, stem        -
*    x1, x2, x3, x4, x5, x6, x7, x8          -
*    xnodce      -
*    xnoi        -
*    zcosg  , zsing  , zcosgl , zsingl , zcosh  , zsinh  , zcoshl , zsinhl ,
*    zcosi  , zsini  , zcosil , zsinil ,
*    zx          -
*    zy          -
*
*  coupling      :
*    none.
*
*  references    :
*    hoots, roehrich, norad spacetrack report #3 1980
*    hoots, norad spacetrack report #6 1986
*    hoots, schumacher and glover 2004
*    vallado, crawford, hujsak, kelso  2006
----------------------------------------------------------------------------*/

/// Provides deep space common items used by both the secular and periodics subroutines.

class DeepSpaceCommon {
  const DeepSpaceCommon({
    required this.snodm,
    required this.cnodm,
    required this.sinim,
    required this.cosim,
    required this.sinomm,
    required this.cosomm,
    required this.day,
    required this.e3,
    required this.ee2,
    required this.em,
    required this.emsq,
    required this.gam,
    required this.peo,
    required this.pgho,
    required this.pho,
    required this.pinco,
    required this.plo,
    required this.rtemsq,
    required this.se2,
    required this.se3,
    required this.sgh2,
    required this.sgh3,
    required this.sgh4,
    required this.sh2,
    required this.sh3,
    required this.si2,
    required this.si3,
    required this.sl2,
    required this.sl3,
    required this.sl4,
    required this.s1,
    required this.s2,
    required this.s3,
    required this.s4,
    required this.s5,
    required this.s6,
    required this.s7,
    required this.ss1,
    required this.ss2,
    required this.ss3,
    required this.ss4,
    required this.ss5,
    required this.ss6,
    required this.ss7,
    required this.sz1,
    required this.sz2,
    required this.sz3,
    required this.sz11,
    required this.sz12,
    required this.sz13,
    required this.sz21,
    required this.sz22,
    required this.sz23,
    required this.sz31,
    required this.sz32,
    required this.sz33,
    required this.xgh2,
    required this.xgh3,
    required this.xgh4,
    required this.xh2,
    required this.xh3,
    required this.xi2,
    required this.xi3,
    required this.xl2,
    required this.xl3,
    required this.xl4,
    required this.nm,
    required this.z1,
    required this.z2,
    required this.z3,
    required this.z11,
    required this.z12,
    required this.z13,
    required this.z21,
    required this.z22,
    required this.z23,
    required this.z31,
    required this.z32,
    required this.z33,
    required this.zmol,
    required this.zmos,
  });

  factory DeepSpaceCommon.calculate({
    required double epoch,
    required double ep,
    required double argpp,
    required double tc,
    required double inclp,
    required double nodep,
    required double np,
  }) {
    var ss1 = 0.0;
    var ss2 = 0.0;
    var ss3 = 0.0;
    var ss4 = 0.0;
    var ss5 = 0.0;
    var ss6 = 0.0;
    var ss7 = 0.0;
    var sz1 = 0.0;
    var sz2 = 0.0;
    var sz3 = 0.0;

    var sz11 = 0.0;
    var sz12 = 0.0;
    var sz13 = 0.0;
    var sz21 = 0.0;
    var sz22 = 0.0;
    var sz23 = 0.0;
    var sz31 = 0.0;
    var sz32 = 0.0;
    var sz33 = 0.0;

    var s1 = 0.0;
    var s2 = 0.0;
    var s3 = 0.0;
    var s4 = 0.0;
    var s5 = 0.0;
    var s6 = 0.0;
    var s7 = 0.0;
    var z1 = 0.0;
    var z2 = 0.0;
    var z3 = 0.0;

    var z11 = 0.0;
    var z12 = 0.0;
    var z13 = 0.0;
    var z21 = 0.0;
    var z22 = 0.0;
    var z23 = 0.0;
    var z31 = 0.0;
    var z32 = 0.0;
    var z33 = 0.0;

    // -------------------------- constants -------------------------
    const double zes = 0.01675;
    const double zel = 0.05490;
    const double c1ss = 2.9864797e-6;
    const double c1l = 4.7968065e-7;
    const double zsinis = 0.39785416;
    const double zcosis = 0.91744867;
    const double zcosgs = 0.1945905;
    const double zsings = -0.98088458;

    //  --------------------- local variables ------------------------
    double nm = np;
    double em = ep;
    double snodm = sin(nodep);
    double cnodm = cos(nodep);
    double sinomm = sin(argpp);
    double cosomm = cos(argpp);
    double sinim = sin(inclp);
    double cosim = cos(inclp);
    double emsq = em * em;
    double betasq = 1.0 - emsq;
    double rtemsq = sqrt(betasq);

    //  ----------------- initialize lunar solar terms ---------------
    const double peo = 0.0;
    const double pinco = 0.0;
    const double plo = 0.0;
    const double pgho = 0.0;
    const double pho = 0.0;
    final day = epoch + 18261.5 + (tc / 1440.0);
    final xnodce = (4.5236020 - (9.2422029e-4 * day)) % twoPi;
    final stem = sin(xnodce);
    final ctem = cos(xnodce);
    final zcosil = 0.91375164 - (0.03568096 * ctem);
    final zsinil = sqrt(1.0 - (zcosil * zcosil));
    final zsinhl = 0.089683511 * stem / zsinil;
    final zcoshl = sqrt(1.0 - (zsinhl * zsinhl));
    final gam = 5.8351514 + (0.0019443680 * day);
    var zx = 0.39785416 * stem / zsinil;
    var zy = (zcoshl * ctem) + (0.91744867 * zsinhl * stem);
    zx = atan2(zx, zy);
    zx += gam - xnodce;
    final zcosgl = cos(zx);
    final zsingl = sin(zx);

    //  ------------------------- do solar terms ---------------------
    var zcosg = zcosgs;
    var zsing = zsings;
    var zcosi = zcosis;
    var zsini = zsinis;
    var zcosh = cnodm;
    var zsinh = snodm;
    var cc = c1ss;
    double xnoi = 1.0 / nm;

    var lsflg = 0;
    while (lsflg < 2) {
      lsflg += 1;
      var a1 = (zcosg * zcosh) + (zsing * zcosi * zsinh);
      var a3 = (-zsing * zcosh) + (zcosg * zcosi * zsinh);
      var a7 = (-zcosg * zsinh) + (zsing * zcosi * zcosh);
      var a8 = zsing * zsini;
      var a9 = (zsing * zsinh) + (zcosg * zcosi * zcosh);
      var a10 = zcosg * zsini;
      var a2 = (cosim * a7) + (sinim * a8);
      var a4 = (cosim * a9) + (sinim * a10);
      var a5 = (-sinim * a7) + (cosim * a8);
      var a6 = (-sinim * a9) + (cosim * a10);

      var x1 = (a1 * cosomm) + (a2 * sinomm);
      var x2 = (a3 * cosomm) + (a4 * sinomm);
      var x3 = (-a1 * sinomm) + (a2 * cosomm);
      var x4 = (-a3 * sinomm) + (a4 * cosomm);
      var x5 = a5 * sinomm;
      var x6 = a6 * sinomm;
      var x7 = a5 * cosomm;
      var x8 = a6 * cosomm;

      z31 = (12.0 * x1 * x1) - (3.0 * x3 * x3);
      z32 = (24.0 * x1 * x2) - (6.0 * x3 * x4);
      z33 = (12.0 * x2 * x2) - (3.0 * x4 * x4);

      z1 = (3.0 * ((a1 * a1) + (a2 * a2))) + (z31 * emsq);
      z2 = (6.0 * ((a1 * a3) + (a2 * a4))) + (z32 * emsq);
      z3 = (3.0 * ((a3 * a3) + (a4 * a4))) + (z33 * emsq);

      z11 = (-6.0 * a1 * a5) + (emsq * ((-24.0 * x1 * x7) - (6.0 * x3 * x5)));
      z12 = (-6.0 * ((a1 * a6) + (a3 * a5))) +
          (emsq *
              ((-24.0 * ((x2 * x7) + (x1 * x8))) +
                  (-6.0 * ((x3 * x6) + (x4 * x5)))));

      z13 = (-6.0 * a3 * a6) + (emsq * ((-24.0 * x2 * x8) - (6.0 * x4 * x6)));

      z21 = (6.0 * a2 * a5) + (emsq * ((24.0 * x1 * x5) - (6.0 * x3 * x7)));
      z22 = (6.0 * ((a4 * a5) + (a2 * a6))) +
          (emsq *
              ((24.0 * ((x2 * x5) + (x1 * x6))) -
                  (6.0 * ((x4 * x7) + (x3 * x8)))));
      z23 = (6.0 * a4 * a6) + (emsq * ((24.0 * x2 * x6) - (6.0 * x4 * x8)));

      z1 = z1 + z1 + (betasq * z31);
      z2 = z2 + z2 + (betasq * z32);
      z3 = z3 + z3 + (betasq * z33);
      s3 = cc * xnoi;
      s2 = -0.5 * s3 / rtemsq;
      s4 = s3 * rtemsq;
      s1 = -15.0 * em * s4;
      s5 = (x1 * x3) + (x2 * x4);
      s6 = (x2 * x3) + (x1 * x4);
      s7 = (x2 * x4) - (x1 * x3);

      //  ----------------------- do lunar terms -------------------
      if (lsflg == 1) {
        ss1 = s1;
        ss2 = s2;
        ss3 = s3;
        ss4 = s4;
        ss5 = s5;
        ss6 = s6;
        ss7 = s7;
        sz1 = z1;
        sz2 = z2;
        sz3 = z3;
        sz11 = z11;
        sz12 = z12;
        sz13 = z13;
        sz21 = z21;
        sz22 = z22;
        sz23 = z23;
        sz31 = z31;
        sz32 = z32;
        sz33 = z33;
        zcosg = zcosgl;
        zsing = zsingl;
        zcosi = zcosil;
        zsini = zsinil;
        zcosh = (zcoshl * cnodm) + (zsinhl * snodm);
        zsinh = (snodm * zcoshl) - (cnodm * zsinhl);
        cc = c1l;
      }
    }

    final zmol = (4.7199672 + ((0.22997150 * day) - gam)) % twoPi;
    final zmos = (6.2565837 + (0.017201977 * day)) % twoPi;

    //  ------------------------ do solar terms ----------------------
    final se2 = 2.0 * ss1 * ss6;
    final se3 = 2.0 * ss1 * ss7;
    final si2 = 2.0 * ss2 * sz12;
    final si3 = 2.0 * ss2 * (sz13 - sz11);
    final sl2 = -2.0 * ss3 * sz2;
    final sl3 = -2.0 * ss3 * (sz3 - sz1);
    final sl4 = -2.0 * ss3 * (-21.0 - (9.0 * emsq)) * zes;
    final sgh2 = 2.0 * ss4 * sz32;
    final sgh3 = 2.0 * ss4 * (sz33 - sz31);
    final sgh4 = -18.0 * ss4 * zes;
    final sh2 = -2.0 * ss2 * sz22;
    final sh3 = -2.0 * ss2 * (sz23 - sz21);

    //  ------------------------ do lunar terms ----------------------
    final ee2 = 2.0 * s1 * s6;
    final e3 = 2.0 * s1 * s7;
    final xi2 = 2.0 * s2 * z12;
    final xi3 = 2.0 * s2 * (z13 - z11);
    final xl2 = -2.0 * s3 * z2;
    final xl3 = -2.0 * s3 * (z3 - z1);
    final xl4 = -2.0 * s3 * (-21.0 - (9.0 * emsq)) * zel;
    final xgh2 = 2.0 * s4 * z32;
    final xgh3 = 2.0 * s4 * (z33 - z31);
    final xgh4 = -18.0 * s4 * zel;
    final xh2 = -2.0 * s2 * z22;
    final xh3 = -2.0 * s2 * (z23 - z21);

    return DeepSpaceCommon(
      snodm: snodm,
      cnodm: cnodm,
      sinim: sinim,
      cosim: cosim,
      sinomm: sinomm,
      cosomm: cosomm,
      day: day,
      e3: e3,
      ee2: ee2,
      em: em,
      emsq: emsq,
      gam: gam,
      peo: peo,
      pgho: pgho,
      pho: pho,
      pinco: pinco,
      plo: plo,
      rtemsq: rtemsq,
      se2: se2,
      se3: se3,
      sgh2: sgh2,
      sgh3: sgh3,
      sgh4: sgh4,
      sh2: sh2,
      sh3: sh3,
      si2: si2,
      si3: si3,
      sl2: sl2,
      sl3: sl3,
      sl4: sl4,
      s1: s1,
      s2: s2,
      s3: s3,
      s4: s4,
      s5: s5,
      s6: s6,
      s7: s7,
      ss1: ss1,
      ss2: ss2,
      ss3: ss3,
      ss4: ss4,
      ss5: ss5,
      ss6: ss6,
      ss7: ss7,
      sz1: sz1,
      sz2: sz2,
      sz3: sz3,
      sz11: sz11,
      sz12: sz12,
      sz13: sz13,
      sz21: sz21,
      sz22: sz22,
      sz23: sz23,
      sz31: sz31,
      sz32: sz32,
      sz33: sz33,
      xgh2: xgh2,
      xgh3: xgh3,
      xgh4: xgh4,
      xh2: xh2,
      xh3: xh3,
      xi2: xi2,
      xi3: xi3,
      xl2: xl2,
      xl3: xl3,
      xl4: xl4,
      nm: nm,
      z1: z1,
      z2: z2,
      z3: z3,
      z11: z11,
      z12: z12,
      z13: z13,
      z21: z21,
      z22: z22,
      z23: z23,
      z31: z31,
      z32: z32,
      z33: z33,
      zmol: zmol,
      zmos: zmos,
    );
  }

  static const double twoPi = pi * 2;
  static const double deg2rad = pi / 180.0;
  static const double rad2deg = 180 / pi;
  static const double x2o3 = 2.0 / 3.0;

  final double snodm;
  final double cnodm;
  final double sinim;
  final double cosim;
  final double sinomm;
  final double cosomm;
  final double day;
  final double e3;
  final double ee2;
  final double em;
  final double emsq;
  final double gam;
  final double peo;
  final double pgho;
  final double pho;
  final double pinco;
  final double plo;
  final double rtemsq;
  final double se2;
  final double se3;
  final double sgh2;
  final double sgh3;
  final double sgh4;
  final double sh2;
  final double sh3;
  final double si2;
  final double si3;
  final double sl2;
  final double sl3;
  final double sl4;
  final double s1;
  final double s2;
  final double s3;
  final double s4;
  final double s5;
  final double s6;
  final double s7;
  final double ss1;
  final double ss2;
  final double ss3;
  final double ss4;
  final double ss5;
  final double ss6;
  final double ss7;
  final double sz1;
  final double sz2;
  final double sz3;
  final double sz11;
  final double sz12;
  final double sz13;
  final double sz21;
  final double sz22;
  final double sz23;
  final double sz31;
  final double sz32;
  final double sz33;
  final double xgh2;
  final double xgh3;
  final double xgh4;
  final double xh2;
  final double xh3;
  final double xi2;
  final double xi3;
  final double xl2;
  final double xl3;
  final double xl4;
  final double nm;
  final double z1;
  final double z2;
  final double z3;
  final double z11;
  final double z12;
  final double z13;
  final double z21;
  final double z22;
  final double z23;
  final double z31;
  final double z32;
  final double z33;
  final double zmol;
  final double zmos;
}
