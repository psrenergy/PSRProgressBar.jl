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
    isFinished = false

end

function _init!(p::AbstractProgressBar)
    @assert p.current_steps == 0
    if p.maximum_length > 2
        println("+" * "-" ^ (p.maximum_length-2) * "+")
    else
        println("+" ^ p.maximum_length)
    end
    return nothing
end


function _end!(p::AbstractProgressBar)
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
        if p.hasFrame
            _init!(p)
        end
    end
    p.current_steps += steps
    frac = p.current_steps / p.maximum_steps
    new_length = floor(Int,p.maximum_length*frac)
    eta = _eta_text(new_length-p.current_length, p.maximum_length-new_length, time()-p.time, p.eta_started)
    p.current_length = new_length
    if p.current_length == p.maximum_length
        p.isFinished = true
    end

    if frac > 1.0
        @warn "Iterating progress bar with $(steps) violates its maximum length ($(p.maximum_length))"
        return nothing
    end    
        
    percentage = floor(Int,frac*100)
    percentage_text = "$(percentage)%|"

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
        elapsed = _elapsed_text(p.start_time)
        full_progress = p.maximum_length - length(percentage_text) - length(elapsed)
        print(percentage_text*p.tick^full_progress*elapsed)
        if p.hasFrame
            _end!(p)
        end
    end

    return nothing
end

function next!(p::IncrementalProgressBar, steps::Integer = 1)
    if p.current_steps == 0
        p.start_time = time()
        if p.hasFrame
            _init!(p)
        end
    end
    p.current_steps += steps
    frac = p.current_steps / p.maximum_steps
    new_length = floor(Int,p.maximum_length*frac)
    elapsed = _elapsed_text(p.start_time)
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
        _end!(p)
    end
    return nothing
end