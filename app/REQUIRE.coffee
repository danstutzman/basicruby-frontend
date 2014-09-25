if typeof(window) is 'object'
  r = {}
  # can't use a loop to DRY this up, because browserify uses static analysis
  #   to determine requirements and needs string literals after require
  r['app/ApiService']            = require './ApiService'
  r['app/AstToBytecodeCompiler'] = require './AstToBytecodeCompiler'
  r['app/BytecodeInterpreter']   = require './BytecodeInterpreter'
  r['app/BytecodeSpool']         = require './BytecodeSpool'
  r['app/CasesComponent']        = require './CasesComponent'
  r['app/ConsoleComponent']      = require './ConsoleComponent'
  r['app/DebuggerComponent']     = require './DebuggerComponent'
  r['app/DebuggerController']    = require './DebuggerController'
  r['app/ExerciseComponent']     = require './ExerciseComponent'
  r['app/ExerciseController']    = require './ExerciseController'
  r['app/HeapComponent']         = require './HeapComponent'
  r['app/InstructionsComponent'] = require './InstructionsComponent'
  r['app/Lexer']                 = require './Lexer'
  r['app/MenuComponent']         = require './MenuComponent'
  r['app/PartialCallsComponent'] = require './PartialCallsComponent'
  r['app/REQUIRE']               = require './REQUIRE'
  r['app/RubyCodeHighlighter']   = require './RubyCodeHighlighter'
  r['app/TutorExeciseComponent'] = require './TutorExerciseComponent'
  r['app/TutorMenuComponent']    = require './TutorMenuComponent'
  r['app/ValueComponent']        = require './ValueComponent'
  r['app/VariablesComponent']    = require './VariablesComponent'
  r['app/application']           = require './application'
  r['app/setup_resize_handler']  = require './setup_resize_handler'
  r['app/tutor']                 = require './tutor'
  window.REQUIRE = r
