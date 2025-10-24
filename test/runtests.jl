using ParallelTestRunner: runtests
import BackgroundMeshes

const init_code = quote
    import StatsBase: median, mean, std, mad
    import StableRNGs: StableRNG

    const rng = StableRNG(659929)
end

runtests(BackgroundMeshes, Base.ARGS; init_code)
