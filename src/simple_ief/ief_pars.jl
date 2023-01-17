using Parameters

"simulation parameters"
@with_kw mutable struct IEFParams
    "virus population size for ief fitness pre-computation"
    ief_pre_N       :: Int              = 10000
    "ief mutation probability per cycle"
    ief_p_mut       :: Float64          = 10^-6
    "length of genome"
    n_basepairs     :: Int              = 30000
    "mean of normal dist describing fitness effect of ief mutation"
    ief_mut_mu      :: Float64          = 0.9
    "sigma of normal dist describing fitness effect of ief mutation"
    ief_mut_sigma   :: Float64          = 0.1
    "number of time steps to pre-compute ief fitness for"
    ief_pre_n_steps :: Int              = floor(Int, 14 * 24 * 4 / 10)
    "number of samples to base fitness calculation on"
    ief_pre_n_samples :: Int            = 10000
    "number of bins in fitness lookup table"
    ief_pre_n_bins  :: Int              = 100
    "time steps per virus reproduction cycle"
    t_repr_cycle    :: Int              = 40
end
