module GenieFactory

using Logging

import Genie
import SearchLight
export create, build, @factory

const factories = Dict()

"""
  @factory Person(first=Faker.name)

mark a call as a factory
"""
macro factory(exp::Expr)
    if exp.head != :call
        @warn "'$(exp.args[1])' is not a valid factory. It must be an expressions of type :call"
        return
    end

    factories[exp.args[1]] = (__module__, exp)
end

"""
  create(:Person)
  create(:Person, first="Bob")

Build a model instance AND persist it to the database
"""
function create(s::Symbol, num=1; kwargs...)
    records = build(s, num; kwargs...)
    if !all(map(SearchLight.save, records))
        @error "not all instances were properly created and/or persisted"
    end
    return num == 1 ? records[1] : records
end

"""
  build(:Person)
  build(:Person, first="Bob")

Build a model instance but do not persist it to the database
"""
function build(s::Symbol, num=1; kwargs...)
    (mod, exp) = factories[s]
    expr = deepcopy(exp)

  # modify expression args if necessary to take into account the new kwargs
    new_keyword_expressions = []
    for (k, v) in kwargs
        found = false
        for e in filter(y -> typeof(y) == Expr && y.head == :kw, expr.args)
            if e.args[1] == k
                e.args[2] = v
                found = true
                break
        end
        end
        if !found push!(new_keyword_expressions, Expr(:kw, k, v)) end
    end
    append!(expr.args, new_keyword_expressions)

    if num == 1
        return Core.eval(mod, expr)
    elseif num > 1
        return [eval(expr) for i in 1:num]
    else
        throw(BoundsError(num, "argument must be greater than or equal to 1"))
    end
end

"""
    install(dest::String; force = false, debug = false) :: Nothing

Copies the plugin's files into the host Genie application.
"""
function install(dest::String; force=false, debug=false)::Nothing
    src = abspath(normpath(joinpath(pathof(@__MODULE__) |> dirname, "..", Genie.Plugins.FILES_FOLDER)))

    debug && @info "Preparing to install from $src into $dest"
    debug && @info "Found these to install $(readdir(src))"

    for f in readdir(src)
        debug && @info "Processing $(joinpath(src, f))"
        debug && @info "$(isdir(joinpath(src, f)))"

        isdir(joinpath(src, f)) || continue

        debug && "Installing from $(joinpath(src, f))"

        Genie.Plugins.install(joinpath(src, f), dest, force=force)
    end

    nothing
end

end
