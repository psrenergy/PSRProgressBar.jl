function _convert_time_unit(time::Float64)
    t_unit = 
        if time < 1.0
            time = round(Int, time * 1000.0)
            "ms"
        elseif time > 3600.0
            time = round(Int, time / 3600.0)
            "h"
        elseif time > 60.0
            time = round(Int, time / 60.0)
            "min"
        else 
            time = round(Int, time)
            "s"
        end
    return "$(time)$(t_unit)"
end

function _eta_text(p::AbstractProgressBar)
    if !p.has_eta
        return p.right_bar
    end
    if !p.eta_started
        return p.right_bar*"ETA: --"
    end

    t1 = time() - p.start_time
    s1 = p.current_length
    s2 = p.maximum_length - p.current_length

    eta = t1*s2/s1

    return p.right_bar*"ETA: $(_convert_time_unit(eta))"
end

function _eta_text(p::AbstractProgressBar, new_length::Float64)
    if !p.has_eta
        return p.right_bar
    end
    if !p.eta_started
        return p.right_bar*"ETA: --"
    end

    if new_length ≈ p.current_length
        return _eta_text(p)
    end

    s1 = new_length - p.current_length # length progress
    s2 = p.maximum_length - new_length # remaining length
    t1 = time() - p.time # time to get from p.current_length to new_length

    eta = t1*s2/s1

    return p.right_bar*"ETA: $(_convert_time_unit(eta))"
end

function _elapsed_text(p::AbstractProgressBar)
    if !p.has_elapsed_time
        return p.right_bar
    end
    elapsed = time() - p.start_time

    return p.right_bar*"Time: $(_convert_time_unit(elapsed))"
end

function _percentage_text(p::AbstractProgressBar ,frac::Float64)
    percentage = floor(Int,frac*100)
    if p.has_percentage
        return "$(percentage)%"*p.left_bar
    end
    return p.left_bar
end

