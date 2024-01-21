# QR Card Generator

This is a simple shiny app that takes group ID inputs and fetches the corresponding QR codes and group logos. It generates a plot that can be downloaded as a PDF file. The PDF has a 2x3 grid of the plots which can be printed on a standard A4 sheet and cut into 6 cards.

## Purpose

The purpose of this app is to generate QR cards for my mom's business that she can give to her customers. The QR code links to each client's fundraising page. The client can then give the card to their friends and family to scan and donate / buy products.

## Tech Stack

- R
- Shiny

Packages:

- tidyverse
- magick
- patchwork
- rvest
- ggpath
- showtext
- htmltools
- shiny
- shinyjs
- shinydashboard
- gridExtra
- pacman

## Notes

- If an error occurs when generating the plot, it can be that the QR code was not yet rendered by the server. In the web-portal you must click on the group then you can try again.
- Running locally you must use the RStudio IDE.
