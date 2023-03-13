abstract type AbstractProgressBar end

Base.@kwdef mutable struct IterativeProgressBar <: AbstractProgressBar

    maximum_steps::Int 
    current_length::Int = 0
    current_steps::Int = 0

    tick::String = "+"

    maximum_length::Int = 63

    start_time::Union{Nothing, Float64} = nothing
    time::Union{Nothing, Float64} = nothing
    eta_started::Bool = false

    hasFrame::Bool = true
    hasPercentage::Bool = true
    hasETA::Bool = true
    hasElapsedTime::Bool = true
    isFinished::Bool = false

end

Base.@kwdef mutable struct IncrementalProgressBar <: AbstractProgressBar

    maximum_steps::Int 
    current_length::Int = 0
    current_steps::Int = 0

    tick::String = "+"

    maximum_length::Int = 63

    start_time::Union{Nothing,Float64} = nothing

    hasFrame::Bool = true
    hasPercentage::Bool = false
    hasETA::Bool = false
    hasElapsedTime::Bool = true
    isFinished = false

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
    @assert p.isFinished
    println("")
    if p.maximum_length > 2
        println("+" * "-" ^ (p.maximum_length-2) * "+")
    else
        println("+" ^ p.maximum_length)
    end
    return nothing 
end

function next!(p::IterativeProgressBar, steps::Integer = 1)
    if p.current_steps == 0
        p.start_time = time()
        p.time = time()
        _header(p)
    end
    p.current_steps += steps
    frac = p.current_steps / p.maximum_steps
    new_length = floor(Int,p.maximum_length*frac)
    eta = _eta_text(p, new_length)
    p.current_length = new_length
    if p.current_length == p.maximum_length
        p.isFinished = true
    end

    if frac > 1.0
        @warn "Iterating progress bar with $(steps) violates its maximum length ($(p.maximum_length))"
        return nothing
    end    
        
    percentage = floor(Int,frac*100)
    percentage_text = 
        if p.hasPercentage
            "$(percentage)%|"
        else
            ""
        end
    
    print("\e[2K") 
    print("\e[1G")
    if !p.isFinished 
        full_progress = p.maximum_length - length(percentage_text) - length(eta)
        length_ticks = floor(Int,full_progress*frac)
        blank_space = full_progress - length_ticks
        print(percentage_text*p.tick^length_ticks*" "^blank_space*eta)
        p.eta_started = true
        p.time = time()
    else
        elapsed = _elapsed_text(p)
        full_progress = p.maximum_length - length(percentage_text) - length(elapsed)
        print(percentage_text*p.tick^full_progress*elapsed)
        if p.hasFrame
            _footer(p)
        end
    end

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
        p.isFinished = true
    end

    if frac > 1.0
        @warn "Iterating progress bar with $(steps) violates its maximum length ($(p.maximum_length))"
        return nothing
    end    
        
    print("\e[2K") 
    print("\e[1G")
    full_progress = p.maximum_length - length(elapsed) - 1
    length_ticks = floor(Int,full_progress*frac)
    blank_space = full_progress - length_ticks
    print("|"*p.tick^length_ticks*" "^blank_space*elapsed)

    if p.isFinished && p.hasFrame
        _footer(p)
    end
    return nothing
end