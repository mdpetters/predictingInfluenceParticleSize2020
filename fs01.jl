using Gadfly, CSV, DataFrames, Colors

shapes = [Shape.xcross, Shape.utriangle, Shape.diamond, Shape.dtriangle,Shape.cross]

df = CSV.read("Data/fs01.csv")
rl, rh = 1.230,1.460
r = 0.5*(rl+rh)

colors = ["darkred","black","steelblue3","indigo","darkgoldenrod3", "black", "black"]
theme = Theme(alphas = [0.3], point_shapes=shapes, highlight_width=0.4pt, 
              discrete_highlight_color=c->RGBA{Float32}(c.r, c.g, c.b), 
              plot_padding=[0.0inch,0.0inch,0inch,-0.1inch])

p = plot(layer(df, x = :RH, y = df[!,:kappa]./r, ymin = df[!,:kappa]./rh, 
         ymax = df[!,:kappa]./rl, color = :l, shape = :l, Geom.point, Geom.errorbar), 
         layer(x = [0.0, 100.0], y = [0.04, 0.04], ymin = [0.005, 0.005], 
               ymax = [0.075, 0.075], color = ["foo","foo"], Geom.line, Geom.ribbon,
               Theme(alphas = [0.2], lowlight_color=c->RGBA{Float32}(c.r, c.g, c.b))),
         theme,
         Guide.xlabel("Relative humidity (%)"), Guide.ylabel("Mass-based hygroscopicity (-)"),
         Guide.shapekey(title = "Shapes/Colors"),
         Guide.xticks(ticks=collect(0:20:100)),
         Guide.yticks(ticks=collect(0.0:0.02:0.18)),
         Scale.color_discrete_manual(colors...),
         Coord.cartesian(xmin=0, xmax=103, ymin = 0, ymax = 0.18))

img = SVG("Figures/fs01.svg", 5inch, 2.75inch)
draw(img,p)

:DONE