# config/.credo.exs
%{
  configs: [
    %{
      name: "default",
      files: %{
        #
        # You can give explicit globs or simply directories.
        # In the latter case `**/*.{ex,exs}` will be used.
        #
        included: [
          "lib/"
        ],
        excluded: [~r"/_build/", ~r"/deps/", ~r"/node_modules/"]
      },
      strict: true,
      checks: [
        {Credo.Check.Readability.LargeNumbers, only_greater_than: 86400},
        {Credo.Check.Readability.ParenthesesOnZeroArityDefs, parens: true},
        {Credo.Check.Readability.Specs, []},
        {Credo.Check.Design.TagTODO, false},
        {Credo.Check.Refactor.Nesting, max_nesting: 3},
        {Credo.Check.Design.AliasUsage, false},
        {Credo.Check.Readability.ImplTrue, []}
      ]
    }
  ]
}
