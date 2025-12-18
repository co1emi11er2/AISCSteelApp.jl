module LShape
using Term
using REPL.TerminalMenus
using Term.LiveWidgets
import AISCSteel.Shapes.LShapes as LS
import AISCSteel.Database: aisc_database
using StructuralUnits
using DataFrames
using PrettyTables

const MODE_OPTIONS = ["Specific Shapes", "Optimizations", "Exit"]
const CAPACITY_OPTIONS = ["Flexure", "Compression", "Go Back"]

include("Modes/modes.jl")
include("precompile.jl")


end
