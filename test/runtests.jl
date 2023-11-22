using Test
using Aqua

import PSRProgressBar: PSRProgressBar

function test_aqua()
    Aqua.test_all(PSRProgressBar)
    return nothing
end

function test_progressbar()
    pb = PSRProgressBar.ProgressBar(maximum_steps = 10)
    for i = 1:10
        redirect_stdout(devnull) do
            PSRProgressBar.next!(pb, 1)
        end
        @test pb.current_steps == i
    end

    pb = PSRProgressBar.ProgressBar(maximum_steps = 10, display = PSRProgressBar.INCREMENTAL)
    for i = 1:10
        redirect_stdout(devnull) do
            PSRProgressBar.next!(pb, 1)
        end
        @test pb.current_steps == i
    end
end

function test_length()
    last_stage = 3
    first_stage = 1

    p_incremental = PSRProgressBar.ProgressBar(
        maximum_steps = last_stage - first_stage + 1,
        maximum_length = 72,
        display = PSRProgressBar.INCREMENTAL,
        color = :green,
    )
    p_iterative = PSRProgressBar.ProgressBar(
        maximum_steps = last_stage - first_stage + 1,
        maximum_length = 72,
        display = PSRProgressBar.ITERATIVE,
        color = :green,
    )

    for stage = first_stage:last_stage
        redirect_stdout(devnull) do
            PSRProgressBar.next!(p_incremental)
            PSRProgressBar.next!(p_iterative)
        end
    end
    @test p_incremental.current_ticks == p_iterative.current_ticks
    @test p_incremental.current_ticks == p_incremental.maximum_length - 2

    last_stage = 104
    first_stage = 1

    p_incremental = PSRProgressBar.ProgressBar(
        maximum_steps = last_stage - first_stage + 1,
        maximum_length = 72,
        display = PSRProgressBar.INCREMENTAL,
        color = :green,
    )
    p_iterative = PSRProgressBar.ProgressBar(
        maximum_steps = last_stage - first_stage + 1,
        maximum_length = 72,
        display = PSRProgressBar.ITERATIVE,
        color = :green,
    )

    for stage = first_stage:last_stage
        redirect_stdout(devnull) do
            PSRProgressBar.next!(p_incremental)
            PSRProgressBar.next!(p_iterative)
        end
    end
    @test p_incremental.current_ticks == p_iterative.current_ticks
    @test p_incremental.current_ticks == p_incremental.maximum_length - 2

end

function test_convert_time()
    @test PSRProgressBar._convert_time_unit(0.1) == "100ms"
    @test PSRProgressBar._convert_time_unit(7200.0) == "2h"
    @test PSRProgressBar._convert_time_unit(180.0) == "3min"
    @test PSRProgressBar._convert_time_unit(10.0) == "10s"
end

test_aqua()
test_progressbar()
test_length()
test_convert_time()
