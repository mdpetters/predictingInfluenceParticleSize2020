using Gadfly, DataFrames, Colors, CSV

RH = 0:0.1:99.5
T = 293.15

Da, k, kGT, Tgs, Tgw = 7, 0.04, 2.5,273.15-1.46, 136.0
angellModel(x, D) = @. -5+0.434*(39.17D/(D/x+39.17/x-39.17)) 
ηᴬ(Tg::Float64,T::Float64;Da=Da) = (Tg/T > 1) ? 12.0 : angellModel(Tg/T, Da) 
ws(RH::Float64;k=k) = (1.0 + k * RH/100.0/(1.0-RH/100.0))^(-1.0);
Tg(ws::Float64;Tg0=[Tgw Tgs],kGT=kGT)=((1.0 - ws)*Tg0[1] + ws*Tg0[2]/kGT)/(1.0-ws+ws/kGT);
ηᴬᴾ(T::Float64,RH::Float64;k=k,kGT=kGT,Tg0=[Tgw Tgs]) = ηᴬ(Tg(ws(RH;k=k);kGT=kGT,Tg0=Tg0),T)

visc = ηᴬᴾ.(T,RH; Tg0 = [Tgw Tgs], k=k, kGT=kGT)
viscl = ηᴬᴾ.(T,RH; Tg0 = [Tgw Tgs-10.0],k=(k+0.035),kGT = kGT+1.5)
viscu = ηᴬᴾ.(T,RH; Tg0 = [Tgw Tgs+10.0],k=(k-0.035),kGT = kGT-1.5)
df1b = DataFrame(x = RH, y = visc, ymin = viscl, ymax = viscu)

data = CSV.read("Data/f03.csv")

colors = ["navajowhite4", "mediumpurple4", "lightskyblue2", "darkgoldenrod", 
          "mediumseagreen", "darkolivegreen3","darkred"]

shapes = [Shape.hline, Shape.diamond,Shape.circle, Shape.square, Shape.utriangle, 
          Shape.dtriangle, Shape.xcross, Shape.vline]

layers = []
theme1 = Theme(alphas = [0.15], default_color = "black", line_width=1.5pt, 
               lowlight_color=c->RGBA{Float32}(c.r, c.g, c.b))

theme2 = Theme(alphas = [0.6],point_size=3.5pt, point_shapes=shapes, highlight_width=0.5pt, 
               discrete_highlight_color=c->RGBA{Float32}(c.r, c.g, c.b, 1),
               plot_padding=[0.0inch,0.0inch,0.1inch,-0.1inch])

push!(layers, layer(df1b,x=:x,y=:y,ymin=:ymin,ymax=:ymax,Geom.line,Geom.ribbon,theme1))
push!(layers, layer(x=data[!,:RH], y=log10.(data[!,:viscosity]),ymin=log10.(data[!,:minv]), 
                    ymax=log10.(data[!,:maxv]),shape=data[!,:source],color=data[!,:source],
                    Geom.point,Geom.errorbar,theme2))
        
guides = []
push!(guides, Guide.xlabel("Relative humidity (%)"))
push!(guides, Guide.ylabel("Log<sub>10</sub> (viscosity in Pa s)"))
push!(guides, Guide.YTicks(ticks=collect(0:1:12)))
push!(guides, Guide.XTicks(ticks=collect(0:10:100)))
push!(guides, Guide.shapekey(title = "Color/Shape"))

scales = []
push!(scales, Scale.color_discrete_manual(colors...))
push!(scales, Scale.x_continuous())

coords = []
push!(coords, Coord.cartesian(ymin = 0, ymax = 12))

p = plot(layers..., guides..., scales..., coords..., theme2)
img = SVG("Figures/f03.svg", 12.3cm, 2.5inch)
draw(img,p)

:DONE