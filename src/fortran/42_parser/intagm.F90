!{\src2tex{textfont=tt}}
!!****f* ABINIT/intagm
!! NAME
!! intagm
!!
!! FUNCTION
!! Search input 'string' for specific 'token'. Search depends on
!! input dataset through 'jdtset'. Then, return the information
!! mentioned after 'token'.
!! See the "notes" section
!!
!! COPYRIGHT
!! Copyright (C) 1998-2010 ABINIT group (DCA, XG, GMR).
!! This file is distributed under the terms of the
!! GNU General Public License, see ~abinit/COPYING
!! or http://www.gnu.org/copyleft/gpl.txt .
!! For the initials of contributors, see ~abinit/doc/developers/contributors.txt .
!!
!! INPUTS
!!  jdtset=see the notes section
!!  marr=dimension of the intarr and dprarr arrays, as declared in the
!!   calling subroutine.
!!  narr=actual size of array to be read in.
!!  string=character string containing 'tags' and data.
!!  typevarphys= variable type (might indicate the physical meaning of
!!   for dimensionality purposes)
!!   'INT'=>integer
!!   'DPR'=>real(dp) (no special treatment)
!!   'LEN'=>real(dp) (expect a "length", identify bohr, au or angstrom,
!!       and return in au -atomic units=bohr- )
!!   'ENE'=>real(dp) (expect a "energy", identify Ha, hartree, eV, Ry, Rydberg)
!!   'LOG'=>integer, but read logical variable T,F,.true., or .false.
!!   'KEY'=>character, returned in token
!!
!! OUTPUT
!!  intarr(1:narr), dprarr(1:narr)
!!   integer or real(dp) arrays, respectively (see typevarphys),
!!   into which data is read if typevarphys/='KEY'. Use these arrays even for scalars.
!!  tread is an integer : tread = 0 => no data was read
!!                        tread = 1 => data was read
!!  ds_input is an optional integer flag:
!!           ds_input = 0 => value was found which is not specific to jdtset
!!           ds_input > 0 => value was found which is specific to jdtset
!!   one could add more information, eg whether a ? or a : was used, etc...
!!
!! SIDE EFFECTS
!!  token=at input  : character string for 'tag'.
!!                    Assumed no longer than fnlen-4 characters
!!                    (affects dimension of 'cs' used in character assignment statement).
!!        at output : chain of character replacing the 'tag'  (only if typevarphys='KEY')
!!
!! NOTES
!!
!! If jdtset==0 :
!!
!!  Search compressed 'string' for blank//'token'//blank and
!!  read input data beside 'token', to be read into appropriate variable.
!!  For this routine to find a given token, the token has to be preceded
!!  and followed by blanks--i.e. the first token should not start out as
!!  the first character in the input file.  This is checked in the calling
!!  subroutine 'input'. Calls inread which performs internal read from
!!  specified string.  Also calls upper which maps characters to all upper case.
!!  Also checks whether there is an occurence of blank//'token'//digit,
!!  in which case the input file might be erroneous, so stops.
!!
!! If jdtset is a positive number :
!!
!!  (1) First search for modified string, blank//'token'//jdtset//blank
!!
!!  (2a) if the occurence of (1) is not found,
!!       look for other modified strings,
!!       blank//'token'//'?'//unities//blank
!!       or
!!       blank//'token'//dozens//'?'//blank
!!       (issue an error message if more than one occurs)
!!       where jdtset=dozens*10+unities (decimal decomposition of jdtset)
!!       if one of them exists, just take the value
!!
!!  (2b-2c) search for a series, with the following tokens :
!!       (issue an error message if more than one occurs, or
!!       goto (3) if none exist)
!!
!!      blank//'token'//':'//blank
!!      if it exists, then a series might have been defined in the input file
!!      must thus find either the increment, blank//'token'//'+'//blank,
!!      or the multiplicative factor, blank//'token'//'*'//blank
!!
!!      blank//'token'//'?'//':'//blank
!!      if it exists, then a series for the inner loop
!!      might have been defined in the input file
!!      must thus find either the increment, blank//'token'//'?'//'+'//blank,
!!      or the multiplicative factor, blank//'token'//'?'//'*'//blank
!!
!!      blank//'token'//':'//'?'//blank
!!      if it exists, then a series for the outer loop
!!      might have been defined in the input file
!!      must thus find either the increment, blank//'token'//'+'//'?'//blank,
!!      or the multiplicative factor, blank//'token'//'*'//'?'//blank
!!
!!  (3) if neither (1) nor (2) are found, search for the 'normal'
!!       string, blank//'token'//blank
!!
!!
!! WARNING
!! Input string 'token' assumed no longer than 6 characters, affects
!! dimension of 'cs' used in character assignment statement.
!!
!! PARENTS
!!      abinit,ingeo,ingeobld,inkpts,invacuum,invars0,invars1,invars2,invars7w
!!      invars9,localorb_S,lwf,newsp
!!
!! CHILDREN
!!      inarray,inupper,leave_new,wrtout
!!
!! SOURCE

#if defined HAVE_CONFIG_H
#include "config.h"
#endif

subroutine intagm(dprarr,intarr,jdtset,marr,narr,string,token,tread,typevarphys, ds_input)

 use defs_basis

!This section has been created automatically by the script Abilint (TD).
!Do not modify the following lines by hand.
! use interfaces_14_hidewrite
! use interfaces_16_hideleave
! use interfaces_32_util
! use interfaces_42_parser, except_this_one => intagm
!End of the abilint section

 implicit none

!Arguments ------------------------------------
!scalars
 integer,intent(in) :: jdtset,marr,narr
 integer,intent(out) :: tread
 integer,intent(out),optional :: ds_input
 character(len=*),intent(in) :: string
 character(len=*),intent(inout) :: token
 character(len=3),intent(in) :: typevarphys
!arrays
 integer,intent(out) :: intarr(marr)
 real(dp),intent(out) :: dprarr(marr)

!Local variables-------------------------------
 character(len=1), parameter :: blank=' '
!scalars
 integer :: b1,cs1len,cslen,dozens,ier,itoken,itoken1,itoken2,itoken2_1colon
 integer :: itoken2_1plus,itoken2_1times,itoken2_2colon,itoken2_2plus
 integer :: itoken2_2times,itoken2_colon,itoken2_plus,itoken2_times
 integer :: itoken_1colon,itoken_1plus,itoken_1times,itoken_2colon,itoken_2plus
 integer :: itoken_2times,itoken_colon,itoken_plus,itoken_times,number,opttoken
 integer :: sum_token,toklen,trial_cslen,trial_jdtset,unities
 integer :: ds_input_
 character(len=2) :: appen
 character(len=3) :: typevar
 character(len=500) :: message
 character(len=fnlen) :: cs,cs1,cs1colon,cs1plus,cs1times,cs2colon,cs2plus
 character(len=fnlen) :: cs2times,cscolon,csplus,cstimes,trial_cs
!arrays
 integer,allocatable :: int1(:),int2(:)
 real(dp),allocatable :: dpr1(:),dpr2(:)

! *************************************************************************

!DEBUG
!write(6,*)' intagm : enter, token,jdtset= ',token,jdtset
!write(6,*)trim(string)
!stop
!ENDDEBUG

 ds_input_ = -1

 dozens=jdtset/10
 unities=jdtset-10*dozens

 if(jdtset<0)then
   write(std_out, '(a,a,a,a,i6,a)' ) ch10,&
&   ' intagm : BUG -',ch10,&
&   '  jdtset=',jdtset,', while it should be non-negative.'
!   call wrtout(std_out,message,'COLL')
!   call leave_new('COLL')
 end if

 if(jdtset>99)then
   write(std_out, '(a,a,a,a,i6,a)' ) ch10,&
&   ' intagm : BUG -',ch10,&
&   '  jdtset=',jdtset,', while it must be lower than 100.'
!   call wrtout(std_out,message,'COLL')
!   call leave_new('COLL')
 end if

!Default values : nothing has been read
 itoken=0
 opttoken=0
!Initialise flags in case of opttoken >= 2 later.
 itoken_times=0
 itoken_plus=0
 itoken_colon=0
 cslen=1

 if (narr/=0) then

   toklen=len_trim(token)
! write(std_out,'(3a)') ch10,' Here2=',ch10
!  --------------------------------------------------------------------------
!  (1) try to find the token with dataset number appended
   if(jdtset>0)then

     if(jdtset<10)write(appen,'(i1)')jdtset
     if(jdtset>=10)write(appen,'(i2)')jdtset
     cs=blank//token(1:toklen)//trim(appen)//blank
     if(jdtset<10) then
       cslen=toklen+3
     else
       cslen=toklen+4
     end if
!    Map token to all upper case (make case-insensitive):
     call inupper(cs)
!    Absolute index of blank//token//blank in string:
     itoken=index(string,cs(1:cslen))
!    Look for another occurence of the same token in string, if so, leaves:
     itoken2=index(string,cs(1:cslen), BACK=.true. )
     if(itoken/=itoken2)then
       write(std_out, '(a,a,a,a,a,a,a,a,a,a)' )ch10,&
&       ' intagm : ERROR - ',ch10,&
&       '  There are two occurences of the keyword "',cs(1:cslen),&
&       '" in the input file.',ch10,&
&       '  This is confusing, so it has been forbidden.',ch10,&
&       '  Action : remove one of the two occurences.'
!       call wrtout(std_out,message,'COLL')
!       call leave_new('COLL')
     end if

     if(itoken/=0) then
       opttoken=1
       ds_input_=jdtset
     end if
!    DEBUG
!    write(6,*)' intagm : token=',token
!    write(6,*)' intagm : itoken=',itoken
!    write(6,*)' intagm : appen=',appen
!    write(6,*)' intagm : cs=',cs
!    ENDDEBUG

   end if
! write(std_out,'(3a)') ch10,' Here3=',ch10
!  --------------------------------------------------------------------------
!  (2a) try to find the token appended with a string that contains the
!  metacharacter "?".

   if(jdtset>0 .and. opttoken==0)then

!    Use the metacharacter for the dozens, and save in cs and itoken
     write(appen,'(i1)')unities
     cs=blank//token(1:toklen)//'?'//trim(appen)//blank
     cslen=toklen+4
!    Map token to all upper case (make case-insensitive):
     call inupper(cs)
!    Absolute index of blank//token//blank in string:
     itoken=index(string,cs(1:cslen))
!    Look for another occurence of the same token in string, if so, leaves:
     itoken2=index(string,cs(1:cslen), BACK=.true. )
     if(itoken/=itoken2)then
       write(std_out, '(a,a,a,a,a,a,a,a,a,a)' )ch10,&
&       ' intagm : ERROR - ',ch10,&
&       '  There are two occurences of the keyword "',cs(1:cslen),&
&       '" in the input file.',ch10,&
&       '  This is confusing, so it has been forbidden.',ch10,&
&       '  Action : remove one of the two occurences.'
!       call wrtout(std_out,message,'COLL')
!       call leave_new('COLL')
     end if
     if(itoken/=0) then
       opttoken=1
       ds_input_=jdtset
     end if

!    Use the metacharacter for the unities, and save in cs1 and itoken1
     write(appen,'(i1)')dozens
     cs1=blank//token(1:toklen)//trim(appen)//'?'//blank
!    Map token to all upper case (make case-insensitive):
     call inupper(cs1)
!    Absolute index of blank//token//blank in string:
     itoken1=index(string,cs1(1:cslen))
!    Look for another occurence of the same token in string, if so, leaves:
     itoken2=index(string,cs1(1:cslen), BACK=.true. )
     if(itoken1/=itoken2)then
       write(std_out, '(a,a,a,a,a,a,a,a,a,a)' )ch10,&
&       ' intagm : ERROR - ',ch10,&
&       '  There are two occurences of the keyword "',cs1(1:cslen),&
&       '" in the input file.',ch10,&
&       '  This is confusing, so it has been forbidden.',ch10,&
&       '  Action : remove one of the two occurences.'
!       call wrtout(std_out,message,'COLL')
!       call leave_new('COLL')
     end if

     if(itoken/=0 .and. itoken1/=0)then
       write(std_out, '(12a)' )ch10,&
&       ' intagm : ERROR - ',ch10,&
&       '  The keywords "',cs(1:cslen),'" and "',cs1(1:cslen),'"',ch10,&
&       '  cannot be used together in the input file.',ch10,&
&       '  Action : remove one of the two keywords.'
!       call wrtout(std_out,message,'COLL')
!       call leave_new('COLL')
     end if

     if(itoken1/=0)then
       opttoken=1
       itoken=itoken1
       cs=cs1
       ds_input_=jdtset
     end if

   end if
! write(std_out,'(3a)') ch10,' Here4=',ch10
!  --------------------------------------------------------------------------
!  (2b) try to find the tokens defining a series
   if(opttoken==0)then

     cs=token(1:toklen)

     cslen=toklen+3
     cs1len=toklen+4

     cscolon=blank//token(1:toklen)//':'//blank
     csplus=blank//token(1:toklen)//'+'//blank
     cstimes=blank//token(1:toklen)//'*'//blank

     cs1colon=blank//token(1:toklen)//'?'//':'//blank
     cs1plus=blank//token(1:toklen)//'?'//'+'//blank
     cs1times=blank//token(1:toklen)//'?'//'*'//blank

     cs2colon=blank//token(1:toklen)//':'//'?'//blank
     cs2plus=blank//token(1:toklen)//'+'//'?'//blank
     cs2times=blank//token(1:toklen)//'*'//'?'//blank

!    Map token to all upper case (make case-insensitive):
     call inupper(cscolon) 
     call inupper(csplus) 
     call inupper(cstimes)
     call inupper(cs1colon) 
     call inupper(cs1plus) 
     call inupper(cs1times)
     call inupper(cs2colon) 
     call inupper(cs2plus) 
     call inupper(cs2times)

!    Absolute index of tokens in string:
     itoken_colon=index(string,cscolon(1:cslen))
     itoken_plus=index(string,csplus(1:cslen))
     itoken_times=index(string,cstimes(1:cslen))
     itoken_1colon=index(string,cs1colon(1:cs1len))
     itoken_1plus=index(string,cs1plus(1:cs1len))
     itoken_1times=index(string,cs1times(1:cs1len))
     itoken_2colon=index(string,cs2colon(1:cs1len))
     itoken_2plus=index(string,cs2plus(1:cs1len))
     itoken_2times=index(string,cs2times(1:cs1len))

!    Look for another occurence of the same tokens in string
     itoken2_colon=index(string,cscolon(1:cslen), BACK=.true. )
     itoken2_plus=index(string,csplus(1:cslen), BACK=.true. )
     itoken2_times=index(string,cstimes(1:cslen), BACK=.true. )
     itoken2_1colon=index(string,cs1colon(1:cs1len), BACK=.true. )
     itoken2_1plus=index(string,cs1plus(1:cs1len), BACK=.true. )
     itoken2_1times=index(string,cs1times(1:cs1len), BACK=.true. )
     itoken2_2colon=index(string,cs2colon(1:cs1len), BACK=.true. )
     itoken2_2plus=index(string,cs2plus(1:cs1len), BACK=.true. )
     itoken2_2times=index(string,cs2times(1:cs1len), BACK=.true. )

     if(jdtset==0)then

!      If the multi-dataset mode is not used, no token should have been found
       if(itoken_colon+itoken_plus+itoken_times+&
&       itoken_2colon+itoken_2plus+itoken_2times > 0 ) then
         write(std_out, '(a,a,a,a,a, a,a,a,a,a, a,a,a,a,a, a)' )ch10,&
&         ' intagm : ERROR - ',ch10,&
&         '  Although the multi-dataset mode is not activated,',ch10,&
&         '  the keyword "',trim(cs),'" has been found',ch10,&
&         '  appended with  + * or :  .',ch10,&
&         '  This is not allowed.',ch10,&
&         '  Action : remove the appended keyword, or',ch10,&
&         '  use the multi-dataset mode (ndtset/=0).'
!         call wrtout(std_out,message,'COLL')
!         call leave_new('COLL')
       end if
       if(itoken_1colon+itoken_1plus+itoken_1times > 0 ) then
         write(std_out, '(a,a,a,a,a, a,a,a,a,a, a,a,a,a,a, a)' )ch10,&
&         ' intagm : ERROR - ',ch10,&
&         '  Although the multi-dataset mode is not activated,',ch10,&
&         '  the keyword "',trim(cs),'" has been found',ch10,&
&         '  appended with ? , then + * or :  .',ch10,&
&         '  This is not allowed.',ch10,&
&         '  Action : remove the appended keyword, or',ch10,&
&         '  use the multi-dataset mode (ndtset/=0).'
!         call wrtout(std_out,message,'COLL')
!         call leave_new('COLL')
       end if

     else

!      If the multi-dataset mode is used, exactly zero or two token must be found
       sum_token=0
       if(itoken_colon/=0)sum_token=sum_token+1
       if(itoken_plus /=0)sum_token=sum_token+1
       if(itoken_times/=0)sum_token=sum_token+1
       if(itoken_1colon/=0)sum_token=sum_token+1
       if(itoken_1plus /=0)sum_token=sum_token+1
       if(itoken_1times/=0)sum_token=sum_token+1
       if(itoken_2colon/=0)sum_token=sum_token+1
       if(itoken_2plus /=0)sum_token=sum_token+1
       if(itoken_2times/=0)sum_token=sum_token+1

       if(sum_token/=0 .and. sum_token/=2) then
         write(std_out, '(a,a,a,a,a,a,a,a,i3,a,a,a,a,a,a,a)' )ch10,&
&         ' intagm : ERROR - ',ch10,&
&         '  The keyword "',trim(cs),'" has been found to take part',ch10,&
&         '  to series definition in the multi-dataset mode',&
&         sum_token,' times.',ch10,&
&         '  This is not allowed, since it should be used once with ":",',ch10,&
&         '  and once with "+" or "*".',ch10,&
&         '  Action : change the number of occurences of this keyword.'
!         call wrtout(std_out,message,'COLL')
!         call leave_new('COLL')
       end if

!      If the multi-dataset mode is used, make sure that
!      no twice the same combined keyword happens
       ier=0
       if(itoken_colon/=itoken2_colon)then
         ier=1 ; cs=cscolon
       end if
       if(itoken_plus/=itoken2_plus)then
         ier=1 ; cs=csplus
       end if
       if(itoken_times/=itoken2_times)then
         ier=1 ; cs=cstimes
       end if
       if(itoken_1colon/=itoken2_1colon)then
         ier=1 ; cs=cs1colon
       end if
       if(itoken_1plus/=itoken2_1plus)then
         ier=1 ; cs=cs1plus
       end if
       if(itoken_1times/=itoken2_1times)then
         ier=1 ; cs=cs1times
       end if
       if(itoken_2colon/=itoken2_2colon)then
         ier=1 ; cs=cs2colon
       end if
       if(itoken_2plus/=itoken2_2plus)then
         ier=1 ; cs=cs2plus
       end if
       if(itoken_2times/=itoken2_2times)then
         ier=1 ; cs=cs2times
       end if
 write(std_out,'(3a)') ch10,' Here5=',ch10
       if(ier==1)then
         write(std_out, '(a,a,a,a,a,a,a,a,a,a)' )ch10,&
&         ' intagm : ERROR - ',ch10,&
&         '  There are two occurences of the keyword "',cs(1:cslen),&
&         '" in the input file.',ch10,&
&         '  This is confusing, so it has been forbidden.',ch10,&
&         '  Action : remove one of the two occurences.'
!         call wrtout(std_out,message,'COLL')
!         call leave_new('COLL')
       end if

!      Select the series according to the presence of a colon flag
       if(itoken_colon>0)then
         opttoken=2
         ds_input_=jdtset
       else if(itoken_1colon>0)then
         opttoken=3
         cscolon=cs1colon ; csplus=cs1plus ; cstimes=cs1times
         itoken_colon=itoken_1colon
         itoken_plus=itoken_1plus ; itoken_times=itoken_1times
         cslen=cs1len
         ds_input_=jdtset
       else if(itoken_2colon>0)then
         opttoken=4
         cscolon=cs2colon ; csplus=cs2plus ; cstimes=cs2times
         itoken_colon=itoken_2colon
         itoken_plus=itoken_2plus ; itoken_times=itoken_2times
         cslen=cs1len
         ds_input_=jdtset
       end if

!      Make sure that the proper combination of : + and * is found .
       if(itoken_colon > 0 .and. (itoken_plus==0 .and. itoken_times==0) )then
         write(std_out, '(16a)' )ch10,&
&         ' intagm : ERROR - ',ch10,&
&         '  The keyword "',cscolon(1:cslen),'" initiate a series,',ch10,&
&         '  but there is no occurence of "',csplus(1:cslen),&
&         '" or "',cstimes(1:cslen),'".',ch10,&
&         '  Action : either suppress the series, or make the increment',ch10,&
&         '   or the factor available.'
!         call wrtout(std_out,message,'COLL')
!         call leave_new('COLL')
       end if
       if(itoken_plus/=0 .and. itoken_times/=0)then
         write(std_out, '(a,a,a,a,a, a,a,a,a,a)' )ch10,&
&         ' intagm : ERROR - ',ch10,&
&         '  The combined occurence of keywords "',csplus(1:cslen),&
&         '" and "',cstimes(1:cslen),'" is not allowed.',ch10,&
&         '  Action : suppress one of them in your input file.'
!         call wrtout(std_out,message,'COLL')
!         call leave_new('COLL')
       end if
       if(itoken_colon==0 .and. (itoken_plus/=0 .or. itoken_times/=0) ) then
         cs=csplus
         if(itoken_times/=0)cs=cstimes
         write(std_out, '(a,a,a,a,a, a,a,a,a,a, a,a,a,a)' )ch10,&
&         ' intagm : ERROR - ',ch10,&
&         '  The keyword "',cscolon(1:cslen),&
&         '" does not appear in the input file.',ch10,&
&         '  However, the keyword "',cs(1:cslen),'" appears.',ch10,&
&         '  This is forbidden.',ch10,&
&         '  Action : make the first appear, or suppress the second.'
!         call wrtout(std_out,message,'COLL')
!         call leave_new('COLL')
       end if

!      At this stage, either
!      - itoken_colon vanish as well as itoken_plus and itoken_times
!      - itoken_colon does not vanish,
!      as well as one of itoken_plus or itoken_times

!      End the condition of multi-dataset mode
     end if

!    End the check on existence of a series
   end if
! write(std_out,'(3a)') ch10,' Here5=',ch10
!  --------------------------------------------------------------------------
!  (3) if not found, try to find the token with non-modified string
   if(opttoken==0)then

     cs=blank//token(1:toklen)//blank
     cslen=toklen+2

!    Map token to all upper case (make case-insensitive):
     call inupper(cs)

!    Absolute index of blank//token//blank in string:
     itoken=index(string,cs(1:cslen))

!    Look for another occurence of the same token in string, if so, leaves:
     itoken2=index(string,cs(1:cslen), BACK=.true. )
     if(itoken/=itoken2)then
       write(std_out, '(a,a,a,a,a,a,a,a,a,a)' )ch10,&
&       ' intagm : ERROR - ',ch10,&
&       '  There are two occurences of the keyword "',cs(1:cslen),&
&       '" in the input file.',ch10,&
&       '  This is confusing, so it has been forbidden.',ch10,&
&       '  Action : remove one of the two occurences.'
!       call wrtout(std_out,message,'COLL')
!       call leave_new('COLL')
     end if

     if(itoken/=0) then
       opttoken=1
       ds_input_=0
     end if

   end if

!  --------------------------------------------------------------------------
!  If jdtset==0, means that the multi-dataset mode is not used, so
!  checks whether the input file contains a multi-dataset keyword,
!  and if this occurs, stop. Check also the forbidden occurence of
!  use of 0 as a multi-dataset index.
!  Note that the occurence of series initiators has already been checked.

   do trial_jdtset=0,9
     if(jdtset==0 .or. trial_jdtset==0)then
       write(appen,'(i1)')trial_jdtset
       trial_cs=blank//token(1:toklen)//trim(appen)
       trial_cslen=toklen+2
!      Map token to all upper case (make case-insensitive):
       call inupper(trial_cs)
!      Look for an occurence of this token in string, if so, leaves:
       itoken2=index(string,trial_cs(1:trial_cslen))
!      If itoken2/=0
       if(itoken2/=0)then
         if(trial_jdtset==0)then
           write(std_out, '(a,a,a,a,a,a,a,a,a,a)' )ch10,&
&           ' intagm : ERROR - ',ch10,&
&           '  There is an occurence of the keyword "',trim(token),&
&           '" appended with 0 in the input file.',ch10,&
&           '  This is forbidden.',ch10,&
&           '  Action : remove this occurence.'
!           call wrtout(std_out,message,'COLL')
         else
           write(std_out, '(a,a,a,a,a,a,a,a,i1,a,a,a,a,a)' )ch10,&
&           ' intagm : ERROR - ',ch10,&
&           '  In the input file, there is an occurence of the ',ch10,&
&           '  keyword "',trim(token),'", appended with the digit "',&
&           trial_jdtset,'".',ch10,&
&           '  This is forbidden when ndtset==0 .',ch10,&
&           '  Action : remove this occurence, or change ndtset.'
!           call wrtout(std_out,message,'COLL')
         end if
!         call leave_new('COLL')
       end if
     end if
   end do

 end if
! write(std_out,'(3a)') ch10,' Here6=',ch10
!===========================================================================
!At this stage, the location of the keyword string is known, as well
!as its length. So, can read the data.
!Usual reading if opttoken==1 (need itoken).
!If opttoken>=2, the characteristics of a series must be read
!(need itoken_colon and either itoken_plus or itoken_times)

 tread = 0
 typevar='INT'
 if(typevarphys=='LOG')typevar='INT'
 if(typevarphys=='DPR' .or. typevarphys=='LEN' .or. typevarphys=='ENE')typevar='DPR'
 if(typevarphys=='KEY')then
   if(opttoken>=2)then
     write(std_out, '(12a)' )ch10,&
&     ' intagm : ERROR - ',ch10,&
&     '  For the keyword "',cs(1:cslen),'", of KEY type,',ch10,&
&     '  a series has been defined in the input file.',ch10,&
&     '  This is forbidden.',ch10,&
&     '  Action : check your input file.'
!     call wrtout(std_out,message,'COLL')
!     call leave_new('COLL')
   end if
   if(narr>=2)then
     write(std_out, '(12a)' )ch10,&
&     ' intagm : ERROR - ',ch10,&
&     '  For the keyword "',cs(1:cslen),'", of KEY type,',ch10,&
&     '  the number of data requested is larger than 1.',ch10,&
&     '  This is forbidden.',ch10,&
&     '  Action : check your input file.'
!     call wrtout(std_out,message,'COLL')
!     call leave_new('COLL')
   end if
   typevar='KEY'
!  DEBUG
!  write(std_out,*)' intagm : will read cs=',trim(cs)
!  stop
!  ENDDEBUG
 end if
! write(std_out,'(3a)') ch10,' Here7=',ch10
!There is something to be read if opttoken>=1
! write(std_out,'(2a,i4)') ch10,' opttoken=',opttoken,ch10
 
if(opttoken==1)then

!  DEBUG
!  write(6,*)' intagm : opttoken==1 , token has been found, will read '
!  ENDDEBUG

!  Absolute location in string of blank which follows token:
   b1=itoken+cslen-1

!  Read the array (or eventual scalar) that follows the blank
!  In case of typevarphys='KEY', the chain of character will be
!  returned in cs.
   call inarray(b1,cs,dprarr,intarr,marr,narr,string,typevarphys)

   if(typevarphys=='KEY')then
     token=trim(cs)
!    DEBUG
!    write(6,*)' intagm : after inarray, token=',trim(token)
!    ENDDEBUG
   end if

!  if this point is reached then data has been read in successfully
   tread = 1

 else if(opttoken>=2)then

!  DEBUG
!  write(6,*)' intagm : opttoken>=2 , token has been found, will read '
!  ENDDEBUG

   allocate(dpr1(narr),dpr2(narr),int1(narr),int2(narr))

!  Absolute location in string of blank which follows token//':':
   b1=itoken_colon+cslen-1
   call inarray(b1,cscolon,dpr1,int1,narr,narr,string,typevarphys)

!  Initialise number even if the if series treat all cases.
   number=1
!  Define the number of the term in the series
   if(opttoken==2)number=jdtset-1
   if(opttoken==3)number=unities-1
   if(opttoken==4)number=dozens-1

!  Distinguish additive and multiplicative series
   if(itoken_plus/=0)then

     b1=itoken_plus+cslen-1
     call inarray(b1,csplus,dpr2,int2,narr,narr,string,typevarphys)

     if(typevar=='INT')then
       intarr(1:narr)=int1(:)+int2(:)*number
     else if(typevar=='DPR')then
       dprarr(1:narr)=dpr1(:)+dpr2(:)*number
     end if

   else if(itoken_times/=0)then

     b1=itoken_times+cslen-1
     call inarray(b1,cstimes,dpr2,int2,narr,narr,string,typevarphys)
     if(typevar=='INT')then
       intarr(1:narr)=int1(:)*int2(:)**number
     else if(typevar=='DPR')then
       dprarr(1:narr)=dpr1(:)*dpr2(:)**number
     end if

   end if

   tread = 1

   deallocate(dpr1,dpr2,int1,int2)

 end if
! write(std_out,'(3a)') ch10,' Here8=',ch10
 if(present(ds_input)) then
   ds_input = ds_input_
 end if
! write(std_out,'(3a)') ch10,' Here9=',ch10
!DEBUG
!write(6,*) ' intagm : exit value tread=',tread
!write(6,*) ' intarr =',intarr(1:narr)
!write(6,*) ' dprarr =',dprarr(1:narr)
!stop
!ENDDEBUG

end subroutine intagm
!!***
