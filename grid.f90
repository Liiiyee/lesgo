
!**********************************************************************
module grid_defs
!**********************************************************************
use types, only : rprec
implicit none
save
private
!public x, y, z, zw, grid_build, grid_built
!public autowrap_i, autowrap_j
public grid_t, grid_build

type grid
  logical :: built
  real(rprec), pointer, dimension(:) :: x, y, z, zw
  integer, pointer, dimension(:) :: autowrap_i, autowrap_j
end type grid

type(grid) :: grid_t
!real(rprec), allocatable, dimension(:) :: x, y, z, zw
! These need to be used in conjunction with modulo


contains

!**********************************************************************
subroutine grid_build()
!**********************************************************************
!
!  This subroutine creates the uv grid for the domain. It uses the x,y,z
!  variables decalared in grid_defs. This subroutine should only be called
!  once. To use x,y,z elsewhere in the code make sure
!  
!  use grid_defs, only : x,y,z 
!  
!  is placed in the routine
!  
use param, only : nx,ny,nz,dx,dy,dz,coord
implicit none

integer :: i,j,k
real(rprec), pointer, dimension(:) :: x,y,z,zw
integer, pointer, dimension(:) :: autowrap_i, autowrap_j

grid_t % built = .false.

! Set pointers
x => grid_t % x
y => grid_t % y
z => grid_t % z
zw => grid_t %zw

autowrap_i => grid_t % autowrap_i
autowrap_j => grid_t % autowrap_j

$if ($MPI)
  !--this dimensioning adds a ghost layer for finite differences
  !--its simpler to have all arrays dimensioned the same, even though
  !  some components do not need ghost layer
  $define $lbz 0
$else
  $define $lbz 1
$endif

!  x and y go to nx+1, ny+1 respectively for adding
!  the buffered points for periodicity
allocate(x(nx+1),y(ny+1),z($lbz:nz),zw($lbz:nz))
allocate(autowrap_i(0:nx+1), autowrap_j(0:ny+1))

do k=$lbz,nz
  $if ($MPI)
  z(k) = (coord*(nz-1) + k - 0.5_rprec) * dz
  $else
  z(k) = (k - 0.5_rprec) * dz
  $endif
enddo
do j=1,ny+1
  y(j) = (j-1)*dy
enddo
do i=1,nx+1
  x(i) = (i - 1)*dx
enddo
zw = z - dz/2._rprec

! Set index autowrapping arrays
autowrap_i(0) = nx
autowrap_j(0) = ny
autowrap_i(nx+1) = 1
autowrap_j(ny+1) = 1
do i=1,nx; autowrap_i(i) = i; enddo
do j=1,ny; autowrap_j(j) = j; enddo
     
grid_t % built = .true. 

nullify(x,y,z,zw)
nullify(autowrap_i,autowrap_j)

return
end subroutine grid_build 

end module grid_defs
