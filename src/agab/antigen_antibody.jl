#
# antibody-antigen interactions
#

"A population of a single type of antibody."
mutable struct Antibody
    strength :: Float64
    abody :: Vector{Int16}
end

const Antigens = Vector{Int16}


# immunity buildup/decay
function update_immunity!(imm, inf, pars)
    imm.strength *= inf ? pars.inc_imm : pars.dec_imm
end

# point mutation in virus
function update_antigens!(antigens, pars)
    if rand() < pars.pmut_antigens
        r = rand(1:length(antigens))
        antigens[r] = (antigens[r] + rand(-pars.dmut_antigens:pars.dmut_antigens) + pars.max_antigen) % 
            pars.max_antigen
    end
end


"Generate a random antibody for a given antigen."
function generate_immunity(antigen, pars)
    # minimum 1 overlap required
    offset = rand((2-pars.n_antibodies):(length(antigen)-1))
    values = zeros(Int16, pars.n_antibodies)
    for i in eachindex(values)
        idx = offset + i - 1
        if 1 <= idx <= length(antigen)
            values[i] = antigen[idx]
            if pars.stoch_imm > 0
                values[i] = (values[i] + rand(-pars.stoch_imm:pars.stoch_imm) + pars.max_antigen) %
                    pars.max_antigen
            end
        end
    end
    
    values
end


# immune reaction
function reaction(agen, imm, pars)
    match(agen, imm.abody, pars) * imm.strength
end

# match agen against abody
function match(agen, abody, pars)
    min_d = pars.max_antigen * length(abody)
    
    # find closest match of abody against agen with at least 1 overlap
    for i in (2-length(abody)):(length(agen)+length(abody)-1)
        d = 0 
        for (j, a) in enumerate(abody)
            c = j + i - 1 
            d += 1 <= c <= length(agen) ? abs(a - agen[c]) : pars.max_antigen
        end
        min_d = min(min_d, d)
    end
    
    1.0 - min_d / length(abody) / pars.max_antigen
end
