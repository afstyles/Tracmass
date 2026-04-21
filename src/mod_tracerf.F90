MODULE mod_tracerf

  !!------------------------------------------------------------------------------
  !!
  !!       MODULE: mod_tracerf
  !!
  !!       This module includes functions and subroutines to compute tracers
  !!       - thermo_dens0
  !!
  !!------------------------------------------------------------------------------

  USE mod_grid, only: imt, jmt, km

  IMPLICIT NONE

  CONTAINS

  FUNCTION thermo_dens0(T,S)
  ! --------------------------------------------------
  !
  ! Purpose:
  ! Compute sigma 0 density
  !
  ! Method:
  ! Compute the sigma 0 densitybased on the 1980
  ! equation of state (EOS-80)
  !
  ! --------------------------------------------------

      IMPLICIT NONE

      REAL, INTENT(IN)                         :: T(:,:,:)      ! Potential T [degC]
      REAL, INTENT(IN)                         :: S(:,:,:)      ! Practical S [PSU]

      REAL, ALLOCATABLE, DIMENSION (:,:,:)     :: T68

      REAL, ALLOCATABLE, DIMENSION (:,:,:)     :: thermo_dens0

      REAL, ALLOCATABLE, DIMENSION (:,:,:)     :: dens_temp

      INTEGER                                  :: nx, ny, nz

      REAL, PARAMETER                          :: a0 = 999.842594
      REAL, PARAMETER                          :: a1 =   6.793952e-2
      REAL, PARAMETER                          :: a2 =  -9.095290e-3
      REAL, PARAMETER                          :: a3 =   1.001685e-4
      REAL, PARAMETER                          :: a4 =  -1.120083e-6
      REAL, PARAMETER                          :: a5 =   6.536332e-9

      REAL, PARAMETER                          :: b0 =  8.24493e-1
      REAL, PARAMETER                          :: b1 = -4.0899e-3
      REAL, PARAMETER                          :: b2 =  7.6438e-5
      REAL, PARAMETER                          :: b3 = -8.2467e-7
      REAL, PARAMETER                          :: b4 =  5.3875e-9

      REAL, PARAMETER                          :: c0 = -5.72466e-3
      REAL, PARAMETER                          :: c1 = +1.0227e-4
      REAL, PARAMETER                          :: c2 = -1.6546e-6

      REAL, PARAMETER                          :: d0 = 4.8314e-4

      ! Size of array
      nx = SIZE(S,1); ny = SIZE(S,2); nz = SIZE(S,3);

      ALLOCATE( dens_temp(nx,ny,nz) ,thermo_dens0(nx,ny,nz), T68(nx,ny,nz) )

      ! Correct T to IPTS-68 standard
      T68 = 1.00024 * T

      dens_temp = a0+(a1+(a2+(a3+(a4+a5*T68)*T68)*T68)*T68)*T68
      thermo_dens0  = dens_temp &
           + (b0+(b1+(b2+(b3+b4*T68)*T68)*T68)*T68)*S &
           + (c0+(c1+c2*T68)*T68)*S*SQRT(S) + d0*S**2

  END FUNCTION thermo_dens0

  FUNCTION thermo_dens0_teos10(T,S)
  ! --------------------------------------------------
  !
  ! Purpose:
  ! Compute sigma 0 density
  !
  ! Method:
  ! Compute the sigma 0 density using the TEOS-10 
  ! equation of state
  !
  ! --------------------------------------------------
    IMPLICIT NONE

    REAL, INTENT(IN)                         :: T(:,:,:)      ! Conservative  T [degC]
    REAL, INTENT(IN)                         :: S(:,:,:)      ! Absolute S [g/kg]
    INTEGER                                  :: nx, ny, nz    ! Size of array
    INTEGER                                  :: ii, ij, ik    ! Dummy indices
    REAL                                     :: zt, zs, zn0   ! Dummy t,s and density
    REAL, ALLOCATABLE, DIMENSION (:,:,:)     :: thermo_dens0_teos10

    REAL, PARAMETER                          :: r1_T0 = 1./40.
    REAL, PARAMETER                          :: r1_S0 = 0.875/35.16504
    REAL, PARAMETER                          :: rdeltaS = 32.0
    REAL, PARAMETER                          :: EOS000 = 8.0189615746e+02
    REAL, PARAMETER                          :: EOS100 = 8.6672408165e+02
    REAL, PARAMETER                          :: EOS200 = -1.7864682637e+03
    REAL, PARAMETER                          :: EOS300 = 2.0375295546e+03
    REAL, PARAMETER                          :: EOS400 = -1.2849161071e+03
    REAL, PARAMETER                          :: EOS500 = 4.3227585684e+02
    REAL, PARAMETER                          :: EOS600 = -6.0579916612e+01
    REAL, PARAMETER                          :: EOS010 = 2.6010145068e+01
    REAL, PARAMETER                          :: EOS110 = -6.5281885265e+01
    REAL, PARAMETER                          :: EOS210 = 8.1770425108e+01
    REAL, PARAMETER                          :: EOS310 = -5.6888046321e+01
    REAL, PARAMETER                          :: EOS410 = 1.7681814114e+01
    REAL, PARAMETER                          :: EOS510 = -1.9193502195
    REAL, PARAMETER                          :: EOS020 = -3.7074170417e+01
    REAL, PARAMETER                          :: EOS120 = 6.1548258127e+01
    REAL, PARAMETER                          :: EOS220 = -6.0362551501e+01
    REAL, PARAMETER                          :: EOS320 = 2.9130021253e+01
    REAL, PARAMETER                          :: EOS420 = -5.4723692739
    REAL, PARAMETER                          :: EOS030 = 2.1661789529e+01
    REAL, PARAMETER                          :: EOS130 = -3.3449108469e+01
    REAL, PARAMETER                          :: EOS230 = 1.9717078466e+01
    REAL, PARAMETER                          :: EOS330 = -3.1742946532
    REAL, PARAMETER                          :: EOS040 = -8.3627885467
    REAL, PARAMETER                          :: EOS140 = 1.1311538584e+01
    REAL, PARAMETER                          :: EOS240 = -5.3563304045
    REAL, PARAMETER                          :: EOS050 = 5.4048723791e-01
    REAL, PARAMETER                          :: EOS150 = 4.8169980163e-01
    REAL, PARAMETER                          :: EOS060 = -1.9083568888e-01

    ! Size of array
    nx = SIZE(S,1); ny = SIZE(S,2); nz = SIZE(S,3);

    ALLOCATE( thermo_dens0_teos10(nx,ny,nz) )

    DO ik = 1,km
      DO ij = 1,jmt
        DO ii = 1, imt
          !
          zt = T(ii, ij, ik) * r1_T0
          zs = SQRT( ABS( S(ii, ij, ik) + rdeltaS ) * r1_S0 )

          zn0 = (((((EOS060*zt   &
          &   + EOS150*zs+EOS050)*zt   &
          &   + (EOS240*zs+EOS140)*zs+EOS040)*zt   &
          &   + ((EOS330*zs+EOS230)*zs+EOS130)*zs+EOS030)*zt   &
          &   + (((EOS420*zs+EOS320)*zs+EOS220)*zs+EOS120)*zs+EOS020)*zt   &
          &   + ((((EOS510*zs+EOS410)*zs+EOS310)*zs+EOS210)*zs+EOS110)*zs+EOS010)*zt   &
          &   + (((((EOS600*zs+EOS500)*zs+EOS400)*zs+EOS300)*zs+EOS200)*zs+EOS100)*zs+EOS000
          !
          thermo_dens0_teos10(ii,ij,ik) = zn0
          
        END DO
      END DO
    END DO

  END FUNCTION thermo_dens0_teos10

  FUNCTION thermo_pt2ct(T,S)
  ! --------------------------------------------------
  !
  ! Purpose:
  ! Compute conservative temperature from Potential
  ! temperature
  !
  ! Method:
  ! TEOS_10 method gsw_ct_fron_pt
  !
  ! --------------------------------------------------

      IMPLICIT NONE

      REAL, INTENT(IN)                         :: T(:,:,:)      ! Potential T [degC]
      REAL, INTENT(IN)                         :: S(:,:,:)      ! Absolut S   [g/kg]

      REAL, ALLOCATABLE, DIMENSION (:,:,:)     :: thermo_pt2ct

      REAL, ALLOCATABLE, DIMENSION (:,:,:)     :: ct_temp, xS, xS2, yT

      REAL, PARAMETER                          :: gsw_sfac = 0.0248826675584615
      REAL, PARAMETER                          :: gsw_cp0  = 3991.86795711963

      INTEGER                                  :: nx, ny, nz

      ! Size of array
      nx = SIZE(S,1); ny = SIZE(S,2); nz = SIZE(S,3);

      ALLOCATE(thermo_pt2ct(nx,ny,nz), ct_temp(nx,ny,nz), xS(nx,ny,nz), xS2(nx,ny,nz), yT(nx,ny,nz))

      ! Calculation
      xS  = gsw_sfac*S
      xS2 = SQRT(xS)
      yT  = T*0.025        ! normalize for F03 and F08

      ct_temp =  61.01362420681071 + yT*(168776.46138048015 + &
                     yT*(-2735.2785605119625 + yT*(2574.2164453821433 + &
                     yT*(-1536.6644434977543 + yT*(545.7340497931629 + &
                     (-50.91091728474331 - 18.30489878927802*yT)*yT))))) + &
                     xS2*(268.5520265845071 + yT*(-12019.028203559312 + &
                     yT*(3734.858026725145 + yT*(-2046.7671145057618 + &
                     yT*(465.28655623826234 + (-0.6370820302376359 - &
                     10.650848542359153*yT)*yT)))) + &
                     xS*(937.2099110620707 + yT*(588.1802812170108 + &
                     yT*(248.39476522971285 + (-3.871557904936333 - &
                     2.6268019854268356*yT)*yT)) + &
                     xS*(-1687.914374187449 + xS*(246.9598888781377 + &
                     xS*(123.59576582457964 - 48.5891069025409*xS)) + &
                     yT*(936.3206544460336 + &
                     yT*(-942.7827304544439 + yT*(369.4389437509002 + &
                     (-33.83664947895248 - 9.987880382780322*yT)*yT))))))

      thermo_pt2ct = ct_temp/gsw_cp0

  END FUNCTION thermo_pt2ct

END MODULE mod_tracerf
