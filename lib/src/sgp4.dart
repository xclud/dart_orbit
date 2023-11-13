part of '../orbit.dart';

/// SGP4 Calculator.
class SGP4 {
  /// The constructor.
  SGP4(this.keplerianElements, this.planet) {
    no = keplerianElements.meanMotion / _xpdotp;
    bstar = keplerianElements.drag;

    inclo = keplerianElements.inclination * _deg2rad;
    nodeo = keplerianElements.rightAscensionOfAscendingNode * _deg2rad;
    argpo = keplerianElements.argumentOfPeriapsis * _deg2rad;
    mo = keplerianElements.meanAnomaly * _deg2rad;
    ecco = keplerianElements.eccentricity;

    var year = keplerianElements.epoch ~/ 1000.0;
    var doy = keplerianElements.epoch - (year * 1000);

    year += year < 57 ? 2000 : 1900;

    var j = _julian(year, doy);

    double epoch = j - 2433281.5;

    var earthRadius = planet.radius;
    var j2 = planet.j2;
    var j3 = planet.j3;
    var j4 = planet.j4;

    var j3oj2 = j3 / j2;

    //  sgp4fix add opsmode
    _operationmode = _OpsMode.i;
    _method = _Method.n;

    /* ------------------------ initialization --------------------- */
    // sgp4fix divisor for divide by zero check on inclination
    // the old check used 1.0 + cos(pi-1.0e-9), but then compared it to
    // 1.5 e-12, so the threshold was changed to 1.5e-12 for consistency
    const double temp4 = 1.5e-12;

    // ------------------------ earth constants -----------------------
    // sgp4fix identify constants and allow alternate values

    var ss = (78.0 / earthRadius) + 1.0;
    // sgp4fix use multiply for speed instead of pow
    var qzms2ttemp = (120.0 - 78.0) / earthRadius;
    var qzms2t = qzms2ttemp * qzms2ttemp * qzms2ttemp * qzms2ttemp;

    var t = 0.0;

    var initlResult = _initialize(
        planet: planet,
        ecco: ecco,
        epoch: epoch,
        inclo: inclo,
        no: no,
        opsmode: _operationmode);

    var ao = initlResult.ao;
    var con42 = initlResult.con42;
    var cosio = initlResult.cosio;
    var cosio2 = initlResult.cosio2;
    var eccsq = initlResult.eccsq;
    var omeosq = initlResult.omeosq;
    var posq = initlResult.posq;
    var rp = initlResult.rp;
    var rteosq = initlResult.rteosq;
    var sinio = initlResult.sinio;

    no = initlResult.no;
    con41 = initlResult.con41;
    gsto = initlResult.gsto;

    // sgp4fix remove this check as it is unnecessary
    // the mrt check in sgp4 handles decaying satellite cases even if the starting
    // condition is below the surface of te earth
    // if (rp < 1.0)
    // {
    //   printf("// *** satn%d epoch elts sub-orbital ***\n", satn);
    //   this.error = 5;
    // }

    if (omeosq >= 0.0 || no >= 0.0) {
      isimp = 0;
      if (rp < ((220.0 / earthRadius) + 1.0)) {
        isimp = 1;
      }
      var sfour = ss;
      var qzms24 = qzms2t;
      var perige = (rp - 1.0) * earthRadius;

      // - for perigees below 156 km, s and qoms2t are altered -
      if (perige < 156.0) {
        sfour = perige - 78.0;
        if (perige < 98.0) {
          sfour = 20.0;
        }

        // sgp4fix use multiply for speed instead of pow
        var qzms24temp = (120.0 - sfour) / earthRadius;
        qzms24 = qzms24temp * qzms24temp * qzms24temp * qzms24temp;
        sfour = (sfour / earthRadius) + 1.0;
      }
      var pinvsq = 1.0 / posq;

      var tsi = 1.0 / (ao - sfour);
      eta = ao * ecco * tsi;
      var etasq = eta * eta;
      var eeta = ecco * eta;
      var psisq = _abs(1.0 - etasq);
      var coef = qzms24 * (tsi * tsi * tsi * tsi);
      var coef1 = coef / pow(psisq, 3.5);
      var cc2 = coef1 *
          no *
          ((ao * (1.0 + (1.5 * etasq) + (eeta * (4.0 + etasq)))) +
              (0.375 *
                  j2 *
                  tsi /
                  psisq *
                  con41 *
                  (8.0 + (3.0 * etasq * (8.0 + etasq)))));
      cc1 = bstar * cc2;
      var cc3 = 0.0;
      if (ecco > 1.0e-4) {
        cc3 = -2.0 * coef * tsi * j3oj2 * no * sinio / ecco;
      }
      x1mth2 = 1.0 - cosio2;
      cc4 = 2.0 *
          no *
          coef1 *
          ao *
          omeosq *
          ((eta * (2.0 + (0.5 * etasq))) +
              (ecco * (0.5 + (2.0 * etasq))) -
              (j2 *
                  tsi /
                  (ao * psisq) *
                  ((-3.0 *
                          con41 *
                          (1.0 -
                              (2.0 * eeta) +
                              (etasq * (1.5 - (0.5 * eeta))))) +
                      (0.75 *
                          x1mth2 *
                          ((2.0 * etasq) - (eeta * (1.0 + etasq))) *
                          cos(2.0 * argpo)))));
      cc5 = 2.0 *
          coef1 *
          ao *
          omeosq *
          (1.0 + (2.75 * (etasq + eeta)) + (eeta * etasq));
      var cosio4 = cosio2 * cosio2;
      var temp1 = 1.5 * j2 * pinvsq * no;
      var temp2 = 0.5 * temp1 * j2 * pinvsq;
      var temp3 = -0.46875 * j4 * pinvsq * pinvsq * no;
      mdot = no +
          (0.5 * temp1 * rteosq * con41) +
          (0.0625 *
              temp2 *
              rteosq *
              (13.0 - (78.0 * cosio2) + (137.0 * cosio4)));
      argpdot = (-0.5 * temp1 * con42) +
          (0.0625 * temp2 * (7.0 - (114.0 * cosio2) + (395.0 * cosio4))) +
          (temp3 * (3.0 - (36.0 * cosio2) + (49.0 * cosio4)));
      var xhdot1 = -temp1 * cosio;
      nodedot = xhdot1 +
          (((0.5 * temp2 * (4.0 - (19.0 * cosio2))) +
                  (2.0 * temp3 * (3.0 - (7.0 * cosio2)))) *
              cosio);
      var xpidot = argpdot + nodedot;
      omgcof = bstar * cc3 * cos(argpo);
      xmcof = 0.0;
      if (ecco > 1.0e-4) {
        xmcof = -_x2o3 * coef * bstar / eeta;
      }
      nodecf = 3.5 * omeosq * xhdot1 * cc1;
      t2cof = 1.5 * cc1;

      // sgp4fix for divide by zero with xinco = 180 deg
      xlcof = _abs(cosio + 1.0) > 1.5e-12
          ? -0.25 * j3oj2 * sinio * (3.0 + (5.0 * cosio)) / (1.0 + cosio)
          : -0.25 * j3oj2 * sinio * (3.0 + (5.0 * cosio)) / temp4;
      aycof = -0.5 * j3oj2 * sinio;

      // sgp4fix use multiply for speed instead of pow
      var delmotemp = 1.0 + (eta * cos(mo));
      delmo = delmotemp * delmotemp * delmotemp;
      sinmao = sin(mo);
      x7thm1 = (7.0 * cosio2) - 1.0;

      // --------------- deep space initialization -------------
      if (2 * pi / no >= 225.0) {
        _method = _Method.d;
        isimp = 1;
        var tc = 0.0;
        var inclm = inclo;

        var dscomr = DeepSpaceCommon.calculate(
            epoch: epoch,
            ep: ecco,
            argpp: argpo,
            tc: tc,
            inclp: inclo,
            nodep: nodeo,
            np: no);

        e3 = dscomr.e3;
        ee2 = dscomr.ee2;
        peo = dscomr.peo;
        pgho = dscomr.pgho;
        pho = dscomr.pho;
        pinco = dscomr.pinco;
        plo = dscomr.plo;
        se2 = dscomr.se2;
        se3 = dscomr.se3;
        sgh2 = dscomr.sgh2;
        sgh3 = dscomr.sgh3;
        sgh4 = dscomr.sgh4;
        sh2 = dscomr.sh2;
        sh3 = dscomr.sh3;
        si2 = dscomr.si2;
        si3 = dscomr.si3;
        sl2 = dscomr.sl2;
        sl3 = dscomr.sl3;
        sl4 = dscomr.sl4;
        xgh2 = dscomr.xgh2;
        xgh3 = dscomr.xgh3;
        xgh4 = dscomr.xgh4;
        xh2 = dscomr.xh2;
        xh3 = dscomr.xh3;
        xi2 = dscomr.xi2;
        xi3 = dscomr.xi3;
        xl2 = dscomr.xl2;
        xl3 = dscomr.xl3;
        xl4 = dscomr.xl4;
        zmol = dscomr.zmol;
        zmos = dscomr.zmos;

        var sinim = dscomr.sinim;
        var cosim = dscomr.cosim;
        var em = dscomr.em;
        var emsq = dscomr.emsq;
        var s1 = dscomr.s1;
        var s2 = dscomr.s2;
        var s3 = dscomr.s3;
        var s4 = dscomr.s4;
        var s5 = dscomr.s5;
        var ss1 = dscomr.ss1;
        var ss2 = dscomr.ss2;
        var ss3 = dscomr.ss3;
        var ss4 = dscomr.ss4;
        var ss5 = dscomr.ss5;
        var sz1 = dscomr.sz1;
        var sz3 = dscomr.sz3;
        var sz11 = dscomr.sz11;
        var sz13 = dscomr.sz13;
        var sz21 = dscomr.sz21;
        var sz23 = dscomr.sz23;
        var sz31 = dscomr.sz31;
        var sz33 = dscomr.sz33;

        var nm = dscomr.nm;
        var z1 = dscomr.z1;
        var z3 = dscomr.z3;
        var z11 = dscomr.z11;
        var z13 = dscomr.z13;
        var z21 = dscomr.z21;
        var z23 = dscomr.z23;
        var z31 = dscomr.z31;
        var z33 = dscomr.z33;

        var dpperResult = _dpper(
            t: t,
            init: true,
            ep: ecco,
            inclp: inclo,
            nodep: nodeo,
            argpp: argpo,
            mp: mo,
            opsmode: _operationmode);

        ecco = dpperResult.ep;
        inclo = dpperResult.inclp;
        nodeo = dpperResult.nodep;
        argpo = dpperResult.argpp;
        mo = dpperResult.mp;

        var argpm = 0.0;
        var nodem = 0.0;
        var mm = 0.0;

        var dsinitResult = _deepSpaceInit(
            planet: planet,
            cosim: cosim,
            emsq: emsq,
            argpo: argpo,
            s1: s1,
            s2: s2,
            s3: s3,
            s4: s4,
            s5: s5,
            sinim: sinim,
            ss1: ss1,
            ss2: ss2,
            ss3: ss3,
            ss4: ss4,
            ss5: ss5,
            sz1: sz1,
            sz3: sz3,
            sz11: sz11,
            sz13: sz13,
            sz21: sz21,
            sz23: sz23,
            sz31: sz31,
            sz33: sz33,
            t: t,
            tc: tc,
            gsto: gsto,
            mo: mo,
            mdot: mdot,
            no: no,
            nodeo: nodeo,
            nodedot: nodedot,
            xpidot: xpidot,
            z1: z1,
            z3: z3,
            z11: z11,
            z13: z13,
            z21: z21,
            z23: z23,
            z31: z31,
            z33: z33,
            ecco: ecco,
            eccsq: eccsq,
            em: em,
            argpm: argpm,
            inclm: inclm,
            mm: mm,
            nm: nm,
            nodem: nodem,
            irez: irez,
            atime: atime,
            d2201: d2201,
            d2211: d2211,
            d3210: d3210,
            d3222: d3222,
            d4410: d4410,
            d4422: d4422,
            d5220: d5220,
            d5232: d5232,
            d5421: d5421,
            d5433: d5433,
            dedt: dedt,
            didt: didt,
            dmdt: dmdt,
            dnodt: dnodt,
            domdt: domdt,
            del1: del1,
            del2: del2,
            del3: del3,
            xfact: xfact,
            xlamo: xlamo,
            xli: xli,
            xni: xni);

        irez = dsinitResult.irez;
        atime = dsinitResult.atime;
        d2201 = dsinitResult.d2201;
        d2211 = dsinitResult.d2211;

        d3210 = dsinitResult.d3210;
        d3222 = dsinitResult.d3222;
        d4410 = dsinitResult.d4410;
        d4422 = dsinitResult.d4422;
        d5220 = dsinitResult.d5220;

        d5232 = dsinitResult.d5232;
        d5421 = dsinitResult.d5421;
        d5433 = dsinitResult.d5433;
        dedt = dsinitResult.dedt;
        didt = dsinitResult.didt;

        dmdt = dsinitResult.dmdt;
        dnodt = dsinitResult.dnodt;
        domdt = dsinitResult.domdt;
        del1 = dsinitResult.del1;

        del2 = dsinitResult.del2;
        del3 = dsinitResult.del3;
        xfact = dsinitResult.xfact;
        xlamo = dsinitResult.xlamo;
        xli = dsinitResult.xli;

        xni = dsinitResult.xni;
      }

      // ----------- set variables if not deep space -----------
      if (isimp != 1) {
        var cc1sq = cc1 * cc1;
        d2 = 4.0 * ao * tsi * cc1sq;
        var temp = d2 * tsi * cc1 / 3.0;
        d3 = ((17.0 * ao) + sfour) * temp;
        d4 = 0.5 * temp * ao * tsi * ((221.0 * ao) + (31.0 * sfour)) * cc1;
        t3cof = d2 + (2.0 * cc1sq);
        t4cof = 0.25 * ((3.0 * d3) + (cc1 * ((12.0 * d2) + (10.0 * cc1sq))));
        t5cof = 0.2 *
            ((3.0 * d4) +
                (12.0 * cc1 * d3) +
                (6.0 * d2 * d2) +
                (15.0 * cc1sq * ((2.0 * d2) + cc1sq)));
      }

      /* finally propogate to zero epoch to initialize all others. */
      // sgp4fix take out check to let satellites process until they are actually below earth surface
      // if(this.error == 0)
    }
  }

  /// Keplerian Elements.
  final KeplerianElements keplerianElements;

  /// The planet.
  final Planet planet;

  /// _method
  late final _Method _method;

  /// aycof
  late final double aycof;

  /// con41
  late final double con41;

  /// cc1
  late final double cc1;

  /// cc4
  late final double cc4;

  /// isimp
  late final int isimp;

  /// cc5
  late final double cc5;

  /// d2
  late final double d2;

  /// d3
  late final double d3;

  /// d4
  late final double d4;

  /// delmo
  late final double delmo;

  /// eta
  late final double eta;

  /// sinmao
  late final double sinmao;

  /// argpdot
  late final double argpdot;

  /// omgcof
  late final double omgcof;

  /// x1mth2
  late final double x1mth2;

  /// xlcof
  late final double xlcof;

  /// x7thm1
  late final double x7thm1;

  /// t2cof
  late final double t2cof;

  /// t3cof
  late final double t3cof;

  /// t4cof
  late final double t4cof;

  /// t5cof
  late final double t5cof;

  /// mdot
  late final double mdot;

  /// nodedot
  late final double nodedot;

  /// xmcof
  late final double xmcof;

  /// nodecf
  late final double nodecf;

  /// irez
  late final int irez;

  /// _operationmode
  late final _OpsMode _operationmode;

  /// ecco
  late final double ecco;

  /// no
  late final double no;

  /// gsto
  late final double gsto;

  /// d2201
  late final double d2201;

  /// d2211
  late final double d2211;

  /// d3210
  late final double d3210;

  /// d3222
  late final double d3222;

  /// d4410
  late final double d4410;

  /// d4422
  late final double d4422;

  /// d5220
  late final double d5220;

  /// d5232
  late final double d5232;

  /// d5421
  late final double d5421;

  /// d5433
  late final double d5433;

  /// dedt
  late final double dedt;

  /// del1
  late final double del1;

  /// del2
  late final double del2;

  /// del3
  late final double del3;

  /// didt
  late final double didt;

  /// dmdt
  late final double dmdt;

  /// dnodt
  late final double dnodt;

  /// domdt
  late final double domdt;

  /// e3
  late final double e3;

  /// ee2
  late final double ee2;

  /// peo
  late final double peo;

  /// pgho
  late final double pgho;

  /// pho
  late final double pho;

  /// pinco
  late final double pinco;

  /// plo
  late final double plo;

  /// se2
  late final double se2;

  /// se3
  late final double se3;

  /// sgh2
  late final double sgh2;

  /// sgh3
  late final double sgh3;

  /// sgh4
  late final double sgh4;

  /// sh2
  late final double sh2;

  /// sh3
  late final double sh3;

  /// si2
  late final double si2;

  /// si3
  late final double si3;

  /// sl2
  late final double sl2;

  /// sl3
  late final double sl3;

  /// sl4
  late final double sl4;

  /// xfact
  late final double xfact;

  /// xgh2
  late final double xgh2;

  /// xgh3
  late final double xgh3;

  /// xgh4
  late final double xgh4;

  /// xh2
  late final double xh2;

  /// xh3
  late final double xh3;

  /// xi2
  late final double xi2;

  /// xi3
  late final double xi3;

  /// xl2
  late final double xl2;

  /// zmol
  late final double zmol;

  /// zmos
  late final double zmos;

  /// xlamo
  late final double xlamo;

  /// atime
  late final double atime;

  /// xli
  late final double xli;

  /// xni
  late final double xni;

  /// xl4
  late final double xl4;

  /// bstar
  late final double bstar;

  /// argpo
  late final double argpo;

  /// inclo
  late final double inclo;

  /// mo
  late final double mo;

  /// nodeo
  late final double nodeo;

  /// xl3
  late final double xl3;

  /* -----------------------------------------------------------------------------
*
*                           procedure dpper
*
*  this procedure provides deep space long period periodic contributions
*    to the mean elements. by design, these periodics are zero at epoch.
*    this used to be dscom which included initialization, but it's really a
*    recurring function.
*
*  author        : david vallado                  719-573-2600   28 jun 2005
*
*  inputs        :
*    e3          -
*    ee2         -
*    peo         -
*    pgho        -
*    pho         -
*    pinco       -
*    plo         -
*    se2 , se3 , sgh2, sgh3, sgh4, sh2, sh3, si2, si3, sl2, sl3, sl4 -
*    t           -
*    xh2, xh3, xi2, xi3, xl2, xl3, xl4 -
*    zmol        -
*    zmos        -
*    ep          - eccentricity                           0.0 - 1.0
*    inclo       - inclination - needed for lyddane modification
*    nodep       - right ascension of ascending node
*    argpp       - argument of perigee
*    mp          - mean anomaly
*
*  outputs       :
*    ep          - eccentricity                           0.0 - 1.0
*    inclp       - inclination
*    nodep        - right ascension of ascending node
*    argpp       - argument of perigee
*    mp          - mean anomaly
*
*  locals        :
*    alfdp       -
*    betdp       -
*    cosip  , sinip  , cosop  , sinop  ,
*    dalf        -
*    dbet        -
*    dls         -
*    f2, f3      -
*    pe          -
*    pgh         -
*    ph          -
*    pinc        -
*    pl          -
*    sel   , ses   , sghl  , sghs  , shl   , shs   , sil   , sinzf , sis   ,
*    sll   , sls
*    xls         -
*    xnoh        -
*    zf          -
*    zm          -
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
  DeepSpaceLongPeriodPeriodicContributions _dpper({
    required double t,
    required double ep,
    required double inclp,
    required double nodep,
    required double argpp,
    required double mp,
    required bool init,
    required _OpsMode opsmode,
  }) {
    //  ---------------------- constants -----------------------------
    const double zns = 1.19459e-5;
    const double zes = 0.01675;
    const double znl = 1.5835218e-4;
    const double zel = 0.05490;

    //  --------------- calculate time varying periodics -----------
    var zm = zmos + (zns * t);

    // be sure that the initial call has time set to zero
    if (init) {
      zm = zmos;
    }

    var zf = zm + (2.0 * zes * sin(zm));
    var sinzf = sin(zf);
    var f2 = (0.5 * sinzf * sinzf) - 0.25;
    var f3 = -0.5 * sinzf * cos(zf);

    double ses = (se2 * f2) + (se3 * f3);
    double sis = (si2 * f2) + (si3 * f3);
    double sls = (sl2 * f2) + (sl3 * f3) + (sl4 * sinzf);
    double sghs = (sgh2 * f2) + (sgh3 * f3) + (sgh4 * sinzf);
    double shs = (sh2 * f2) + (sh3 * f3);

    zm = zmol + (znl * t);
    if (init) {
      zm = zmol;
    }

    zf = zm + (2.0 * zel * sin(zm));
    sinzf = sin(zf);
    f2 = (0.5 * sinzf * sinzf) - 0.25;
    f3 = -0.5 * sinzf * cos(zf);

    var sel = (ee2 * f2) + (e3 * f3);
    var sil = (xi2 * f2) + (xi3 * f3);
    var sll = (xl2 * f2) + (xl3 * f3) + (xl4 * sinzf);
    var sghl = (xgh2 * f2) + (xgh3 * f3) + (xgh4 * sinzf);
    var shll = (xh2 * f2) + (xh3 * f3);

    var pe = ses + sel;
    var pinc = sis + sil;
    var pl = sls + sll;
    var pgh = sghs + sghl;
    var ph = shs + shll;

    if (!init) {
      pe -= peo;
      pinc -= pinco;
      pl -= plo;
      pgh -= pgho;
      ph -= pho;
      inclp += pinc;
      ep += pe;
      var sinip = sin(inclp);
      var cosip = cos(inclp);

      /* ----------------- apply periodics directly ------------ */
      // sgp4fix for lyddane choice
      // strn3 used original inclination - this is technically feasible
      // gsfc used perturbed inclination - also technically feasible
      // probably best to readjust the 0.2 limit value and limit discontinuity
      // 0.2 rad = 11.45916 deg
      // use next line for original strn3 approach and original inclination
      // if (inclo >= 0.2)
      // use next line for gsfc version and perturbed inclination
      if (inclp >= 0.2) {
        ph /= sinip;
        pgh -= cosip * ph;
        argpp += pgh;
        nodep += ph;
        mp += pl;
      } else {
        //  ---- apply periodics with lyddane modification ----
        var sinop = sin(nodep);
        var cosop = cos(nodep);
        var alfdp = sinip * sinop;
        var betdp = sinip * cosop;
        var dalf = (ph * cosop) + (pinc * cosip * sinop);
        var dbet = (-ph * sinop) + (pinc * cosip * cosop);
        alfdp += dalf;
        betdp += dbet;
        nodep %= _twoPi;

        //  sgp4fix for afspc written intrinsic functions
        //  nodep used without a trigonometric function ahead
        if (nodep < 0.0 && opsmode == _OpsMode.a) {
          nodep += _twoPi;
        }
        var xls = mp + argpp + (cosip * nodep);
        var dls = pl + pgh - (pinc * nodep * sinip);
        xls += dls;
        var xnoh = nodep;
        nodep = atan2(alfdp, betdp);

        //  sgp4fix for afspc written intrinsic functions
        //  nodep used without a trigonometric function ahead
        if (nodep < 0.0 && opsmode == _OpsMode.a) {
          nodep += _twoPi;
        }
        if (_abs(xnoh - nodep) > pi) {
          if (nodep < xnoh) {
            nodep += _twoPi;
          } else {
            nodep -= _twoPi;
          }
        }
        mp += pl;
        argpp = xls - mp - (cosip * nodep);
      }
    }

    return DeepSpaceLongPeriodPeriodicContributions(
        ep: ep, inclp: inclp, nodep: nodep, argpp: argpp, mp: mp);
  }

  /*-----------------------------------------------------------------------------
 *
 *                           procedure initl
 *
 *  this procedure initializes the sgp4 propagator. all the initialization is
 *    consolidated here instead of having multiple loops inside other routines.
 *
 *  author        : david vallado                  719-573-2600   28 jun 2005
 *
 *  inputs        :
 *    ecco        - eccentricity                           0.0 - 1.0
 *    epoch       - epoch time in days from jan 0, 1950. 0 hr
 *    inclo       - inclination of satellite
 *    no          - mean motion of satellite
 *    satn        - satellite number
 *
 *  outputs       :
 *    ainv        - 1.0 / a
 *    ao          - semi major axis
 *    con41       -
 *    con42       - 1.0 - 5.0 cos(i)
 *    cosio       - cosine of inclination
 *    cosio2      - cosio squared
 *    eccsq       - eccentricity squared
 *    method      - flag for deep space                    'd', 'n'
 *    omeosq      - 1.0 - ecco * ecco
 *    posq        - semi-parameter squared
 *    rp          - radius of perigee
 *    rteosq      - square root of (1.0 - ecco*ecco)
 *    sinio       - sine of inclination
 *    gsto        - gst at time of observation               rad
 *    no          - mean motion of satellite
 *
 *  locals        :
 *    ak          -
 *    d1          -
 *    del         -
 *    adel        -
 *    po          -
 *
 *  coupling      :
 *    getgravconst
 *    gstime      - find greenwich sidereal time from the julian date
 *
 *  references    :
 *    hoots, roehrich, norad spacetrack report #3 1980
 *    hoots, norad spacetrack report #6 1986
 *    hoots, schumacher and glover 2004
 *    vallado, crawford, hujsak, kelso  2006
 ----------------------------------------------------------------------------*/
  static _Spg4InitResult _initialize({
    required Planet planet,
    required double ecco,
    required double epoch,
    required double inclo,
    required double no,
    required _OpsMode opsmode,
  }) {
    var j2 = planet.j2;
    var xke = planet.xke();

    // sgp4fix use old way of finding gst
    // ----------------------- earth constants ---------------------
    // sgp4fix identify constants and allow alternate values

    // ------------- calculate auxillary epoch quantities ----------
    var eccsq = ecco * ecco;
    var omeosq = 1.0 - eccsq;
    var rteosq = sqrt(omeosq);
    var cosio = cos(inclo);
    var cosio2 = cosio * cosio;

    // ------------------ un-kozai the mean motion -----------------
    var ak = pow(xke / no, _x2o3);
    var d1 = 0.75 * j2 * ((3.0 * cosio2) - 1.0) / (rteosq * omeosq);
    var delPrime = d1 / (ak * ak);
    var adel = ak *
        (1.0 -
            (delPrime * delPrime) -
            (delPrime * ((1.0 / 3.0) + (134.0 * delPrime * delPrime / 81.0))));
    delPrime = d1 / (adel * adel);
    no /= 1.0 + delPrime;

    final ao = pow(xke / no, _x2o3).toDouble();
    final sinio = sin(inclo);
    final po = ao * omeosq;
    final con42 = 1.0 - (5.0 * cosio2);
    final con41 = -con42 - cosio2 - cosio2;
    final ainv = 1.0 / ao;
    final posq = po * po;
    final rp = ao * (1.0 - ecco);
    final method = _OpsMode.n;

    //  sgp4fix modern approach to finding sidereal time
    double gsto;
    if (opsmode == _OpsMode.a) {
      //  sgp4fix use old way of finding gst
      //  count integer number of days from 0 jan 1970
      final ts70 = epoch - 7305.0;
      final ds70 = (ts70 + 1.0e-8).floor();
      final tfrac = ts70 - ds70;

      //  find greenwich location at epoch
      const double c1 = 1.72027916940703639e-2;
      const double thgr70 = 1.7321343856509374;
      const double fk5r = 5.07551419432269442e-15;

      var c1p2p = c1 + _twoPi;
      gsto = (thgr70 + (c1 * ds70) + (c1p2p * tfrac) + (ts70 * ts70 * fk5r)) %
          _twoPi;
      if (gsto < 0.0) {
        gsto += _twoPi;
      }
    } else {
      gsto = _gstime(epoch + 2433281.5);
    }

    return _Spg4InitResult(
      no: no,
      method: method,
      ainv: ainv,
      ao: ao,
      con41: con41,
      con42: con42,
      cosio: cosio,
      cosio2: cosio2,
      eccsq: eccsq,
      omeosq: omeosq,
      posq: posq,
      rp: rp,
      rteosq: rteosq,
      sinio: sinio,
      gsto: gsto,
    );
  }

  /*----------------------------------------------------------------------------
     *
     *                             procedure sgp4
     *
     *  this procedure is the sgp4 prediction model from space command. this is an
     *    updated and combined version of sgp4 and sdp4, which were originally
     *    published separately in spacetrack report //3. this version follows the
     *    methodology from the aiaa paper (2006) describing the history and
     *    development of the code.
     *
     *  author        : david vallado                  719-573-2600   28 jun 2005
     *
     *  inputs        :
     *    satrec  - initialised structure from sgp4init() call.
     *    tsince  - time since epoch (minutes)
     *
     *  outputs       :
     *    r           - position vector                     km
     *    v           - velocity                            km/sec
     *  return code - non-zero on error.
     *                   1 - mean elements, ecc >= 1.0 or ecc < -0.001 or a < 0.95 er
     *                   2 - mean motion less than 0.0
     *                   3 - pert elements, ecc < 0.0  or  ecc > 1.0
     *                   4 - semi-latus rectum < 0.0
     *                   5 - epoch elements are sub-orbital
     *                   6 - satellite has decayed
     *
     *  locals        :
     *    am          -
     *    axnl, aynl        -
     *    betal       -
     *    cosim   , sinim   , cosomm  , sinomm  , cnod    , snod    , cos2u   ,
     *    sin2u   , coseo1  , sineo1  , cosi    , sini    , cosip   , sinip   ,
     *    cosisq  , cossu   , sinsu   , cosu    , sinu
     *    delm        -
     *    delomg      -
     *    dndt        -
     *    eccm        -
     *    emsq        -
     *    ecose       -
     *    el2         -
     *    eo1         -
     *    eccp        -
     *    esine       -
     *    argpm       -
     *    argpp       -
     *    omgadf      -
     *    pl          -
     *    r           -
     *    rtemsq      -
     *    rdotl       -
     *    rl          -
     *    rvdot       -
     *    rvdotl      -
     *    su          -
     *    t2  , t3   , t4    , tc
     *    tem5, temp , temp1 , temp2  , tempa  , tempe  , templ
     *    u   , ux   , uy    , uz     , vx     , vy     , vz
     *    inclm       - inclination
     *    mm          - mean anomaly
     *    nm          - mean motion
     *    nodem       - right asc of ascending node
     *    xinc        -
     *    xincp       -
     *    xl          -
     *    xlm         -
     *    mp          -
     *    xmdf        -
     *    xmx         -
     *    xmy         -
     *    nodedf      -
     *    xnode       -
     *    nodep       -
     *    np          -
     *
     *  coupling      :
     *    getgravconst-
     *    dpper
     *    dspace
     *
     *  references    :
     *    hoots, roehrich, norad spacetrack report //3 1980
     *    hoots, norad spacetrack report //6 1986
     *    hoots, schumacher and glover 2004
     *    vallado, crawford, hujsak, kelso  2006
     ----------------------------------------------------------------------------*/

  /// Get Position.
  OrbitalState getPosition(double minutes) {
    var satrec = this;
    var planet = satrec.planet;
    var earthRadius = planet.radius;
    var xke = planet.xke();
    var j2 = planet.j2;
    var j3 = planet.j3;

    var j3oj2 = j3 / j2;
    var vkmpersec = earthRadius * xke / 60.0;

    /* ------------------ set mathematical constants --------------- */
    // sgp4fix divisor for divide by zero check on inclination
    // the old check used 1.0 + cos(pi-1.0e-9), but then compared it to
    // 1.5 e-12, so the threshold was changed to 1.5e-12 for consistency

    const double temp4 = 1.5e-12;

    // --------------------- clear sgp4 error flag -----------------
    var t = minutes;

    //  ------- update for secular gravity and atmospheric drag -----
    var xmdf = satrec.mo + (satrec.mdot * t);
    var argpdf = satrec.argpo + (satrec.argpdot * t);
    var nodedf = satrec.nodeo + (satrec.nodedot * t);
    var argpm = argpdf;
    var mm = xmdf;
    var t2 = t * t;
    var nodem = nodedf + (satrec.nodecf * t2);
    var tempa = 1.0 - (satrec.cc1 * t);
    var tempe = satrec.bstar * satrec.cc4 * t;
    var templ = satrec.t2cof * t2;

    if (satrec.isimp != 1) {
      var delomg = satrec.omgcof * t;
      //  sgp4fix use mutliply for speed instead of pow
      var delmtemp = 1.0 + (satrec.eta * cos(xmdf));
      var delm =
          satrec.xmcof * ((delmtemp * delmtemp * delmtemp) - satrec.delmo);
      var tempp = delomg + delm;
      mm = xmdf + tempp;
      argpm = argpdf - tempp;
      var t3 = t2 * t;
      var t4 = t3 * t;
      tempa = tempa - (satrec.d2 * t2) - (satrec.d3 * t3) - (satrec.d4 * t4);
      tempe += satrec.bstar * satrec.cc5 * (sin(mm) - satrec.sinmao);
      templ = templ +
          (satrec.t3cof * t3) +
          (t4 * (satrec.t4cof + (t * satrec.t5cof)));
    }
    var nm = satrec.no;
    var em = satrec.ecco;
    var inclm = satrec.inclo;

    if (satrec._method == _Method.d) {
      var tc = t;

      var dspaceResult = _deepSpace(
          satrec: satrec,
          t: t,
          tc: tc,
          em: em,
          argpm: argpm,
          inclm: inclm,
          xli: satrec.xli,
          mm: mm,
          xni: satrec.xni,
          nodem: nodem,
          nm: nm);

      em = dspaceResult.em;
      argpm = dspaceResult.argpm;
      inclm = dspaceResult.inclm;
      mm = dspaceResult.mm;
      nodem = dspaceResult.nodem;
      nm = dspaceResult.nm;
    }

    if (nm <= 0.0) {
      throw PropagationException('Error nm $nm', 2);
    }

    var am = pow(xke / nm, _x2o3) * tempa * tempa;
    nm = xke / pow(am, 1.5);
    em -= tempe;

    // fix tolerance for error recognition
    // sgp4fix am is fixed from the previous nm check
    if (em >= 1.0 || em < -0.001) // || (am < 0.95)
    {
      throw PropagationException('Error em $em', 1);
    }

    //  sgp4fix fix tolerance to avoid a divide by zero
    if (em < 1.0e-6) {
      em = 1.0e-6;
    }
    mm += satrec.no * templ;
    var xlm = mm + argpm + nodem;

    nodem %= _twoPi;
    argpm %= _twoPi;
    xlm %= _twoPi;
    mm = (xlm - argpm - nodem) % _twoPi;

    // ----------------- compute extra mean quantities -------------
    var sinim = sin(inclm);
    var cosim = cos(inclm);

    // -------------------- add lunar-solar periodics --------------
    var ep = em;
    var xincp = inclm;
    var argpp = argpm;
    var nodep = nodem;
    var mp = mm;
    var sinip = sinim;
    var cosip = cosim;

    if (satrec._method == _Method.d) {
      var dpperResult = satrec._dpper(
          t: t,
          init: false,
          ep: ep,
          inclp: xincp,
          nodep: nodep,
          argpp: argpp,
          mp: mp,
          opsmode: satrec._operationmode);

      xincp = dpperResult.inclp;

      if (xincp < 0.0) {
        xincp = -xincp;
        nodep += pi;
        argpp -= pi;
      }
      if (ep < 0.0 || ep > 1.0) {
        throw PropagationException('Error ep $ep', 3);
      }
    }

    var aycof = satrec.aycof;
    var xlcof = satrec.xlcof;

    //  -------------------- long period periodics ------------------
    if (satrec._method == _Method.d) {
      sinip = sin(xincp);
      cosip = cos(xincp);
      aycof = -0.5 * j3oj2 * sinip;

      //  sgp4fix for divide by zero for xincp = 180 deg
      xlcof = _abs(cosip + 1.0) > 1.5e-12
          ? -0.25 * j3oj2 * sinip * (3.0 + (5.0 * cosip)) / (1.0 + cosip)
          : -0.25 * j3oj2 * sinip * (3.0 + (5.0 * cosip)) / temp4;
    }

    var axnl = ep * cos(argpp);
    var temp = 1.0 / (am * (1.0 - (ep * ep)));
    var aynl = (ep * sin(argpp)) + (temp * aycof);
    var xl = mp + argpp + nodep + (temp * xlcof * axnl);

    // --------------------- solve kepler's equation ---------------
    var u = (xl - nodep) % _twoPi;
    var eo1 = u;
    var tem5 = 9999.9;
    var ktr = 1;

    var coseo1 = 0.0;
    var sineo1 = 0.0;

    //    sgp4fix for kepler iteration
    //    the following iteration needs better limits on corrections
    while (_abs(tem5) >= 1.0e-12 && ktr <= 10) {
      sineo1 = sin(eo1);
      coseo1 = cos(eo1);
      tem5 = 1.0 - (coseo1 * axnl) - (sineo1 * aynl);
      tem5 = (u - (aynl * coseo1) + (axnl * sineo1) - eo1) / tem5;
      if (_abs(tem5) >= 0.95) {
        tem5 = tem5 > 0.0 ? 0.95 : -0.95;
      }
      eo1 += tem5;
      ktr += 1;
    }

    //  ------------- short period preliminary quantities -----------
    var ecose = (axnl * coseo1) + (aynl * sineo1);
    var esine = (axnl * sineo1) - (aynl * coseo1);
    var el2 = (axnl * axnl) + (aynl * aynl);
    var pl = am * (1.0 - el2);
    if (pl < 0.0) {
      throw PropagationException('Error pl $pl', 4);
    }

    var rl = am * (1.0 - ecose);
    var rdotl = sqrt(am) * esine / rl;
    var rvdotl = sqrt(pl) / rl;
    var betal = sqrt(1.0 - el2);
    temp = esine / (1.0 + betal);
    var sinu = am / rl * (sineo1 - aynl - (axnl * temp));
    var cosu = am / rl * (coseo1 - axnl + (aynl * temp));
    var su = atan2(sinu, cosu);
    var sin2u = (cosu + cosu) * sinu;
    var cos2u = 1.0 - (2.0 * sinu * sinu);
    temp = 1.0 / pl;
    var temp1 = 0.5 * j2 * temp;
    var temp2 = temp1 * temp;

    var con41 = satrec.con41;
    var x1mth2 = satrec.x1mth2;
    var x7thm1 = satrec.x7thm1;

    // -------------- update for short period periodics ------------
    if (satrec._method == _Method.d) {
      var cosisq = cosip * cosip;
      con41 = (3.0 * cosisq) - 1.0;
      x1mth2 = 1.0 - cosisq;
      x7thm1 = (7.0 * cosisq) - 1.0;
    }

    var mrt = (rl * (1.0 - (1.5 * temp2 * betal * con41))) +
        (0.5 * temp1 * x1mth2 * cos2u);

    // sgp4fix for decaying satellites
    if (mrt < 1.0) {
      throw PropagationException('decay condition $mrt', 6);
    }

    su -= 0.25 * temp2 * x7thm1 * sin2u;
    var xnode = nodep + (1.5 * temp2 * cosip * sin2u);
    var xinc = xincp + (1.5 * temp2 * cosip * sinip * cos2u);
    var mvt = rdotl - (nm * temp1 * x1mth2 * sin2u / xke);
    var rvdot =
        rvdotl + (nm * temp1 * ((x1mth2 * cos2u) + (1.5 * con41)) / xke);

    // --------------------- orientation vectors -------------------
    var sinsu = sin(su);
    var cossu = cos(su);
    var snod = sin(xnode);
    var cnod = cos(xnode);
    var sini = sin(xinc);
    var cosi = cos(xinc);
    var xmx = -snod * cosi;
    var xmy = cnod * cosi;
    var ux = (xmx * sinsu) + (cnod * cossu);
    var uy = (xmy * sinsu) + (snod * cossu);
    var uz = sini * sinsu;
    var vx = (xmx * cossu) - (cnod * sinsu);
    var vy = (xmy * cossu) - (snod * sinsu);
    var vz = sini * cossu;

    // --------- position and velocity (in km and km/sec) ----------
    var r = EarthCenteredInertial(
        mrt * ux * earthRadius, mrt * uy * earthRadius, mrt * uz * earthRadius);
    var v = EarthCenteredInertial(
        ((mvt * ux) + (rvdot * vx)) * vkmpersec,
        ((mvt * uy) + (rvdot * vy)) * vkmpersec,
        ((mvt * uz) + (rvdot * vz)) * vkmpersec);

    return OrbitalState(r, v);
  }

  /// Get Position.
  OrbitalState getPositionByDateTime(DateTime utc) {
    final minutes = keplerianElements.getMinutesPastEpoch(utc);

    return getPosition(minutes);
  }
}

class _DspaceResult {
  const _DspaceResult({
    required this.atime,
    required this.em,
    required this.argpm,
    required this.inclm,
    required this.xli,
    required this.mm,
    required this.xni,
    required this.nodem,
    required this.nm,
    required this.dndt,
  });

  final double atime;
  final double em;
  final double argpm;
  final double inclm;
  final double xli;
  final double mm;
  final double xni;
  final double nodem;
  final double nm;
  final double dndt;
}

class _Spg4InitResult {
  const _Spg4InitResult({
    required this.method,
    required this.no,
    required this.ainv,
    required this.ao,
    required this.con41,
    required this.con42,
    required this.cosio,
    required this.cosio2,
    required this.eccsq,
    required this.omeosq,
    required this.posq,
    required this.rp,
    required this.rteosq,
    required this.sinio,
    required this.gsto,
  });
  final _OpsMode method;
  final double no;
  final double ainv;
  final double ao;
  final double con41;
  final double con42;
  final double cosio;
  final double cosio2;
  final double eccsq;
  final double omeosq;
  final double posq;
  final double rp;
  final double rteosq;
  final double sinio;
  final double gsto;
}

class _DsInitResult {
  const _DsInitResult(
      {required this.irez,
      required this.em,
      required this.argpm,
      required this.inclm,
      required this.mm,
      required this.nm,
      required this.nodem,
      required this.atime,
      required this.d2201,
      required this.d2211,
      required this.d3210,
      required this.d3222,
      required this.d4410,
      required this.d4422,
      required this.d5220,
      required this.d5232,
      required this.d5421,
      required this.d5433,
      required this.dedt,
      required this.didt,
      required this.dmdt,
      required this.dndt,
      required this.dnodt,
      required this.domdt,
      required this.del1,
      required this.del2,
      required this.del3,
      required this.xfact,
      required this.xlamo,
      required this.xli,
      required this.xni});

  final int irez;
  final double em;
  final double argpm;
  final double inclm;
  final double mm;
  final double nm;
  final double nodem;
  final double atime;
  final double d2201;
  final double d2211;
  final double d3210;
  final double d3222;
  final double d4410;
  final double d4422;
  final double d5220;
  final double d5232;
  final double d5421;
  final double d5433;
  final double dedt;
  final double didt;
  final double dmdt;
  final double dndt;
  final double dnodt;
  final double domdt;
  final double del1;
  final double del2;
  final double del3;
  final double xfact;
  final double xlamo;
  final double xli;
  final double xni;
}

/// Propagation Exception.
class PropagationException implements Exception {
  /// The constructor.
  const PropagationException(this.message, [int n = 0]);

  /// Error message.
  final String message;
}

enum _OpsMode {
  n,
  a,
  i,
}

enum _Method {
  d,
  n,
}

num _abs(num v) {
  return v.abs();
}

double _julian(int year, double doy) {
  {
    // Now calculate Julian date
    // Ref: "Astronomical Formulae for Calculators", Jean Meeus, pages 23-25

    year--;

    // Centuries are not leap years unless they divide by 400
    int A = year ~/ 100;
    int B = 2 - A + (A ~/ 4);

    double jan01 =
        (365.25 * year).toInt() + (30.6001 * 14).toInt() + 1720994.5 + B;

    return jan01 + doy;
  }
}

double _gstime(double jdut1) {
  var tut1 = (jdut1 - 2451545.0) / 36525.0;

  var temp = (-6.2e-6 * tut1 * tut1 * tut1) +
      (0.093104 * tut1 * tut1) +
      (((876600.0 * 3600) + 8640184.812866) * tut1) +
      67310.54841; // # sec
  temp = temp * _deg2rad / 240.0 % _twoPi; // 360/86400 = 1/240, to deg, to rad

  //  ------------------------ check quadrants ---------------------
  if (temp < 0.0) {
    temp += _twoPi;
  }

  return temp;
}

extension _X on Planet {
  double xke() {
    final earthRadius = radius;

    return 60.0 / sqrt(earthRadius * earthRadius * earthRadius / mu);
  }
}

/*-----------------------------------------------------------------------------
    *
    *                           procedure dspace
    *
    *  this procedure provides deep space contributions to mean elements for
    *    perturbing third body.  these effects have been averaged over one
    *    revolution of the sun and moon.  for earth resonance effects, the
    *    effects have been averaged over no revolutions of the satellite.
    *    (mean motion)
    *
    *  author        : david vallado                  719-573-2600   28 jun 2005
    *
    *  inputs        :
    *    d2201, d2211, d3210, d3222, d4410, d4422, d5220, d5232, d5421, d5433 -
    *    dedt        -
    *    del1, del2, del3  -
    *    didt        -
    *    dmdt        -
    *    dnodt       -
    *    domdt       -
    *    irez        - flag for resonance           0-none, 1-one day, 2-half day
    *    argpo       - argument of perigee
    *    argpdot     - argument of perigee dot (rate)
    *    t           - time
    *    tc          -
    *    gsto        - gst
    *    xfact       -
    *    xlamo       -
    *    no          - mean motion
    *    atime       -
    *    em          - eccentricity
    *    ft          -
    *    argpm       - argument of perigee
    *    inclm       - inclination
    *    xli         -
    *    mm          - mean anomaly
    *    xni         - mean motion
    *    nodem       - right ascension of ascending node
    *
    *  outputs       :
    *    atime       -
    *    em          - eccentricity
    *    argpm       - argument of perigee
    *    inclm       - inclination
    *    xli         -
    *    mm          - mean anomaly
    *    xni         -
    *    nodem       - right ascension of ascending node
    *    dndt        -
    *    nm          - mean motion
    *
    *  locals        :
    *    delt        -
    *    ft          -
    *    theta       -
    *    x2li        -
    *    x2omi       -
    *    xl          -
    *    xldot       -
    *    xnddt       -
    *    xndt        -
    *    xomi        -
    *
    *  coupling      :
    *    none        -
    *
    *  references    :
    *    hoots, roehrich, norad spacetrack report #3 1980
    *    hoots, norad spacetrack report #6 1986
    *    hoots, schumacher and glover 2004
    *    vallado, crawford, hujsak, kelso  2006
    ----------------------------------------------------------------------------*/
_DspaceResult _deepSpace({
  required SGP4 satrec,
  required double t,
  required double tc,
  //
  required double em,
  required double argpm,
  required double inclm,
  required double xli,
  required double mm,
  required double xni,
  required double nodem,
  required double nm,
}) {
  var irez = satrec.irez;
  var d2201 = satrec.d2201;
  var d2211 = satrec.d2211;
  var d3210 = satrec.d3210;
  var d3222 = satrec.d3222;
  var d4410 = satrec.d4410;
  var d4422 = satrec.d4422;
  var d5220 = satrec.d5220;
  var d5232 = satrec.d5232;
  var d5421 = satrec.d5421;
  var d5433 = satrec.d5433;
  var dedt = satrec.dedt;
  var del1 = satrec.del1;
  var del2 = satrec.del2;
  var del3 = satrec.del3;
  var didt = satrec.didt;
  var dmdt = satrec.dmdt;
  var dnodt = satrec.dnodt;
  var domdt = satrec.domdt;
  var argpo = satrec.argpo;
  var argpdot = satrec.argpdot;

  var gsto = satrec.gsto;
  var xfact = satrec.xfact;
  var xlamo = satrec.xlamo;
  var no = satrec.no;
  var atime = satrec.atime;

  const double fasx2 = 0.13130908;
  const double fasx4 = 2.8843198;
  const double fasx6 = 0.37448087;
  const double g22 = 5.7686396;
  const double g32 = 0.95240898;
  const double g44 = 1.8014998;
  const double g52 = 1.0508330;
  const double g54 = 4.4108898;
  const double rptim =
      4.37526908801129966e-3; // equates to 7.29211514668855e-5 rad/sec
  const double stepp = 720.0;
  const double stepn = -720.0;
  const double step2 = 259200.0;

  double x2li;
  double x2omi;
  double xl;
  double xldot = 0;
  double xnddt = 0;
  double xndt = 0;
  double xomi;
  double dndt = 0.0;
  double ft = 0.0;

  //  ----------- calculate deep space resonance effects -----------
  double theta = (gsto + (tc * rptim)) % _twoPi;
  em += dedt * t;
  inclm += didt * t;
  argpm += domdt * t;
  nodem += dnodt * t;
  mm += dmdt * t;

  // sgp4fix for negative inclinations
  // the following if statement should be commented out
  // if (inclm < 0.0)
  // {
  //   inclm = -inclm;
  //   argpm = argpm - pi;
  //   nodem = nodem + pi;
  // }

  /* - update resonances : numerical (euler-maclaurin) integration - */
  /* ------------------------- epoch restart ----------------------  */
  //   sgp4fix for propagator problems
  //   the following integration works for negative time steps and periods
  //   the specific changes are unknown because the original code was so convoluted

  // sgp4fix take out atime = 0.0 and fix for faster operation

  if (irez != 0) {
    //  sgp4fix streamline check
    if (atime == 0.0 || t * atime <= 0.0 || _abs(t) < _abs(atime)) {
      atime = 0.0;
      xni = no;
      xli = xlamo;
    }

    // sgp4fix move check outside loop
    var delt = t > 0.0 ? stepp : stepn;

    var iretn = 381; // added for do loop
    while (iretn == 381) {
      //  ------------------- dot terms calculated -------------
      //  ----------- near - synchronous resonance terms -------
      if (irez != 2) {
        xndt = (del1 * sin(xli - fasx2)) +
            (del2 * sin(2.0 * (xli - fasx4))) +
            (del3 * sin(3.0 * (xli - fasx6)));
        xldot = xni + xfact;
        xnddt = (del1 * cos(xli - fasx2)) +
            (2.0 * del2 * cos(2.0 * (xli - fasx4))) +
            (3.0 * del3 * cos(3.0 * (xli - fasx6)));
        xnddt *= xldot;
      } else {
        // --------- near - half-day resonance terms --------
        xomi = argpo + (argpdot * atime);
        x2omi = xomi + xomi;
        x2li = xli + xli;
        xndt = (d2201 * sin(x2omi + xli - g22)) +
            (d2211 * sin(xli - g22)) +
            (d3210 * sin(xomi + xli - g32)) +
            (d3222 * sin(-xomi + xli - g32)) +
            (d4410 * sin(x2omi + x2li - g44)) +
            (d4422 * sin(x2li - g44)) +
            (d5220 * sin(xomi + xli - g52)) +
            (d5232 * sin(-xomi + xli - g52)) +
            (d5421 * sin(xomi + x2li - g54)) +
            (d5433 * sin(-xomi + x2li - g54));
        xldot = xni + xfact;
        xnddt = (d2201 * cos(x2omi + xli - g22)) +
            (d2211 * cos(xli - g22)) +
            (d3210 * cos(xomi + xli - g32)) +
            (d3222 * cos(-xomi + xli - g32)) +
            (d5220 * cos(xomi + xli - g52)) +
            (d5232 * cos(-xomi + xli - g52)) +
            (2.0 * d4410 * cos(x2omi + x2li - g44)) +
            (d4422 * cos(x2li - g44)) +
            (d5421 * cos(xomi + x2li - g54)) +
            (d5433 * cos(-xomi + x2li - g54));
        xnddt *= xldot;
      }

      //  ----------------------- integrator -------------------
      //  sgp4fix move end checks to end of routine
      if (_abs(t - atime) >= stepp) {
        iretn = 381;
      } else {
        ft = t - atime;
        iretn = 0;
      }

      if (iretn == 381) {
        xli += (xldot * delt) + (xndt * step2);
        xni += (xndt * delt) + (xnddt * step2);
        atime += delt;
      }
    }

    nm = xni + (xndt * ft) + (xnddt * ft * ft * 0.5);
    xl = xli + (xldot * ft) + (xndt * ft * ft * 0.5);
    if (irez != 1) {
      mm = xl - (2.0 * nodem) + (2.0 * theta);
      dndt = nm - no;
    } else {
      mm = xl - nodem - argpm + theta;
      dndt = nm - no;
    }
    nm = no + dndt;
  }

  var ret = _DspaceResult(
      atime: atime,
      em: em,
      argpm: argpm,
      inclm: inclm,
      xli: xli,
      mm: mm,
      xni: xni,
      nodem: nodem,
      dndt: dndt,
      nm: nm);

  return ret;
}

/*-----------------------------------------------------------------------------
    *
    *                           procedure dsinit
    *
    *  this procedure provides deep space contributions to mean motion dot due
    *    to geopotential resonance with half day and one day orbits.
    *
    *  author        : david vallado                  719-573-2600   28 jun 2005
    *
    *  inputs        :
    *    cosim, sinim-
    *    emsq        - eccentricity squared
    *    argpo       - argument of perigee
    *    s1, s2, s3, s4, s5      -
    *    ss1, ss2, ss3, ss4, ss5 -
    *    sz1, sz3, sz11, sz13, sz21, sz23, sz31, sz33 -
    *    t           - time
    *    tc          -
    *    gsto        - greenwich sidereal time                   rad
    *    mo          - mean anomaly
    *    mdot        - mean anomaly dot (rate)
    *    no          - mean motion
    *    nodeo       - right ascension of ascending node
    *    nodedot     - right ascension of ascending node dot (rate)
    *    xpidot      -
    *    z1, z3, z11, z13, z21, z23, z31, z33 -
    *    eccm        - eccentricity
    *    argpm       - argument of perigee
    *    inclm       - inclination
    *    mm          - mean anomaly
    *    xn          - mean motion
    *    nodem       - right ascension of ascending node
    *
    *  outputs       :
    *    em          - eccentricity
    *    argpm       - argument of perigee
    *    inclm       - inclination
    *    mm          - mean anomaly
    *    nm          - mean motion
    *    nodem       - right ascension of ascending node
    *    irez        - flag for resonance           0-none, 1-one day, 2-half day
    *    atime       -
    *    d2201, d2211, d3210, d3222, d4410, d4422, d5220, d5232, d5421, d5433    -
    *    dedt        -
    *    didt        -
    *    dmdt        -
    *    dndt        -
    *    dnodt       -
    *    domdt       -
    *    del1, del2, del3        -
    *    ses  , sghl , sghs , sgs  , shl  , shs  , sis  , sls
    *    theta       -
    *    xfact       -
    *    xlamo       -
    *    xli         -
    *    xni
    *
    *  locals        :
    *    ainv2       -
    *    aonv        -
    *    cosisq      -
    *    eoc         -
    *    f220, f221, f311, f321, f322, f330, f441, f442, f522, f523, f542, f543  -
    *    g200, g201, g211, g300, g310, g322, g410, g422, g520, g521, g532, g533  -
    *    sini2       -
    *    temp        -
    *    temp1       -
    *    theta       -
    *    xno2        -
    *
    *  coupling      :
    *    getgravconst
    *
    *  references    :
    *    hoots, roehrich, norad spacetrack report #3 1980
    *    hoots, norad spacetrack report #6 1986
    *    hoots, schumacher and glover 2004
    *    vallado, crawford, hujsak, kelso  2006
    ----------------------------------------------------------------------------*/
_DsInitResult _deepSpaceInit({
  required Planet planet,
  required double cosim,
  required double argpo,
  required double s1,
  required double s2,
  required double s3,
  required double s4,
  required double s5,
  required double sinim,
  required double ss1,
  required double ss2,
  required double ss3,
  required double ss4,
  required double ss5,
  required double sz1,
  required double sz3,
  required double sz11,
  required double sz13,
  required double sz21,
  required double sz23,
  required double sz31,
  required double sz33,
  required double t,
  required double tc,
  required double gsto,
  required double mo,
  required double mdot,
  required double no,
  required double nodeo,
  required double nodedot,
  required double xpidot,
  required double z1,
  required double z3,
  required double z11,
  required double z13,
  required double z21,
  required double z23,
  required double z31,
  required double z33,
  required double ecco,
  required double eccsq,
  required double emsq,
  required double em,
  required double argpm,
  required double inclm,
  required double mm,
  required double nm,
  required double nodem,
  required int irez,
  required double atime,
  required double d2201,
  required double d2211,
  required double d3210,
  required double d3222,
  required double d4410,
  required double d4422,
  required double d5220,
  required double d5232,
  required double d5421,
  required double d5433,
  required double dedt,
  required double didt,
  required double dmdt,
  required double dnodt,
  required double domdt,
  required double del1,
  required double del2,
  required double del3,
  required double xfact,
  required double xlamo,
  required double xli,
  required double xni,
}) {
  var xke = planet.xke();

  const double q22 = 1.7891679e-6;
  const double q31 = 2.1460748e-6;
  const double q33 = 2.2123015e-7;
  const double root22 = 1.7891679e-6;
  const double root44 = 7.3636953e-9;
  const double root54 = 2.1765803e-9;
  const double rptim =
      4.37526908801129966e-3; // equates to 7.29211514668855e-5 rad/sec
  const double root32 = 3.7393792e-7;
  const double root52 = 1.1428639e-7;
  const double znl = 1.5835218e-4;
  const double zns = 1.19459e-5;

  // -------------------- deep space initialization ------------
  irez = 0;
  if (nm < 0.0052359877 && nm > 0.0034906585) {
    irez = 1;
  }
  if ((nm >= 8.26e-3) && (nm <= 9.24e-3) && (em >= 0.5)) {
    irez = 2;
  }

  // ------------------------ do solar terms -------------------
  var ses = ss1 * zns * ss5;
  var sis = ss2 * zns * (sz11 + sz13);
  var sls = -zns * ss3 * (sz1 + sz3 - 14.0 - (6.0 * emsq));
  var sghs = ss4 * zns * (sz31 + sz33 - 6.0);
  var shs = -zns * ss2 * (sz21 + sz23);

  // sgp4fix for 180 deg incl
  if (inclm < 5.2359877e-2 || inclm > (pi - 5.2359877e-2)) {
    shs = 0.0;
  }
  if (sinim != 0.0) {
    shs /= sinim;
  }
  var sgs = sghs - (cosim * shs);

  // ------------------------- do lunar terms ------------------
  dedt = ses + (s1 * znl * s5);
  didt = sis + (s2 * znl * (z11 + z13));
  dmdt = sls - (znl * s3 * (z1 + z3 - 14.0 - (6.0 * emsq)));
  var sghl = s4 * znl * (z31 + z33 - 6.0);
  var shll = -znl * s2 * (z21 + z23);

  // sgp4fix for 180 deg incl
  if (inclm < 5.2359877e-2 || inclm > (pi - 5.2359877e-2)) {
    shll = 0.0;
  }
  domdt = sgs + sghl;
  dnodt = shs;
  if (sinim != 0.0) {
    domdt -= cosim / sinim * shll;
    dnodt += shll / sinim;
  }

  // ----------- calculate deep space resonance effects --------
  const double dndt = 0.0;
  var theta = (gsto + (tc * rptim)) % _twoPi;
  em += dedt * t;
  inclm += didt * t;
  argpm += domdt * t;
  nodem += dnodt * t;
  mm += dmdt * t;

  // sgp4fix for negative inclinations
  // the following if statement should be commented out
  // if (inclm < 0.0)
  // {
  //   inclm  = -inclm;
  //   argpm  = argpm - pi;
  //   nodem = nodem + pi;
  // }

  // -------------- initialize the resonance terms -------------
  if (irez != 0) {
    var aonv = nm / pow(xke, _x2o3);

    // ---------- geopotential resonance for 12 hour orbits ------
    if (irez == 2) {
      var cosisq = cosim * cosim;
      var emo = em;
      em = ecco;
      var emsqo = emsq;
      emsq = eccsq;
      var eoc = em * emsq;
      var g201 = -0.306 - ((em - 0.64) * 0.440);

      double g211;
      double g310;
      double g322;
      double g410;
      double g422;
      double g520;
      double g533;
      double g521;
      double g532;

      if (em <= 0.65) {
        g211 = 3.616 - (13.2470 * em) + (16.2900 * emsq);
        g310 = -19.302 + (117.3900 * em) - (228.4190 * emsq) + (156.5910 * eoc);
        g322 =
            -18.9068 + (109.7927 * em) - (214.6334 * emsq) + (146.5816 * eoc);
        g410 = -41.122 + (242.6940 * em) - (471.0940 * emsq) + (313.9530 * eoc);
        g422 =
            -146.407 + (841.8800 * em) - (1629.014 * emsq) + (1083.4350 * eoc);
        g520 =
            -532.114 + (3017.977 * em) - (5740.032 * emsq) + (3708.2760 * eoc);
      } else {
        g211 = -72.099 + (331.819 * em) - (508.738 * emsq) + (266.724 * eoc);
        g310 =
            -346.844 + (1582.851 * em) - (2415.925 * emsq) + (1246.113 * eoc);
        g322 =
            -342.585 + (1554.908 * em) - (2366.899 * emsq) + (1215.972 * eoc);
        g410 =
            -1052.797 + (4758.686 * em) - (7193.992 * emsq) + (3651.957 * eoc);
        g422 = -3581.690 +
            (16178.110 * em) -
            (24462.770 * emsq) +
            (12422.520 * eoc);
        g520 = em > 0.715
            ? -5149.66 + (29936.92 * em) - (54087.36 * emsq) + (31324.56 * eoc)
            : 1464.74 - (4664.75 * em) + (3763.64 * emsq);
      }
      if (em < 0.7) {
        g533 = -919.22770 +
            (4988.6100 * em) -
            (9064.7700 * emsq) +
            (5542.21 * eoc);
        g521 = -822.71072 +
            (4568.6173 * em) -
            (8491.4146 * emsq) +
            (5337.524 * eoc);
        g532 =
            -853.66600 + (4690.2500 * em) - (8624.7700 * emsq) + (5341.4 * eoc);
      } else {
        g533 = -37995.780 +
            (161616.52 * em) -
            (229838.20 * emsq) +
            (109377.94 * eoc);
        g521 = -51752.104 +
            (218913.95 * em) -
            (309468.16 * emsq) +
            (146349.42 * eoc);
        g532 = -40023.880 +
            (170470.89 * em) -
            (242699.48 * emsq) +
            (115605.82 * eoc);
      }
      var sini2 = sinim * sinim;
      var f220 = 0.75 * (1.0 + (2.0 * cosim) + cosisq);
      var f221 = 1.5 * sini2;
      var f321 = 1.875 * sinim * (1.0 - (2.0 * cosim) - (3.0 * cosisq));
      var f322 = -1.875 * sinim * (1.0 + (2.0 * cosim) - (3.0 * cosisq));
      var f441 = 35.0 * sini2 * f220;
      var f442 = 39.3750 * sini2 * sini2;

      var f522 = 9.84375 *
          sinim *
          ((sini2 * (1.0 - (2.0 * cosim) - (5.0 * cosisq))) +
              (0.33333333 * (-2.0 + (4.0 * cosim) + (6.0 * cosisq))));
      var f523 = sinim *
          ((4.92187512 * sini2 * (-2.0 - (4.0 * cosim) + (10.0 * cosisq))) +
              (6.56250012 * (1.0 + (2.0 * cosim) - (3.0 * cosisq))));
      var f542 = 29.53125 *
          sinim *
          (2.0 -
              (8.0 * cosim) +
              (cosisq * (-12.0 + (8.0 * cosim) + (10.0 * cosisq))));
      var f543 = 29.53125 *
          sinim *
          (-2.0 -
              (8.0 * cosim) +
              (cosisq * (12.0 + (8.0 * cosim) - (10.0 * cosisq))));

      var xno2 = nm * nm;
      var ainv2 = aonv * aonv;
      var temp1 = 3.0 * xno2 * ainv2;
      var temp = temp1 * root22;
      d2201 = temp * f220 * g201;
      d2211 = temp * f221 * g211;
      temp1 *= aonv;
      temp = temp1 * root32;
      d3210 = temp * f321 * g310;
      d3222 = temp * f322 * g322;
      temp1 *= aonv;
      temp = 2.0 * temp1 * root44;
      d4410 = temp * f441 * g410;
      d4422 = temp * f442 * g422;
      temp1 *= aonv;
      temp = temp1 * root52;
      d5220 = temp * f522 * g520;
      d5232 = temp * f523 * g532;
      temp = 2.0 * temp1 * root54;
      d5421 = temp * f542 * g521;
      d5433 = temp * f543 * g533;
      xlamo = (mo + nodeo + nodeo - (theta + theta)) % _twoPi;
      xfact = mdot + dmdt + (2.0 * (nodedot + dnodt - rptim)) - no;
      em = emo;
      emsq = emsqo;
    }

    //  ---------------- synchronous resonance terms --------------
    if (irez == 1) {
      var g200 = 1.0 + (emsq * (-2.5 + (0.8125 * emsq)));
      var g310 = 1.0 + (2.0 * emsq);
      var g300 = 1.0 + (emsq * (-6.0 + (6.60937 * emsq)));
      var f220 = 0.75 * (1.0 + cosim) * (1.0 + cosim);
      var f311 = (0.9375 * sinim * sinim * (1.0 + (3.0 * cosim))) -
          (0.75 * (1.0 + cosim));
      var f330 = 1.0 + cosim;

      f330 *= 1.875 * f330 * f330;
      del1 = 3.0 * nm * nm * aonv * aonv;
      del2 = 2.0 * del1 * f220 * g200 * q22;
      del3 = 3.0 * del1 * f330 * g300 * q33 * aonv;
      del1 = del1 * f311 * g310 * q31 * aonv;
      xlamo = (mo + nodeo + argpo - theta) % _twoPi;
      xfact = mdot + xpidot + dmdt + domdt + dnodt - (no + rptim);
    }

    //  ------------ for sgp4, initialize the integrator ----------
    xli = xlamo;
    xni = no;
    atime = 0.0;
    nm = no + dndt;
  }

  return _DsInitResult(
      em: em,
      argpm: argpm,
      inclm: inclm,
      mm: mm,
      nm: nm,
      nodem: nodem,
      irez: irez,
      atime: atime,
      d2201: d2201,
      d2211: d2211,
      d3210: d3210,
      d3222: d3222,
      d4410: d4410,
      d4422: d4422,
      d5220: d5220,
      d5232: d5232,
      d5421: d5421,
      d5433: d5433,
      dedt: dedt,
      didt: didt,
      dmdt: dmdt,
      dndt: dndt,
      dnodt: dnodt,
      domdt: domdt,
      del1: del1,
      del2: del2,
      del3: del3,
      xfact: xfact,
      xlamo: xlamo,
      xli: xli,
      xni: xni);
}

const double _twoPi = pi * 2;
const double _deg2rad = pi / 180.0;
const double _x2o3 = 2.0 / 3.0;
const double _xpdotp = 1440.0 / (2.0 * pi); // 229.1831180523293;
