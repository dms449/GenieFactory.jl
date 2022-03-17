# GenieFactory

Factory plugin using [Faker.jl](https://github.com/neomatrixcode/Faker.jl) for `Genie.jl`

## Installation

The `GenieFactory.jl` package is a Factory plugin for `Genie.jl`, the highly productive Julia web framework.
As such, it requires installation within the environment of a `Genie.jl` MVC application, allowing the plugin to install
its files (which include models, controllers, database migrations, plugins, and other files).



## Usage

Define a factory (we recommend doing it in the model file itself). We also highly recommend
[Faker.jl](https://github.com/neomatrixcode/Faker.jl) for all your fake data needs.

```
module Persons

import SearchLight: AbstractModel, DbId
import Base:@kwdef
import Faker
import GenieFactory: @factory

export Person

@kwdef mutable struct Person <: AbstractModel
    id::DbId = DbId()
    first::String = ""
    last::String = ""
    mi::String = ""
    email::String = ""
    phone::String = ""
    contact_preference::String = "email"
end

@factory Person(
  first=Faker.first_name(),
  last=Faker.last_name(),
  email=Faker.email(),
  phone=Faker.phone_number(),
  contact_preference=rand(["email", "phone"])
)

end
```

Use the factory to build a new Person (not persisted yet)

```
julia> import GenieFactory

julia> GenieFactory.build(:Person, first="Bob")

Person
| KEY                        | VALUE                |
|----------------------------|----------------------|
| contact_preference::String | email                |
| email::String              | THintz@yahoo.com     |
| first::String              | Bob                  |
| id::SearchLight.DbId       | NULL                 |
| last::String               | Carroll              |
| mi::String                 |                      |
| phone::String              | (737) 547-6768 x9062 |
```

To build a new object and persist it, use `GenieFactory.create`

## Options

keyword arguments (like 'first=Bob') provided to `build` or `create` will override any defined in the factory.

Both `GenieFactory.create` and `GenieFactory.build` take an optional argument to create any number of instances at once.

For example

```
julia> import GenieFactory

julia> GenieFactory.create(:Person, 5)

```
will create and persist 5 `Person` objects


