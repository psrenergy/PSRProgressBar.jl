using Test
import PSRProgressBar: PSRProgressBar

function run_pb()
    pb = PSRProgressBar.ProgressBar(maximum_steps = 10)
    for i in 1:10
        redirect_stdout(devnull) do 
            PSRProgressBar.next!(pb, 1)
        end
        @test pb.current_steps == i
    end

    pb = PSRProgressBar.ProgressBar(maximum_steps = 10, display = PSRProgressBar.INCREMENTAL)
    for i in 1:10
        redirect_stdout(devnull) do 
            PSRProgressBar.next!(pb, 1)
        end
        @test pb.current_steps == i
    end
end

function test_convert_time()
    @test PSRProgressBar._convert_time_unit(0.1) == "100ms"
    @test PSRProgressBar._convert_time_unit(7200.0) == "2h"
    @test PSRProgressBar._convert_time_unit(180.0) == "3min"
    @test PSRProgressBar._convert_time_unit(10.0) == "10s"
end

run_pb()
test_convert_time()