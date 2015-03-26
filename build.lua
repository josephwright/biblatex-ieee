#!/usr/bin/env texlua

-- Build script for "biblatex-ieee" files

-- Identify the bundle and module
bundle = ""
module = "biblatex-ieee"

-- Documentation consists of .tex files to typeset plus .bib file to support
-- This needs a little bit of trickery to get the .bib file into the right
-- places
demofiles    = {"*.bib"}
typesetfiles = {"*.tex"}
supportdir       = "."
typesetsuppfiles = {"*.bib"}

-- .Nothing to unpack
unpackfiles = { }

-- Install biblatex style files and use these as the sources
installfiles = {"*.cbx", "*.bbx"}
sourcefiles  = installfiles

-- Release a TDS-style zip
packtdszip  = true

-- No tests for this bundle
testfildir = ""

-- Find and run the build system
kpse.set_program_name ("kpsewhich")
dofile (kpse.lookup ("l3build.lua"))
