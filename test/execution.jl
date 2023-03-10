function run_pb()
    pb = PSRProgressBar.IterativeProgressBar(maximum_steps = 10)
    for i in 1:10
        redirect_stdout(devnull) do 
            PSRProgressBar.next!(pb, 1)
        end
        @test pb.current_steps == i
    end

    pb = PSRProgressBar.IncrementalProgressBar(maximum_steps = 10)
    for i in 1:10
        redirect_stdout(devnull) do 
            PSRProgressBar.next!(pb, 1)
        end
        @test pb.current_steps == i
    end
end

run_pb()