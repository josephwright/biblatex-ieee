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
installfiles = {"*.cbx", "*.bbx", "*.lbx"}
sourcefiles  = installfiles

-- Release a TDS-style zip
packtdszip  = true

-- No tests for this bundle
testfildir = ""

versionfiles = {"*.bbx", "*.cbx", "*.tex"}

function setversion_update_line (line, date, version)
  local date = string.gsub(date, "%-", "/")
  if string.match(line, "Released %d%d%d%d/%d%d/%d%d") or
     string.match(line, "last revised %d%d%d%d/%d%d/%d%d") then
    line = string.gsub(line, "%d%d%d%d/%d%d/%d%d", date)
  end
  if string.match(line, "This file describes v") then
    line = string.gsub(line, "v%d%.%d%w?", "v" .. version)
  end
  if string.match(line, "^\\ProvidesFile") then
    line = string.gsub(line, "%d%d%d%d/%d%d/%d%d", date)
    line = string.gsub(line, "v%d%.%d%w?", "v" .. version)
  end
  return line
end

-- Find and run the build system
kpse.set_program_name ("kpsewhich")
dofile (kpse.lookup ("l3build.lua"))
