function _get_time_unit(t::Float64)
    
end

function _eta_text(p::IterativeProgressBar, new_length::Int)
    if !p.hasETA
        return ""
    end
    if !p.eta_started
        return return "|ETA: --"
    end

    s1 = new_length - p.current_length # length progress
    s2 = p.maximum_length - new_length # remaining length
    t1 = time() - p.time # time to get from p.current_length to new_length

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

function _elapsed_text(p::AbstractProgressBar)
    if !p.hasElapsedTime
        return ""
    end
    elapsed = time() - p.start_time

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
