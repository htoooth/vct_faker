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

Size Calculate
==============
`size = 500 => file size = 250M, time = 8 minutes, total = 16 minutes.`

About
=====

Thanks to Shuai Zhang.
