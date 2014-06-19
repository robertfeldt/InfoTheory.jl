# InfoTheory.jl

A Julia package for non-parametric estimation of information theoretic quantities such as entropy and mutual information.

## Limitations

We currently need the latest versions of the Distance and NearestNeighbors packages since the KDTree implementation does not work in the versions of these libs available in the METADATA. Should soon resolve itself once packages are in sync.

## Acknowledgement

This package is partly based on the [NPEET library version 1.1 by Greg Ver Steeg](http://www.isi.edu/~gregv/npeet.html).

## Build status

[![Build Status](https://travis-ci.org/robertfeldt/InfoTheory.jl.svg?branch=master)](https://travis-ci.org/robertfeldt/InfoTheory.jl)
