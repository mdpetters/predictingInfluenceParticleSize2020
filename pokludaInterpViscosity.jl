function pokludaInterpViscosity(ξ, Dₘ, σ, τ)
    # Fitted prediction data from Table 1 in Pokluda et al. (1997)
    DIMLESS_TIMES = [0.0001, 0.01, 0.02, 0.03, 0.04, 0.05, 0.06, 0.07, 0.08,
                     0.09, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1.0,
                     1.5, 2.0, 4.0, 8.0];
    DIMLESS_NECKS = [0.01, 0.0979, 0.1396, 0.1713, 0.1984, 0.2210, 0.2419,
                     0.2609, 0.2786, 0.2949, 0.3109, 0.4274, 0.5060, 0.5736,
                     0.6242, 0.6721, 0.7062, 0.7403, 0.7666, 0.7910, 0.8767,
                     0.9241, 0.9872, 0.9995]

    VISCOSITIES = τ * σ ./ (DIMLESS_TIMES * Dₘ)
    sinteringAngle = acos.(sqrt.(ξ) .- 1.0)
    dimlessNeck = sin.(sinteringAngle)

    η = zeros(size(ξ,1))
    fill!(η, NaN)
    for i = 1:length(ξ)
        # If below the data range, don't attempt to estimate a data range.
        if dimlessNeck[i] < minimum(DIMLESS_NECKS)
            continue
        end
        # If above the data range, assume full coalesence and use the
        # minimum viscosity
        if dimlessNeck[i] >= maximum(DIMLESS_NECKS)
            η[i] = minimum(VISCOSITIES)
            continue
        end

        # For now, do a simple two-point log-linear interpolation.  This should
        # be adequate for order-of-magnitude estimates.
        lowerIdx = (findall(DIMLESS_NECKS .<= dimlessNeck[i]))[end]
        lowerNeck = DIMLESS_NECKS[lowerIdx]
        upperNeck = DIMLESS_NECKS[lowerIdx+1]
        lowerNeckViscosity = VISCOSITIES[lowerIdx]
        upperNeckViscosity = VISCOSITIES[lowerIdx+1]

        η[i] = 10^(((dimlessNeck[i] - lowerNeck) / (upperNeck - lowerNeck)) *
            (log10(upperNeckViscosity) - log10(lowerNeckViscosity)) +
            log10(lowerNeckViscosity))
    end
    return η
end