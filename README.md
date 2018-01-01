
<!-- README.md is generated from README.Rmd. Please edit that file -->
PALMSplus for R
===============

<!--[![AppVeyor Build Status](https://ci.appveyor.com/api/projects/status/github/TheTS/palmsplusr?branch=master&svg=true)](https://ci.appveyor.com/project/TheTS/palmsplusr)-->
<!--[![Travis-CI Build Status](https://travis-ci.org/TheTS/palmsplusr.svg?branch=master)](https://travis-ci.org/TheTS/palmsplusr) -->
<!--[![codecov](https://codecov.io/gh/TheTS/actigraph.sleepr/branch/master/graph/badge.svg)](https://codecov.io/gh/TheTS/actigraph.sleepr)-->
[![Project Status](http://www.repostatus.org/badges/latest/wip.svg)](http://www.repostatus.org/#wip) [![Version](https://img.shields.io/badge/Package%20version-0.1.0-orange.svg)](commits/master) [![Last Change](https://img.shields.io/badge/Last%20change-2018--01--01-yellowgreen.svg)](/commits/master)

Overview
--------

**palmsplusr** is an extension to the *Personal Activity Location Measurement System*, commonly known as [PALMS](https://ucsd-palms-project.wikispaces.com/). The **palmsplusr** package provides a platform to combine PALMS data with other sources of information, such as shape files or personal timetables.

The **palmsplusr** workflow is presented in the figure below. The PALMS data along with various other input files are used to build the palmsplus data frame. Once palmsplus is built, it can be summarised two ways:

-   `days` provides a breakdown of information per day, per person.
-   `trajectories` builds individual trips from PALMS points, and provides trip-level summaries. This can then be processed into multimodal trips if desired.

The user is able to specify how each data source is combined to build palmsplus. This is done by creating `field` and `domain` formulas which are highly customisable.

![Palms Workflow](http://i.imgur.com/aSzlC3E.png)

Installation
------------

The easiest way to install **palmsplusr** is using devtools:

``` r
library("devtools")
install_github("TheTS/palmsplusr")
```

Documentation and Examples
--------------------------

For further information and examples, please see the [GitHub documentation](http://thets.github.io/palmsplusr/)

### Notes

This project is based on the [palmsplus](https://github.com/bsnizek/palmsplus) project originally written in PostgreSQL and PostGIS.
