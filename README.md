# PSRProgressBar.jl

<div align="center">
    <a href="/assets/">
        <img src="/assets/logo.svg" width=400px alt="PSRProgressBar.jl" />
    </a>
    <br>
    <a href="https://github.com/psrenergy/PSRProgressBar.jl/actions/workflows/CI.yml">
        <img src="https://github.com/psrenergy/PSRProgressBar.jl/actions/workflows/CI.yml/badge.svg?branch=master" alt="CI" />
    </a>
</div>

## Getting Started

### Installation
```julia
julia> ]add https://github.com/psrenergy/PSRProgressBar.jl#master
```

### Ways of displaying a progress bar

Currently, there are two types of progress bars available:

#### `Iterative`

The iterative progress bar keeps overwriting the same line in the terminal, updating as it progresses.

#### `Incremental`
The incremental progress bar does not overwrite the whole terminal line. It adds new ticks to the end of the line as it progresses.

> **Note**
> It is advised to use the incremental progress bar when yout terminal cannot overwrite the terminal line.


## Costumizing the progress bar

The progress bar can be costumized by passing the following arguments to the `ProgressBar` constructor:

- `display`: The type of progress bar to be displayed (`PSRProgressBar.Iterative` or `PSRProgressBar.Incremental`).

- `maximum_steps`(Int): The maximum number of steps the progress bar will take.

- `tick`(Char): The character that will be used to represent the progress bar (".", "*", "+", etc.).

- `first_tick`(Char): The leading tick of the progress bar (">", etc.)

- `left_bar`(Char): The character that will be used to represent the left bar of the progress bar ("|", "[", etc.).

- `right_bar`(Char): The character that will be used to represent the right bar of the progress bar ("|", "]", etc.).

- `maximum_length`(Int): The width of the progress bar in characters.

- `color`(Symbol): The color of the progress bar (e.g. `:red`, `:green`, `:blue` , etc.).

- `has_percentage`(Bool): Whether to show the percentage of the progress bar or not.

- `has_frame`(Bool): Whether to show a top and bottom frame of the progress bar or not.

- `has_eta`(Bool): Whether to show the estimated time of arrival or not.

- `has_elapsed_time`(Bool): Whether to show the elapsed time or not.






## Examples

```julia
using PSRProgressBar

pb = PSRProgressBar.ProgressBar(maximum_steps = 100, tick = "+", left_bar = "|", right_bar="|")

for i in 1:100
    PSRProgressBar.next!(pb)
    sleep(0.1)
end
```



