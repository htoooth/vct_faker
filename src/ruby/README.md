How To Use?
===========

* install `ruby` and `rake` gem.
* cd `src/ruby/` directory.
* run `rake` if you want to generate VCT file.
* run `rake clean` if you want to clean `*.VCT`.

How to write
============

```
|--------------|    |--------------|    |--------------|    |--------------|
|  vctcreator  | => | vctgenerator | => |  vctdataset  | => |    vctfile   |
|--------------|    |--------------|    |--------------|    |--------------|

```

## vctcreator

The main function of this file is to create geometrys about point, line and polygon.

## vctgenerator

The vctgenerator generates different vctdataset. There are two algorithm EFC and FCI in this file.

## vctdataset

The vctdataset includes data structures of vct dataset.

## vctfile

The algorithm decide how to convert a vct dataset to a file.


About
=====

Thanks to Shuai Zhang.
