using Gadfly,  CSV,  DataFrames, Colors

df = CSV.read("Data/fs02.csv")
mes = df[!, :tgm]
cal = df[!, :tgc]
Tmelting = cal./0.7
theme = Theme(alphas=[0.1], default_color = "black", point_size = 2pt, 
    discrete_highlight_color=c->RGBA{Float32}(c.r, c.g, c.b, 1),
    point_shapes=[Shape.circle],
    plot_padding=[0.0inch,0.1inch,0.1inch,-0.1inch])

colors = ["darkred","slateblue3","darkgoldenrod"]
p = plot(
    layer(x=Tmelting, y=mes./(cal/0.7), Geom.point),  
    yintercept=[0.5, 0.7, 0.9], 
    Geom.hline(color=colors, style=:dot, size=[0.3mm,0.3mm,0.3mm]), 
    Guide.YTicks(ticks=collect(0.4:0.1:1.15)),
    Guide.XTicks(ticks=collect(0:100:500)),
    Guide.ylabel("T<sub>g</sub>/T<sub>m</sub>", orientation = :vertical), #from calculated Tg(Tg = 0.7Tm)</sub>
    Guide.xlabel("T <sub>m</sub> (K)",orientation = :horizontal), 
    Coord.cartesian(xmin = 0, xmax = 550, ymin = 0.4, ymax = 1.1),
    theme
)

img = SVG("Figures/fs02.svg", 4inch, 2.75inch)
draw(img,p)