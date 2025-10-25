using ParallelTestRunner: runtests, parse_args
import BackgroundMeshes

const init_code = quote
    import StatsBase: median, mean, std, mad
    import StableRNGs: StableRNG

    const rng = StableRNG(659929)
end

args = parse_args(Base.ARGS)

runtests(BackgroundMeshes, args; init_code)
