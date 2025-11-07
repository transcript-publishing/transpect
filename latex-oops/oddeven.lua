
local ID = node.id
local GLYPH = ID ( "glyph" )
local DISC = ID ( "disc" )
local GLUE = ID ( "glue" )
local KERN = ID ( "kern" )
local WI = ID ( "whatsit" )
local BOUND = ID ( "boundary" )
local PENALTY = ID ( "penalty" )
local HLIST = ID ( "hlist" )
local VLIST = ID ( "vlist" )
local LOCAL_PAR = ID ( "local_par" )
local INS = ID ( "ins" )

local SWAPPED = table.swapped
local SUBTYPES = node.subtypes
local WIS = node.whatsits
local USER_DEFINED = SWAPPED ( WIS () )["user_defined"]
local PDF_LITERAL = SWAPPED ( WIS () )["pdf_literal"]
local SPECIAL = SWAPPED ( WIS () )["special"]
local SPACESKIP = SWAPPED ( SUBTYPES ("glue") )["spaceskip"]
local USERSKIP = SWAPPED ( SUBTYPES ("glue") )["userskip"]
local LEFTSKIP = SWAPPED ( SUBTYPES ("glue") )["leftskip"]
local LEADERS = SWAPPED ( SUBTYPES ("glue") )["leaders"]
local USERKERN = SWAPPED ( SUBTYPES ("kern") )["userkern"]
local LBPENALTY = SWAPPED ( SUBTYPES ("penalty") )["linebreakpenalty"]
local LINE = SWAPPED ( SUBTYPES ("hlist") )["line"]
local BOX = SWAPPED ( SUBTYPES ("hlist") )["box"]

local NEW = node.new
local COPY = node.copy
local REM = node.remove
local PREV = node.prev
local NEXT = node.next
local TAIL = node.tail
local INS_B = node.insert_before
local INS_A = node.insert_after
local HAS_GLYPH = node.has_glyph
local T = node.traverse
local T_ID = node.traverse_id
local T_GLYPH = node.traverse_glyph
local EFF_GLUE = node.effective_glue

local U = unicode.utf8
local CHAR = U.char
local SUB = U.sub
local GSUB = U.gsub
local FIND = U.find

local ipairs = ipairs

local T_CC = table.concat

local FLOOR = math.floor

local GET_FONT = font.getfont

local LOG = texio.write
local LOG_LINE = texio.write_nl

local OUTPUT = io.output

local ATC = luatexbase.add_to_callback
local RFC = luatexbase.remove_from_callback

-----


local page_counter = 0


local function find_first_last ( n, d, node_type )
    while true do
        if n and n.id == node_type then
            return n
        end
        if d ( n ) then
            n = d ( n )
        else
            return false
        end
    end
end

local function check_for_hlist ( head )
    for n in T_ID ( HLIST, head ) do
        return n
    end
    return false
end

local function count_pages ( head )
    local first_wi = find_first_last ( check_for_hlist ( head ), PREV, WI )
    if check_for_hlist ( head ) and not ( first_wi and first_wi.user_id == 298477 ) then
        local wi_node = NEW ( WI, USER_DEFINED )
        wi_node.type = 100
        wi_node.user_id = 298477
        INS_B ( head, check_for_hlist ( head ), wi_node )
        page_counter = page_counter + 1
    end
    return head
end

function Oe_resetcounter ()
    page_counter = 0
end

function Oe_stepcounter ()
    page_counter = page_counter + 1
end

local function get_x_value ( n, x_value, hlist )
    local exp_fac = 1
    if n.expansion_factor then
        exp_fac = n.expansion_factor / 1000000 + 1
    end
    if n.width then
        if n.id == GLUE then
            x_value = x_value + EFF_GLUE ( n, hlist ) * exp_fac
        else
            x_value = x_value + n.width * exp_fac
        end
    elseif n.kern then
        x_value = x_value + n.kern * exp_fac
    elseif n.replace then
        for node in T ( n.replace ) do
            x_value = get_x_value ( node, x_value, hlist )
        end
    end
    return x_value
end

local function do_stuff ( head )
    for n in T ( head ) do
        if n.id == VLIST or n.id == HLIST then
            n.head = do_stuff ( n.head )
        elseif n.id == WI and n.subtype == SPECIAL and n.data == "gets_hfill" then
            local glue_node = NEW ( GLUE )
            glue_node.subtype = SPACESKIP
            glue_node.stretch = 2^16
            glue_node.stretch_order = 2
            if page_counter % 2 == 0 then
                local width = 0
                for node in T ( head ) do
                    width = get_x_value ( node, width, head )
                end
                local kern_value = width
                kern_value = kern_value + tex.sp ( "1.4cm" )
                local next_node = n
                while next_node and not ( next_node.id == HLIST and next_node.subtype == BOX ) do
                    next_node = NEXT ( next_node )
                end
                for node in T ( next_node.head ) do
                    if node.id == KERN and node.subtype == USERKERN then
                        node.kern = - kern_value
                        break
                    -- elseif node.id == HLIST and node.subtype == BOX and node.shift then
                        -- node.shift = -5000
                        -- break
                    end
                end
            else
                head = INS_A ( head, n, glue_node )
            end
            head = REM ( head, n )
        end
    end
    return head
end

ATC ( "vpack_filter", do_stuff, "do odd even stuff" )
ATC ( "pre_output_filter", count_pages, "count pages" )
