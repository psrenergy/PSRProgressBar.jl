abstract type AbstractProgressBar end

Base.@kwdef mutable struct IterativeProgressBar <: AbstractProgressBar

    maximum_steps::Int 
    current_length::Int = 0
    current_steps::Int = 0

    tick::String = "="
    left_bar::String = "["
    right_bar::String = "]"

    maximum_length::Int = 63

    start_time::Union{Nothing, Float64} = nothing
    time::Union{Nothing, Float64} = nothing
    eta_started::Bool = false

    hasFrame::Bool = false
    hasPercentage::Bool = true
    hasETA::Bool = true
    hasElapsedTime::Bool = true
    hasFinished::Bool = false

end

Base.@kwdef mutable struct IncrementalProgressBar <: AbstractProgressBar

    maximum_steps::Int 
    current_length::Int = 0
    current_steps::Int = 0

    tick::String = "="
    left_bar::String = "["
    right_bar::String = "]"

    maximum_length::Int = 63

    start_time::Union{Nothing,Float64} = nothing

    hasFrame::Bool = false
    hasPercentage::Bool = false
    hasETA::Bool = false
    hasElapsedTime::Bool = true
    hasFinished = false

end

function _header(p::AbstractProgressBar)
    @assert p.current_steps == 0
    if p.maximum_length > 2
        println("+" * "-" ^ (p.maximum_length-2) * "+")
    else
        println("+" ^ p.maximum_length)
    end
    return nothing
end


function _footer(p::AbstractProgressBar)
    @assert p.hasFinished
    println("")
    if p.maximum_length > 2
        println("+" * "-" ^ (p.maximum_length-2) * "+")
    else
        println("+" ^ p.maximum_length)
    end
    return nothing 
end

function _show_progress_bar(p::AbstractProgressBar, l_text::String = "", r_text::String = "")
    if isempty(l_text) l_text = p.left_bar end
    if isempty(r_text) r_text = p.right_bar end

    print("\e[2K") 
    print("\e[1G")

    full_progress = p.maximum_length - length(l_text) - length(r_text)
    length_ticks = floor(Int,full_progress*(p.current_steps/p.maximum_steps))
    blank_space = full_progress - length_ticks
    print(l_text*p.tick^length_ticks*" "^blank_space*r_text)

    return nothing
end

function update_progress_bar(p::IterativeProgressBar)
    eta = _eta_text(p)
    percentage = _percentage_text(p, p.current_steps/p.maximum_steps)
    _show_progress_bar(p, percentage, eta)
end

function next!(p::IterativeProgressBar, steps::Integer = 1)
    if p.current_steps == 0
        p.start_time = time()
        p.time = time()
        if p.hasFrame _header(p) end
    end
    p.current_steps += steps
    frac = p.current_steps / p.maximum_steps
    new_length = p.maximum_length*frac
    eta = _eta_text(p, new_length)
    p.current_length = floor(Int,new_length)
    if p.current_length == p.maximum_length
        p.hasFinished = true
    end

    if frac > 1.0
        @warn "Iterating progress bar with $(steps) violates its maximum length ($(p.maximum_length))"
        return nothing
    end    
        
    percentage_text = _percentage_text(p, frac)
    
    if !p.hasFinished 
        _show_progress_bar(p, percentage_text, eta)
        p.eta_started = true
    else
        elapsed = _elapsed_text(p)
        _show_progress_bar(p, percentage_text, elapsed)
        if p.hasFrame _footer(p) end
    end

    p.time = time()
    return nothing
end

function next!(p::IncrementalProgressBar, steps::Integer = 1)
    if p.current_steps == 0
        p.start_time = time()
        if p.hasFrame
            _header(p)
        end
    end
    p.current_steps += steps
    frac = p.current_steps / p.maximum_steps
    new_length = floor(Int,p.maximum_length*frac)
    elapsed = _elapsed_text(p)
    p.current_length = new_length
    if p.current_length == p.maximum_length
        p.hasFinished = true
    end

    if frac > 1.0
        @warn "Iterating progress bar with $(steps) violates its maximum length ($(p.maximum_length))"
        return nothing
    end    

    _show_progress_bar(p, p.left_bar, elapsed)

    if p.hasFinished && p.hasFrame
        _footer(p)
    end
    return nothing
end