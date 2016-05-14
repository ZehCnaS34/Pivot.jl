module Generate


boot = """

module KT
# KT is the namespace of your application
using Pivot
import Pivot.@include_all_in


# Getting the absolute path to the directory
appdir = @__FILE__() |> dirname |> abspath

controllers_directory = joinpath(appdir, "app/controllers")
models_directory = joinpath(appdir, "app/models")
views_directory = joinpath(appdir, "app/views")
config_directory = joinpath(appdir, "config")




# loading the models
@include_all_in models_directory
@include_all_in views_directory
@include_all_in controllers_directory
@include_all_in config_directory


end
"""


end
