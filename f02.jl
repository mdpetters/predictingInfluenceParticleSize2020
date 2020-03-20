using Gadfly, DataFrames, Colors, SpecialFunctions

shapes = [Shape.hline, Shape.circle]

# global parameters
Da, k, kGT, Tgs, Tgw, ξ = 7, 0.04, 2.5, 271.7, 136.0, 1050.0

angellModel(x, D) = @. -5+0.434*(39.17D/(D/x+39.17/x-39.17)) 

include("pokludaInterpViscosity.jl")
ksi(T, p) = @. 1.0 + 1.5*erfc((T - p[1])/(p[2]*sqrt(2)))
T = (20.2-4.93):2.5:(20.2+4.93)
ξ = ksi(T, [20.2, 4.93])
ηsoa = log10.(pokludaInterpViscosity(ξ, 100e-9, 0.035, 5.0))
df0 = DataFrame(x = Tgs./(collect(T).+273.15),y = ηsoa, Source = "Viscosity data",
                Color = "α-pinene SOA data")
df1 = DataFrame(x = [1.0], y = [12],  Source =  ["Extrapolated Tg"], Color = "α-pinene SOA data")
df = [df0;df1]


df2 = DataFrame(x = [0,1], y = [-5, 12], Source = ["Arrhenius model" for i in 1:length([0,1])])

Tᵖ = 0:0.01:1
label = "Angell model"
df3 = DataFrame(x = Tᵖ, y = angellModel(Tᵖ, 7.0), ymin = angellModel(Tᵖ, 4.0), 
                 ymax = angellModel(Tᵖ, 20.0), Source =  [label for i in 1:length(collect(Tᵖ))])

ts = Theme(alphas=[0.3], discrete_highlight_color=c->RGBA{Float32}(c.r, c.g, c.b, 1), 
           point_shapes=shapes,highlight_width=0.4pt, point_size = 3pt)

layers = []
push!(layers, layer(df,  x = :x, y = :y, color = :Color, shape = :Source, Geom.point, ts))
push!(layers, layer(df1, x = :x, y = :y, xmin = [(Tgs-10.0)/Tgs], xmax = [(Tgs+10.0)/Tgs], 
      Geom.errorbar, Theme(default_color = "grey", line_width=1pt)))
push!(layers, layer(df2, x = :x, y = :y, Geom.line, color = :Source, ts))
push!(layers, layer(df3, x = :x, y = :y, ymin = :ymin, ymax = :ymax, color = :Source, 
                    Geom.line, Geom.ribbon, ts))
         
guides = []
push!(guides, Guide.xlabel("Tg/T (-)"))
push!(guides, Guide.ylabel("Log<sub>10</sub> (viscosity in Pa s)"))
push!(guides, Guide.YTicks(ticks=collect(-5:1:12)))
push!(guides, Guide.XTicks(ticks=collect(0:0.1:1.0)))
push!(guides, Guide.shapekey(title = "Shapekey", pos = [2mm,-20mm]))
push!(guides, Guide.colorkey(title = "Colorkey", pos = [2mm,-2mm]))

scales = []
push!(scales, Scale.color_discrete_manual( "black", "darkred", "darkgoldenrod"))  
push!(scales, Scale.x_continuous())

coords = []
push!(coords, Coord.cartesian(ymin = -5, ymax = 13, xmax = 1.04, xmin = 0))

theme = Theme(alphas=[0.4], discrete_highlight_color=c->RGBA{Float32}(c.r, c.g, c.b), 
              point_shapes=shapes,key_swatch_color=colorant"slategrey", 
              plot_padding=[0.0inch,0.1inch,0inch,-0.1inch])
p = plot(layers..., guides..., scales..., coords..., theme)
img = SVG("Figures/f02.svg", 3.75inch, 2.75inch)
draw(img,p)

:DONE