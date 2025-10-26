using ParallelTestRunner: runtests, find_tests, parse_args
import BackgroundMeshes

const init_code = quote
    import StatsBase: median, mean, std, mad
    import StableRNGs: StableRNG

    const rng = StableRNG(659929)
end

testsuite = find_tests(@__DIR__)

# TODO: remove after this is resolved: https://github.com/JuliaAstro/BackgroundMeshes.jl/pull/19#issuecomment-3447897150
#args = parse_args(Base.ARGS)
@info :hmmm (@__DIR__) testsuite
runtests(BackgroundMeshes, Base.ARGS; testsuite, init_code)
