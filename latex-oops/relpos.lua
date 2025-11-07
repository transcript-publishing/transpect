-- Copyright (c) 2025 Thomas Kelkel kelkel@emaileon.de

-- This file may be distributed and/or modified under the
-- conditions of the LaTeX Project Public License, either
-- version 1.3c of this license or (at your option) any later
-- version. The latest version of this license is in

--    http://www.latex-project.org/lppl.txt

-- and version 1.3c or later is part of all distributions of
-- LaTeX version 2009/09/24 or later.

-- Version: 0.1 beta

function process_and_write_invisible_box0 ()
    local original_box_node = tex.box[0]
    if not original_box_node then
        tex.error ( "Lua Fehler: Box 0 ist leer." )
        return
    end
    local box_copy = node.copy ( original_box_node )
    tex.box[0] = nil
    box_copy.width = 0
    box_copy.height = 0
    box_copy.depth = 0
    node.write ( box_copy )
end
