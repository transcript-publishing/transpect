
local ID = node.id
local WI = ID ( "whatsit" )
local HLIST = ID ( "hlist" )
local VLIST = ID ( "vlist" )

local SWAPPED = table.swapped
local WIS = node.whatsits
local PDF_LITERAL = SWAPPED ( WIS () )["pdf_literal"]
local SPECIAL = SWAPPED ( WIS () )["special"]

local NEW = node.new
local REM = node.remove
local INS_B = node.insert_before
local T = node.traverse
local EFF_GLUE = node.effective_glue

local FLOOR = math.floor

local ATC = luatexbase.add_to_callback

--------------------

local function round ( num, dec )
    return FLOOR ( num * 10^dec + 0.5 ) / 10^dec
end


Du_last_length = 0

local function calc_value ( value )
    value = round ( value / 65781, 3 )
    return value
end

local function get_x_value ( n, x_value, hlist )
    local exp_fac = 1
    if n.expansion_factor then
        exp_fac = n.expansion_factor / 1000000 + 1
    end
    if n.width then
        if n.id == GLUE then
            x_value = x_value + calc_value ( EFF_GLUE ( n, hlist ) ) * exp_fac
        else
            x_value = x_value + calc_value ( n.width ) * exp_fac
        end
    elseif n.kern then
        x_value = x_value + calc_value ( n.kern ) * exp_fac
    elseif n.replace then
        for node in T ( n.replace ) do
            x_value = get_x_value ( node, x_value, hlist )
        end
    end
    return x_value
end

-- local attr_id = luatexbase.attributes['tagpdf@attribute']

local function make_partline ( head )
    for n in T ( head ) do
        if n.id == HLIST or n.id == VLIST then
            n.head = make_partline ( n.head )
        elseif n.id == WI and n.subtype == SPECIAL and n.data == "PHPL_part_line" then
            local width = 0
            for node in T ( head ) do
                width = get_x_value ( node, width, head )
            end
            Du_last_length = width
            local wi_node = NEW ( WI, PDF_LITERAL )
            wi_node.mode = 0
            local excess = calc_value ( tex.sp ( "4mm" ) )
            width = width + 2 * excess
            -- wi_node.data = "/Artifact BMC q " .. width .. " w " .. width * 0.5 - excess .. " " .. calc_value ( tex.sp ( "-.85em" ) ) + calc_value ( tex.sp ( "1pt" ) ) .. " m " .. width * 0.5 - excess .. " " .. calc_value ( tex.sp ( "-.85em" ) ) .. " l .57 G S Q EMC"
            wi_node.data = "q " .. width .. " w " .. width * 0.5 - excess .. " " .. calc_value ( tex.sp ( "-.85em" ) ) + calc_value ( tex.sp ( "1pt" ) ) .. " m " .. width * 0.5 - excess .. " " .. calc_value ( tex.sp ( "-.85em" ) ) .. " l .57 G S Q"
            -- wi_node.attr = node.new ("attribute_list")
            -- wi_node.attr.number = attr_id
            -- node.set_attribute ( wi_node, attr_id, 1 )
            -- wi_node.attr.value = 1
            -- head = INS_B ( head, node.first_glyph ( head ), wi_node )
            head = INS_B ( head, n, wi_node )
            head = REM ( head, n )
        end
    end
    return head
end

ATC ( "post_linebreak_filter", make_partline , "make partline" )
