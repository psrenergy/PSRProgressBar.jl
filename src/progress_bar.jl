abstract type AbstractProgressBar end

Base.@kwdef mutable struct ProgressBar <: AbstractProgressBar

    maximum_steps::Int 
    current_length::Int = 0
    current_steps::Int = 0

    tick::String = "="
    left_bar::String = "["
    right_bar::String = "]"

    maximum_length::Int = 63

    color::Symbol = :white

    start_time::Union{Nothing, Float64} = nothing
    time::Union{Nothing, Float64} = nothing
    eta_started::Bool = false

    has_frame::Bool = false
    has_percentage::Bool = true
    has_eta::Bool = true
    has_elapsed_time::Bool = true
    has_finished::Bool = false

end

Base.@kwdef mutable struct IncrementalProgressBar <: AbstractProgressBar

    maximum_steps::Int 
    current_length::Int = 0
    current_steps::Int = 0
    
    current_ticks::Int = 0

    tick::String = "="
    left_bar::String = "["
    right_bar::String = "]"

    maximum_length::Int = 63

    color::Symbol = :white

    start_time::Union{Nothing, Float64} = nothing
    time::Union{Nothing, Float64} = nothing
    eta_started::Bool = false

    has_frame::Bool = false
    has_percentage::Bool = false
    has_eta::Bool = false
    has_elapsed_time::Bool = true
    has_finished::Bool = false

end

function _header(p::AbstractProgressBar)
    @assert p.current_steps == 0
    if p.maximum_length > 2
        printstyled("+" * "-" ^ (p.maximum_length-2) * "+"; color = p.color)
    else
        printstyled("+" ^ p.maximum_length; color = p.color)
    end
    return nothing
end


function _footer(p::AbstractProgressBar)
    @assert p.has_finished
    if p.maximum_length > 2
        printstyled("+" * "-" ^ (p.maximum_length-2) * "+"; color = p.color)
    else
        printstyled("+" ^ p.maximum_length; color = p.color)
    end
    return nothing 
end

function _show_progress_bar(p::IncrementalProgressBar, l_text::String = "", r_text::String = "")
    if isempty(l_text) l_text = p.left_bar end
    if isempty(r_text) r_text = p.right_bar end

    full_progress = p.maximum_length - length(l_text) - length(r_text)
    length_ticks = floor(Int,full_progress*(p.current_steps/p.maximum_steps))

    
    if p.current_steps == 1
        print(l_text*p.tick)
    elseif p.has_finished
        println(p.tick*r_text)
    elseif length_ticks <= p.current_ticks
        return nothing    
    else
        print(p.tick)
    end
    p.current_ticks += 1

    return nothing
end

function _show_progress_bar(p::ProgressBar, l_text::String = "", r_text::String = "")
    if isempty(l_text) l_text = p.left_bar end
    if isempty(r_text) r_text = p.right_bar end

    print("\e[1G")
    print(" \e[2K")


    full_progress = p.maximum_length - length(l_text) - length(r_text)
    length_ticks = floor(Int,full_progress*(p.current_steps/p.maximum_steps))
    blank_space = full_progress - length_ticks
    if p.has_finished
        printstyled(l_text*p.tick^length_ticks*" "^blank_space*r_text; color = p.color)
        println("")
    else
        printstyled(l_text*p.tick^length_ticks*" "^blank_space*r_text;color= p.color)
    end

    return nothing
end


function next!(p::AbstractProgressBar, steps::Int = 1)
    if p.current_steps == 0
        p.start_time = time()
        p.time = time()
        if p.has_frame _header(p) end
    end
    p.current_steps += steps
    frac = p.current_steps / p.maximum_steps
    new_length = p.maximum_length*frac
    eta = _eta_text(p, new_length)
    p.current_length = floor(Int,new_length)
    if p.current_length == p.maximum_length
        p.has_finished = true
    end

    if frac > 1.0
        @warn "Iterating progress bar with $(steps) violates its maximum length ($(p.maximum_length))"
        return nothing
    end    
        
    percentage_text = _percentage_text(p, frac)
    
    if !p.has_finished 
        _show_progress_bar(p, percentage_text, eta)
        p.eta_started = true
    else
        elapsed = _elapsed_text(p)
        _show_progress_bar(p, percentage_text, elapsed)
        if p.has_frame _footer(p) end
    end
    p.time = time()
    return nothing
end
