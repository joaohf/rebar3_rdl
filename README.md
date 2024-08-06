# rebar3_rdl

This is a rebar3 plugin that transform SystemRDL .rdl files into Erlang modules.

The main focus is to provide APIs for serialize and deserialize register values read/write
from hardware.

## How to use

In our _rebar.config_ file add rebar3_rdl as a plugin:

```
{plugins, [rebar3_rdl]}.
```

Create a folder called _rdl_ and add all your .rdl files there. The plugin will generate erlang modules from all .rdl files.

It's possible to configure the rebar3_rdl with the following properties:

```
{rdl_opts, [{peakrdl, "/home/joaohf/peakrdl/PeakRDL-beam/venv/bin/peakrdl"},
            {module_name_prefix, "rebar3_rdl_example_"},
            {module_name_suffix, "_pb"}]}.
```

* _peakrdl_: specify an alternative peakrdl location
* _module\_name\_prefix_: prefix for erlang module name
* _module\_name\_suffix_: suffix for erlang module name

## How does it work ?

This plugin just implements the callbacks for [rebar3 Custom Compiler Modules](https://rebar3.org/docs/extending/custom_compiler_modules/).
Under the hood the rebar3_rdl_compiler module calls the `peakrdl` command line, passing the right arguments. It's very convenient because
you don't need to create any additional scripts to transform .rdl files into .erl modules.

### Links

* [SystemRDL](https://github.com/SystemRDL)
* [SystemRDL Compiler](https://systemrdl-compiler.readthedocs.io/en/stable/)
* [SystemRDL Specification](http://accellera.org/downloads/standards/systemrdl)
* [peakrdl](https://peakrdl.readthedocs.io/en/latest/): PeakRDL is a free and open-source control & status register (CSR) generator toolchain

## References

* [Custom Compiler Modules](https://rebar3.org/docs/extending/custom_compiler_modules/)
* [rebar3_caramel](https://github.com/AbstractMachinesLab/rebar3_caramel): I got some examples from there in order to understand how custom compile modules works.

## TODO

* Implement compile_and_track callback
* Improve needed_files callback
* Add unit tests

## License

Released under [Apache License 2.0](http://www.apache.org/licenses/LICENSE-2.0).