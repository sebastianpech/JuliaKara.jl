using LightXML

" Name mappings from Kara.jl to classic Kara"
const XML_NAMES = Dict(
    :tree => "XmlWallPoints",
    :musroom => "XmlObstaclePoints",
    :leaf => "XmlPaintedfieldPoints",
    :kara => "XmlKaraLis"
)

"Directions mappings from classic Kara to Kara.jl"
const XML_DIR = Dict(
    0 => 1,
    1 => 4,
    2 => 3,
    3 => 2,
)

function xml_map_direction(kara_index::Int)
    Kara_noGUI.ActorsWorld.DIRECTIONS[XML_DIR[kara_index]]
end

function xml_parse_tree!(wo::World,element::Element)
    place_tree(
        wo,
        attribute(p,"x"),
        attribute(p,"y")
    )
end

function xml_parse_mushroom!(wo::World,element::Element)
    place_mushroom(
        wo,
        attribute(p,"x"),
        attribute(p,"y")
    )
end

function xml_parse_leaf!(wo::World,element::Element)
    place_leaf(
        wo,
        attribute(p,"x"),
        attribute(p,"y")
    )
end

function xml_parse_kara!(wo::World,element::Element)
    place_kara(
        wo,
        attribute(p,"x"),
        attribute(p,"y"),
        attribute(p,"direction") |> parse |> xml_map_direction
    )
end

function xml_generate_world(element::Element)
    World(
        attribute(element,"sizex") |> parse,
        attribute(element,"sizey") |> parse
    )
end

function xml_parse_actor!(wo::World,elements::Vector{XMLElement},
                          element_name::String,parser::Function)
    for el in elements
        for p in get_elements_by_tagname(el,element_name)
            parser(wo,p)
        end
    end
end

function xml_load_world(path::AbstractString)
    xworld = parse_file(path)
    xworld_def = root(xworld)

    world = xml_generate_world(xworld_def)

    xtree = get_elements_by_tagname(xworld_def,XML_NAMES[:tree])
    xmushroom = get_elements_by_tagname(xworld_def,XML_NAMES[:mushroome])
    xleaf = get_elements_by_tagname(xworld_def,XML_NAMES[:leaf])
    xkara = get_elements_by_tagname(xworld_def,XML_NAMES[:kara])

    xml_parse_actor!(
        world,
        xtree,
        "XmlPoint",
        xml_parse_tree!
    )

    xml_parse_actor!(
        world,
        xmushroom,
        "XmlPoint",
:        xml_parse_mushroom!
    )

    xml_parse_actor!(
        world,
        xleaf,
        "XmlPoint",
        xml_parse_leaf!
    )

    xml_parse_actor!(
        world,
        xkara,
        "XmlKara",
        xml_parse_kara!
    )

    return world
end
