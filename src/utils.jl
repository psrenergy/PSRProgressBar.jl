function _get_time_unit(t::Float64)
    
end

function _eta_text(s1::Int, s2::Int, t1::Float64, eta_started::Bool = true)
    if !eta_started
        return return "|ETA: --"
    end
    eta = floor(Int,t1*s2/s1)
    t_unit = 
        if eta < 1.0
            eta = eta * 1000.0
            "ms"
        elseif eta > 3600.0
            eta = eta / 3600.0
            "h"
        elseif eta > 60.0
            eta = eta / 60.0
            "min"
        else 
            "s"
        end
    return "|ETA: $(eta)$(t_unit)"
end

function _elapsed_text(t::Float64)
    elapsed = time() - t

    t_unit = 
        if elapsed < 1.0
            elapsed = elapsed * 1000.0
            "ms"
        elseif elapsed > 3600.0
            elapsed = elapsed / 3600.0
            "h"
        elseif elapsed > 60.0
            elapsed = elapsed / 60.0
            "min"
        else 
            "s"
        end
    elapsed = floor(Int,elapsed)
    return "|Time: $(elapsed)$(t_unit)"
end