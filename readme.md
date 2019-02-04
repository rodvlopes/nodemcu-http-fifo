# Description 

A nodemcu _http_ wrapper to handle multiple/single http requests sequencially

## Motivation

...

## Installation

Copy http_fifo.lua to your nodemcu project.

## Usage

It is as simple as replacing all the calls of the nodemcu http lib to http_fifo.

    dofile('http_fifo.lua')
    http_fifo.get(url, headers, callback)
