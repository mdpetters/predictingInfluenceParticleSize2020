using Gadfly, DataFrames, CSV, Colors, NumericIO


shapes = [Shape.circle, Shape.square, Shape.diamond, Shape.utriangle, Shape.xcross]

RH,T = 0.0, 293.15
Da, k, kGT, Tgs, Tgw, ξ = 7, 0.04, 2.5,271.7, 136.0, 350.0

angellModel(x, D) = @. -5+0.434*(39.17D/(D/x+39.17/x-39.17)) 
ηᴬ(T::Float64, Tg::Float64;Ax=Ax) = (Tg/T > 1) ? 12.0 : angellModel(Tg/T, Ax) 
ws(RH::Float64, Dp::Float64;k=k) = (1.0 + k * RH/100.0/exp(2.1/Dp)/(1.0-RH/100.0/exp(2.1/Dp)))^(-1.0);
TgGT(ws::Float64;Tg0=[Tgw Tgs],kGT=kGT) = ((1.0 - ws)*Tg0[1] + ws*Tg0[2]/kGT)/(1.0-ws+ws/kGT);
TgSize(Tg::Float64, D::Float64;ξ=300.0) = Tg - 0.7*ξ*D^-1.0
ηᴬᴾ(T::Float64,RH::Float64,Dp::Float64;k=k,kGT=kGT,Tg0=[Tgw Tgs],ξ=ξ) =  
      ηᴬ(T,TgSize(TgGT(ws(RH,Dp;k=k);kGT=kGT,Tg0=Tg0),Dp;ξ=ξ);Ax=Da)

RH,T = 0.0, 293.15
Dp = collect(exp10.(range(log10(1.0), stop=log10(10000), length = 1000)))
visc = ηᴬᴾ.(T,RH,Dp; Tg0 = [Tgw Tgs],k=k,kGT=kGT,ξ=ξ)
viscl = ηᴬᴾ.(T,RH,Dp; Tg0 = [Tgw Tgs-10.0],k=(k+0.035),kGT = kGT+1.5,ξ=ξ)
viscu = ηᴬᴾ.(T,RH,Dp; Tg0 = [Tgw Tgs+10.0],k=(k-0.035),kGT = kGT-1.5,ξ=ξ) 
df1a = DataFrame(x = Dp.*1e-9, y = visc, ymin = viscl, ymax = viscu, 
                 label = ["T=20°C" for i in 1:length(Dp)])

RH,T = 0.0, 333.15
visc = ηᴬᴾ.(T,RH,Dp; Tg0 = [Tgw Tgs],k=k,kGT=kGT,ξ=ξ)
viscl = ηᴬᴾ.(T,RH,Dp; Tg0 = [Tgw Tgs-10.0],k=(k+0.035),kGT = kGT+1.5,ξ=ξ)
viscu = ηᴬᴾ.(T,RH,Dp; Tg0 = [Tgw Tgs+10.0],k=(k-0.035),kGT = kGT-1.5,ξ=ξ) 
df1b = DataFrame(x = Dp.*1e-9, y = visc, ymin = viscl, ymax = viscu, 
                  label = ["T=60°C" for i in 1:length(Dp)])
                 
RH,T = 0.0, 253.15
visc = ηᴬᴾ.(T,RH,Dp; Tg0 = [Tgw Tgs],k=k,kGT=kGT,ξ=ξ)
viscl = ηᴬᴾ.(T,RH,Dp; Tg0 = [Tgw Tgs-10.0],k=(k+0.035),kGT = kGT+1.5,ξ=ξ)
viscu = ηᴬᴾ.(T,RH,Dp; Tg0 = [Tgw Tgs+10.0],k=(k-0.035),kGT = kGT-1.5,ξ=ξ) 
df1c = DataFrame(x = Dp.*1e-9, y = visc, ymin = viscl, ymax = viscu, 
                  label = ["T=-20°C" for i in 1:length(Dp)])

df = [df1b;df1a;df1c]

colors = ["grey", "darkgoldenrod3", "darkred", "steelblue3"]
theme1 = Theme(alphas = [0.15], default_color = "black", line_width=1.5pt, 
               lowlight_color=c->RGBA{Float32}(c.r, c.g, c.b))
theme2 = Theme(alphas = [0.6],point_size=4pt, point_shapes=shapes, highlight_width=0.5pt, 
               discrete_highlight_color=c->RGBA{Float32}(c.r, c.g, c.b))

layers = []
 
push!(layers, layer(df, x = :x, y = :y, ymin = :ymin, ymax = :ymax, color = :label,                  
                    Geom.line,Geom.ribbon,theme1))
plot(layers...)

guides = []
gengrid(r) = [vcat(map(x->x:x:8x,r)...);r[end]*10]
xticks = log10.(gengrid([1e-9,1e-8,1e-7,1e-6]))
push!(guides, Guide.xlabel("Diameter (m)"))
push!(guides, Guide.title("(a) Temperature/RH = 0%"))
push!(guides, Guide.ylabel("Log<sub>10</sub> (viscosity in Pa s)"))
push!(guides, Guide.YTicks(ticks=collect(-3:1:12)))
push!(guides, Guide.XTicks(ticks=xticks))

push!(guides, Guide.colorkey(title = "Colorkey"))

scales = []
push!(scales, Scale.color_discrete_manual(colors...))
push!(scales, Scale.x_log10(labels=x->x in log10.([1,10,100,1000,10000].*1e-9) ? 
                           formatted(exp10(x),:SI,ndigits=1) : ""))

coords = []
push!(coords, Coord.cartesian(ymin = -3, ymax = 12, xmax = log10(10.3e-6)))

theme3 = Theme(alphas=[0.4], discrete_highlight_color=c->RGBA{Float32}(c.r, c.g, c.b), 
               point_shapes=shapes,key_swatch_color=colorant"slategrey", 
               plot_padding=[0.0inch,0.1inch,0.1inch,-0.1inch])

p1 = plot(layers..., guides..., scales..., coords..., theme3)


RH,T = 40.0, 293.15
Dp = collect(exp10.(range(log10(1.0), stop=log10(10000), length = 1000)))
visc = ηᴬᴾ.(T,RH,Dp; Tg0 = [Tgw Tgs],k=k,kGT=kGT,ξ=ξ)
viscl = ηᴬᴾ.(T,RH,Dp; Tg0 = [Tgw Tgs-10.0],k=(k+0.035),kGT = kGT+1.5,ξ=ξ)
viscu = ηᴬᴾ.(T,RH,Dp; Tg0 = [Tgw Tgs+10.0],k=(k-0.035),kGT = kGT-1.5,ξ=ξ) 
df1a = DataFrame(x = Dp.*1e-9, y = visc, ymin = viscl, ymax = viscu, 
                 label = ["RH = 40%" for i in 1:length(Dp)])

RH,T = 80.0, 293.15
visc = ηᴬᴾ.(T,RH,Dp; Tg0 = [Tgw Tgs],k=k,kGT=kGT,ξ=ξ)
viscl = ηᴬᴾ.(T,RH,Dp; Tg0 = [Tgw Tgs-10.0],k=(k+0.035),kGT = kGT+1.5,ξ=ξ)
viscu = ηᴬᴾ.(T,RH,Dp; Tg0 = [Tgw Tgs+10.0],k=(k-0.035),kGT = kGT-1.5,ξ=ξ) 
df1b = DataFrame(x = Dp.*1e-9, y = visc, ymin = viscl, ymax = viscu, 
                  label = ["RH = 80%" for i in 1:length(Dp)])
                 
RH,T = 0.0, 293.15
visc = ηᴬᴾ.(T,RH,Dp; Tg0 = [Tgw Tgs],k=k,kGT=kGT,ξ=ξ)
viscl = ηᴬᴾ.(T,RH,Dp; Tg0 = [Tgw Tgs-10.0],k=(k+0.035),kGT = kGT+1.5,ξ=ξ)
viscu = ηᴬᴾ.(T,RH,Dp; Tg0 = [Tgw Tgs+10.0],k=(k-0.035),kGT = kGT-1.5,ξ=ξ) 
df1c = DataFrame(x = Dp.*1e-9, y = visc, ymin = viscl, ymax = viscu, 
                  label = ["RH = 0%" for i in 1:length(Dp)])

df = [df1c;df1a;df1b]

colors = ["darkgoldenrod3", "steelblue3", "forestgreen"]
theme1 = Theme(alphas = [0.15], default_color = "black", line_width=1.5pt, 
               lowlight_color=c->RGBA{Float32}(c.r, c.g, c.b))
theme2 = Theme(alphas = [0.6],point_size=4pt, point_shapes=shapes, highlight_width=0.5pt, 
               discrete_highlight_color=c->RGBA{Float32}(c.r, c.g, c.b))

layers = []
 
push!(layers, layer(df, x = :x, y = :y, ymin = :ymin, ymax = :ymax, color = :label,                  
                    Geom.line,Geom.ribbon,theme1))
plot(layers...)

guides = []
gengrid(r) = [vcat(map(x->x:x:8x,r)...);r[end]*10]
xticks = log10.(gengrid([1e-9,1e-8,1e-7,1e-6]))
push!(guides, Guide.xlabel("Diameter (m)"))
push!(guides, Guide.title("(b) Relative humidity/T=20°C"))
push!(guides, Guide.ylabel("Log<sub>10</sub> (viscosity in Pa s)"))
push!(guides, Guide.YTicks(ticks=collect(-3:1:12)))
push!(guides, Guide.XTicks(ticks=xticks))

push!(guides, Guide.colorkey(title = "Colorkey"))

scales = []
push!(scales, Scale.color_discrete_manual(colors...))
push!(scales, Scale.x_log10(labels=x->x in log10.([1,10,100,1000,10000].*1e-9) ? 
                           formatted(exp10(x),:SI,ndigits=1) : ""))

coords = []
push!(coords, Coord.cartesian(ymin = -3, ymax = 12, xmax = log10(10.3e-6)))

theme3 = Theme(alphas=[0.4], discrete_highlight_color=c->RGBA{Float32}(c.r, c.g, c.b), 
               point_shapes=shapes,key_swatch_color=colorant"slategrey", 
               plot_padding=[0.0inch,0.1inch,0.1inch,-0.1inch])

p2 = plot(layers..., guides..., scales..., coords..., theme3)





p = hstack(p1, p2)

img = SVG("Figures/fs02.svg", 7inch, 3inch)

draw(img,p)
:DONE