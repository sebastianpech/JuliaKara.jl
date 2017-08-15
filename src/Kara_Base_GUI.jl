module Kara_Base_GUI
using Gtk,Gtk.ShortNames, Graphics

export
    Grid,
    grid_draw,
    world_init,
    symbol_triangle,
    symbol_circle,
    symbol_star

struct Grid{Tx<:Real,Ty<:Real,Tw<:Real,Th<:Real}
    x::Tx
    y::Ty
    width::Tw
    height::Th
    xe::Int
    ye::Int
end

function grid_draw(gr::Grid,ctx::Gtk.CairoContext)
    new_path(ctx)
    move_to(ctx,gr.x,gr.y)
    set_source_rgb(ctx,0,0,0)
    for x in linspace(gr.x,gr.x+gr.width,gr.xe+1)
        move_to(ctx,x,gr.y+gr.height)
        rel_line_to(ctx,0,-gr.height)
    end
    for y in linspace(gr.y,gr.y+gr.height,gr.ye+1)
        move_to(ctx,gr.x,y)
        rel_line_to(ctx,gr.width,0)
    end
    stroke(ctx)
end

function grid_coordinate_real(gr::Grid,x::Int,y::Int)
    gr.x + gr.width/gr.xe*(x-1),
    gr.y + gr.height/gr.ye*(gr.ye-y)
end

function world_init(title::AbstractString)
    b = GtkBuilder(filename=joinpath(@__DIR__,"layout.glade"))
    c = @Canvas()
    fc = b["frame_canvas"]
    push!(fc,c)
    win = b["win_main"]
    showall(win)
    return win,c
end

function symbol_triangle(gr::Grid,ctx::Gtk.CairoContext,x::Int,y::Int,angle::T) where T <: Real
    wi = gr.width/gr.xe
    hi = gr.height/gr.ye
    xr,yr = grid_coordinate_real(gr,x,y)
    vbase = Vec2(xr,yr)
    vrot = vbase + 0.5*Vec2(wi,hi)
    va = rotate(Vec2(xr+wi/10,yr+9hi/10),-angle,vrot)
    vb = rotate(Vec2(xr+9wi/10,yr+9hi/10),-angle,vrot)
    vc = rotate(Vec2(xr+wi/2,yr+hi/10),-angle,vrot)
    move_to(ctx,va.x,va.y)
    line_to(ctx,vb.x,vb.y)
    line_to(ctx,vc.x,vc.y)
    line_to(ctx,va.x,va.y)
    fill(ctx)
end

function symbol_circle(gr::Grid,ctx::Gtk.CairoContext,x::Int,y::Int)
    wi = gr.width/gr.xe
    hi = gr.height/gr.ye
    radi = (min(wi,hi)/2)*0.9
    xr,yr = grid_coordinate_real(gr,x,y)
    vbase = Vec2(xr,yr)
    vrot = vbase + 0.5*Vec2(wi,hi)
    circle(ctx,vrot.x,vrot.y,radi)
    fill(ctx)
end

function symbol_star(gr::Grid,ctx::Gtk.CairoContext,x::Int,y::Int)
    wi = gr.width/gr.xe
    hi = gr.height/gr.ye
    xr,yr = grid_coordinate_real(gr,x,y)
    move_to(ctx,xr+wi/10,yr+hi/10)
    line_to(ctx,xr+9wi/10,yr+9hi/10)
    move_to(ctx,xr+9wi/10,yr+hi/10)
    line_to(ctx,xr+wi/10,yr+9hi/10)
    move_to(ctx,xr+wi/2,yr+hi/10)
    line_to(ctx,xr+wi/2,yr+9hi/10)
    move_to(ctx,xr+wi/10,yr+hi/2)
    line_to(ctx,xr+9wi/10,yr+hi/2)
    stroke(ctx)
end

end
