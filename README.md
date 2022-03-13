# GenieFactory

Factory plugin using [Faker.jl](https://github.com/neomatrixcode/Faker.jl) for `Genie.jl`

## Installation

The `GenieFactory.jl` package is a Factory plugin for `Genie.jl`, the highly productive Julia web framework.
As such, it requires installation within the environment of a `Genie.jl` MVC application, allowing the plugin to install
its files (which include models, controllers, database migrations, plugins, and other files).

## Usage

Define a factory (we recommend doing it in model file itself). We also highly recommend
[Faker.jl](https://github.com/neomatrixcode/Faker.jl) for all your fake data needs.

```
import Factor: @factory
using Faker

@factory Person()
```

Use the factory to create a new Person

```
using Factory

Factory.build(:Person, first="Bob")

```


