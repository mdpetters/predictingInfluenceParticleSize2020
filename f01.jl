using Gadfly, DataFrames, Colors, CSV, NumericIO

ΔT_data = CSV.read("Data/f01.csv")

T = 298.0
D = exp10.(range(log10(1.0), stop=log10(1000.0), length=100))
ΔT(ξ) = @. ξ*D^-1.0 

df = DataFrame(x = D.*1e-9, y = ΔT.(1800.0))
df1 = DataFrame(x = D.*1e-9, y = ΔT.(300.0))

shapes = [Shape.hline, Shape.diamond,Shape.circle, Shape.square, Shape.utriangle, Shape.dtriangle, 
          Shape.xcross, Shape.vline, Shape.octagon]

theme2 = Theme(alphas = [0.6],point_size=3pt, point_shapes=shapes, highlight_width=0.5pt, 
               discrete_highlight_color=c->RGBA{Float32}(c.r, c.g, c.b, 1),
               key_label_color=colorant"black", key_swatch_color=colorant"slategrey",
               plot_padding=[0.0inch,0.0inch,0.1inch,-0.1inch])

colors = ["darkgoldenrod", "darkred", "black", "grey40", "grey65", "lightblue2", "steelblue3", 
          "navy", "forestgreen"]

xticks = log10.([1,2,3,4,5,6,7,8,9,10,20,30,40,50,60,70,80,90,100,200].*1e-9)
yticks = log10.([5,6,7,8,9,10,20,30,40,50,60,70,80,90,100,200,300,400,500,600,700,800,900,1000])

p = plot(
    layer(df, x=:x, y=:y, Geom.line, Theme(default_color = "darkgoldenrod", line_width=1.5pt)),
    layer(df1, x=:x, y=:y, Geom.line, Theme(default_color = "forestgreen", line_width=1.5pt)),
    layer(ΔT_data, x=ΔT_data[!,:D].*1e-9, y=:ΔT, color = :Compound, shape = :Method), theme2,
    Scale.color_discrete_manual(colors...),
    Coord.Cartesian(ymin=log10(5),ymax=log10(1000),xmin=log10(1e-9),xmax=log10(200e-9)), 
    Scale.x_log10(labels=x->x in log10.([1,10,100].*1e-9) ? formatted(exp10(x),:SI,ndigits=1) : ""),
    Scale.y_log10(labels=y->y in log10.([10,100,1000]) ? formatted(exp10(y),:SI,ndigits=1) : ""),
    Guide.XTicks(ticks=xticks),
    Guide.YTicks(ticks=yticks),
    Guide.ylabel("Melting point depression (K)", orientation=:vertical),
    Guide.xlabel("Diameter (m)"))

img = SVG("Figures/f01.svg", 5inch, 2.75inch);
draw(img,p)