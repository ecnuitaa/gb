#
# Makefile for ABINIT                                      -*- Automake -*-
# Generated by make-makefiles-corelibs on 2010/12/26 07:52:17 +0000

#
# IMPORTANT NOTE
#
# Any manual change to this file will systematically be overwritten.
# Please modify the make-makefiles-corelibs script or its config file instead.
#

AM_CFLAGS = @ABI_CPPFLAGS@
AM_FCFLAGS = @FPPFLAGS@ @FCFLAGS_FREEFORM@ @FCFLAGS_MODDIR@ @fcflags_opt_42_parser@

INCLUDES = \
	@src_incs_incs@

# Regular source files
lib42_parser_srcs = \
	inarray.F90 \
	incomprs.F90 \
	inread.F90 \
	inreplsp.F90 \
	instrng.F90 \
	intagm.F90 \
	interfaces_42_parser.F90

# Library description
noinst_LIBRARIES = lib42_parser.a

lib42_parser_a_SOURCES= $(lib42_parser_srcs)

CLEANFILES = \
	inarray_cpp.f90 \
	incomprs_cpp.f90 \
	inread_cpp.f90 \
	inreplsp_cpp.f90 \
	instrng_cpp.f90 \
	intagm_cpp.f90 \
	interfaces_42_parser_cpp.f90

EXTRA_DIST = abinit.src

EXTRA_DIST += abinit.dep

#Dependencies (inside the directory) of the directory ./src/42_parser
#
#COPYRIGHT
#Copyright (C) 2010 ABINIT group
#This file is distributed under the terms of the
#GNU General Public License, see ~abinit/COPYING
#or http://www.gnu.org/copyleft/gpl.txt .
#
#THIS FILE IS GENERATED AUTOMATICALLY BY abilint.
#To do that: config/scripts/abilint --dependencies . .

CLEANFILES += \
	interfaces_42_parser.$(MODEXT) 

inarray.$(OBJEXT): interfaces_42_parser.$(OBJEXT) 

incomprs.$(OBJEXT): interfaces_42_parser.$(OBJEXT) 

instrng.$(OBJEXT): interfaces_42_parser.$(OBJEXT) 

intagm.$(OBJEXT): interfaces_42_parser.$(OBJEXT) 

EXTRA_DIST += _42_parser_
