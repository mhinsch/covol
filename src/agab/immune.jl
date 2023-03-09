"An immune system, consisting of a number of antibodies of varying strengths."
const ImmuneSystem = Vector{Antibody}

"Add antibody for given antigen."
function new_immunity!(imm, antigens, pars)
    values = generate_immunity(antigens, pars)    
    push!(imm, Antibody(pars.ini_imm_strength, values))
end


"Immune system update, returns strength of immune response."
function update_immune_system!(imms, antigens, pars)
    # immunity build-up or decay
    s = 1.0 
    for i in length(imms):-1:1
        imm = imms[i]
        m = match(antigens, imm.abody, pars)
        update_immunity!(imm, m > pars.inc_imm_threshold, pars)
        # for efficiency we delete weak immunities 
        if imm.strength < pars.del_imm_threshold
            remove_unsorted_at!(imms, i)
        end
        # keep track of "surviving" virus
        s *= 1.0 - (m * imm.strength)
    end
        
    1.0 - s
end

