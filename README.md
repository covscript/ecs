# Extended Covariant Script(CovScript 4)
ECS is the next generation of Covariant Script Programming Language

## How to install
### 1. Install CovScript 3 Runtime
Please visit [CovScript Official Website](http://covscript.org.cn) and follow the instruction

### 2. Install Dependencies via CSPKG
```bash
cspkg install bitwise sdk_extension --yes
```
Please note that in Microsoft Windows, you must run CSPKG as Administrator
### 3. Clone this repository to your machine
```bash
git clone https://github.com/covscript/ecs
```
### 4. Give execution permission to bootstrap script(for *nix only)
```bash
chmod +x bin/ecs
```
### 5. Add absolute path of `bin` to `PATH` environment variable of your OS
## How to use
`ecs` command is a compiler that will translate ECS to CovScript 3, but can use like an 'interpreter' (will compile your code before run automatically)
```
Usage: ecs [options...] <FILE> [arguments...]

Options:
    Option    Function
   -h         Show help information
   -v         Show version infomation
   -m         Disable beautify
   -c         Check grammar only
   -o <PATH>  Set output path
   -- <ARGS>  Pass parameters to CovScript

```
## Compatibility Notice
1. The program translated by ECS Compiler will depends on package `ecs`.
2. The behavior of Lambda Expression will be very different
3. Separated exception system. Please call `e = ecs.handle_exception(e)` to solve compatible problem in CovScript 3 when catch exception from ECS Packages