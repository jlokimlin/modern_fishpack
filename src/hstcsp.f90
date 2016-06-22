!
!     file hstcsp.f90
!
!     * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
!     *                                                               *
!     *                  copyright (c) 2005 by UCAR                   *
!     *                                                               *
!     *       University Corporation for Atmospheric Research         *
!     *                                                               *
!     *                      all rights reserved                      *
!     *                                                               *
!     *                    FISHPACK90  Version 1.1                    *
!     *                                                               *
!     *                      A Package of Fortran                     *
!     *                                                               *
!     *                Subroutines and Example Programs               *
!     *                                                               *
!     *               for Modeling Geophysical Processes              *
!     *                                                               *
!     *                             by                                *
!     *                                                               *
!     *        John Adams, Paul Swarztrauber and Roland Sweet         *
!     *                                                               *
!     *                             of                                *
!     *                                                               *
!     *         the National Center for Atmospheric Research          *
!     *                                                               *
!     *                Boulder, Colorado  (80307)  U.S.A.             *
!     *                                                               *
!     *                   which is sponsored by                       *
!     *                                                               *
!     *              the National Science Foundation                  *
!     *                                                               *
!     * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
!
!     SUBROUTINE hstcsp(intl, a, b, m, mbdcnd, bda, bdb, c, d, n, nbdcnd, bdc,
!                       bdd, elmbda, f, idimf, pertrb, ierror, w)
!
!
! DIMENSION OF           bda(n), bdb(n), bdc(m), bdd(m), f(idimf, n)
! ARGUMENTS
!
! LATEST REVISION        May 2016
!
! PURPOSE                Solves the standard five-point finite
!                        difference approximation on a staggered
!                        grid to the modified helmholtz equation in
!                        spherical coordinates assuming axisymmetry
!                        (no dependence on longitude).
!
!                        the equation is
!
!                           (1/r**2)(d/dr)(r**2(du/dr)) +
!                           1/(r**2*sin(theta))(d/dtheta)
!                           (sin(theta)(du/dtheta)) +
!                           (lambda/(r*sin(theta))**2)u  =  f(theta, r)
!
!                        where theta is colatitude and r is the
!                        radial coordinate. this two-dimensional
!                        modified helmholtz equation results from
!                        the fourier transform of the three-
!                        dimensional poisson equation.
!
!
! USAGE                  call hstcsp(intl, a, b, m, mbdcnd, bda, bdb, c, d, n,
!                                    nbdcnd, bdc, bdd, elmbda, f, idimf,
!                                    pertrb, ierror, w)
!
! ARGUMENTS
!  ON INPUT              intl
!
!                          = 0  on initial entry to hstcsp or if any
!                               of the arguments c, d, n, or nbdcnd
!                               are changed from a previous call
!
!                          = 1  if c, d, n, and nbdcnd are all
!                               unchanged from previous call to hstcsp
!
!                          note:
!                          a call with intl = 0 takes approximately
!                          1.5 times as much time as a call with
!                          intl = 1.  once a call with intl = 0
!                          has been made then subsequent solutions
!                          corresponding to different f, bda, bdb,
!                          bdc, and bdd can be obtained faster with
!                          intl = 1 since initialization is not
!                          repeated.
!
!                        a, b
!                          the range of theta (colatitude),
!                          i.e. a <= theta <= b.  a
!                          must be less than b and a must be
!                          non-negative.  a and b are in radians.
!                          a = 0 corresponds to the north pole and
!                          b = pi corresponds to the south pole.
!
!                          * * *  important  * * *
!
!                          if b is equal to pi, then b must be
!                          computed using the statement
!                              b = pi_mach(dum)
!                          this insures that b in the user's program
!                          is equal to pi in this program, permitting
!                          several tests of the input parameters that
!                          otherwise would not be possible.
!
!                          * * * * * * * * * * * *
!
!                        m
!                          the number of grid points in the interval
!                          (a, b).  the grid points in the theta-
!                          direction are given by
!                            theta(i) = a + (i-0.5)dtheta
!                          for i=1, 2, ..., m where dtheta =(b-a)/m.
!                          m must be greater than 4.
!
!                        mbdcnd
!                          indicates the type of boundary conditions
!                          at theta = a and theta = b.
!
!                          = 1  if the solution is specified at
!                               theta = a and theta = b.
!                               (see notes 1, 2 below)
!
!                          = 2  if the solution is specified at
!                               theta = a and the derivative of the
!                               solution with respect to theta is
!                               specified at theta = b
!                               (see notes 1, 2 below).
!
!                          = 3  if the derivative of the solution
!                               with respect to theta is specified
!                               at theta = a (see notes 1, 2 below)
!                               and theta = b.
!
!                          = 4  if the derivative of the solution
!                               with respect to theta is specified at
!                               theta = a (see notes 1, 2 below) and
!                               the solution is specified at theta = b.
!
!                          = 5  if the solution is unspecified at
!                               theta = a = 0 and the solution is
!                               specified at theta = b.
!                               (see note 2 below)
!
!                          = 6  if the solution is unspecified at
!                               theta = a = 0 and the derivative of
!                               the solution with respect to theta is
!                               specified at theta = b
!                               (see note 2 below).
!
!                          = 7  if the solution is specified at
!                               theta = a and the solution is
!                               unspecified at theta = b = pi.
!
!                          = 8  if the derivative of the solution
!                               with respect to theta is specified at
!                               theta = a (see note 1 below)
!                               and the solution is unspecified at
!                               theta = b = pi.
!
!                          = 9  if the solution is unspecified at
!                                theta = a = 0 and theta = b = pi.
!
!                          note 1:
!                          if a = 0, do not use mbdcnd = 1, 2, 3, 4, 7
!                          or 8, but instead use mbdcnd = 5, 6, or 9.
!
!                          note 2:
!                          if b = pi, do not use mbdcnd = 1, 2, 3, 4, 5,
!                          or 6, but instead use mbdcnd = 7, 8, or 9.
!
!                          note 3:
!                          when a = 0  and/or b = pi the only
!                          meaningful boundary condition is
!                          du/dtheta = 0.   see d. greenspan,
!                          'numerical analysis of elliptic
!                           boundary value problems, '
!                          harper and row, 1965, chapter 5.)
!
!                        bda
!                          a one-dimensional array of length n that
!                          specifies the boundary values (if any) of
!                          the solution at theta = a.
!
!                          when  mbdcnd = 1, 2, or 7,
!                            bda(j) = u(a, r(j)),   j=1, 2, ..., n.
!
!                          when mbdcnd = 3, 4, or 8,
!                            bda(j) = (d/dtheta)u(a, r(j)), j=1, 2, ..., n.
!
!                          when mbdcnd has any other value, bda is a
!                          dummy variable.
!
!                        bdb
!                          a one-dimensional array of length n that
!                          specifies the boundary values of the
!                          solution at theta = b.
!
!                          when mbdcnd = 1, 4, or 5,
!                            bdb(j) = u(b, r(j)),     j=1, 2, ..., n.
!
!                          when mbdcnd = 2, 3, or 6,
!                            bdb(j) = (d/dtheta)u(b, r(j)), j=1, 2, ..., n.
!
!                          when mbdcnd has any other value, bdb is
!                          a dummy variable.
!
!                        c, d
!                          the range of r , i.e. c <= r <= d.
!                          c must be less than d and non-negative.
!
!                        n
!                          the number of unknowns in the interval
!                          (c, d).  the unknowns in the r-direction
!                          are given by r(j) = c + (j-0.5)dr,
!                          j=1, 2, ..., n, where dr = (d-c)/n.
!                          n must be greater than 4.
!
!                        nbdcnd
!                          indicates the type of boundary conditions
!                          at r = c and r = d.
!
!
!                          = 1  if the solution is specified at
!                               r = c and r = d.
!
!                          = 2  if the solution is specified at
!                               r = c and the derivative of the
!                               solution with respect to r is
!                               specified at r = d. (see note 1 below)
!
!                          = 3  if the derivative of the solution
!                               with respect to r is specified at
!                               r = c and r = d.
!
!                          = 4  if the derivative of the solution
!                               with respect to r is
!                               specified at r = c and the solution
!                               is specified at r = d.
!
!                          = 5  if the solution is unspecified at
!                               r = c = 0 (see note 2 below) and the
!                               solution is specified at r = d.
!
!                          = 6  if the solution is unspecified at
!                               r = c = 0 (see note 2 below)
!                               and the derivative of the solution
!                               with respect to r is specified at
!                               r = d.
!
!                          note 1:
!                          if c = 0 and mbdcnd = 3, 6, 8 or 9, the
!                          system of equations to be solved is
!                          singular.  the unique solution is
!                          determined by extrapolation to the
!                          specification of u(theta(1), c).
!                          but in these cases the right side of the
!                          system will be perturbed by the constant
!                          pertrb.
!
!                          note 2:
!                          nbdcnd = 5 or 6 cannot be used with
!                          mbdcnd =1, 2, 4, 5, or 7
!                          (the former indicates that the solution is
!                          unspecified at r = 0; the latter indicates
!                          solution is specified).
!                          use instead nbdcnd = 1 or 2.
!
!                        bdc
!                          a one dimensional array of length m that
!                          specifies the boundary values of the
!                          solution at r = c.  when nbdcnd = 1 or 2,
!                            bdc(i) = u(theta(i), c),    i=1, 2, ..., m.
!
!                          when nbdcnd = 3 or 4,
!                            bdc(i) = (d/dr)u(theta(i), c), i=1, 2, ..., m.
!
!                          when nbdcnd has any other value, bdc is
!                          a dummy variable.
!
!                        bdd
!                          a one-dimensional array of length m that
!                          specifies the boundary values of the
!                          solution at r = d.  when nbdcnd = 1 or 4,
!                            bdd(i) = u(theta(i), d) ,    i=1, 2, ..., m.
!
!                          when nbdcnd = 2 or 3,
!                            bdd(i) = (d/dr)u(theta(i), d), i=1, 2, ..., m.
!
!                          when nbdcnd has any other value, bdd is
!                          a dummy variable.
!
!                        elmbda
!                          the constant lambda in the modified
!                          helmholtz equation.  if lambda is greater
!                          than 0, a solution may not exist.
!                          however, hstcsp will attempt to find a
!                          solution.
!
!                        f
!                          a two-dimensional array that specifies the
!                          values of the right side of the modified
!                          helmholtz equation.  for i=1, 2, ..., m and
!                          j=1, 2, ..., n
!
!                                f(i, j) = f(theta(i), r(j)) .
!
!                          f must be dimensioned at least m x n.
!
!                        idimf
!                          the row (or first) dimension of the array
!                          f as it appears in the program calling
!                          hstcsp.  this parameter is used to specify
!                          the variable dimension of f.
!                          idimf must be at least m.
!
!                        w
!                          A derived type (FishpackWorkspace) variable
!                          that must be declared by the user.  the first
!                          two declarative statements in the user program
!                          calling hstcsp must be:
!
!                               use type_fishpackworkspace
!                               type (FishpackWorkspace) :: w
!
!                          the first statement makes the fishpack module
!                          defined in the file "type_fishpackworkspace.f90" available to the
!                          user program calling hstcsp.  the second statement
!                          declares a derived type variable (defined in
!                          the module "type_fishpackworkspace.f90") which is used internally
!                          in blktri to dynamically allocate real and complex
!                          work space used in solution.  an error flag
!                          (ierror = 20) is set if the required work space
!                          allocation fails (for example if n, m are too large)
!                          real and complex values are set in the components
!                          of w on a initial (iflg=0) call to hstcsp.  these
!                          must be preserved on non-initial calls (intl=1)
!                          to hstcsp.  this eliminates redundant calculations
!                          and saves compute time.
!
!               ****       IMPORTANT!  the user program calling hstcsp should
!                          include the statement:
!
!                               call w%destroy()
!
!                          after the final approximation is generated by
!                          hstcsp.  the will deallocate the real and complex
!                          work space of w.  failure to include this statement
!                          could result in serious memory leakage.
!
!
!
! ON OUTPUT              f
!                          contains the solution u(i, j) of the finite
!                          difference approximation for the grid point
!                          (theta(i), r(j)) for i=1, 2, .., m, j=1, 2, ..., n.
!
!                        pertrb
!                          if a combination of periodic, derivative,
!                          or unspecified boundary conditions is
!                          specified for a poisson equation
!                          (lambda = 0), a solution may not exist.
!                          pertrb is a constant, calculated and
!                          subtracted from f, which ensures that a
!                          solution exists.  hstcsp then computes this
!                          solution, which is a least squares solution
!                          to the original approximation.
!                          this solution plus any constant is also
!                          a solution; hence, the solution is not
!                          unique.  the value of pertrb should be
!                          small compared to the right side f.
!                          otherwise, a solution is obtained to an
!                          essentially different problem.
!                          this comparison should always be made to
!                          insure that a meaningful solution has been
!                          obtained.
!
!                        ierror
!                          an error flag that indicates invalid input
!                          parameters. except for numbers 0 and 10,
!                          a solution is not attempted.
!
!                          =  0  no error
!
!                          =  1  a < 0 or b > pi
!
!                          =  2  a >= b
!
!                          =  3  mbdcnd < 1 or mbdcnd > 9
!
!                          =  4  c < 0
!
!                          =  5  c >= d
!
!                          =  6  nbdcnd < 1 or nbdcnd > 6
!
!                          =  7  n < 5
!
!                          =  8  nbdcnd = 5 or 6 and
!                                mbdcnd = 1, 2, 4, 5, or 7
!
!                          =  9  c > 0 and nbdcnd >= 5
!
!                          = 10  elmbda > 0
!
!                          = 11  idimf < m
!
!                          = 12  m < 5
!
!                          = 13  a = 0 and mbdcnd =1, 2, 3, 4, 7 or 8
!
!                          = 14  b = pi and mbdcnd <= 6
!
!                          = 15  a > 0 and mbdcnd = 5, 6, or 9
!
!                          = 16  b < pi and mbdcnd >= 7
!
!                          = 17  lambda /= 0 and nbdcnd >= 5
!
!                          since this is the only means of indicating
!                          a possibly incorrect call to hstcsp,
!                          the user should test ierror after the call.
!
!                        = 20 If the dynamic allocation of real and
!                             complex work space in the derived type
!                             (FishpackWorkspace) variable w fails (e.g.,
!                             if n, m are too large for the platform used)
!
!                        w
!                             The derived type (FishpackWorkspace) variable w
!                             contains real and complex values that must not
!                             be destroyed if hstcsp is called again with
!                             iflg=1.
!
!
! I/O                    None
!
! PRECISION              64-bit double precision
!
! REQUIRED LIBRARY       type_FishpackWorkspace.f90, blktri.f90, comf.f90
! FILES
!
! HISTORY                * Written by Roland Sweet at NCAR in 1977.
!                          released on NCAR's public software libraries
!                          in January 1980.
!                        * Revised by John Adams in June
!                          2004 using Fortan 90 dynamically allocated work
!                          space and derived data types to eliminate mixed
!                          mode conflicts in the earlier versions.
!
! STANDARD               Fortran 2008
!
! ALGORITHM              This subroutine defines the finite-difference
!                        equations, incorporates boundary data, adjusts
!                        the right side when the system is singular
!                        and calls blktri which solves the linear
!                        system of equations.
!
!
! TIMING                 For large m and n, the operation count is
!                        roughly proportional to
!
!                        m*n*log2(n).
!
!                        The timing also depends on input parameter intl.
!
! ACCURACY               The solution process employed results in
!                        a loss of no more than four significant
!                        digits for n and m as large as 64.
!                        more detailed information about accuracy
!                        can be found in the documentation for
!                        subroutine blktri which is the routine
!                        solves the finite difference equations.
!
! REFERENCES             P.N. Swarztrauber, "A direct method for
!                        the discrete solution of separable elliptic
!                        equations", SIAM J. Numer. Anal. 11(1974),
!                        pp. 1136-1150.
!
!                        U. Schumann and R. Sweet, "A direct method for
!                        the solution of poisson's equation with neumann
!                        boundary conditions on a staggered grid of
!                        arbitrary size, " J. Comp. Phys. 20(1976), 
!                        pp. 171-182.
!
module module_hstcsp

    use, intrinsic :: iso_fortran_env, only: &
        wp => REAL64, &
        ip => INT32, &
        stdout => OUTPUT_UNIT

    use type_FishpackWorkspace, only: &
        Fish => FishpackWorkspace

    use module_blktri, only:&
        blktrii

    ! Explicit typing only
    implicit None

    ! Everything is private unless stated otherwise
    private
    public :: hstcsp


contains


    subroutine hstcsp(intl, a, b, m, mbdcnd, bda, bdb, c, d, n, nbdcnd, &
        bdc, bdd, elmbda, f, idimf, pertrb, ierror, w)
        !-----------------------------------------------
        ! Dictionary: calling arguments
        !-----------------------------------------------
        integer (ip), intent (in out) :: intl
        integer (ip), intent (in)     :: m
        integer (ip), intent (in)     :: mbdcnd
        integer (ip), intent (in)     :: n
        integer (ip), intent (in)     :: nbdcnd
        integer (ip), intent (in)     :: idimf
        integer (ip), intent (out)    :: ierror
        real (wp),    intent (in)     :: a
        real (wp),    intent (in)     :: b
        real (wp),    intent (in)     :: c
        real (wp),    intent (in)     :: d
        real (wp),    intent (in)     :: elmbda
        real (wp),    intent (out)    :: pertrb
        real (wp),    intent (in)     :: bda(:)
        real (wp),    intent (in)     :: bdb(:)
        real (wp),    intent (in)     :: bdc(:)
        real (wp),    intent (in)     :: bdd(:)
        real (wp),    intent (in out) :: f(:,:)
        class (Fish), intent (in out) :: w
        !-----------------------------------------------
        ! Dictionary: local variables
        !-----------------------------------------------
        integer (ip)         :: k, l, np, irwk, icwk, local_error_flag
        real (wp), parameter :: pi = acos(-1.0_wp)
        integer (ip), save   :: workspace_indices(8)
        !-----------------------------------------------

        !
        !==> Check for invalid input parameters
        !
        if (a < 0. .or. b > pi) then
            ierror = 1
            return
        else if (a >= b) then
            ierror = 2
            return
        else if (mbdcnd < 1 .or. mbdcnd > 9) then
            ierror = 3
            return
        else if (c < 0.0_wp) then
            ierror = 4
            return
        else if (c >= d) then
            ierror = 5
            return
        else if (nbdcnd < 1 .or. nbdcnd > 6) then
            ierror = 6
            return
        else if (n < 5) then
            ierror = 7
            return
        else if (&
            (nbdcnd == 5 .or. nbdcnd == 6) &
            .and. &
            (mbdcnd == 1 .or. mbdcnd == 2 .or. mbdcnd == 4 .or. mbdcnd == 5 .or. mbdcnd == 7)) &
            then
            ierror = 8
            return
        else if (c > 0. .and. nbdcnd >= 5) then
            ierror = 9
            return
        else if (idimf < m) then
            ierror = 11
            return
        else if (m < 5) then
            ierror = 12
            return
        else if (a == 0.0_wp .and. mbdcnd /= 5.and. mbdcnd /= 6.and. mbdcnd /= 9) then
            ierror=13
            return
        else if (b == pi .and. mbdcnd <= 6) then
            ierror = 14
            return
        else if (a > 0.0_wp .and. (mbdcnd == 5.or.mbdcnd == 6.or.mbdcnd == 9)) then
            ierror=15
            return
        else if (b < pi .and. mbdcnd >= 7) then
            ierror = 16
            return
        else if (elmbda /= 0.0_wp .and. nbdcnd >= 5) then
            ierror = 17
            return
        else
            ierror = 0
        end if

        associate( &
            iw1 => workspace_indices(1), &
            iwbm => workspace_indices(2), &
            iwcm => workspace_indices(3), &
            iwan => workspace_indices(4), &
            iwbn => workspace_indices(5), &
            iwcn => workspace_indices(6), &
            iwsnth => workspace_indices(7), &
            iwrsq => workspace_indices(8) &
            )

            if (intl == 0) then
                !
                !==> Compute workspace indices and required workspace sizes
                !
                k = m + 1
                l = n + 1
                np = nbdcnd
                !
                !==> Compute blktri requirements in irwk, icwk
                !
                call w%get_block_tridiagonal_workpace_dimensions(n, m, irwk, icwk)
                !
                !==> Set work space indices
                !
                iw1 = irwk + 1
                iwbm = iw1 + m
                iwcm = iwbm + m
                iwan = iwcm + m
                iwbn = iwan + n
                iwcn = iwbn + n
                iwsnth = iwcn + n
                iwrsq = iwsnth + m
                !
                !==>  Allocate workspace arrays
                !
                irwk = iwrsq + n
                icwk = icwk + 3*k
                call w%create(irwk, icwk, ierror)

                ! Check if allocation was successful
                if (ierror == 20) return

            end if

            ! Initialize error flag
            local_error_flag = 0

            associate( &
                rew => w%real_workspace, &
                cxw => w%complex_workspace &
                )

                !
                !==> Solve system
                !
                call hstcs1(intl, a, b, m, mbdcnd, bda, bdb, c, d, n, nbdcnd, bdc, bdd, &
                    elmbda, f, idimf, pertrb, local_error_flag, rew(iw1:), rew(iwbm:), rew(iwcm:), &
                    rew(iwan:), rew(iwbn:), rew(iwcn:), rew(iwsnth:), rew(iwrsq:), &
                    rew, cxw)

            end associate

            !
            !==>  Set error flag from lower routine
            !
            ierror = local_error_flag

        end associate


    contains

        subroutine hstcs1(intl, a, b, m, mbdcnd, bda, bdb, c, d, n, nbdcnd, &
            bdc, bdd, elmbda, f, idimf, pertrb, ierr1, am, bm, cm, an, bn, &
            cn, snth, rsq, w, wc)
            !-----------------------------------------------
            ! Dictionary: calling arguments
            !-----------------------------------------------
            integer (ip), intent (in)     :: intl
            integer (ip), intent (in)     :: m
            integer (ip), intent (in)     :: mbdcnd
            integer (ip), intent (in)     :: n
            integer (ip), intent (in)     :: nbdcnd
            integer (ip), intent (in)     :: idimf
            integer (ip), intent (out)    :: ierr1
            real (wp),    intent (in)     :: a
            real (wp),    intent (in)     :: b
            real (wp),    intent (in)     :: c
            real (wp),    intent (in)     :: d
            real (wp),    intent (in)     :: elmbda
            real (wp),    intent (out)    :: pertrb
            real (wp),    intent (in)     :: bda(:)
            real (wp),    intent (in)     :: bdb(:)
            real (wp),    intent (in)     :: bdc(:)
            real (wp),    intent (in)     :: bdd(:)
            real (wp),    intent (in out) :: f(idimf,n)
            real (wp),    intent (out)    :: am(:)
            real (wp),    intent (out)    :: bm(:)
            real (wp),    intent (out)    :: cm(:)
            real (wp),    intent (out)    :: an(:)
            real (wp),    intent (out)    :: bn(:)
            real (wp),    intent (out)    :: cn(:)
            real (wp),    intent (in out) :: snth(:)
            real (wp),    intent (in out) :: rsq(:)
            real (wp),    intent (in out) :: w(*)
            complex (wp), intent (in out) :: wc(*)
            !-----------------------------------------------
            ! Dictionary: local variables
            !-----------------------------------------------
            integer (ip) :: i, j, isw, nb
            real (wp)    :: dth, dthsq, dr, x, y, a2, a1, a3
            !-----------------------------------------------

            dth = (b - a)/m
            dthsq = dth**2

            do i = 1, m
                snth(i) = sin(a + (real(i, kind=wp) - 0.5_wp)*dth)
            end do

            dr = (d - c)/n

            do j = 1, n
                rsq(j) = (c + (real(j, kind=wp) - 0.5_wp)*dr)**2
            end do
            !
            !     multiply right side by r(j)**2
            !
            do j = 1, n
                x = rsq(j)
                f(:m, j) = x*f(:m, j)
            end do
            !
            !      define coefficients am, bm, cm
            !
            x = 1./(2.0_wp*cos(dth/2.))
            am(2:m) = (snth(:m-1)+snth(2:m))*x
            cm(:m-1) = am(2:m)
            am(1) = sin(a)
            cm(m) = sin(b)
            do i = 1, m
                x = 1./snth(i)
                y = x/dthsq
                am(i) = am(i)*y
                cm(i) = cm(i)*y
                bm(i) = elmbda*x*x - am(i) - cm(i)
            end do
            !
            !==> Define coefficients an, bn, cn
            !
            x = c/dr
            do j = 1, n
                an(j) = (x + real(j - 1, kind=wp))**2
                cn(j) = (x + real(j, kind=wp))**2
                bn(j) = -(an(j)+cn(j))
            end do
            isw = 1
            nb = nbdcnd

            if (c == 0. .and. nb == 2) nb = 6
            !
            !==> Enter data on theta boundaries
            !
            select case (mbdcnd)
                case (1:2, 7)
                    bm(1) = bm(1) - am(1)
                    x = 2.0_wp*am(1)
                    f(1, :n) = f(1, :n) - x*bda(:n)
                case (3:4, 8)
                    bm(1) = bm(1) + am(1)
                    x = dth*am(1)
                    f(1, :n) = f(1, :n) + x*bda(:n)
            end select

            select case (mbdcnd)
                case (1, 4:5)
                    bm(m) = bm(m) - cm(m)
                    x = 2.0_wp*cm(m)
                    f(m, :n) = f(m, :n) - x*bdb(:n)
                case (2:3, 6)
                    bm(m) = bm(m) + cm(m)
                    x = dth*cm(m)
                    f(m, :n) = f(m, :n) - x*bdb(:n)
            end select

            select case (nb)
                case (1:2)
                    bn(1) = bn(1) - an(1)
                    x = 2.0_wp*an(1)
                    f(:m, 1) = f(:m, 1) - x*bdc(:m)
                case (3:4)
                    bn(1) = bn(1) + an(1)
                    x = dr*an(1)
                    f(:m, 1) = f(:m, 1) + x*bdc(:m)
            end select

            select case (nb)
                case (1, 4:5)
                    bn(n) = bn(n) - cn(n)
                    x = 2.0_wp*cn(n)
                    f(:m, n) = f(:m, n) - x*bdd(:m)
                case (2:3, 6)
                    bn(n) = bn(n) + cn(n)
                    x = dr*cn(n)
                    f(:m, n) = f(:m, n) - x*bdd(:m)
            end select

            pertrb = 0.0_wp

            case_block: block
                select case (mbdcnd)
                    case (1:2, 4:5, 7)
                        exit case_block
                    case (3, 6, 8:9)
                        select case (nb)
                            case (1:2, 4:5)
                                exit case_block
                            case (3, 6)
                                if (elmbda >= 0.0_wp) then
                                    if (elmbda /= 0.0_wp) then
                                        ierr1 = 10
                                    else
                                        isw = 2
                                        do i = 1, m
                                            x = 0.0_wp
                                            x = sum(f(i, :n))
                                            pertrb = pertrb + x*snth(i)
                                        end do
                                        x = 0.0_wp
                                        x = sum(rsq(:n))
                                        pertrb = 2.0_wp*(pertrb*sin(dth/2.))/(x*(cos(a) - cos(b)))
                                        do j = 1, n
                                            x = rsq(j)*pertrb
                                            f(:m, j) = f(:m, j) - x
                                        end do
                                    end if
                                end if
                        end select
                end select
            end block case_block

            a2 = sum(f(:m, 1))
            a2 = a2/rsq(1)
            !
            !     initialize blktri
            !
            ierr1 = 0
            if (intl == 0) call blktrii(0, 1, n, an, bn, cn, 1, m, am, bm, cm, idimf, f, ierr1, w, wc)

            call blktrii(1, 1, n, an, bn, cn, 1, m, am, bm, cm, idimf, f, ierr1, w, wc)

            if (.not.(isw /=2 .or. c /= 0. .or. nbdcnd /= 2)) then
                a3 = 0.0_wp
                a1 = dot_product(snth(:m), f(:m, 1))
                a3 = sum(snth(:m))
                a1 = a1 + rsq(1)*a2/2

                if (mbdcnd == 3) a1=a1+(sin(b)*bdb(1)-sin(a)*bda(1))/(2.0_wp*(b-a))

                a1 = a1/a3
                a1 = bdc(1) - a1
                f(:m, :n) = f(:m, :n) + a1
            end if

        end subroutine hstcs1

    end subroutine hstcsp


end module module_hstcsp
!
! REVISION HISTORY
!
! September 1973    Version 1
! April     1976    Version 2
! January   1978    Version 3
! December  1979    Version 3.1
! February  1985    Documentation upgrade
! November  1988    Version 3.2, FORTRAN 77 changes
! June      2004    Version 5.0, Fortran 90 changes
!-----------------------------------------------------------------------
