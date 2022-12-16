# Extended Covariant Script(CovScript 4)
ECS is the next generation of Covariant Script Programming Language

## How to install
### 1. Install CovScript 3 Runtime
Please visit [CovScript Official Website](http://covscript.org.cn) and follow the instruction

### 2. Install Dependencies via CSPKG
```bash
cspkg install ecs_bootstrap --yes
```
If you are running officially released CovScript runtime version 3.4.1+, `ecs` is setup ready after this step. 
### (Optional) 3. Clone this repository to your machine
```bash
git clone https://github.com/covscript/ecs
```
### (Optional)  4. Give execution permission to bootstrap script(for *nix only)
```bash
chmod +x ecs
```
### (Optional)  5. Add absolute path of `ecs` to `PATH` environment variable of your OS
## How to use
`ecs` command is a compiler that will translate ECS to CovScript 3, but can use like an 'interpreter' (will compile your code before run automatically)
```
Usage: ecs [options...] <FILE> [arguments...]

Options:
    Option    Function
   -h         Show help information
   -v         Show version infomation
   -f         Disable compile cache
   -m         Disable beautify
   -c         Check grammar only
   -i <PATH>  Set import path
   -o <PATH>  Set output path
   -- <ARGS>  Pass parameters to CovScript

```
## Compatibility Notice
1. The program translated by ECS Compiler will depends on package `ecs`.
2. The behavior of Lambda Expression will be very different.
3. Separated exception system. Please call `e = ecs.handle_exception(e)` to solve compatible problem in CovScript 3 when catch exception from ECS Packages.
4. To support `new` and `gcnew` operator with arguments, please define `construct` function separately.