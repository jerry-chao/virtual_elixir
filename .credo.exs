# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

config :credo,
  strict: true,
  format: "default",
  check_for_updates: false,
  parse_timeout: 5000,
  color: true,
  files: %{
    included: ["lib/", "test/", "config/"],
    excluded: ["**/poison**", "**/teex**"]
  },
  checks: [
    {Credo.Check.Consistency.TabsOrSpaces},
    {Credo.Check.Design.AliasUsage},
    {Credo.Check.Design.TagFIXME},
    {Credo.Check.Readability.FunctionNames},
    {Credo.Check.Readability.LargeNumbers},
    {Credo.Check.Readability.MaxLineLength, priority: :low},
    {Credo.Check.Readability.ModuleAttributeNames},
    {Credo.Check.Readability.ParenthesesInCondition},
    {Credo.Check.Readability.PreferImplicitTry},
    {Credo.Check.Readability.RedundantBlankLines},
    {Credo.Check.Readability.StringSigils},
    {Credo.Check.Readability.TrailingBlankLine},
    {Credo.Check.Readability.TrailingWhiteSpace},
    {Credo.Check.Readability.VariableNames},
    {Credo.Check.Refactor.ABCSize},
    {Credo.Check.Refactor.CaseTrivialMatches},
    {Credo.Check.Refactor.CondStatements},
    {Credo.Check.Refactor.PipeChainStart},
    {Credo.Check.Warning.BoolOperationOnSameValues},
    {Credo.Check.Warning.IExPry},
    {Credo.Check.Warning.IoInspect},
    {Credo.Check.Warning.NameRedeclarationByAssignment},
    {Credo.Check.Warning.NameRedeclarationByCase},
    {Credo.Check.Warning.NameRedeclarationByDef},
    {Credo.Check.Warning.NameRedeclarationByFn},
    {Credo.Check.Warning.OperationOnSameValues},
    {Credo.Check.Warning.UnusedFileOperation},
    {Credo.Check.Warning.UnusedKeywordOperation},
    {Credo.Check.Warning.UnusedListOperation},
    {Credo.Check.Warning.UnusedStringOperation},
    {Credo.Check.Warning.UnusedTupleOperation}
  ]
